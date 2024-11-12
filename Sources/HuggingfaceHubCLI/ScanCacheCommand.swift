//
//  ScanCacheCommand.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/12.
//
import ArgumentParser
import Foundation
import HuggingfaceHub

struct ScanCacheCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "scan-cache",
        abstract: "Scan cache directory."
    )
    
    @Option(name: .long, help: "cache directory to scan (optional). Default to the default HuggingFace cache.")
    var dir: String?
    
    @Flag(name: .shortAndLong, help: "show a more verbose output")
    var verbose = false
    
    func run() throws {
        let start = Date()
        let hfCacheInfo = try CacheManager().scanCacheDir()
        
        printHFCacheInfoAsTable(hfCacheInfo)
        printSummary(hfCacheInfo, duration: Date().timeIntervalSince(start))
    }
    
    // MARK: - Private Methods
    
    private func printHFCacheInfoAsTable(_ hfCacheInfo: HFCacheInfo) {
        print(createTable(for: hfCacheInfo))
    }
    
    private func createTable(for hfCacheInfo: HFCacheInfo) -> String {
        let headers = verbose ? verboseHeaders : standardHeaders
        let rows = verbose ? createVerboseRows(from: hfCacheInfo) : createStandardRows(from: hfCacheInfo)
        return tabulate(rows: rows, headers: headers)
    }
    
    private func printSummary(_ hfCacheInfo: HFCacheInfo, duration: TimeInterval) {
        let roundedDuration = (duration * 10).rounded() / 10
        print("\nDone in \(roundedDuration)s. Scanned \(hfCacheInfo.repos.count) repo(s) for a total of \(ANSI.red(hfCacheInfo.sizeOnDiskStr)).")
        
        guard !hfCacheInfo.warnings.isEmpty else { return }
        
        let warningCount = hfCacheInfo.warnings.count
        let message = "Got \(warningCount) warning(s) while scanning."
        
        if verbose {
            print(ANSI.gray(message))
            hfCacheInfo.warnings.forEach { print(ANSI.gray($0.localizedDescription)) }
        } else {
            print(ANSI.gray(message + " Use -v to print details."))
        }
    }
}

// MARK: - Table Generation

private extension ScanCacheCommand {
    var standardHeaders: [String] {
        ["REPO ID", "REPO TYPE", "SIZE ON DISK", "NB FILES", "LAST_ACCESSED",
         "LAST_MODIFIED", "REFS", "LOCAL PATH"]
    }
    
    var verboseHeaders: [String] {
        ["REPO ID", "REPO TYPE", "REVISION", "SIZE ON DISK", "NB FILES",
         "LAST_MODIFIED", "REFS", "LOCAL PATH"]
    }
    
    func createStandardRows(from hfCacheInfo: HFCacheInfo) -> [[String]] {
        hfCacheInfo.repos
            .sorted { $0.repoPath.lastPathComponent < $1.repoPath.lastPathComponent }
            .map { repo in
                [
                    repo.repoId,
                    repo.repoType.rawValue,
                    repo.sizeOnDiskStr.leftPadding(toLength: 12),
                    String(format: "%8d", repo.nbFiles),
                    repo.lastAccessedStr,
                    repo.lastModifiedStr,
                    repo.refs.keys.sorted().joined(separator: ", "),
                    repo.repoPath.path
                ]
            }
    }
    
    func createVerboseRows(from hfCacheInfo: HFCacheInfo) -> [[String]] {
        hfCacheInfo.repos
            .sorted { $0.repoPath.lastPathComponent < $1.repoPath.lastPathComponent }
            .flatMap { repo in
                repo.revisions
                    .sorted { $0.commitHash < $1.commitHash }
                    .map { revision in
                        [
                            repo.repoId,
                            repo.repoType.rawValue,
                            revision.commitHash,
                            revision.sizeOnDiskStr.leftPadding(toLength: 12),
                            String(format: "%8d", revision.nbFiles),
                            revision.lastModifiedStr,
                            revision.refs.sorted().joined(separator: ", "),
                            revision.snapshotPath.path
                        ]
                    }
            }
    }
    
    func tabulate(rows: [[String]], headers: [String]) -> String {
        let colWidths = calculateColumnWidths(rows: rows, headers: headers)
        return generateTableString(rows: rows, headers: headers, colWidths: colWidths)
    }
    
    private func calculateColumnWidths(rows: [[String]], headers: [String]) -> [Int] {
        zip(headers, 0 ..< headers.count).map { header, col in
            max(
                header.count,
                rows.map { String(describing: $0[col]).count }.max() ?? 0
            )
        }
    }
    
    private func generateTableString(rows: [[String]], headers: [String], colWidths: [Int]) -> String {
        let headerRow = formatRow(headers, colWidths)
        let separator = formatRow(colWidths.map { String(repeating: "-", count: $0) }, colWidths)
        let dataRows = rows.map { formatRow($0, colWidths) }
        
        return ([headerRow, separator] + dataRows).joined(separator: "\n")
    }
    
    private func formatRow(_ items: [String], _ widths: [Int]) -> String {
        zip(items, widths)
            .map { $0.padding(toLength: $1, withPad: " ", startingAt: 0) }
            .joined(separator: " ")
    }
}
