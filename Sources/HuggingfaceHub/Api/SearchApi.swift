//
//  SearchApi.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/12.
//

import Foundation

public extension HFApi {
    func modelInfo(repoId: String, options: ModelInfoOptions = .init()) async throws -> ModelInfo {
        if options.expand != nil, options.expand?.isEmpty == false, options.securityStatus == true || options.filesMetadata {
            throw Error.invalidExpandOptions
        }

        let headers = buildHFHeaders(token: options.token)

        var path: String
        if let revision = options.revision {
            let encodedRevision = revision.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? revision
            path = "\(endpoint)/api/models/\(repoId)/revision/\(encodedRevision)"
        } else {
            path = "\(endpoint)/api/models/\(repoId)"
        }

        var urlComponents = URLComponents(string: path)!

        var queryItems: [URLQueryItem] = []
        if options.securityStatus == true {
            queryItems.append(URLQueryItem(name: "securityStatus", value: "true"))
        }

        if options.filesMetadata {
            queryItems.append(URLQueryItem(name: "blobs", value: "true"))
        }

        if options.expand?.isEmpty == false {
            queryItems.append(URLQueryItem(name: "expand", value: options.expand!.map(\.rawValue).joined(separator: ",")))
        }

        urlComponents.queryItems = queryItems

        var request = URLRequest(url: urlComponents.url!)
        request.allHTTPHeaderFields = headers

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200..<300: break
        case 400..<500: throw Error.authenticationError
        default: throw Error.httpStatusCode(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
        
        print(String(data:data, encoding: .utf8)!)

        return try decoder.decode(ModelInfo.self, from: data)
    }
}

public extension HFApi {
    struct ModelInfoOptions {
        let revision: String?
        let timeout: TimeInterval?
        let securityStatus: Bool?
        let filesMetadata: Bool
        let expand: [ExpandModelProperty]?
        let token: String?

        public init(
            revision: String? = nil,
            timeout: TimeInterval? = nil,
            securityStatus: Bool? = nil,
            filesMetadata: Bool = false,
            expand: [ExpandModelProperty]? = nil,
            token: String? = nil
        ) {
            self.revision = revision
            self.timeout = timeout
            self.securityStatus = securityStatus
            self.filesMetadata = filesMetadata
            self.expand = expand
            self.token = token
        }
    }

    enum ExpandModelProperty: String, Codable {
        case author
        case baseModels
        case cardData
        case childrenModelCount
        case config
        case createdAt
        case disabled
        case downloads
        case downloadsAllTime
        case gated
        case gguf
        case inference
        case lastModified
        case libraryName = "library_name"
        case likes
        case maskToken = "mask_token"
        case modelIndex = "model-index"
        case pipelineTag = "pipeline_tag"
        case `private`
        case safetensors
        case sha
        case siblings
        case spaces
        case tags
        case transformersInfo
        case trendingScore
        case widgetData
    }
}
