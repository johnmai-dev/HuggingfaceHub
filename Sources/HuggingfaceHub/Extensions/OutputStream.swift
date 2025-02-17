//
//  OutputStream.swift
//  HuggingfaceHub
//  Source: https://stackoverflow.com/questions/68276940/how-to-get-the-download-progress-with-the-new-try-await-urlsession-shared-downlo
//  Created by John Mai on 2024/12/3.
//

import Foundation

extension OutputStream {

    /// Write `Data` to `OutputStream`
    ///
    /// - parameter data:                  The `Data` to write.

    func write(_ data: Data) throws {
        try data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws in
            guard var pointer = buffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(EINVAL), userInfo: nil)
            }

            var bytesRemaining = buffer.count

            while bytesRemaining > 0 {
                let bytesWritten = write(pointer, maxLength: bytesRemaining)
                if bytesWritten < 0 {
                    throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: nil)
                }

                bytesRemaining -= bytesWritten
                pointer += bytesWritten
            }
        }
    }
}
