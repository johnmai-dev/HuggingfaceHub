//
//  WeakFileLock.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2025/2/17.
//

import Foundation

public enum WeakFileLockError: Error, LocalizedError {
    case timeout

    public var errorDescription: String? {
        switch self {
        case .timeout:
            return "Timeout while waiting to acquire lock"
        }
    }
}

final class WeakFileLock {
    private let lockPath: String
    private let lock: NSDistributedLock?
    private let timeout: TimeInterval?
    private let logInterval: TimeInterval = 10

    init(lockPath: String, timeout: TimeInterval?) {
        self.lockPath = lockPath
        self.lock = NSDistributedLock(path: lockPath)
        self.timeout = timeout
    }

    init(lockPath: String) {
        self.lockPath = lockPath
        self.lock = NSDistributedLock(path: lockPath)
        self.timeout = nil
    }

    func acquire() async throws {
        let start = Date()
        while true {
            let elapsed = Date().timeIntervalSince(start)
            if let timeout, elapsed >= timeout {
                throw WeakFileLockError.timeout
            }

            if lock?.try() == true {
                return
            }

            NSLog(
                "Still waiting to acquire lock on \(lockPath) (elapsed: \(String(format: "%.1f", Date().timeIntervalSince(start))) seconds)"
            )

            let nextTimeout: TimeInterval =
                if let timeout = timeout {
                    min(logInterval, timeout - elapsed)
                } else {
                    logInterval
                }

            try await Task.sleep(nanoseconds: UInt64(nextTimeout * 1_000_000_000))
        }
    }

    func release() {
        lock?.unlock()

        try? FileManager.default.removeItem(atPath: lockPath)
    }
}
