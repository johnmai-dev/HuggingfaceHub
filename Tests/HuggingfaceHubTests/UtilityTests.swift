//
//  UtilityTests.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/15.
//

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
}
