// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPath",
    products: [
        .library(
            name: "SwiftPath",
            targets: ["SwiftPath"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftPath",
            dependencies: []),
        .testTarget(
            name: "SwiftPathTests",
            dependencies: ["SwiftPath"],
            resources: [
                .copy("Resources/cts.json"),
                .copy("Resources/cts-known-failures.json"),
            ]),
    ]
)
