// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StoreKit2Manager",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "StoreKit2Manager",
            targets: ["StoreKit2Manager"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "StoreKit2Manager",
            dependencies: [],
            path: ".",
            sources: [
                "StoreKitManager.swift",
                "Models",
                "Protocols",
                "Internal",
                "Locals",
                "Converts"
            ],
            exclude: [
                "Docs"
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)

