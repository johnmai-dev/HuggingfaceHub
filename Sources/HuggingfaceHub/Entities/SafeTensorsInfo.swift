//
//  SafeTensorsInfo.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/13.
//

public struct SafeTensorsInfo: Codable {
    public let parameters: [String: Int]
    public let total: Int
}
