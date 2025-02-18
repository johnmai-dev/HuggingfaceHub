import Testing

//
//  UserApiTests.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/7.
//
@testable import HuggingfaceHub

struct UserApiTests {
    @Test func whoamiAuthenticationError() async throws {
        await #expect(throws: HFApi.Error.authenticationError) {
            let api = HFApi()
            _ = try await api.whoami()
        }
    }
}
