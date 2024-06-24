// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExamplePackage",
    products: [
        .executable(name: "ExampleCLI", targets: ["ExampleCLI"])
    ],
    dependencies: [
        .package(path: "..")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "ExampleCLI",
            dependencies: [
                .product(name: "ArtifactParser", package: "swift-plugin-artifact-expander")
            ]
        ),
        .binaryTarget(
            name: "lefthook",
            url: "https://github.com/csjones/lefthook-plugin/releases/download/1.6.18/lefthook.artifactbundle.zip",
            checksum: "4feb5c77ce2375bfecddeefc51a0f5ada270257a0904605721c7fc374ffb26c6"
        )
    ]
)
