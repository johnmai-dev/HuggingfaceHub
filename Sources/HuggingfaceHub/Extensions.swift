//
//  Extensions.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/11.
//

import Foundation
extension String {
    func appendingPathComponent(_ str: String) -> String {
        (self as NSString).appendingPathComponent(str)
    }

    var expandingTildeInPath: String {
        (self as NSString).expandingTildeInPath
    }
}

extension URL {
    func exists() -> Bool {
        FileManager.default.fileExists(atPath: self.path)
    }

    func isDirectory() -> Bool {
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: self.path, isDirectory: &isDir) && isDir.boolValue
    }

    func isFile() -> Bool {
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: self.path, isDirectory: &isDir) && !isDir.boolValue
    }
}
