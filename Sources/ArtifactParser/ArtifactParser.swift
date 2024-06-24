//
//  ArtifactParser.swift
//  21-DOT-DEV/swift-plugin-artifact-expander
//
//  Modifications Copyright (c) 2024 GigaBitcoin LLC
//  Distributed under the MIT software license
//
//  See the accompanying file LICENSE for information
//
//
//  NOTICE: THIS FILE HAS BEEN MODIFIED BY GigaBitcoin LLC
//  UNDER COMPLIANCE WITH THE APACHE 2.0 LICENSE FROM THE
//  ORIGINAL WORK OF THE COMPANY Apple Inc.
//
//  THE FOLLOWING IS THE COPYRIGHT OF THE ORIGINAL DOCUMENT:
//
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Foundation

/// Parses the artifact bundle to find the correct executable binary to run for the given OS.
///
/// This code is heavily modified from the Swift Package Manager's implementation of parsing artifact bundles.
/// Reference links to the relevant code sections in Swift Package Manager are provided in the comments.
public final class ArtifactParser {

    /// Parses the unzipped artifact bundle to find the correct binary to run for the given OS.
    ///
    /// - Parameters:
    ///   - binaryName: The name of the binary (e.g., "lefthook").
    ///   - repositoryName: The name of the repository.
    /// - Returns: The path to the binary executable, or `nil` if not found.
    ///
    /// Reference: [Swift Package Manager - BinaryTarget Extensions](https://github.com/apple/swift-package-manager/blob/1c68e6c/Sources/SPMBuildCore/BinaryTarget%2BExtensions.swift#L59-L85)
    public static func getPathToBinary(binaryName: String, repositoryName: String) -> String? {
        // 1. Get the system triple.
        // Reference: [Get System Triple](https://github.com/apple/swift-package-manager/blob/1c68e6c/Sources/SPMBuildCore/BinaryTarget%2BExtensions.swift#L61)
        //
        // If you look in an artifact bundle (artifactbundle.zip), you will see a file called info.json that defines what executables belong to which OS.
        // Swift uses the term "triples" to determine the OS and architecture of the system.
        // To find the correct binary to execute, we need to get the system triple.
        guard let systemTriple = OS.getSystemTriple() else {
            return nil
        }

        // 2. Parse the artifact bundle's info.json manifest file to get a list of all available executable binaries.
        // Reference: [Parse Artifact Bundle](https://github.com/apple/swift-package-manager/blob/1c68e6c/Sources/SPMBuildCore/BinaryTarget%2BExtensions.swift#L63-L66)
        //
        // By the time this executable target is compiled, Swift Package Manager (SPM) has already downloaded and unzipped the remote artifact bundle (artifactbundle.zip).
        // SPM downloads the artifact bundle because we define a binary target dependency. It unzips it to the .build directory because we define a pre-build plugin that's executed before this target is compiled.
        guard let rootDirectoryOfArtifactBundle = getArtifactBundlePath(bundleName: binaryName, directoryName: repositoryName) else {
            print("Unexpected error. Unable to find an artifact bundle directory that contains the executables.")
            return nil
        }

        let infoJsonPath = "\(rootDirectoryOfArtifactBundle)/info.json"
        guard let infoJsonFileContents: Data = try? Data(contentsOf: URL(fileURLWithPath: infoJsonPath)) else {
            print("Unexpected error. Unable to read info.json file. Perhaps the path is incorrect? Given path: \(infoJsonPath)")
            return nil
        }

        guard let infoJsonParsed: BundleInfo = try? JSONDecoder().decode(BundleInfo.self, from: infoJsonFileContents) else {
            print("Unexpected error. Unable to parse manifest file JSON. Check if \(infoJsonPath) format is compatible with \(BundleInfo.self) data type.")
            return nil
        }

        // 3. Take the system triple and use it to find the binary that we should run.
        // Reference: [Find Binary](https://github.com/apple/swift-package-manager/blob/1c68e6c/Sources/SPMBuildCore/BinaryTarget%2BExtensions.swift#L75-L81)
        guard let binaryFileNameForOS = infoJsonParsed.artifacts[binaryName]?.variants.first(where: { $0.supportedTriples.contains(systemTriple) })?.path else {
            print("According to the artifact bundle manifest file, no binary exists for the given OS: \(systemTriple)")
            return nil
        }

        return "\(rootDirectoryOfArtifactBundle)/\(binaryFileNameForOS)"
    }

    /// Gets the path to the root directory of the artifact bundle.
    ///
    /// The root is considered to be the path where the info.json file exists.
    /// Depending on how you execute the executable target, the artifact bundle path will be different.
    ///
    /// - Parameters:
    ///   - bundleName: The name of the artifact bundle.
    ///   - directoryName: The name of the directory.
    /// - Returns: The path to the artifact bundle directory, or `nil` if not found.
    static func getArtifactBundlePath(bundleName: String, directoryName: String) -> String? {
        // For local "swift run" development, the path is:
        let localDevelopmentPath = ".build/artifacts/\(directoryName.lowercased())/\(bundleName)"
        print("localDevelopmentPath \(localDevelopmentPath)")
        if let absolutePath = FileSystem.getAbsolutePathThatExists(relativePath: localDevelopmentPath) {
            return absolutePath
        }

        // If you run the executable with Mint, the path relative to the executable will follow this pattern:
        // "artifacts/github.com_*/<binaryName>"
        // The path name is determined by the GitHub repository name.
        if let absolutePathToMintResources = FileSystem.getAbsolutePathThatExists(relativePath: "artifacts"),
           let absoluteMintArtifactPath = FileSystem.getSubdirectories(atAbsolutePath: absolutePathToMintResources)
            .first(where: { $0.contains("github.com_") })?.appending("/\(bundleName)") {
            return absoluteMintArtifactPath
        }

        return nil
    }
}
