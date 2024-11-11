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
        ""
    }

    var blobLastModifiedStr: String {
        ""
    }

    var sizeOnDiskStr: String {
        ""
    }
}

extension CachedFileInfo: Hashable {}
