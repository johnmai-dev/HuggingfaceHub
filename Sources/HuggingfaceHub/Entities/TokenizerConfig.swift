//
//  TokenizerConfig.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/13.
//

public struct TokenizerConfig: Codable {
    let bosToken: String?
    let chatTemplate: String
    let eosToken: String
    let padToken: String
    let unkToken: String?
}
