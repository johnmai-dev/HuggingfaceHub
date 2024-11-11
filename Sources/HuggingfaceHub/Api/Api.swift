//
//  HfApi.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/7.
//

import Foundation

public class Api {
    let endpoint: String
    let token: String?
    let libraryName: String?
    let libraryVersion: String?
    let userAgent: [String: String]?
    let headers: [String: String]?

    public init(
        endpoint: String? = nil,
        token: String? = nil,
        libraryName: String? = nil,
        libraryVersion: String? = nil,
        userAgent: [String: String]? = nil,
        headers: [String: String]? = nil
    ) {
        self.endpoint = endpoint ?? Constants.endpoint
        self.token = token
        self.libraryName = libraryName
        self.libraryVersion = libraryVersion
        self.userAgent = userAgent
        self.headers = headers
    }

    func buildHfHeaders(
        token: String? = nil,
        libraryName: String? = nil,
        libraryVersion: String? = nil,
        userAgent: [String: String]? = nil,
        headers: [String: String]? = nil
    ) -> [String: String] {
        var hfHeaders = [
            "user-agent": buildUserAgent(
                libraryName: libraryName ?? self.libraryName,
                libraryVersion: libraryVersion ?? self.libraryVersion,
                userAgent: userAgent
            ),
        ]

        if let token {
            hfHeaders["authorization"] = "Bearer \(token)"
        } else if let token = self.token {
            hfHeaders["authorization"] = "Bearer \(token)"
        }
//        else if let token = Constants.token() {
//            hfHeaders["authorization"] = "Bearer \(token)"
//        }

        if let headers {
            hfHeaders.merge(headers) { _, new in new }
        }

        return hfHeaders
    }

    func buildUserAgent(
        libraryName: String? = nil,
        libraryVersion: String? = nil,
        userAgent: [String: String]? = nil
    ) -> String {
        var ua = "unknown/None"
        if let libraryName {
            ua = "\(libraryName)/\(libraryVersion ?? "")"
        }
        ua += "; hf_hub/\(Constants.version)"
        ua += "; swift/6.0"

        if let userAgent {
            for (key, value) in userAgent {
                ua += "; \(key)/\(value)"
            }
        }

        return deduplicateUserAgent(ua)
    }

    func deduplicateUserAgent(_ ua: String) -> String {
        let components = ua.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }
        return (NSOrderedSet(array: components).array as! [String]).joined(separator: "; ")
    }
}

public extension Api {
    enum Error: Swift.Error, LocalizedError, Equatable {
        case invalidResponse
        case authenticationError
        case httpStatusCode(Int)

        public var errorDescription: String? {
            switch self {
            case .invalidResponse:
                "Invalid response received"
            case .authenticationError:
                "Authentication failed"
            case .httpStatusCode(let code):
                "HTTP error with status code: \(code)"
            }
        }
    }
}
