//
//  CacheManagerError.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/12.
//

import Foundation

public enum CacheManagerError: Error, LocalizedError {
    case notFound(URL)
    case corrupted(String)

    var errorDescription: String {
        switch self {
        case .notFound(let url):
            "Cache directory not found or not a directory: \(url.path). Please use `cacheDir` argument or set `HF_HUB_CACHE` environment variable."
        case .corrupted(let message):
            message
        }
    }
}
