//
//  UserApiTests.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/7.
//
@testable import HuggingfaceHub
import Testing

struct UserApiTests {
    @Test func whoami() async throws {
        let api = HFApi()
        let response = try await api.whoami(token: "hf_test")
        print(response)
    }

    @Test func whoamiAuthenticationError() async throws {
        await #expect(throws: HFApi.Error.authenticationError) {
            let api = HFApi()
            _ = try await api.whoami()
        }
    }
}
