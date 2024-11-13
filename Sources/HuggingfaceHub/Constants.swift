//
//  Constants.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/7.
//

import Foundation

enum Constants {
    static let version = "v1"
    static let endpoint = "https://huggingface.co"
    
    static let defaultRevision = "main"
    
    static let defaultHome: String = "~/.cache"
    
    static var hfHome: String {
        let environment = ProcessInfo.processInfo.environment
        return environment["HF_HOME"] ?? (environment["XDG_CACHE_HOME"] ?? defaultHome).appendingPathComponent("huggingface")
    }
    
    static var defaultCache: String {
        hfHome.appendingPathComponent("hub")
    }
    
    static var huggingFaceHubCache: String {
        ProcessInfo.processInfo.environment["HUGGINGFACE_HUB_CACHE"] ?? defaultCache
    }
    
    static var hfHubCache: String {
        ProcessInfo.processInfo.environment["HF_HUB_CACHE"] ?? huggingFaceHubCache
    }
    
    static let filesToIgnore: [String] = [".DS_Store"]
    
    static let repoIdSeparator: String = "--"
}
