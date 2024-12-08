//
//  Downloader.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/12/3.
//
import Foundation

actor Downloader {
    private var continuation: CheckedContinuation<URL, Error>?
    private let task: URLSessionDownloadTask

    private var onProgress: (@Sendable (Double) -> Void)?

    init(url: URL) {
        self.init(task: URLSession.shared.downloadTask(with: url))
    }

    init(resumeData data: Data) {
        self.init(task: URLSession.shared.downloadTask(withResumeData: data))
    }

    private init(task: URLSessionDownloadTask) {
        self.task = task
    }

    func start(onProgress: (@Sendable (Double) -> Void)? = nil) async throws -> URL {
        self.onProgress = onProgress
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            task.delegate = Delegate(self)
            task.resume()
        }
    }

    func cancel() {
        task.cancel()
    }
}

extension Downloader {
    private final class Delegate: NSObject, URLSessionDownloadDelegate, Sendable {
        let downloader: Downloader

        init(_ downloader: Downloader) {
            self.downloader = downloader
        }

        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            Task {
                await self.downloader.continuation?.resume(returning: location)
            }
        }

        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            Task {
                await self.downloader.onProgress?(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite))
            }
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
            if let error {
                Task {
                    await self.downloader.continuation?.resume(throwing: error)
                }
            }
        }
    }
}
