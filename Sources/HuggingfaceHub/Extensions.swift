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

extension JSONDecoder.DateDecodingStrategy {
//    "2024-03-01T08:47:23.000Z"
    static let iso8601withFractionalSeconds = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = formatter.date(from: string) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        }
        return date
    }
}
