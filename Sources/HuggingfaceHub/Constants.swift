//
//  Constants.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/7.
//

import Foundation

public enum Constants {
    public static let version = "1.0.0"
    
    static let hfDefaultEndpoint = "https://huggingface.co"
    
    static let endpoint = ProcessInfo.processInfo.environment["HF_ENDPOINT"] ?? hfDefaultEndpoint
    
    static let defaultRevision = "main"
    
    static let defaultHome: String = "~/.cache"
    
    static let hfHome: String = ProcessInfo.processInfo.environment["HF_HOME"] ?? (
        ProcessInfo.processInfo.environment["XDG_CACHE_HOME"] ?? defaultHome
    ).appendingPathComponent("huggingface")
    
    static let defaultCache: String = hfHome.appendingPathComponent("hub")
    
    static let huggingFaceHubCache: String = ProcessInfo.processInfo.environment["HUGGINGFACE_HUB_CACHE"] ?? defaultCache
    
    static let hfHubCache: String = ProcessInfo.processInfo.environment["HF_HUB_CACHE"] ?? huggingFaceHubCache
    
    static let filesToIgnore: [String] = [".DS_Store"]
    
    static let repoIdSeparator: String = "--"
    
    static let defaultIgnorePatterns: [String] = [
        ".git",
        ".git/*",
        "*/.git",
        "**/.git/**",
        ".cache/huggingface",
        ".cache/huggingface/*",
        "*/.cache/huggingface",
        "**/.cache/huggingface/**",
    ]
    
    static let forbiddenFolders: [String] = [
        ".git",
        ".cache",
    ]
    
    static let envVarsTrueValues: Set<String> = [
        "1",
        "ON",
        "YES",
        "TRUE",
    ]
    
    static func isTrue(_ value: String?) -> Bool {
        guard let value else { return false }
        return envVarsTrueValues.contains(value.uppercased())
    }
    
    static let hfHubEnableHFTransfer: Bool = isTrue(ProcessInfo.processInfo.environment["HF_HUB_ENABLE_HF_TRANSFER"])
    
    static func asTimeInterval(_ value: String?) -> TimeInterval? {
        guard let value else {
            return nil
        }
        return TimeInterval(value)
    }
    
    static let defaultEtagTimeout: TimeInterval = 10.0
    static let defaultDownloadTimeout: TimeInterval = 10.0
    
    static let hfHubEtagTimeout: TimeInterval = asTimeInterval(ProcessInfo.processInfo.environment["HF_HUB_ETAG_TIMEOUT"]) ?? defaultEtagTimeout
    static let hfHubDownloadTimeout: TimeInterval = asTimeInterval(ProcessInfo.processInfo.environment["HF_HUB_DOWNLOAD_TIMEOUT"]) ?? defaultDownloadTimeout
    
    static func cleanToken(_ token: String?) -> String? {
        guard let token else {
            return nil
        }
        
        let cleaned = token
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned.isEmpty ? nil : cleaned
    }
    
    static let hfHubPath = ProcessInfo.processInfo.environment["HF_TOKEN_PATH"] ?? hfHome.appendingPathComponent("token")
    
    static let hfHubDisableImplicitToken: Bool = isTrue(ProcessInfo.processInfo.environment["HF_HUB_DISABLE_IMPLICIT_TOKEN"])
    
    static let hfHubToken: String? = hfHubDisableImplicitToken ? nil : cleanToken(
        ProcessInfo.processInfo.environment["HF_TOKEN"] ?? ProcessInfo.processInfo.environment["HUGGING_FACE_HUB_TOKEN"]
    ) ?? cleanToken(
        try? String(contentsOfFile: hfHubPath)
    )
    
    static let huggingFaceHeaderXRepoCommit = "X-Repo-Commit"
    static let huggingFaceHeaderXLinkedEtag = "X-Linked-Etag"
    static let huggingFaceHeaderXLinkedSize = "X-Linked-Size"
}
