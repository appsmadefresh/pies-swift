// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pies",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "Pies",
            targets: ["Pies"]),
    ],
    targets: [
        .target(
            name: "Pies",
            dependencies: [],
            path: "Pies"),
    ]
)
