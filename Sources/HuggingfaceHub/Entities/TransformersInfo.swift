//
//  TransformersInfo.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/13.
//

public struct TransformersInfo: Codable, Sendable {
    public let autoModel: String
    public let customClass: String?
    public let pipelineTag: String?
    public let processor: String?

    public enum CodingKeys: String, CodingKey {
        case autoModel = "auto_model"
        case customClass = "custom_class"
        case pipelineTag = "pipeline_tag"
        case processor
    }
}
