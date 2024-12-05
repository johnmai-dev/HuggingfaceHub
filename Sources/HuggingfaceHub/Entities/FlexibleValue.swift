//
//  FlexibleValue.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/12/2.
//
import Foundation

/// A generic enum to handle both single and array values of the same type
public enum FlexibleValue<T: Codable>: Codable {
    case single(T)
    case array([T])
    
    // MARK: - Computed Properties
    
    /// Returns the single value if available
    public var singleValue: T? {
        if case .single(let value) = self {
            return value
        }
        return nil
    }
    
    /// Returns the array value if available
    public var arrayValue: [T]? {
        if case .array(let value) = self {
            return value
        }
        return nil
    }
    
    // MARK: - Codable Implementation
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let singleValue = try? container.decode(T.self) {
            self = .single(singleValue)
            return
        }
        
        if let arrayValue = try? container.decode([T].self) {
            self = .array(arrayValue)
            return
        }
        
        throw DecodingError.typeMismatch(
            FlexibleValue<T>.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected either single value of type \(T.self) or array of \(T.self)"
            )
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .single(let value):
            try container.encode(value)
        case .array(let array):
            try container.encode(array)
        }
    }
}
