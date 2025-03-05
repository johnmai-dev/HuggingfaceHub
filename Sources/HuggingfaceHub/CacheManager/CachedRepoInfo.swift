//
//  CachedRepoInfo.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/11.
//

import Foundation

public struct CachedRepoInfo {
    public let repoId: String
    public let repoType: RepoType
    public let repoPath: URL
    public let sizeOnDisk: Int
    public let nbFiles: Int
    public let revisions: Set<CachedRevisionInfo>
    public let lastAccessed: TimeInterval
    public let lastModified: TimeInterval

    public var lastAccessedStr: String {
        Date(timeIntervalSince1970: lastAccessed).timeAgoDisplay()
    }

    public var lastModifiedStr: String {
        Date(timeIntervalSince1970: lastModified).timeAgoDisplay()
    }

    public var sizeOnDiskStr: String {
        ByteCountFormatter.string(fromByteCount: Int64(sizeOnDisk), countStyle: .file)
    }

    public var refs: [String: CachedRevisionInfo] {
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
extension CachedRepoInfo: Identifiable {
    public var id: String {
        repoId
    }
}
