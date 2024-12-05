//
//  Utility.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/12.
//

import Foundation

public enum Utility {
    static func fileSizeFormatter(_ bytes: Int) -> String {
        let units = ["", "K", "M", "G", "T", "P", "E", "Z"]
        var size = Double(bytes)
        
        for unit in units {
            if abs(size) < 1000.0 {
                return String(format: "%.1f%@", size, unit)
            }
            size /= 1000.0
        }
        
        return String(format: "%.1f%@", size, "Y")
    }
    
    static func filterRepoObjects(
        items: [String],
        allowPatterns: [String]? = nil,
        ignorePatterns: [String]? = nil,
        key: ((String) -> String)? = nil
    ) -> [String] {
        let allowPatterns = allowPatterns?.map(addWildcardToDirectories)
        let ignorePatterns = ignorePatterns?.map(addWildcardToDirectories)
        
        return items.filter { item in
            let path = key?(item) ?? item
            
            if let allowPatterns, !allowPatterns.contains(where: { fnmatch($0, path) }) {
                return false
            }
            
            if let ignorePatterns, ignorePatterns.contains(where: { fnmatch($0, path) }) {
                return false
            }
            
            return true
        }
    }
    
    static func addWildcardToDirectories(_ pattern: String) -> String {
        pattern.hasSuffix("/") ? pattern + "*" : pattern
    }
    
    static func fnmatch(_ pattern: String, _ string: String) -> Bool {
        NSPredicate(format: "self LIKE %@", pattern).evaluate(with: string)
    }
    
    static var swiftVersion: String {
#if swift(>=6.0)
        return "6.0"
#elseif swift(>=5.9)
        return "5.10"
#elseif swift(>=5.9)
        return "5.9"
#elseif swift(>=5.8)
        return "5.8"
#elseif swift(>=5.7)
        return "5.7"
#elseif swift(>=5.6)
        return "5.6"
#elseif swift(>=5.5)
        return "5.5"
#endif
        return "unknown or less than 5.5"
    }
}
