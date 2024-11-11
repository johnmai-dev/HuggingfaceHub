//
//  CachedRevisionInfo.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/11.
//

import Foundation

struct CachedRevisionInfo {
    let commitHash: String
    let snapshotPath: URL
    let sizeOnDisk: Int
    let files: Set<CachedFileInfo>
    let refs: Set<String>
    let lastModified: TimeInterval

    var lastModifiedStr: String {
        return ""
    }

    var sizeOnDiskStr: String {
        return ""
    }

    var nbFiles: Int {
        return files.count
    }
}

extension CachedRevisionInfo: Hashable {
}
