//
//  ExampleTests.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/17.
//

import Alamofire
import Foundation
@testable import HuggingfaceHub
import Testing

class DownloadManager: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
    var progressHandler: ((Float) -> Void)?
    var completionHandler: ((URL) -> Void)?
    private var session: URLSession!

    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration,
                             delegate: self,
                             delegateQueue: OperationQueue())
    }

    func downloadFile(from url: URL) {
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
    }

    func downloadFile(from url: URL) async throws -> (URL, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = session.downloadTask(with: url) { fileURL, response, error in
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

    // 实现进度跟踪的代理方法
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64)
    {
        // 注意：这里要使用 Double 类型进行除法运算，避免整数除法导致的精度问题
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)

        print("下载进度：\(progress)")
        DispatchQueue.main.async {
            self.progressHandler?(Float(progress))
        }
    }

    // 实现下载完成的代理方法
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL)
    {
        DispatchQueue.main.async {
            self.completionHandler?(location)
        }
    }
}

struct ExampleTests {
    @Test
    func example() async throws {
        let downloadManager = DownloadManager()
        guard let url = URL(string: "https://huggingface.co/Qwen/QwQ-32B-Preview/resolve/main/model-00001-of-00017.safetensors?download=true") else { return }

        _ = try await downloadManager.downloadFile(from: url)

        sleep(20)
    }

    @Test
    func example2() async throws {
        print("Downloading file...")
        let session = Session.default
        
        let destination: DownloadRequest.Destination = { _, _ in
               let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
               let fileURL = documentsURL.appendingPathComponent("file.zip")

               return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
           }

        let request = AF.download("https://updatecdn.meeting.qq.com/cos/4bb380a65595b444cd1364b0871b2192/TencentMeeting_0300000000_3.29.30.407.publish.arm64.officialwebsite.dmg")
//            .downloadProgress(closure: { progress in
//                print("Download Progress: \(progress.fractionCompleted)")
//            })
//            .responseData { _ in
//                print("Downloaded file...")
        
//            }
        
        let response = request.serializingDownloadedFileURL()

        
        for await progress in request.downloadProgress() {
            print("Download Progress: \(progress.fractionCompleted)")
        }
        


        sleep(20)
    }
    
    
    @Test
    func example3() async throws {
        let downloader = Downloader(url: URL(string:"https://updatecdn.meeting.qq.com/cos/4bb380a65595b444cd1364b0871b2192/TencentMeeting_0300000000_3.29.30.407.publish.arm64.officialwebsite.dmg")!)
        
        downloader.start()
        
        for await event in downloader.events {
            switch event {
            case .progress(totalBytesWritten: let totalBytesWritten, totalBytesExpectedToWrite: let totalBytesExpectedToWrite):
                print("Download Progress: \(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))")
            case .completed(url: let url):
                print("Downloaded file: \(url)")
            case .canceled(data: let data):
                print("Download canceled: \(data)")
            }
        }
    }
}
