//
//  DeleteCacheStrategy.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/11.
//

import Foundation

struct DeleteCacheStrategy {
    let expectedFreedSize: Int
    let blobs: Set<URL>
    let refs: Set<URL>
    let repos: Set<URL>
    let snapshots: Set<URL>

    var expectedFreedSizeStr: String {
        ByteCountFormatter.string(fromByteCount: Int64(expectedFreedSize), countStyle: .file)
    }

    func execute() {
        
    }
}

