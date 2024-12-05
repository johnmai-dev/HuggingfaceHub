//
//  HFHubHTTPError.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/16.
//

import Foundation

public enum HFHubHTTPError: Error, LocalizedError, Equatable {
    case invalidResponse
    case authenticationError
    case httpStatusCode(Int)
    case invalidExpandOptions

    case revisionNotFound(HTTPURLResponse)
    case entryNotFound(HTTPURLResponse)
    case gatedRepo(HTTPURLResponse)
    case resourceDisabled(HTTPURLResponse)
    case repoNotFound(HTTPURLResponse)
    case forbidden(response: HTTPURLResponse, errorMessage: String?)
    case rangeNotSatisfiable(HTTPURLResponse)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "Invalid response received"
        case .authenticationError:
            "Authentication failed"
        case .httpStatusCode(let code):
            "HTTP error with status code: \(code)"
        case .invalidExpandOptions:
            "`expand` cannot be used if `securityStatus` or `files_metadata` are set."
        case .revisionNotFound(let response):
            "\(response.statusCode) Client Error." + "\n\n" + "Revision Not Found for url: \(response.url?.absoluteString ?? "")."
        case .entryNotFound(let response):
            "\(response.statusCode) Client Error." + "\n\n" + "Entry Not Found for url: \(response.url?.absoluteString ?? "")."
        case .gatedRepo(let response):
            "\(response.statusCode) Client Error." + "\n\n" + "Cannot access gated repo for url: \(response.url?.absoluteString ?? "")."

        case .resourceDisabled(let response):
            "\(response.statusCode) Client Error." + "\n\n" + "Cannot access repository for url \(response.url?.absoluteString ?? "")." + "\n" + "Access to this resource is disabled."
        case .repoNotFound(let response):
            "\(response.statusCode) Client Error." + "\n\n" + "Repository Not Found for url: \(response.url?.absoluteString ?? "")." + "\nPlease make sure you specified the correct `repo_id` and `repo_type`." + "\nIf you are trying to access a private or gated repo, make sure you are authenticated."
        case .forbidden(response: let response, errorMessage: let errorMessage):
            "\(response.statusCode) Forbidden: \(errorMessage ?? "unknown")." + "\nCannot access content at: \(response.url?.absoluteString ?? "")." + "\nMake sure your token has the correct permissions."
        case .rangeNotSatisfiable(let response):
            "\(response.statusCode) Requested range not satisfiable." + "\n\n" + "Requested range: \(response.allHeaderFields["Range"] ?? ""). Content-Range: \(response.allHeaderFields["Content-Range"] ?? "")."
        }
    }
}
