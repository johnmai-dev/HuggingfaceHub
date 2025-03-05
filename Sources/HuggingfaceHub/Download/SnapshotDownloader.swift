//
//  SnapshotDownloader.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/12.
//

import Foundation
import Semaphore

public actor SnapshotDownloader {
    let repoId: String
    let options: Options
    var tasks: [String: FileDownloader] = [:]

    public init(repoId: String, options: Options = .init()) {
        self.repoId = repoId
        self.options = options
    }

    func innerDownload(
        progress: Progress,
        filename: String,
        commitHash: String,
        cacheDir: URL,
        progressBar: ProgressBar?
    ) async throws {
        try Task.checkCancellation()

        let fileProgress = Progress(totalUnitCount: 0, parent: progress, pendingUnitCount: 1)
        

        let task =
            tasks[filename]
            ?? FileDownloader(
                repoId: repoId,
                filename: filename,
                options: .init(
                    repoType: options.repoType,
                    revision: commitHash,
                    libraryName: options.libraryName,
                    libraryVersion: options.libraryVersion,
                    cacheDir: cacheDir,
                    localDir: options.localDir,
                    userAgent: options.userAgent,
                    forceDownload: options.forceDownload,
                    proxies: options.proxies,
                    etagTimeout: options.etagTimeout,
                    token: options.token,
                    headers: options.headers,
                    endpoint: options.endpoint,
                    onProgress: { (totalBytesWritten, totalBytesExpectedToWrite) in
                        fileProgress.totalUnitCount = totalBytesExpectedToWrite
                        fileProgress.completedUnitCount = totalBytesWritten
  
                        self.options.onProgress(progress)
                    },
                    quiet: options.quiet
                )
            )

        tasks[filename] = task

        try await task.download()

        await progressBar?.update(
            current: progress.completedUnitCount,
            total: progress.totalUnitCount
        )

        fileProgress.completedUnitCount = fileProgress.totalUnitCount
    }

    @discardableResult
    public func download() async throws -> URL {
        let cacheDir: URL =
            options.cacheDir
            ?? URL(
                fileURLWithPath: Constants.hfHubCache.expandingTildeInPath
            ).standardized

        let revision: String = options.revision ?? Constants.defaultRevision

        let storageFolder = cacheDir.appendingPathComponent(
            HFUtility.repoFolderName(
                repoId: repoId,
                repoType: options.repoType
            )
        )

        var repoInfo: RepoInfoType?

        if !options.localFilesOnly {
            let api = HFApi(
                endpoint: options.endpoint,
                libraryName: options.libraryName,
                libraryVersion: options.libraryVersion,
                userAgent: options.userAgent,
                headers: options.headers
            )

            repoInfo = try await api.repoInfo(
                repoId: repoId,
                options: .init(
                    revision: revision,
                    token: options.token
                )
            )
        }

        if repoInfo == nil {
            var commitHash: String?

            if let revision = options.revision, revision.contains(#/^[0-9a-f]{40}$/#) {
                commitHash = revision
            } else {
                let refURL = storageFolder.appendingPathComponent("refs/\(revision)")
                if refURL.exists() {
                    commitHash = try String(contentsOf: refURL)
                }
            }

            if let commitHash {
                let snapshotFolder = storageFolder.appendingPathComponent("snapshots/\(commitHash)")
                if snapshotFolder.exists() {
                    return snapshotFolder
                }
            }

            if let localDir = options.localDir,
                localDir.isDirectory(),
                let contents = try? FileManager.default.contentsOfDirectory(
                    at: localDir,
                    includingPropertiesForKeys: nil,
                    options: .skipsHiddenFiles
                ),
                !contents.isEmpty
            {
                return localDir
            }
        }

        guard let commitHash = repoInfo?.sha else {
            throw Error.missingRevision
        }

        guard let siblings = repoInfo?.siblings else {
            throw Error.missingSiblings
        }

        let filteredRepoFiles = Utility.filterRepoObjects(
            items: siblings.map(\.rfilename),
            allowPatterns: options.allowPatterns,
            ignorePatterns: options.ignorePatterns
        )

        let snapshotFolder = storageFolder.appendingPathComponent("snapshots/\(commitHash)")

        if options.revision != commitHash {
            let refURL = storageFolder.appendingPathComponent("refs/\(revision)")

            do {
                try FileManager.default.createDirectory(
                    at: refURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true,
                    attributes: nil
                )

                try commitHash.write(
                    to: refURL,
                    atomically: true,
                    encoding: .utf8
                )
            } catch {
                NSLog("Ignored error while writing commit hash to \(refURL): \(error).")
            }
        }

        let progress = Progress(totalUnitCount: Int64(filteredRepoFiles.count))

        var progressBar: ProgressBar?
        if !options.quiet {
            progressBar = ProgressBar(
                title: "Fetching \(filteredRepoFiles.count) files",
                total: 0,
                type: .count
            )

            await progressBar?.update(current: 0)
        }
        if Constants.hfHubEnableHFTransfer {
            for file in filteredRepoFiles {
                try await innerDownload(
                    progress: progress,
                    filename: file,
                    commitHash: commitHash,
                    cacheDir: cacheDir,
                    progressBar: progressBar
                )
            }

            options.onProgress(progress)
        } else {
            let semaphore = AsyncSemaphore(value: options.maxWorkers)

            try await withThrowingTaskGroup(of: Void.self) { group in
                for file in filteredRepoFiles {
                    let file = file
                    let progress = progress
                    let commitHash = commitHash
                    let cacheDir = cacheDir
                    let progressBar = progressBar

                    await semaphore.wait()

                    group.addTask { [weak self] in
                        defer {
                            semaphore.signal()
                        }

                        try await self?.innerDownload(
                            progress: progress,
                            filename: file,
                            commitHash: commitHash,
                            cacheDir: cacheDir,
                            progressBar: progressBar
                        )
                    }
                }

                try await group.waitForAll()
            }

            options.onProgress(progress)
        }

        return snapshotFolder
    }

    public func cancel() async {
        for (_, task) in tasks {
            await task.cancel()
        }
        tasks = [:]
    }

    public func pause() async {
        for (_, task) in tasks {
            await task.pause()
        }
    }
}

