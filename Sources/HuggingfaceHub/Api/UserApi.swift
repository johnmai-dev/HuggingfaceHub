//
//  User.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/7.
//

import Foundation

extension HFApi {
    public func whoami(token: String? = nil) async throws -> User {
        let url = URL(string: "\(endpoint)/api/whoami-v2")!

        var request = URLRequest(url: url)
        let headers = buildHFHeaders(token: token)

        request.allHTTPHeaderFields = headers

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200 ..< 300: break
        case 400 ..< 500: throw Error.authenticationError
        default: throw Error.httpStatusCode(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(User.self, from: data)
    }
}

public struct User: Codable {
    let type: String
    let id: String
    let name: String
    let fullname: String
    let email: String
    let emailVerified: Bool
    let canPay: Bool
    let periodEnd: Int
    let isPro: Bool
    let avatarUrl: String
    let orgs: [Organization]
    let auth: Auth
}

public struct Organization: Codable {
    let type: String
    let id: String
    let name: String
    let fullname: String
    let email: String?
    let canPay: Bool
    let periodEnd: Int?
    let avatarUrl: String
    let roleInOrg: String
    let isEnterprise: Bool
}

public struct Auth: Codable {
    let type: String
    let accessToken: AccessToken?
}

public struct AccessToken: Codable {
    let displayName: String
    let role: String
    let createdAt: String
}
