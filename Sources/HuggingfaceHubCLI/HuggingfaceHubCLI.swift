//
//  HuggingfaceHubCLI.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/12.
//
import ArgumentParser
import Foundation
import HuggingfaceHub

@main
struct HuggingfaceHubCLI: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "huggingface-cli",
        abstract: "huggingface-cli command helpers",
        usage: "huggingface-cli <command> [<args>]",
        version: Constants.version,
        subcommands: [ScanCacheCommand.self, DownloadCommand.self]
    )
}
