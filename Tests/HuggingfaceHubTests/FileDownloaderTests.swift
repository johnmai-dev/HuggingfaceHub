//
//  FileDownloaderTests.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/16.
//

import Foundation
@testable import HuggingfaceHub
import Testing

struct FileDownloaderTests {
    @Test
    func createSymlinkRelativeSrcTest() throws {
        let fileManager = FileManager.default
        
        let testDir = fileManager.temporaryDirectory.appendingPathComponent("testDir")
        
        print("testDir: \(testDir)")
        
        try fileManager.createDirectory(at: testDir, withIntermediateDirectories: true, attributes: nil)
        
        print("testDir: \(testDir.isDirectory())")
        
        let src = testDir.appendingPathComponent("source")
        try "source".write(to: src, atomically: true, encoding: .utf8)
        
        let dst = testDir.appendingPathComponent("destination")
        
        let downloader = FileDownloader(
            repoId: "",
            filename: ""
        )
        
        try downloader.createSymlink(src: src, dst: dst)
        
        #expect(dst.isFile())
        
        try? fileManager.removeItem(at: testDir)
    }
    
    @Test
    func normalizeEtagTest() throws {
        let downloader = FileDownloader(
            repoId: "",
            filename: ""
        )
        
        #expect(downloader.normalizeEtag("\"a16a55fda99d2f2e7b69cce5cf93ff4ad3049930\"") == "a16a55fda99d2f2e7b69cce5cf93ff4ad3049930")
        #expect(downloader.normalizeEtag("W/\"a16a55fda99d2f2e7b69cce5cf93ff4ad3049930\"") == "a16a55fda99d2f2e7b69cce5cf93ff4ad3049930")
    }
}
