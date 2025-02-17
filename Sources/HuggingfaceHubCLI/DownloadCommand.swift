//
//  DownloadCommand.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2025/2/17.
//

import ArgumentParser
import Foundation
import HuggingfaceHub
@preconcurrency import Tqdm

actor ProgressBar {
    private let width: Int = 40
    private var lastPrintedPercentage: Int = -1
    private var startTime: Date?
    private var lastUpdateTime: Date?
    private var lastCompletedUnits: Int64 = 0

    func update(progress: Progress) {
        if startTime == nil {
            startTime = Date()
        }

        let now = Date()
        let percentage = Int(progress.fractionCompleted * 100)

        // 避免过于频繁的更新，只在百分比变化时更新显示
        if percentage != lastPrintedPercentage {
            lastPrintedPercentage = percentage

            // 计算进度条
            let filled = Int(Double(width) * progress.fractionCompleted)
            let empty = width - filled
            let bar = String(repeating: "█", count: filled) + String(repeating: "░", count: empty)

            // 计算速度
            var speedStr = "计算中..."
            if let lastUpdate = lastUpdateTime {
                let timeInterval = now.timeIntervalSince(lastUpdate)
                let unitsDiff = progress.completedUnitCount - lastCompletedUnits
                let unitsPerSecond = Double(unitsDiff) / timeInterval
                speedStr = formatSpeed(unitsPerSecond)
            }

            // 估算剩余时间
            var remainingTime = "计算中..."
            if let start = startTime, progress.fractionCompleted > 0 {
                let elapsedTime = now.timeIntervalSince(start)
                let estimatedTotalTime = elapsedTime / progress.fractionCompleted
                let remainingSeconds = estimatedTotalTime - elapsedTime
                remainingTime = formatTime(remainingSeconds)
            }

            // 构建状态行
            let statusLine = String(
                format: "\r%3d%% [\(bar)] %@ - 剩余: %@",
                percentage,
                speedStr,
                remainingTime)

            print(statusLine, terminator: "")
            fflush(stdout)

            // 下载完成时换行
            if progress.fractionCompleted >= 1.0 {
                print()
            }
        }

        lastUpdateTime = now
        lastCompletedUnits = progress.completedUnitCount
    }

    private func formatSpeed(_ unitsPerSecond: Double) -> String {
        let units = ["B/s", "KB/s", "MB/s", "GB/s"]
        var speed = unitsPerSecond
        var unitIndex = 0

        while speed >= 1024 && unitIndex < units.count - 1 {
            speed /= 1024
            unitIndex += 1
        }

        return String(format: "%.1f %@", speed, units[unitIndex])
    }

    private func formatTime(_ seconds: Double) -> String {
        if seconds.isInfinite || seconds.isNaN {
            return "计算中..."
        }

        if seconds < 60 {
            return String(format: "%.0f秒", seconds)
        } else if seconds < 3600 {
            return String(format: "%.1f分钟", seconds / 60)
        } else {
            return String(format: "%.1f小时", seconds / 3600)
        }
    }
}

struct ArrayStringArgument: ExpressibleByArgument {
    let value: [String]

    init?(argument: String) {
        if argument.isEmpty {
            value = []
        } else {
            value = argument.components(separatedBy: " ")
        }
    }
}

struct DownloadCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "download",
        abstract: "Download files from the Hub"
    )

    @Argument(
        help: "ID of the repo to download from (e.g. `username/repo-name`)."
    )
    var repoId: String

    @Argument(
        help: "Files to download (e.g. `config.json`, `data/metadata.jsonl`)."
    )
    var filenames: [String] = []

    @Option(
        name: .long,
        help: "Type of repo to download from (defaults to 'model')."
    )
    var repoType: String = "model"

    @Option(
        name: .long,
        help: "An optional Git revision id which can be a branch name, a tag, or a commit hash."
    )
    var revision: String?

    @Option(
        name: .long,
        help: "Glob patterns to match files to download."
    )
    var include: ArrayStringArgument?

    @Option(
        name: .long,
        help: "Glob patterns to exclude from files to download."
    )
    var exclude: ArrayStringArgument?

    @Option(
        name: .long,
        help: "Path to the directory where to save the downloaded files."
    )
    var cacheDir: String?

    @Option(
        name: .long,
        help:
            "If set, the downloaded file will be placed under this directory. Check out https://huggingface.co/docs/huggingface_hub/guides/download#download-files-to-local-folder for more details."
    )
    var localDir: String?

    @Flag(
        help: "If True, the files will be downloaded even if they are already cached."
    )
    var forceDownload: Bool = false

    @Option(
        name: .long,
        help: "A User Access Token generated from https://huggingface.co/settings/tokens"
    )
    var token: String?

    @Flag(
        help: "If True, progress bars are disabled and only the path to the download files is printed."
    )
    var quiet: Bool = false

    @Option(
        name: .long,
        help: "Maximum number of workers to use for downloading files. Default is 8."
    )
    var maxWorkers: Int = 8

    func run() async throws {

        if !filenames.isEmpty {
            if let include, !include.value.isEmpty {
                NSLog("Ignoring `--include` since filenames have being explicitly set.")
            }
            if let exclude, !exclude.value.isEmpty {
                NSLog("Ignoring `--exclude` since filenames have being explicitly set.")
            }
        }

        if filenames.count == 1 {
            let downloader = FileDownloader(
                repoId: repoId,
                filename: filenames[0],
                options: .init(
                    repoType: .init(rawValue: repoType)!,
                    revision: revision,
                    libraryName: "huggingface-cli",
                    cacheDir: cacheDir != nil ? URL(fileURLWithPath: cacheDir!) : nil,
                    localDir: localDir != nil ? URL(fileURLWithPath: localDir!) : nil,
                    forceDownload: forceDownload,
                    token: token
                )
            )

            let url = try await downloader.download()
            print(url.absoluteString)
        }

        var allowPatterns: [String]?
        var ignorePatterns: [String]?

        if filenames.isEmpty {
            allowPatterns = include?.value
            ignorePatterns = exclude?.value
        } else {
            allowPatterns = filenames
            ignorePatterns = []
        }

        let progressBar = ProgressBar()

        let downloader = SnapshotDownloader(
            repoId: repoId,
            options: .init(
                repoType: .init(rawValue: repoType)!,
                revision: revision,
                cacheDir: cacheDir != nil ? URL(fileURLWithPath: cacheDir!) : nil,
                localDir: localDir != nil ? URL(fileURLWithPath: localDir!) : nil,
                libraryName: "huggingface-cli",
                forceDownload: forceDownload,
                token: token,
                allowPatterns: allowPatterns,
                ignorePatterns: ignorePatterns,
                maxWorkers: maxWorkers,
                onProgress: { progress in
                    if !quiet {
                        Task {
                            await progressBar.update(progress: progress)
                        }
                    }
                }
            )
        )
        let snapshot = try await downloader.download()
        print(snapshot.path())
    }
}
