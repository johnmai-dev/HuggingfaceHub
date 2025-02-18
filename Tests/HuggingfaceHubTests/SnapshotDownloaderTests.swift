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
            repoId: "JohnMai/test",
            options: .init(
                onProgress: { progress in
                    print("progress ->", progress)
                }
            )
        )
        let snapshot = try await downloader.download()

        #expect(snapshot.path().contains("models--JohnMai--test/snapshots/200c7cf12460c019f79d746313d6e0b72b6c77ba"))
    }
}
