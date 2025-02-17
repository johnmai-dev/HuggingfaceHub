//
//  FileDownloader.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/16.
//

import Foundation

public actor FileDownloader {
    let repoId: String
    let filename: String
    var options: Options
    private var session: URLSession?
    private var task: URLSessionDownloadTask?
    private var resumeData: Data?

    private var destinationURL: URL?

    private var continuation: CheckedContinuation<URL, Error>?

    public init(repoId: String, filename: String, options: Options = .init()) {
        self.repoId = repoId
        self.filename =
            if let subfolder = options.subfolder, !subfolder.isEmpty {
                subfolder + "/" + filename
            } else {
                filename
            }
        self.options = options
    }

    public func download() async throws -> URL {
        var etagTimeout = options.etagTimeout
        if etagTimeout != Constants.hfHubEtagTimeout {
            etagTimeout = Constants.hfHubEtagTimeout
        }

        if options.localDir != nil {
            return try await downloadToLocalDir()
        }

        return try await downloadToCacheDir()
    }

    private func downloadToLocalDir() async throws -> URL {
        fatalError("downloadToLocalDir -> Not implemented ")
    }

    private func downloadToCacheDir() async throws -> URL {
        let cacheDir: URL =
            options.cacheDir
            ?? URL(fileURLWithPath: Constants.hfHubCache.expandingTildeInPath)
            .standardized

        let locksDir = cacheDir.appendingPathComponent(".locks")

        let storageFolder = cacheDir.appendingPathComponent(
            HFUtility.repoFolderName(
                repoId: repoId,
                repoType: options.repoType
            )
        )

        let revision: String = options.revision ?? Constants.defaultRevision

        if revision.contains(#/^[0-9a-f]{40}$/#) {
            let pointerURL = try getPointerPath(
                storageFolder: storageFolder,
                revision: revision,
                relativeFilename: filename
            )

            if pointerURL.exists(), !options.forceDownload {
                return pointerURL
            }
        }

        let (
            urlToDownload,
            etag,
            commitHash,
            expectedSize
        ) = try await getMetadata(
            revision: revision,
            storageFolder: storageFolder
        )

        if !options.forceDownload {
            var commitHash: String?
            if let revision = options.revision,
                revision.contains(#/^[0-9a-f]{40}$/#)
            {
                commitHash = revision
            } else {
                let refURL = storageFolder.appendingPathComponent(
                    "refs/\(revision)"
                )
                if refURL.isFile() {
                    commitHash = try String(contentsOf: refURL)
                }
            }

            if let commitHash {
                let pointerURL = try getPointerPath(
                    storageFolder: storageFolder,
                    revision: commitHash,
                    relativeFilename: filename
                )

                if pointerURL.exists(), !options.forceDownload {
                    return pointerURL
                }
            }
        }

        let blobURL = storageFolder.appendingPathComponent("blobs/\(etag)")
        let pointerURL = try getPointerPath(
            storageFolder: storageFolder,
            revision: commitHash,
            relativeFilename: filename
        )

        try FileManager.default.createDirectory(
            at: blobURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        try FileManager.default.createDirectory(
            at: pointerURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        try cacheCommitHashForSpecificRevision(
            storageFolder: storageFolder,
            revision: revision,
            commitHash: commitHash
        )

        if !options.forceDownload {
            if pointerURL.exists() {
                return pointerURL
            }

            if blobURL.exists() {
                try createSymlink(
                    src: blobURL,
                    dst: pointerURL
                )
                return pointerURL
            }
        }

        let lockURL = locksDir.appendingPathComponent(
            HFUtility.repoFolderName(
                repoId: repoId,
                repoType: options.repoType
            ).appendingPathComponent("\(etag).lock")
        )

        try FileManager.default.createDirectory(
            at: lockURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let lock = WeakFileLock(lockPath: lockURL.path())

        try? await lock.acquire()
        defer {
            lock.release()
        }

        destinationURL = blobURL

        _ = try await downloadToTmpAndMove(
            urlToDownload: urlToDownload,
            expectedSize: expectedSize
        )

        if !pointerURL.exists() {
            try createSymlink(
                src: blobURL,
                dst: pointerURL,
                newBlob: true
            )
        }

        return pointerURL
    }

    func downloadToTmpAndMove(
        urlToDownload: URL,
        expectedSize: Int?
    ) async throws -> URL {
        let destinationURL = self.destinationURL!

        if destinationURL.exists(), !options.forceDownload {
            return destinationURL
        }

        NSLog("Downloading \(filename)")

        if let expectedSize {
            checkDiskSpace(
                needed: expectedSize,
                at: destinationURL.deletingLastPathComponent()
            )
        }

        var request = URLRequest(url: urlToDownload)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = options.headers

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let session = URLSession(
                configuration: .default,
                delegate: Delegate(
                    continuation: continuation,
                    destinationURL: destinationURL,
                    onProgress: options.onProgress
                ),
                delegateQueue: nil
            )

            task = session.downloadTask(with: request)
            task?.resume()

            NSLog("Download complete. Moving file to \(destinationURL)")
        }
    }

    func setResumeData(_ resumeData: Data?) {
        self.resumeData = resumeData
    }

    public func cancel() {
        task?.cancel()
    }

    public func pause() {
        task?.cancel { data in
            Task {
                await self.setResumeData(data)
            }
        }
    }

    public func resume() {
        if let resumeData {
            task = session?.downloadTask(withResumeData: resumeData)
            task?.resume()
            self.resumeData = nil
        }
    }

    private func checkDiskSpace(needed: Int, at url: URL) {
        NSLog("checkDiskSpace -> Not implemented")
    }

    func createSymlink(src: URL, dst: URL, newBlob: Bool = false) throws {
        let fileManager = FileManager.default

        try? fileManager.removeItem(at: dst)

        let dstFolder = dst.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: dstFolder.path) {
            try fileManager.createDirectory(
                at: dstFolder,
                withIntermediateDirectories: true
            )
        }

        let absSrc = src.standardized
        let absDst = dst.standardized
        let absDstFolder = absDst.deletingLastPathComponent()

        do {
            NSLog("Creating pointer from \(absSrc) to \(absDst)")
            if let relativeSrc = absSrc.relativePath(from: absDstFolder) {
                try fileManager.createSymbolicLink(
                    atPath: absDst.path(),
                    withDestinationPath: relativeSrc
                )
            } else {
                try fileManager.createSymbolicLink(
                    at: absDst,
                    withDestinationURL: absSrc
                )
            }
        } catch {
            NSLog("Falling back to absolute path symlink")
            if newBlob {
                NSLog("Moving file from \(absSrc) to \(absDst)")
                try fileManager.moveItem(at: absSrc, to: absDst)
            } else {
                NSLog("Copying file from \(absSrc) to \(absDst)")
                try fileManager.copyItem(at: absSrc, to: absDst)
            }
        }
    }

    private func getPointerPath(
        storageFolder: URL,
        revision: String,
        relativeFilename: String
    ) throws -> URL {
        let snapshotURL = storageFolder.appendingPathComponent("snapshots")
        let pointerURL = snapshotURL.appendingPathComponent(revision)
            .appendingPathComponent(
                relativeFilename
            )

        if !pointerURL.pathComponents.contains(snapshotURL.lastPathComponent) {
            throw FileDownloaderError.invalidPointerPath(
                storageFolder: storageFolder,
                revision: revision,
                relativeFilename: relativeFilename
            )
        }

        return pointerURL
    }

    private func getMetadata(
        revision: String,
        storageFolder: URL
    ) async throws -> (
        urlToDownload: URL,
        etag: String,
        commitHash: String,
        size: Int
    ) {
        if options.localFilesOnly {
            throw FileDownloaderError.offlineModeIsEnabled(
                repoId: repoId,
                repoType: options.repoType,
                revision: revision,
                filename: filename
            )
        }

        let url = HFUtility.hfHubURL(
            repoId: repoId,
            filename: filename,
            repoType: options.repoType,
            revision: revision,
            endpoint: options.endpoint
        )

        var metadata: HFFileMeta
        do {
            metadata = try await getHFFileMetadata(url: url)
        } catch {
            if case .entryNotFound(let response) = error as? HFHubHTTPError {
                let commitHash = response.value(
                    forHTTPHeaderField: Constants.huggingFaceHeaderXRepoCommit
                )

                if let commitHash {
                    let noExistFileURL = storageFolder.appendingPathComponent(
                        ".no_exist/\(commitHash)/\(filename)"
                    )
                    do {
                        try FileManager.default.createDirectory(
                            at: noExistFileURL.deletingLastPathComponent(),
                            withIntermediateDirectories: true
                        )
                        try "".write(
                            to: noExistFileURL,
                            atomically: true,
                            encoding: .utf8
                        )
                    } catch {
                        NSLog(
                            "Could not cache non-existence of file. Will ignore error and continue. Error: \(error)."
                        )
                    }
                    try cacheCommitHashForSpecificRevision(
                        storageFolder: storageFolder,
                        revision: revision,
                        commitHash: commitHash
                    )
                }
            }
            throw error
        }

        guard let commitHash = metadata.commitHash else {
            throw FileDownloaderError.distantResourceNotOnHuggingFace
        }

        guard let etag = metadata.etag else {
            throw FileDownloaderError.distantResourceNoEtag
        }

        guard let size = metadata.size else {
            throw FileDownloaderError.distantResourceNoSize
        }

        var urlToDownload: URL = url
        if url != metadata.location {
            urlToDownload = metadata.location
            if url.host() != metadata.location.host() {
                options.headers?.removeValue(forKey: "authorization")
            }
        }

        return (urlToDownload, etag, commitHash, size)
    }

    private func cacheCommitHashForSpecificRevision(
        storageFolder: URL,
        revision: String,
        commitHash: String
    ) throws {
        if revision != commitHash {
            let refURL = storageFolder.appendingPathComponent(
                "refs/\(revision)"
            )

            try FileManager.default.createDirectory(
                at: refURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            if !refURL.exists(), try commitHash != String(contentsOf: refURL) {
                try commitHash.write(
                    to: refURL,
                    atomically: true,
                    encoding: .utf8
                )
            }
        }
    }

    private func getHFFileMetadata(url: URL) async throws -> HFFileMeta {
        var hfHeaders = HFUtility.buildHFHeaders(
            token: options.token,
            libraryName: options.libraryName,
            libraryVersion: options.libraryVersion,
            userAgent: options.userAgent,
            headers: options.headers
        )
        hfHeaders["Accept-Encoding"] = "identity"

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.allHTTPHeaderFields = hfHeaders

        let (data, response) = try await URLSessionWrapper(session: .shared).data(
            for: request,
            followRelativeRedirects: true
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        try HFUtility.hfRaiseForStatus(data: data, response: httpResponse)

        let commitHash = httpResponse.value(
            forHTTPHeaderField: Constants.huggingFaceHeaderXRepoCommit
        )

        let etag = normalizeEtag(
            httpResponse.value(
                forHTTPHeaderField: Constants.huggingFaceHeaderXLinkedEtag
            )
                ?? httpResponse.value(forHTTPHeaderField: "Etag")
        )

        let location =
            httpResponse.value(forHTTPHeaderField: "Location")
            .flatMap(URL.init) ?? url

        let size =
            (httpResponse.value(
                forHTTPHeaderField: Constants.huggingFaceHeaderXLinkedSize
            ) ?? httpResponse.value(forHTTPHeaderField: "Content-Length"))
            .flatMap(Int.init)

        return HFFileMeta(
            commitHash: commitHash,
            etag: etag,
            location: location,
            size: size
        )
    }

    func normalizeEtag(_ etag: String?) -> String? {
        guard let etag else {
            return nil
        }

        let normalized =
            etag
            .replacingOccurrences(
                of: "^W/",
                with: "",
                options: .regularExpression
            )
            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))

        return normalized
    }
}

extension FileDownloader {
    public struct Options: Sendable {
        let subfolder: String?
        let repoType: RepoType
        let revision: String?
        let libraryName: String?
        let libraryVersion: String?
        let cacheDir: URL?
        let localDir: URL?
        let userAgent: [String: String]?
        let forceDownload: Bool
        let proxies: [String: String]?
        let etagTimeout: TimeInterval
        let token: String?
        let localFilesOnly: Bool
        var headers: [String: String]?
        let endpoint: String?
        let onProgress: @Sendable (Int64, Int64) -> Void

        public init(
            subfolder: String? = nil,
            repoType: RepoType = .model,
            revision: String? = nil,
            libraryName: String? = nil,
            libraryVersion: String? = nil,
            cacheDir: URL? = nil,
            localDir: URL? = nil,
            userAgent: [String: String]? = nil,
            forceDownload: Bool = false,
            proxies: [String: String]? = nil,
            etagTimeout: TimeInterval = Constants.defaultEtagTimeout,
            token: String? = nil,
            localFilesOnly: Bool = false,
            headers: [String: String]? = nil,
            endpoint: String? = nil,
            onProgress: @escaping (@Sendable (Int64, Int64) -> Void) = { _, _ in }
        ) {
            self.subfolder = subfolder
            self.repoType = repoType
            self.revision = revision
            self.libraryName = libraryName
            self.libraryVersion = libraryVersion
            self.cacheDir = cacheDir
            self.localDir = localDir
            self.userAgent = userAgent
            self.forceDownload = forceDownload
            self.proxies = proxies
            self.etagTimeout = etagTimeout
            self.token = token
            self.localFilesOnly = localFilesOnly
            self.headers = headers
            self.endpoint = endpoint
            self.onProgress = onProgress
        }
    }
}

extension FileDownloader {
    public enum FileDownloaderError: Error, LocalizedError, Equatable {
        case invalidPointerPath(
            storageFolder: URL,
            revision: String,
            relativeFilename: String
        )
        case offlineModeIsEnabled(
            repoId: String,
            repoType: RepoType,
            revision: String,
            filename: String
        )
        case distantResourceNotOnHuggingFace
        case distantResourceNoEtag
        case distantResourceNoSize

        public var errorDescription: String? {
            switch self {
            case .invalidPointerPath(
                let storageFolder,
                let revision,
                let relativeFilename
            ):
                "Invalid pointer path: cannot create pointer path in snapshot folder if `storage_folder='\(storageFolder.path())'`, `revision='\(revision)'` and `relative_filename='\(relativeFilename)'`."
            case .offlineModeIsEnabled(
                let repoId,
                let repoType,
                let revision,
                let filename
            ):
                "Cannot access file since 'local_files_only=True' as been set. (repo_id: \(repoId), repo_type: \(repoType), revision: \(revision), filename: \(filename))"
            case .distantResourceNotOnHuggingFace:
                "Distant resource does not seem to be on huggingface.co. It is possible that a configuration issue prevents you from downloading resources from https://huggingface.co. Please check your firewall and proxy settings and make sure your SSL certificates are updated."
            case .distantResourceNoEtag:
                "Distant resource does not have an ETag, we won't be able to reliably ensure reproducibility."
            case .distantResourceNoSize:
                "Distant resource does not have a size, we won't be able to reliably ensure reproducibility."
            }
        }
    }
}

extension FileDownloader {
    private final class Delegate: NSObject, URLSessionTaskDelegate, URLSessionDownloadDelegate, @unchecked Sendable {
        private let continuation: CheckedContinuation<URL, Error>
        private let destinationURL: URL
        private let onProgress: @Sendable (Int64, Int64) -> Void
        private let progressBar = ProgressBar()
        private let lock = NSLock()
        private var lastUpdateTime = Date()
        init(
            continuation: CheckedContinuation<URL, Error>,
            destinationURL: URL,
            onProgress: @Sendable @escaping (Int64, Int64) -> Void
        ) {
            self.continuation = continuation
            self.destinationURL = destinationURL
            self.onProgress = onProgress
        }

        func urlSession(
            _ session: URLSession,
            downloadTask: URLSessionDownloadTask,
            didFinishDownloadingTo location: URL
        ) {

            let temporaryDirectory = FileManager.default.temporaryDirectory
            let temporaryFile = temporaryDirectory.appendingPathComponent(
                "tmp_\(UUID().uuidString)")
            do {
                try FileManager.default.copyItem(at: location, to: temporaryFile)
                try FileManager.default.moveItem(at: temporaryFile, to: destinationURL)

                continuation.resume(returning: destinationURL)
            } catch {
                continuation.resume(throwing: error)
            }
        }

        private func shouldUpdate() -> Bool {
            lock.lock()
            defer { lock.unlock() }

            let currentTime = Date()
            if currentTime.timeIntervalSince(lastUpdateTime) < 0.5 {
                return false
            }
            lastUpdateTime = currentTime
            return true
        }

        func urlSession(
            _ session: URLSession,
            downloadTask: URLSessionDownloadTask,
            didWriteData bytesWritten: Int64,
            totalBytesWritten: Int64,
            totalBytesExpectedToWrite: Int64
        ) {
            guard shouldUpdate() else { return }

            onProgress(totalBytesWritten, totalBytesExpectedToWrite)

            Task {
                await progressBar.update(currentBytes: totalBytesWritten, totalBytes: totalBytesExpectedToWrite)
            }
        }

        func urlSession(
            _ session: URLSession,
            task: URLSessionTask,
            didCompleteWithError error: FileDownloaderError?
        ) {
            if let error {
                continuation.resume(throwing: error)
            }
        }
    }
}

actor ProgressBar {
    private var width: Int = 100
    private let startTime: Date
    private var lastUpdateTime: Date
    private var lastBytes: Int64 = 0

    init() {
        self.startTime = Date()
        self.lastUpdateTime = Date()
    }

    func update(currentBytes: Int64, totalBytes: Int64) {
        let now = Date()
        let timeElapsed = now.timeIntervalSince(startTime)
        let timeSinceLastUpdate = now.timeIntervalSince(lastUpdateTime)

        // 计算速度
        let bytesSinceLastUpdate = currentBytes - lastBytes
        let speed = Double(bytesSinceLastUpdate) / timeSinceLastUpdate

        // 计算剩余时间
        let remainingBytes = totalBytes - currentBytes
        let eta = remainingBytes > 0 ? Double(remainingBytes) / speed : 0

        // 计算进度百分比
        let percentage = Double(currentBytes) * 100.0 / Double(totalBytes)

        // 创建进度条
        let filledWidth = Int(Double(width) * percentage / 100.0)
        let emptyWidth = width - filledWidth
        let progressBar = String(repeating: "█", count: filledWidth) + String(repeating: "░", count: emptyWidth)

        // 清除当前行并更新进度
        print("\u{1B}[1A\u{1B}[K", terminator: "")  // 移动光标到行首并清除行
        print(
            String(
                format: "%.1f%%|%@| %@/%@ [%@<%@, %@]",
                percentage,
                progressBar,
                ByteCountFormatter.string(fromByteCount: currentBytes, countStyle: .file),
                ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file),
                timeElapsed.formattedDuration(),
                eta.formattedDuration(),
                ByteCountFormatter.string(fromByteCount: Int64(speed), countStyle: .file) + "/s"
            )
        )

        // 更新最后更新时间和字节数
        lastUpdateTime = now
        lastBytes = currentBytes
    }
}
