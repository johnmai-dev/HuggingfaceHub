//
//  SnapshotDownloaderTests.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/15.
//

import Foundation
@testable import HuggingfaceHub
import Testing

struct SnapshotDownloaderTests {
    @Test
    func download() async throws {
//        let downloader = SnapshotDownloader(repoId: "HuggingFaceTB/SmolLM2-135M")
        let downloader = SnapshotDownloader(repoId: "Qwen/QwQ-32B-Preview", options: .init(onProgress: { progress in
            print("下载进度 ->", progress)
        }))
        let snapshot = try await downloader.download()
        print(snapshot)
        sleep(60*5)
    }
}
