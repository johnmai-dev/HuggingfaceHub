//
//  CachedRevisionInfo.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/11.
//

import Foundation

public struct CachedRevisionInfo {
    public let commitHash: String
    public let snapshotPath: URL
    public let sizeOnDisk: Int
    public let files: Set<CachedFileInfo>
    public let refs: Set<String>
    public let lastModified: TimeInterval

    public var lastModifiedStr: String {
        Date(timeIntervalSince1970: lastModified).timeAgoDisplay()
    }

    public var sizeOnDiskStr: String {
        ByteCountFormatter.string(fromByteCount: Int64(sizeOnDisk), countStyle: .file)
    }

    public var nbFiles: Int {
        files.count
    }
}

extension CachedRevisionInfo: Hashable {}
