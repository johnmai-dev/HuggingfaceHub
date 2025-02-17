//
//  FileDownloaderTests.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/16.
//

import Foundation
import Testing

@testable import HuggingfaceHub

struct FileDownloaderTests {
    @Test
    func createSymlinkRelativeSrcTest() async throws {
        let fileManager = FileManager.default

        let testDir = fileManager.temporaryDirectory.appendingPathComponent("testDir")

        print("testDir: \(testDir)")

        try fileManager.createDirectory(
            at: testDir, withIntermediateDirectories: true, attributes: nil)

        print("testDir: \(testDir.isDirectory())")

        let src = testDir.appendingPathComponent("source")
        try "source".write(to: src, atomically: true, encoding: .utf8)

        let dst = testDir.appendingPathComponent("destination")

        let downloader = FileDownloader(
            repoId: "",
            filename: ""
        )

        try await downloader.createSymlink(src: src, dst: dst)

        #expect(dst.isFile())

        try? fileManager.removeItem(at: testDir)
    }

    @Test
    func normalizeEtagTest() throws {
        let downloader = FileDownloader(
            repoId: "",
            filename: ""
        )

        //        #expect(downloader.normalizeEtag("\"a16a55fda99d2f2e7b69cce5cf93ff4ad3049930\"") == "a16a55fda99d2f2e7b69cce5cf93ff4ad3049930")
        //        #expect(downloader.normalizeEtag("W/\"a16a55fda99d2f2e7b69cce5cf93ff4ad3049930\"") == "a16a55fda99d2f2e7b69cce5cf93ff4ad3049930")
    }

    @Test
    func download() async throws {
        let downloader = FileDownloader(
            repoId: "Qwen/QwQ-32B-Preview",
            filename: "config.json",
            options: .init(
                revision: "d233ae7673ea6b1ebbebcc01f354065142d46990",
                cacheDir: FileManager.default.temporaryDirectory,
                onProgress: { progress in
                    print("Download progress: \(progress)")
                }
            )
        )

        let url = try await downloader.download()

        print("Downloaded file to: \(url)")
    }
}
