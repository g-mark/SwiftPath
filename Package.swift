// swift-tools-version:5.1
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
            dependencies: ["SwiftPath"]),
    ]
)
