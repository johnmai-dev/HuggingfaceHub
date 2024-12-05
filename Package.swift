// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HuggingfaceHub",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HuggingfaceHub",
            targets: ["HuggingfaceHub"]
        ),
        .executable(name: "huggingface-cli", targets: ["HuggingfaceHubCLI"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.3.0"
        ),
        .package(
            url: "https://github.com/Flight-School/AnyCodable",
            from: "0.6.0"
        ),
        .package(
            url: "https://github.com/Alamofire/Alamofire.git",
            .upToNextMajor(from: "5.10.0")
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HuggingfaceHub",
            dependencies: [
                "AnyCodable",
                .product(name: "Alamofire", package: "Alamofire")
            ]
        ),
        .testTarget(
            name: "HuggingfaceHubTests",
            dependencies: [
                "HuggingfaceHub",
            ]
        ),
        .executableTarget(
            name: "HuggingfaceHubCLI",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                "HuggingfaceHub",
            ]
        ),
    ]
)
