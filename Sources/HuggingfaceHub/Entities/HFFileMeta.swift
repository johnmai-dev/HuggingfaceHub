//
//  HfFileMeta.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/16.
//

import Foundation

struct HFFileMeta {
    let commitHash: String?
    let etag: String?
    let location: URL
    let size: Int?
}
