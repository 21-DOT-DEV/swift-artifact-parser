//
//  FileSystem.swift
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

/// A utility class for handling file system operations, such as resolving paths and checking for the existence of files and directories.
///
/// This code is heavily modified from the Swift Package Manager's implementation.
final class FileSystem {

    /// The base absolute path when using "swift run".
    ///
    /// - Returns: The current directory path from which the binary is executed.
    static var pathWhereBinaryExecutedFrom: String {
        return FileManager.default.currentDirectoryPath
    }

    /// The base absolute path when using "mint run".
    ///
    /// - Returns: The directory path where the binary exists.
    static var pathWhereBinaryExists: String {
        let fileURL = Bundle.main.executableURL!
        let directoryURL = fileURL.deletingLastPathComponent()
        return directoryURL.path
    }

    /// Given a relative path, returns the expanded absolute path if the path exists.
    ///
    /// Depending on if the executable is run by "swift run" or "mint run", the absolute path will be different.
    /// This method determines the correct absolute path to find and parse the artifact bundle.
    ///
    /// - Parameter relativePath: The relative path to be expanded.
    /// - Returns: The absolute path if it exists, otherwise `nil`.
    static func getAbsolutePathThatExists(relativePath: String) -> String? {
        let absolutePathSwiftRun = "\(pathWhereBinaryExecutedFrom)/\(relativePath)"
        let absolutePathMintRun = "\(pathWhereBinaryExists)/\(relativePath)"

        if doesPathExist(path: absolutePathSwiftRun) {
            return absolutePathSwiftRun
        } else if doesPathExist(path: absolutePathMintRun) {
            return absolutePathMintRun
        }

        return nil
    }

    /// Checks if a given path exists in the file system.
    ///
    /// - Parameter path: The path to be checked.
    /// - Returns: `true` if the path exists, otherwise `false`.
    static func doesPathExist(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    /// Retrieves the subdirectories at a given absolute path.
    ///
    /// - Parameter path: The absolute path where subdirectories are to be found.
    /// - Returns: An array of paths to the subdirectories.
    static func getSubdirectories(atAbsolutePath path: String) -> [String] {
        let contents = (try? FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: path), includingPropertiesForKeys: nil)) ?? []

        var subdirectories: [String] = []

        for item in contents {
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: item.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    let absolutePathToSubdirectory = "\(path)/\(item.lastPathComponent)"
                    subdirectories.append(absolutePathToSubdirectory)
                }
            }
        }

        return subdirectories
    }
}
