# swift-artifact-parser

## Overview

`ArtifactParser` is a Swift library designed to utilize `.binaryTargets` from an artifact bundle file. This library enables executable targets to run compiled binaries, a capability currently only built for Swift plugins.

## Features

- **Artifact Parsing**: Seamlessly leverage artifact bundles for your Swift executables using the `ArtifactParser` library.
- **Binary Target Integration**: Enhance the functionality and efficiency of your Swift packages by utilizing binary targets.
- **Ease of Use**: Simplified integration with clear, concise documentation to help you get started quickly.

## Installation

To integrate `swift-artifact-parser` into your project, add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/21-DOT-DEV/swift-artifact-parser", exact: "0.0.1")
]
```

## Usage

To use the `ArtifactParser` library in your Swift package, follow these steps:

1. **Import the Library**: Import the `ArtifactParser` module in your Swift files where you need to use its functionality.

    ```swift
    import ArtifactParser
    ```

2. **Add the Binary Target**: Update your `Package.swift` file to include the `.binaryTarget` definition for the binary you want to use. Here’s an example setup:

    ```swift
    // swift-tools-version: 5.6
    import PackageDescription

    let package = Package(
        name: "ExamplePackage",
        products: [
            .executable(name: "ExampleCLI", targets: ["ExampleCLI"])
        ],
        dependencies: [
            .package(url: "https://github.com/21-DOT-DEV/swift-artifact-parser", exact: "0.0.1")
        ],
        targets: [
            .executableTarget(
                name: "ExampleCLI",
                dependencies: [
                    .product(name: "ArtifactParser", package: "swift-artifact-parser")
                ]
            ),
            .binaryTarget(
                name: "lefthook",
                url: "https://github.com/csjones/lefthook-plugin/releases/download/1.6.18/lefthook.artifactbundle.zip",
                checksum: "4feb5c77ce2375bfecddeefc51a0f5ada270257a0904605721c7fc374ffb26c6"
            )
        ]
    )
    ```

3. **Get the Path to the Binary**: Use the `ArtifactParser` to get the path to the binary in your executable target.

    ```swift
    import ArtifactParser
    import Foundation

    @main
    struct ExampleCLI {
        static func main() {
            // Get arguments that were passed into this executable and will be forwarded to lefthook as args.
            let lefthookArgs = Array(ProcessInfo.processInfo.arguments.dropFirst())

            // Get the current directory name to use as the repository name for finding the binary.
            guard let currentDirectory = FileManager.default.currentDirectoryPath.components(separatedBy: "/").last,
                  let binaryPath = ArtifactParser.getPathToBinary(
                    binaryName: "lefthook",
                    repositoryName: currentDirectory
                  ) else {
                print("Error: Unable to find lefthook binary. Unable to run lefthook.")
                exit(1)
            }

            // Run lefthook binary with the arguments that were passed into this executable.
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = [binaryPath] + lefthookArgs

            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                print("Error running process: \(error)")
            }
        }
    }
    ```

4. **Refer to Examples**: Check the "Examples" directory in the repository for a complete package that integrates the `ArtifactParser` library. This will help you understand how to set up and use the library effectively in a real-world scenario.

### Example Project

You can find a complete example project in the "Examples" directory of the repository. This example demonstrates how to set up a Swift package that uses the `ArtifactParser` library to manage and execute binaries from an artifact bundle.

To get started with the example:

1. Clone the repository:
    ```sh
    git clone https://github.com/21-DOT-DEV/swift-artifact-parser
    ```

2. Navigate to the "Examples" directory:
    ```sh
    cd swift-artifact-parser/Examples
    ```

3. Open the example project:
    ```sh
    open Package.swift
    ```

4. Follow the instructions in the example project's README to build and run the example.

## License

`swift-artifact-parser` is released under the MIT License. See [LICENSE](LICENSE) for details.