//
//  HfApiTests.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/7.
//

@testable import HuggingfaceHub
import Testing

struct HfApiTests {
    @Test func deduplicateUserAgent() async throws {
        let api = Api()
        let ua = api.deduplicateUserAgent("python/3.7; python/3.8; hf_hub/0.12; transformers/None; hf_hub/0.12; python/3.7; diffusers/0.12.1")
        #expect(ua == "python/3.7; python/3.8; hf_hub/0.12; transformers/None; diffusers/0.12.1")
    }
}
