//
//  URLSessionWrapper.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/12/2.
//

import Foundation

class URLSessionWrapper: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func data(
        for request: URLRequest,
        followRelativeRedirects: Bool = false
    ) async throws -> (
        Data, URLResponse
    ) {
        if followRelativeRedirects {
            let (data, response) = try await self.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            if (300 ... 399).contains(httpResponse.statusCode) {
                let parsedTarget = URL(
                    string: httpResponse.allHeaderFields["Location"] as? String ?? "")
                if parsedTarget?.host == nil {
                    let nextURL = URL(string: request.url?.absoluteString ?? "")?
                        .appendingPathComponent(
                            parsedTarget?.path ?? ""
                        )
                    return try await self.data(
                        for: URLRequest(url: nextURL!), followRelativeRedirects: true)
                }
                return (data, response)
            }
        }

        return try await session.data(for: request, delegate: self)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest
    ) async -> URLRequest? {
        nil
    }
}
