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
            repoId: "mlx-community/Qwen2.5-Coder-0.5B-4bit-gs32",
            options: .init(onProgress: { progress in
                print("下载进度 ->", progress)
            })
        )
        let snapshot = try await downloader.download()

        print("snapshot ->", snapshot)
    }
}
