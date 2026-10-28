// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AIHelpSPM",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "AIHelpSDK",
            targets: ["AIHelpSupport"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "AIHelpSupportSDK",
            path: "Sources/AIHelpSupportSDK.xcframework"
        ),
        .target(
            name: "AIHelpSupport",
            dependencies: ["AIHelpSupportSDK"],
            resources: [
                // Preserve the paths used by the SDK's resource bundle lookup.
                .copy("Resources/AIHelpSupportSDK.bundle"),
                .copy("Resources/PrivacyInfo.xcprivacy"),
            ],
            linkerSettings: [
                .linkedFramework("WebKit"),
                .linkedFramework("Photos"),
                .linkedFramework("PhotosUI"),
                .linkedLibrary("sqlite3"),
            ]
        ),
        .testTarget(name: "AIHelpSupportTests", dependencies: ["AIHelpSupport"]),
    ]
)
