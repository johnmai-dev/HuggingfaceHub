//
//  HuggingfaceHubTests.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/7.
//

import Foundation
@testable import HuggingfaceHub
import Testing

struct HuggingfaceHubTests {
    @Test
    func commitHashRegexTest() async throws {
        let commitHash = "fdb6e0218f874993ccb1525994452f48255fb6de"

        #expect(commitHash.contains(#/^[0-9a-f]{40}$/#))
    }

    @Test
    func repoApiRegexTest() async throws {
        let regex = #/^https://[^/]+(/api/(models|datasets|spaces)/(.+)|/(.+)/resolve/(.+))/#

        // Listing endpoints => False
        #expect(!"https://huggingface.co/api/models".contains(regex))
        #expect(!"https://huggingface.co/api/datasets".contains(regex))
        #expect(!"https://huggingface.co/api/spaces".contains(regex))
        // Create repo endpoint => False
        #expect(!"https://huggingface.co/api/repos/create".contains(regex))
        // Collection endpoints => False
        #expect(!"https://huggingface.co/api/collections".contains(regex))
        #expect(!"https://huggingface.co/api/collections/foo/bar".contains(regex))
        // Repo endpoints => True
        #expect("https://huggingface.co/api/models/repo_id".contains(regex))
        #expect("https://huggingface.co/api/datasets/repo_id".contains(regex))
        #expect("https://huggingface.co/api/spaces/repo_id".contains(regex))
        #expect("https://huggingface.co/api/models/username/repo_name/refs/main".contains(regex))
        #expect("https://huggingface.co/api/datasets/username/repo_name/refs/main".contains(regex))
        #expect("https://huggingface.co/api/spaces/username/repo_name/refs/main".contains(regex))
        // Inference Endpoint => False
        #expect(!"https://api.endpoints.huggingface.cloud/v2/endpoint/namespace".contains(regex))
        // Staging Endpoint => True
        #expect("https://hub-ci.huggingface.co/api/models/repo_id".contains(regex))
        #expect("https://hub-ci.huggingface.co/api/datasets/repo_id".contains(regex))
        #expect("https://hub-ci.huggingface.co/api/spaces/repo_id".contains(regex))
        // /resolve Endpoint => True
        #expect("https://huggingface.co/gpt2/resolve/main/README.md".contains(regex))
        #expect("https://huggingface.co/datasets/google/fleurs/resolve/revision/README.md".contains(regex))
        // Regression tests
        #expect("https://huggingface.co/bert-base/resolve/main/pytorch_model.bin".contains(regex))
        #expect("https://hub-ci.huggingface.co/__DUMMY_USER__/repo-1470b5/resolve/main/file.txt".contains(regex))
    }
}
