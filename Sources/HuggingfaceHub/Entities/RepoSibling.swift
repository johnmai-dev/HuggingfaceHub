//
//  RepoSibling.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/13.
//

public struct RepoSibling: Codable {
    let rfilename: String
    let size: Int?
    let blobId: String?
    let lfs: BlobLfsInfo?

    enum CodingKeys: String, CodingKey {
        case rfilename
        case size
        case blobId
        case lfs
    }
}
