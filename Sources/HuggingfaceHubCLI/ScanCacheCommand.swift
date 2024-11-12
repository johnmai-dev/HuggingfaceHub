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
    static let configuration: CommandConfiguration = .init(
        commandName: "scan-cache",
        abstract: "Scan cache directory."
    )

    @Option(name: .long, help: "cache directory to scan (optional). Default to the default HuggingFace cache.")
    var dir: String?

    @Flag(name: .shortAndLong, help: "show a more verbose output")
    var verbose = false

    mutating func run() throws {
        let start = Date()

        let manager = try CacheManager()
        let hfCacheInfo = try manager.scanCacheDir()
        let end = Date()

        printHFCacheInfoAsTable(hfCacheInfo: hfCacheInfo)

        let duration = end.timeIntervalSince(start)

        print("\nDone in \(round(duration * 10) / 10)s. Scanned \(hfCacheInfo.repos.count) repo(s) for a total of \(hfCacheInfo.sizeOnDiskStr).")

        if !hfCacheInfo.warnings.isEmpty {
            let message = "Got \(hfCacheInfo.warnings.count) warning(s) while scanning."
            if verbose {
                print(ANSI.gray(message))
                for warning in hfCacheInfo.warnings {
                    print(ANSI.gray(warning.localizedDescription))
                }
            } else {
                print(ANSI.gray(message + " Use -v to print details."))
            }
        }
    }

    private func printHFCacheInfoAsTable(hfCacheInfo: HFCacheInfo) {
        print(getTable(hfCacheInfo: hfCacheInfo, verbosity: verbose))
    }

    private func getTable(hfCacheInfo: HFCacheInfo, verbosity: Bool = false) -> String {
        if verbosity {
            let rows = hfCacheInfo.repos.sorted { $0.repoPath.lastPathComponent < $1.repoPath.lastPathComponent }.map { repo in
                repo.revisions.sorted { $0.commitHash < $1.commitHash }.map { revision in
                    [
                        repo.repoId,
                        repo.repoType,
                        revision.commitHash,
                        revision.sizeOnDiskStr.leftPadding(toLength: 12),
                        String(format: "%8d", revision.nbFiles),
                        revision.lastModifiedStr,
                        revision.refs.sorted().joined(separator: ", "),
                        revision.snapshotPath.path,
                    ]
                }
            }.flatMap { $0 }

            return tabulate(rows: rows, headers: [
                "REPO ID",
                "REPO TYPE",
                "REVISION",
                "SIZE ON DISK",
                "NB FILES",
                "LAST_MODIFIED",
                "REFS",
                "LOCAL PATH",
            ])
        } else {
            let rows = hfCacheInfo.repos.sorted { $0.repoPath.lastPathComponent < $1.repoPath.lastPathComponent }.map { repo in
                [
                    repo.repoId,
                    repo.repoType,
                    repo.sizeOnDiskStr.leftPadding(toLength: 12),
                    String(format: "%8d", repo.nbFiles),
                    repo.lastAccessedStr,
                    repo.lastModifiedStr,
                    repo.refs.keys.sorted().joined(separator: ", "),
                    repo.repoPath.path,
                ]
            }

            return tabulate(rows: rows, headers: [
                "REPO ID",
                "REPO TYPE",
                "SIZE ON DISK",
                "NB FILES",
                "LAST_ACCESSED",
                "LAST_MODIFIED",
                "REFS",
                "LOCAL PATH",
            ])
        }
    }

    private func formatRow(_ items: [String], _ widths: [Int]) -> String {
        zip(items, widths).map { item, width in
            item.padding(toLength: width, withPad: " ", startingAt: 0)
        }.joined(separator: " ")
    }

    private func tabulate(rows: [[Any]], headers: [String]) -> String {
        let colWidths = zip(headers, (0 ..< headers.count).map { col in
            rows.map { row in String(describing: row[col]).count }
        }).map { header, lengths in
            max(header.count, lengths.max() ?? 0)
        }

        var lines: [String] = []

        lines.append(formatRow(headers, colWidths))

        let separators = colWidths.map { String(repeating: "-", count: $0) }
        lines.append(formatRow(separators, colWidths))

        for row in rows {
            let rowStrings = row.map { String(describing: $0) }
            lines.append(formatRow(rowStrings, colWidths))
        }

        return lines.joined(separator: "\n")
    }
}
