//
//  ArtifactBundle.swift
//  21-DOT-DEV/swift-artifact-parser
//
//  Copyright (c) 2024 GigaBitcoin LLC
//  Distributed under the MIT software license
//
//  See the accompanying file LICENSE for information
//

import Foundation

/// A structure representing the root object of the info.json file in the artifact bundle.
internal struct BundleInfo: Codable {
    /// The version of the schema used in the info.json file.
    let schemaVersion: String
    
    /// A dictionary of artifacts where the key is the artifact name (e.g., "lefthook")
    /// and the value is an `Artifact` object containing details about the artifact.
    let artifacts: [String: Artifact]
}

/// A structure representing an artifact in the info.json file.
internal struct Artifact: Codable {
    /// The type of the artifact (e.g., "executable").
    let type: String
    
    /// The version of the artifact.
    let version: String
    
    /// An array of `Variant` objects, each representing a specific variant of the artifact
    /// for different operating systems and architectures.
    let variants: [Variant]
}

/// A structure representing a variant of an artifact in the info.json file.
internal struct Variant: Codable {
    /// The file path to the variant of the artifact.
    let path: String
    
    /// An array of strings representing the supported triples for the variant.
    /// Each triple denotes a specific operating system and architecture combination.
    let supportedTriples: [String]
}
