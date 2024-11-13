//
//  ModelCardData.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/13.
//


struct ModelCardData: Codable {
        let baseModel: String?
        let datasets: [String]?
        let evalResults: [EvalResult]?
        let language: [String]?
        let libraryName: String?
        let license: String?
        let licenseName: String?
        let licenseLink: String?
        let metrics: [String]?
        let modelName: String?
        let pipelineTag: String?
        let tags: [String]?

        enum CodingKeys: String, CodingKey {
            case baseModel = "base_model"
            case datasets
            case evalResults = "eval_results"
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
