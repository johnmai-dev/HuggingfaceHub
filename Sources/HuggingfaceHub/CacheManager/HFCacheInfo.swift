//
//  HFCacheInfo.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/11.
//

import Foundation

public struct HFCacheInfo {
    public let sizeOnDisk: Int
    public let repos: Set<CachedRepoInfo>
    public let warnings: [CacheManager.CorruptedError]

    public var sizeOnDiskStr: String {
        return ByteCountFormatter.string(fromByteCount: Int64(sizeOnDisk), countStyle: .file)
    }
}
