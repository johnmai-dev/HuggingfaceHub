//
//  BlobLfsInfo.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/13.
//

struct BlobLfsInfo: Codable {
    let size: Int
    let sha256: String
    let pointerSize: Int

    enum CodingKeys: String, CodingKey {
        case size
        case sha256
        case pointerSize
    }
}
