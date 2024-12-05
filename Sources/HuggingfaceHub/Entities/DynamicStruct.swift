//
//  DynamicStruct.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/12/2.
//

import Foundation

@dynamicMemberLookup
public struct DynamicStruct {
    public private(set) var dictionary: [String: Any]

    public init(_ dictionary: [String: Any]) {
        self.dictionary = dictionary
    }

    func camelCase(_ string: String) -> String {
        string
            .split(separator: "_")
            .enumerated()
            .map { $0.offset == 0 ? $0.element.lowercased() : $0.element.capitalized }
            .joined()
    }

    func uncamelCase(_ string: String) -> String {
        let scalars = string.unicodeScalars
        var result = ""

        var previousCharacterIsLowercase = false
        for scalar in scalars {
            if CharacterSet.uppercaseLetters.contains(scalar) {
                if previousCharacterIsLowercase {
                    result += "_"
                }
                let lowercaseChar = Character(scalar).lowercased()
                result += lowercaseChar
                previousCharacterIsLowercase = false
            } else {
                result += String(scalar)
                previousCharacterIsLowercase = true
            }
        }

        return result
    }

    public subscript(dynamicMember member: String) -> DynamicStruct? {
        let key = dictionary[member] != nil ? member : uncamelCase(member)
        if let value = dictionary[key] as? [String: Any] {
            return DynamicStruct(value)
        } else if let value = dictionary[key] {
            return DynamicStruct(["value": value])
        }
        return nil
    }

    public var value: Any? {
        dictionary["value"]
    }

    public var intValue: Int? { value as? Int }
    public var boolValue: Bool? { value as? Bool }
    public var stringValue: String? { value as? String }

    public var arrayValue: [DynamicStruct]? {
        guard let list = value as? [Any] else { return nil }
        return list.map { DynamicStruct($0 as! [String: Any]) }
    }
}
