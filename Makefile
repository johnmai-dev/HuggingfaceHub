# Description: Makefile for the Huggingface CLI

# Build the CLI
build:
	swift build

# Build the CLI in release mode
build-release:
	swift build -c release

# Run the CLI
run:
	swift run huggingface-cli

# Run the CLI with the `scan-cache` command
run-scan-cache:
	swift run huggingface-cli scan-cache

# Run the CLI with the `scan-cache` command and the `--verbose` flag
run-scan-cache-verbose:
	swift run huggingface-cli scan-cache --verbose