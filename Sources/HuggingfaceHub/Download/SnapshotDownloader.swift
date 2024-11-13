//
//  SnapshotDownloader.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/12.
//

import Foundation

public class SnapshotDownloader {
    struct Options {
        let repoType: RepoType?
        let revision: String?
        let cacheDir: URL?
        let localDir: URL?
        let libraryName: String?
        let libraryVersion: String?
        let userAgent: [String: String]?
        let proxies: [String: String]?
        let etagTimeout: Float
        let forceDownload: Bool
        let token: String?
        let localFilesOnly: Bool
        let allowPatterns: [String]?
        let ignorePatterns: [String]?
        let maxWorkers: Int
        let headers: [String: String]?
        let endpoint: String?
        
        init(
            repoType: RepoType? = nil,
            revision: String? = nil,
            cacheDir: URL? = nil,
            localDir: URL? = nil,
            libraryName: String? = nil,
            libraryVersion: String? = nil,
            userAgent: [String: String]? = nil,
            proxies: [String: String]? = nil,
            etagTimeout: Float = 0.0,
            forceDownload: Bool = false,
            token: String? = nil,
            localFilesOnly: Bool = false,
            allowPatterns: [String]? = nil,
            ignorePatterns: [String]? = nil,
            maxWorkers: Int = 8,
            headers: [String: String]? = nil,
            endpoint: String? = nil
        ) {
            self.repoType = repoType
            self.revision = revision
            self.cacheDir = cacheDir
            self.localDir = localDir
            self.libraryName = libraryName
            self.libraryVersion = libraryVersion
            self.userAgent = userAgent
            self.proxies = proxies
            self.etagTimeout = etagTimeout
            self.forceDownload = forceDownload
            self.token = token
            self.localFilesOnly = localFilesOnly
            self.allowPatterns = allowPatterns
            self.ignorePatterns = ignorePatterns
            self.maxWorkers = maxWorkers
            self.headers = headers
            self.endpoint = endpoint
        }
    }
    
    let repoId: String
    let options: Options
    
    init(repoId: String, options: Options = .init()) {
        self.repoId = repoId
        self.options = options
    }
    
    func download() async throws -> URL {
        var cacheDir: URL = options.cacheDir ?? URL(fileURLWithPath: Constants.hfHubCache.expandingTildeInPath).standardized
        
        var revision: String = options.revision ?? Constants.defaultRevision
        
        var repoType: RepoType = options.repoType ?? .model
        
        var storageFolder = cacheDir.appendingPathComponent(repoFolderName(repoId: repoId, repoType: repoType))
        
        fatalError()
    }
    
    private func repoFolderName(repoId: String, repoType: RepoType) -> String {
        "\(repoType)s\(Constants.repoIdSeparator)\(repoId.replacingOccurrences(of: "/", with: Constants.repoIdSeparator))"
    }
}
