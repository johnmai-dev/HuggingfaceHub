//
//  HFUtility.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/16.
//

import Foundation

enum HFUtility {
    static func repoFolderName(repoId: String, repoType: RepoType) -> String {
        "\(repoType)s\(Constants.repoIdSeparator)\(repoId.replacingOccurrences(of: "/", with: Constants.repoIdSeparator))"
    }

    static func hfHubURL(
        repoId: String,
        filename: String,
        subfolder: String? = nil,
        repoType: RepoType = .model,
        revision: String? = nil,
        endpoint: String? = nil
    ) -> URL {
        let name = if let subfolder, !subfolder.isEmpty {
            subfolder + "/" + filename
        } else {
            filename
        }

        var repoId: String = switch repoType {
        case .dataset:
            "datasets/\(repoId)"
        case .model:
            repoId
        case .space:
            "spaces/\(repoId)"
        }

        let revision: String = revision ?? Constants.defaultRevision
        let endpoint = endpoint ?? Constants.endpoint

        return URL(string: "\(endpoint)/\(repoId)/resolve/\(revision)/\(name)")!
    }

    static func buildHFHeaders(
        token: String? = nil,
        libraryName: String? = nil,
        libraryVersion: String? = nil,
        userAgent: [String: String]? = nil,
        headers: [String: String]? = nil
    ) -> [String: String] {
        var hfHeaders = [
            "user-agent": buildUserAgent(
                libraryName: libraryName,
                libraryVersion: libraryVersion,
                userAgent: userAgent
            ),
        ]

        if let token {
            hfHeaders["authorization"] = "Bearer \(token)"
        } else if let token = Constants.hfHubToken {
            hfHeaders["authorization"] = "Bearer \(token)"
        }

        if let headers {
            hfHeaders.merge(headers) { _, new in new }
        }

        return hfHeaders
    }

    static func buildUserAgent(
        libraryName: String? = nil,
        libraryVersion: String? = nil,
        userAgent: [String: String]? = nil
    ) -> String {
        var ua = if let libraryName {
            "\(libraryName)/\(libraryVersion ?? "None")"
        } else {
            "unknown/None"
        }

        ua += "; hf_hub/\(Constants.version)"
        ua += "; swift_hf_hub/\(Constants.version)"
        ua += "; swift/\(Utility.swiftVersion)"

        if let userAgent {
            for (key, value) in userAgent {
                ua += "; \(key)/\(value)"
            }
        }

        return deduplicateUserAgent(ua)
    }

    static func deduplicateUserAgent(_ ua: String) -> String {
        let components = ua.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }
        return (NSOrderedSet(array: components).array as! [String]).joined(separator: "; ")
    }

    static func hfRaiseForStatus(data: Data, response: HTTPURLResponse) throws {
        do {
            try raiseForStatus(data: data, response: response)
        } catch {
            let errorCode = response.value(forHTTPHeaderField: "X-Error-Code")
            let errorMessage = response.value(forHTTPHeaderField: "X-Error-Message")

            let repoApiRegex = #/^https://[^/]+(/api/(models|datasets|spaces)/(.+)|/(.+)/resolve/(.+))/#

            if errorCode == "RevisionNotFound" {
                throw HFHubHTTPError.revisionNotFound(response)
            } else if errorCode == "EntryNotFound" {
                throw HFHubHTTPError.entryNotFound(response)
            } else if errorCode == "GatedRepo" {
                throw HFHubHTTPError.gatedRepo(response)
            } else if errorMessage == "Access to this resource is disabled." {
                throw HFHubHTTPError.resourceDisabled(response)
            } else if errorCode == "RepoNotFound" || (response.statusCode == 401 && response.url?.absoluteString.contains(repoApiRegex) ?? false) {
                throw HFHubHTTPError.repoNotFound(response)
            } else if response.statusCode == 403 {
                throw HFHubHTTPError.forbidden(response: response, errorMessage: errorMessage)
            } else if response.statusCode == 416 {
                throw HFHubHTTPError.rangeNotSatisfiable(response)
            }

            throw HFHubHTTPError.invalidResponse
        }
    }

    static func raiseForStatus(data: Data, response: HTTPURLResponse) throws {
        let reason = String(data: data, encoding: .utf8)

        let httpErrorMessages = switch response.statusCode {
        case 400 ..< 500:
            "\(response.statusCode) Client Error: \(reason ?? "") for url: \(response.url?.absoluteString ?? "")"
        case 500 ..< 600:
            "\(response.statusCode) Server Error: \(reason ?? "") for url: \(response.url?.absoluteString ?? "")"
        default:
            ""
        }

        if !httpErrorMessages.isEmpty {
            throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: httpErrorMessages])
        }
    }
}
