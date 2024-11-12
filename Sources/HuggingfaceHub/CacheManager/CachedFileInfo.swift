//
//  CachedFileInfo.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/11.
//

import Foundation

public struct CachedFileInfo {
    let fileName: String
    let filePath: URL
    let blobPath: URL
    let sizeOnDisk: Int
    let blobLastAccessed: TimeInterval
    let blobLastModified: TimeInterval

    var blobLastAccessedStr: String {
        Date(timeIntervalSince1970: blobLastAccessed).timeAgoDisplay()
    }

    var blobLastModifiedStr: String {
        Date(timeIntervalSince1970: blobLastModified).timeAgoDisplay()
    }

    var sizeOnDiskStr: String {
        ByteCountFormatter.string(fromByteCount: Int64(sizeOnDisk), countStyle: .file)
    }
}

extension CachedFileInfo: Hashable {}
