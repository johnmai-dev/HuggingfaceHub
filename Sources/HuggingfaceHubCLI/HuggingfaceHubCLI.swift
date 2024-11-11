
//
//  HuggingfaceHubCLI.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/12.
//
import ArgumentParser

@main
struct HuggingfaceHubCLI: ParsableCommand {
    @Flag(help: "Include a counter with each repetition.")
        var includeCounter = false

        @Option(name: .shortAndLong, help: "The number of times to repeat 'phrase'.")
        var count: Int? = nil

        @Argument(help: "The phrase to repeat.")
        var phrase: String

        mutating func run() throws {
            let repeatCount = count ?? 2

            for i in 1...repeatCount {
                if includeCounter {
                    print("\(i): \(phrase)")
                } else {
                    print(phrase)
                }
            }
        }
}
