//
//  TransformersInfo.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/13.
//


struct TransformersInfo: Codable {
        let autoModel: String
        let customClass: String?
        let pipelineTag: String?
        let processor: String?

        enum CodingKeys: String, CodingKey {
            case autoModel = "auto_model"
            case customClass = "custom_class"
            case pipelineTag = "pipeline_tag"
            case processor
        }
    }