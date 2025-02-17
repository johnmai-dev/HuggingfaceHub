//
//  HFApiTests.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/7.
//

import Foundation
import Testing

@testable import HuggingfaceHub

struct HFApiTests {
    @Test
    func deduplicateUserAgent() async throws {
        let api = HFApi()
        let ua = api.deduplicateUserAgent(
            "python/3.7; python/3.8; hf_hub/0.12; transformers/None; hf_hub/0.12; python/3.7; diffusers/0.12.1"
        )

        #expect(ua == "python/3.7; python/3.8; hf_hub/0.12; transformers/None; diffusers/0.12.1")
    }

    @Test
    func modelInfo() async throws {
        let api = HFApi()
        let response = try await api.modelInfo(repoId: "mlx-community/Qwen1.5-0.5B-Chat")

        #expect(response.id == "mlx-community/Qwen1.5-0.5B-Chat")
    }
}
