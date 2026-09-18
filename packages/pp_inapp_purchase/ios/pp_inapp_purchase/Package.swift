// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "pp_inapp_purchase",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        // Flutter resolves plugin products using the hyphenated package name.
        .library(name: "pp-inapp-purchase", targets: ["pp_inapp_purchase"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "pp_inapp_purchase",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
    ]
)
