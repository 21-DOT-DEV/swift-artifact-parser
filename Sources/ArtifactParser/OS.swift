//
//  OS.swift
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

/// Utility class that helps determine the OS on which Swift is being executed.
/// This is helpful for determining the right binary to run for the given OS.
///
/// This code is heavily modified from the Swift Package Manager's implementation of parsing artifact bundles.
/// Reference links to the relevant code sections in Swift Package Manager are provided in the comments. 
final class OS {
    
    /// Retrieves the system triple that represents the OS on which Swift is being executed.
    ///
    /// This method is based on the Swift Package Manager's implementation:
    /// https://github.com/apple/swift-package-manager/blob/1c68e6c/Sources/Basics/Triple%2BBasics.swift#L84-L121
    ///
    /// - Returns: A string representing the system triple, or `nil` if an error occurs.
    static func getSystemTriple() -> String? {
        let process = Process()
        let stdoutPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["swift", "-print-target-info"]
        process.standardOutput = stdoutPipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            print("Error running process: \(error)")
            return nil
        }

        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        guard let stdoutParsed: SwiftTargetInfo = try? JSONDecoder().decode(SwiftTargetInfo.self, from: stdoutData) else {
            print("Unexpected error. Unable to parse JSON: \(stdoutData) into data type \(SwiftTargetInfo.self)")
            return nil
        }

        return stdoutParsed.target.unversionedTriple
    }

    /// A structure used to parse the output of the "swift -print-target-info" command.
    ///
    /// Run the "swift -print-target-info" command on your computer to see the output.
    struct SwiftTargetInfo: Codable {
        let target: Target

        /// A structure representing the target information.
        struct Target: Codable {
            /// The unversioned triple string that represents the target.
            let unversionedTriple: String
        }
    }
}
