# Swift HuggingfaceHub

The Swift client for the Huggingface Hub.

> Swift Package to implement a [huggingface_hub](https://github.com/huggingface/huggingface_hub) API in Swift.

## Features [🚧 WIP]

> `huggingface_hub` Documentation (Python): https://huggingface.co/docs/huggingface_hub

- [x] Download files from the Hub
- [ ] Upload files to the Hub
- [ ] Command Line Interface (CLI)
    - [x] download
    - [ ] upload
    - [ ] repo-files
    - [ ] env
    - [ ] login
    - [ ] auth
    - [ ] repo
    - [ ] lfs-enable-largefiles
    - [x] scan-cache
    - [ ] delete-cache
    - [ ] tag
    - [ ] version
    - [ ] upload-large-folder
- [ ] Interact with the Hub through the Filesystem API
- [ ] Create and manage a repository
- [ ] Search the Hub
- [ ] Run Inference on servers
- [ ] Inference Endpoints
- [ ] Interact with Discussions and Pull Requests
- [ ] Collections
- [x] Manage huggingface_hub cache-system
- [ ] Create and share Model Cards
- [ ] Manage your Space
- [ ] Integrate any ML framework with the Hub
- [ ] Webhooks

## Swift Package Manager

```swift
let package = Package(
  dependencies: [
      .package(url: "https://github.com/johnmai-dev/HuggingfaceHub.git", from: "main")
  ],
  targets: [
      .target(name: "YourTarget", dependencies: ["HuggingfaceHub"])
  ]
)
```

## Command Line Interface (CLI)

### Build the CLI

```bash
swift build -c release

# Or Makefile command
# make build-release
```

cli executable will be located in `.build/release/huggingface-cli`

### Usage

#### Scan Cache

```bash
huggingface-cli scan-cache
```

#### Download

```bash
huggingface-cli download <model-name>
```