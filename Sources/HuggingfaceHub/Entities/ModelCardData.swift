//
//  ModelCardData.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/13.
//

public struct ModelCardData: Codable {
    public let baseModel: FlexibleValue<String>?
    public let datasets: FlexibleValue<String>?
    public let language: FlexibleValue<String>?
    public let libraryName: String?
    public let license: String?
    public let licenseName: String?
    public let licenseLink: String?
    public let metrics: [String]?
    public let modelName: String?
    public let pipelineTag: String?
    public let tags: [String]?

    public enum CodingKeys: String, CodingKey {
        case baseModel = "base_model"
        case datasets
        case language
        case libraryName = "library_name"
        case license
        case licenseName = "license_name"
        case licenseLink = "license_link"
        case metrics
        case modelName = "model_name"
        case pipelineTag = "pipeline_tag"
        case tags
    }
}
