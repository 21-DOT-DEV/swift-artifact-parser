//
//  Main.swift
//  21-DOT-DEV/swift-artifact-parser
//
//  Copyright (c) 2024 GigaBitcoin LLC
//  Distributed under the MIT software license
//
//  See the accompanying file LICENSE for information
//

import ArtifactParser
import Foundation

/// The main entry point for the CLI application.
@main
struct ExampleCLI {
    static func main() {
        // Get arguments that were passed into this executable and will be forwarded to lefthook as args.
        let lefthookArgs = Array(ProcessInfo.processInfo.arguments.dropFirst())
        let currentDirectoryPath = FileManager.default.currentDirectoryPath

        print("currentDirectoryPath: \(currentDirectoryPath)")

        // Get the current directory name to use as the repository name for finding the binary.
        guard let currentDirectory = currentDirectoryPath.components(separatedBy: "/").last,
              let binaryPath = ArtifactParser.getPathToBinary(
                binaryName: "lefthook",
                repositoryName: currentDirectory
              ) else {
            print("Error: Unable to find lefthook binary. Make sure use `swift run` to execute this application.")
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
