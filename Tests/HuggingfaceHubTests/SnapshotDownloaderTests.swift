//
//  SnapshotDownloaderTests.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/15.
//

import Foundation
import Testing

@testable import HuggingfaceHub

struct SnapshotDownloaderTests {
    @Test
    func download() async throws {
        let downloader = SnapshotDownloader(
            repoId: "JohnMai/test"
        )
        let snapshot = try await downloader.download()

        #expect(snapshot.path().contains("models--JohnMai--test/snapshots/200c7cf12460c019f79d746313d6e0b72b6c77ba"))
    }

    @Test
    func downloadTaskCancel() async throws {
        let downloader = SnapshotDownloader(
            repoId: "HuggingFaceTB/SmolLM2-135M",
            options: .init(onProgress: { progress in
                print("progress -> ", progress.fractionCompleted)
            })
        )

        let task = Task(priority: .high) {
            do {
                let snapshot = try await downloader.download()
                #expect(
                    snapshot.path().contains("models--JohnMai--test/snapshots/200c7cf12460c019f79d746313d6e0b72b6c77ba")
                )
            } catch {
                #expect(error is CancellationError || (error as NSError).code == NSURLErrorCancelled)
            }
        }

        try? await Task.sleep(nanoseconds: 2_000_000_000)

        task.cancel()

        try? await Task.sleep(nanoseconds: 2_000_000_000)
    }

    @Test
    func pause() async throws {
        let downloader = SnapshotDownloader(
            repoId: "HuggingFaceTB/SmolLM2-135M",
            options: .init(quiet: false)
        )

        Task {
            try await Task.sleep(nanoseconds: 5_000_000_000)
            await downloader.pause()
            try await Task.sleep(nanoseconds: 2_000_000_000)
            try await downloader.download()
        }

        let snapshot = try await downloader.download()
    }

}
