//
//  ANSI.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/12.
//

import Foundation

public class ANSI {
    private static let bold = "\u{001B}[1m"
    private static let gray = "\u{001B}[90m"
    private static let red = "\u{001B}[31m"
    private static let reset = "\u{001B}[0m"
    private static let yellow = "\u{001B}[33m"

    public static func bold(_ s: String) -> String {
        format(s, with: bold)
    }

    public static func gray(_ s: String) -> String {
        format(s, with: gray)
    }

    public static func red(_ s: String) -> String {
        format(s, with: bold + red)
    }

    public static func yellow(_ s: String) -> String {
        format(s, with: yellow)
    }

    private static func format(_ s: String, with code: String) -> String {
        if ProcessInfo.processInfo.environment["NO_COLOR"] != nil {
            return s
        }
        return "\(code)\(s)\(reset)"
    }
}
