//
//  URLSession+Extension.swift
//  HuggingfaceHub
//  Source: https://stackoverflow.com/questions/68276940/how-to-get-the-download-progress-with-the-new-try-await-urlsession-shared-downlo
//  Created by John Mai on 2024/12/3.
//

import Foundation

extension URLSession {
    func download(with request: URLRequest) async throws -> (URL, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = downloadTask(with: request) { fileURL, response, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let fileURL,
                      let response
                else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }

                continuation.resume(returning: (fileURL, response))
            }

            task.resume()
        }
    }

    func download(withResumeData resumeData: Data) async throws -> (URL, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = downloadTask(withResumeData: resumeData) { fileURL, response, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let fileURL,
                      let response
                else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                continuation.resume(returning: (fileURL, response))
            }
            task.resume()
        }
    }
}