extension SnapshotDownloader {
    public struct Options: Sendable {
        let repoType: RepoType
        let revision: String?
        let cacheDir: URL?
        let localDir: URL?
        let libraryName: String?
        let libraryVersion: String?
        let userAgent: [String: String]?
        let proxies: [String: String]?
        let etagTimeout: TimeInterval
        let forceDownload: Bool
        let token: String?
        let localFilesOnly: Bool
        let allowPatterns: [String]?
        let ignorePatterns: [String]?
        let maxWorkers: Int
        let headers: [String: String]?
        let endpoint: String?
        let onProgress: @Sendable (Progress) -> Void
        let quiet: Bool

        public init(
            repoType: RepoType = .model,
            revision: String? = nil,
            cacheDir: URL? = nil,
            localDir: URL? = nil,
            libraryName: String? = nil,
            libraryVersion: String? = nil,
            userAgent: [String: String]? = nil,
            proxies: [String: String]? = nil,
            etagTimeout: TimeInterval = Constants.defaultEtagTimeout,
            forceDownload: Bool = false,
            token: String? = nil,
            localFilesOnly: Bool = false,
            allowPatterns: [String]? = nil,
            ignorePatterns: [String]? = nil,
            maxWorkers: Int = 8,
            headers: [String: String]? = nil,
            endpoint: String? = nil,
            onProgress: @Sendable @escaping (Progress) -> Void = { _ in },
            quiet: Bool = true
        ) {
            self.repoType = repoType
            self.revision = revision
            self.cacheDir = cacheDir
            self.localDir = localDir
            self.libraryName = libraryName
            self.libraryVersion = libraryVersion
            self.userAgent = userAgent
            self.proxies = proxies
            self.etagTimeout = etagTimeout
            self.forceDownload = forceDownload
            self.token = token
            self.localFilesOnly = localFilesOnly
            self.allowPatterns = allowPatterns
            self.ignorePatterns = ignorePatterns
            self.maxWorkers = maxWorkers
            self.headers = headers
            self.endpoint = endpoint
            self.onProgress = onProgress
            self.quiet = quiet
        }
    }
}

extension SnapshotDownloader {
    public enum Error: Swift.Error, LocalizedError, Equatable {
        case missingRevision
        case missingSiblings

        public var errorDescription: String? {
            switch self {
            case .missingRevision:
                "Repo info returned from server must have a revision sha."
            case .missingSiblings:
                "Repo info returned from server must have a siblings list."
            }
        }
    }
}
