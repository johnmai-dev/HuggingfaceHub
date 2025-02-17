//
//  RepoInfoType.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/13.
//

import Foundation

public protocol RepoInfoType {
    var sha: String? { get }
    var siblings: [RepoSibling]? { get }
}
