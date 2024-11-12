//
//  Utility.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/12.
//

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
}
