//
//  CachedRepoInfo.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/11.
//

import Foundation

public struct CachedRepoInfo {
    let repoId: String
    let repoType: RepoType
    let repoPath: URL
    let sizeOnDisk: Int
    let nbFiles: Int
    let revisions: Set<CachedRevisionInfo>
    let lastAccessed: TimeInterval
    let lastModified: TimeInterval

    var lastAccessedStr: String {
        ""
    }

    var lastModifiedStr: String {
        ""
    }

    var sizeOnDiskStr: String {
        ""
    }

    var refs: [String: CachedRevisionInfo] {
        var refsDict = [String: CachedRevisionInfo]()
        for revision in revisions {
            for ref in revision.refs {
                refsDict[ref] = revision
            }
        }
        return refsDict
    }
}

extension CachedRepoInfo: Hashable {}


