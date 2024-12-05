//
//  CacheManagerTests.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/7.
//

import Foundation
@testable import HuggingfaceHub
import Testing

struct CacheManagerTests {
    @Test
    func parseRepoTest() async throws {
        let repoPath = "~/.cache/huggingface/hub/models--HuggingFaceTB--SmolLM2-135M"

        let repoURL = URL(fileURLWithPath: repoPath.expandingTildeInPath).standardized

        let (repoType, repoId) = try CacheManager.parseRepo(repoURL)
        #expect(repoType == .model)
        #expect(repoId == "HuggingFaceTB/SmolLM2-135M")
    }

    @Test
    func scanCacheDirTest() async throws {
        let hfCacheInfo = try CacheManager().scanCacheDir()
        print(hfCacheInfo)
    }
}
