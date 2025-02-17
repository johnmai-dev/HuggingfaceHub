//
//  String+Ext.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/12/6.
//

import Foundation

extension String {
    func asURL() -> URL? {
        URL(string: self)
    }
}
