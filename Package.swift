// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NuggetSDK",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "NuggetSDK",
            targets: ["NuggetSDK"]),
    ],
    targets: [
        // Main Nugget binary
        .binaryTarget(
            name: "Nugget",
            url: "https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/4.5.0-Nugget/Nugget.xcframework.zip",
            checksum: "de485e17187471b793dc6244db0353e66d4cf340fad0012032a611ce1c477155"
        ),
        .target(
            name: "NuggetSDK",
            dependencies: [
                "Nugget", // Main binary
            ]
        ),
        .testTarget(
            name: "NuggetSDKTests",
            dependencies: ["NuggetSDK"]),
    ]
)
