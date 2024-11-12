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

    public func leftPadding(toLength: Int, withPad character: Character = " ") -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
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

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "en_US")
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
