//
//  ModelInfo.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/13.
//

import AnyCodable
import Foundation

public struct ModelInfo: Codable {
    let id: String
    let author: String?
    let sha: String?
    let createdAt: Date?
    let lastModified: Date?
    let isPrivate: Bool?
    let isDisabled: Bool?
    let downloads: Int?
    let downloadsAllTime: Int?
    let gated: GatedStatus?
    let gguf: [String: Any]?
    let inference: InferenceStatus?
    let likes: Int?
    let libraryName: String?
    let tags: [String]?
    let pipelineTag: String?
    let maskToken: String?
    let cardData: ModelCardData?
    let widgetData: [WidgetData]?
    let modelIndex: [String: Any]?
    let config: [String: Any]?
    let transformersInfo: TransformersInfo?
    let trendingScore: Int?
    let siblings: [RepoSibling]?
    let spaces: [String]?
    let safetensors: SafeTensorsInfo?
    let securityRepoStatus: [String: Any]?

    struct GenericResponse<T: Codable>: Codable {
        let value: T?

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            value = try? container.decode(T.self)
        }
    }

    enum GatedStatus: String, Codable {
        case auto
        case manual
        case disabled = "false"

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let boolValue = try? container.decode(Bool.self) {
                self = boolValue ? .manual : .disabled
            } else if let stringValue = try? container.decode(String.self) {
                switch stringValue.lowercased() {
                case "auto":
                    self = .auto
                case "manual":
                    self = .manual
                default:
                    self = .disabled
                }
            } else {
                self = .disabled
            }
        }
    }

    enum InferenceStatus: String, Codable {
        case warm
        case cold
        case frozen
    }

    enum CodingKeys: String, CodingKey {
        case id
        case author
        case sha
        case createdAt
        case lastModified
        case isPrivate = "private"
        case isDisabled = "disabled"
        case downloads
        case downloadsAllTime
        case gated
        case gguf
        case inference
        case likes
        case libraryName = "library_name"
        case tags
        case pipelineTag = "pipeline_tag"
        case maskToken = "mask_token"
        case cardData
        case widgetData
        case modelIndex = "model-index"
        case config
        case transformersInfo
        case trendingScore
        case siblings
        case spaces
        case safetensors
        case securityRepoStatus
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        author = try container.decodeIfPresent(String.self, forKey: .author)
        sha = try container.decodeIfPresent(String.self, forKey: .sha)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        lastModified = try container.decodeIfPresent(Date.self, forKey: .lastModified)
        isPrivate = try container.decodeIfPresent(Bool.self, forKey: .isPrivate)
        isDisabled = try container.decodeIfPresent(Bool.self, forKey: .isDisabled)
        downloads = try container.decodeIfPresent(Int.self, forKey: .downloads)
        downloadsAllTime = try container.decodeIfPresent(Int.self, forKey: .downloadsAllTime)
        gated = try container.decodeIfPresent(GatedStatus.self, forKey: .gated)
        gguf = try container.decodeIfPresent([String: AnyDecodable].self, forKey: .gguf)
        inference = try container.decodeIfPresent(InferenceStatus.self, forKey: .inference)
        likes = try container.decodeIfPresent(Int.self, forKey: .likes)
        libraryName = try container.decodeIfPresent(String.self, forKey: .libraryName)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        pipelineTag = try container.decodeIfPresent(String.self, forKey: .pipelineTag)
        maskToken = try container.decodeIfPresent(String.self, forKey: .maskToken)
        cardData = try container.decodeIfPresent(ModelCardData.self, forKey: .cardData)
        widgetData = try container.decodeIfPresent([WidgetData].self, forKey: .widgetData)
        modelIndex = try container.decodeIfPresent([String: AnyDecodable].self, forKey: .modelIndex)
        config = try container.decodeIfPresent([String: AnyDecodable].self, forKey: .config)
        transformersInfo = try container.decodeIfPresent(TransformersInfo.self, forKey: .transformersInfo)
        trendingScore = try container.decodeIfPresent(Int.self, forKey: .trendingScore)
        siblings = try container.decodeIfPresent([RepoSibling].self, forKey: .siblings)
        spaces = try container.decodeIfPresent([String].self, forKey: .spaces)
        safetensors = try container.decodeIfPresent(SafeTensorsInfo.self, forKey: .safetensors)
        securityRepoStatus = try container.decodeIfPresent([String: AnyDecodable].self, forKey: .securityRepoStatus)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(author, forKey: .author)
        try container.encode(sha, forKey: .sha)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(lastModified, forKey: .lastModified)
        try container.encode(isPrivate, forKey: .isPrivate)
        try container.encode(isDisabled, forKey: .isDisabled)
        try container.encode(downloads, forKey: .downloads)
        try container.encode(downloadsAllTime, forKey: .downloadsAllTime)
        try container.encode(gated, forKey: .gated)
        try container.encode(AnyEncodable(gguf), forKey: .gguf)
        try container.encode(inference, forKey: .inference)
        try container.encode(likes, forKey: .likes)
        try container.encode(libraryName, forKey: .libraryName)
        try container.encode(tags, forKey: .tags)
        try container.encode(pipelineTag, forKey: .pipelineTag)
        try container.encode(maskToken, forKey: .maskToken)
        try container.encode(cardData, forKey: .cardData)
        try container.encode(widgetData, forKey: .widgetData)
        try container.encode(AnyEncodable(modelIndex), forKey: .modelIndex)
        try container.encode(AnyEncodable(config), forKey: .config)
        try container.encode(transformersInfo, forKey: .transformersInfo)
        try container.encode(trendingScore, forKey: .trendingScore)
        try container.encode(siblings, forKey: .siblings)
        try container.encode(spaces, forKey: .spaces)
        try container.encode(safetensors, forKey: .safetensors)
        try container.encode(AnyEncodable(securityRepoStatus), forKey: .securityRepoStatus)
    }
}
