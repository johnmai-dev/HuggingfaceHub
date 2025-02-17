//
//  TimeInterval+Extensions.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2025/2/18.
//

import Foundation

extension TimeInterval {
    func formattedDuration() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        if self >= 3600 {
            formatter.allowedUnits = [.hour, .minute, .second]
        } else {
            formatter.allowedUnits = [.minute, .second]
        }
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self) ?? "00:00"
    }
}
