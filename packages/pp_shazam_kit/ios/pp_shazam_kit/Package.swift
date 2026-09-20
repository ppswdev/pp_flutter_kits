// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "pp_shazam_kit",
    platforms: [
        .iOS("15.0"),
    ],
    products: [
        .library(
            name: "pp-shazam-kit",
            targets: ["pp_shazam_kit"]
        ),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "pp_shazam_kit",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("ShazamKit"),
            ]
        ),
    ]
)
