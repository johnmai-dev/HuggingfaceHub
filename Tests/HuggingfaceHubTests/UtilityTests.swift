//
//  UtilityTests.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/15.
//

import Foundation
import Testing

@testable import HuggingfaceHub

struct UtilityTests {
    @Test
    func filterRepoObjectsWithFolder() throws {
        let expectedItems = Utility.filterRepoObjects(
            items: [
                "file.txt",
                "lfs.bin",
                "path/to/file.txt",
                "path/to/lfs.bin",
                "nested/path/to/file.txt",
                "nested/path/to/lfs.bin",
            ],
            allowPatterns: ["path/to/"]
        )

        #expect(expectedItems == ["path/to/file.txt", "path/to/lfs.bin"])
    }

    @Test
    func filterRepoObjectsExcludeGitFolder() throws {
        let ignoreItems = [
            ".git",
            ".git/file.txt",
            ".git/folder/file.txt",
            "path/to/folder/.git",
            "path/to/folder/.git/file.txt",
            "path/to/.git/folder/file.txt",
            ".cache/huggingface",
            ".cache/huggingface/file.txt",
            ".cache/huggingface/folder/file.txt",
            "path/to/.cache/huggingface",
            "path/to/.cache/huggingface/file.txt",
        ]

        let validItems = [
            ".gitignore",
            "path/foo.git/file.txt",
            "path/.git_bar/file.txt",
            "path/to/file.git",
            "file.huggingface",
            "path/file.huggingface",
            ".cache/huggingface_folder",
            ".cache/huggingface_folder/file.txt",
        ]

        let expectedItems = Utility.filterRepoObjects(
            items: ignoreItems + validItems,
            ignorePatterns: Constants.defaultIgnorePatterns
        )

        #expect(expectedItems == validItems)
    }

    @Test
    func testProgressBar() async throws {
        let current: Int64 = 10
        let total: Int64 = 100

        let networkProgressBar = ProgressBar(title: "config.json", type: .network)
        await networkProgressBar.update(current: current, total: total)

        let countProgressBar = ProgressBar(title: "Fetching \(total) files", type: .count)
        await countProgressBar.update(current: current, total: total)

    }
}
