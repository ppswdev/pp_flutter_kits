// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "pp_asa_attribution",
    platforms: [
        .iOS("15.0"),
    ],
    products: [
        .library(
            name: "pp-asa-attribution",
            targets: ["pp_asa_attribution"]
        ),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "pp_asa_attribution",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ],
            linkerSettings: [
                .linkedFramework("AdServices"),
            ]
        ),
    ]
)
