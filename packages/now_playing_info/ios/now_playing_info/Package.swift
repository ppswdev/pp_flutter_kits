// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "now_playing_info",
    platforms: [.iOS("15.0")],
    products: [
        .library(name: "now-playing-info", targets: ["now_playing_info"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "now_playing_info",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            resources: [.process("PrivacyInfo.xcprivacy")],
            linkerSettings: [.linkedFramework("MediaPlayer")]
        ),
    ]
)
