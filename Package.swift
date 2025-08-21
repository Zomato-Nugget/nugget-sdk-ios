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
            url: "https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/99.0.7-Nugget/Nugget.xcframework.zip",
            checksum: "ec06c16b2095a42b0cd3f1e78b266541e93b4b4b7904cd3d91747727eedc1110"
        ),
        // Binary targets previously for NuggetInternalDependency, now direct dependencies for NuggetSDK
        .binaryTarget(
            name: "NuggetFoundation",
            url: "https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.2-Foundation/NuggetFoundation.xcframework.zip",
            checksum: "bac60616a9c27b2fb2d5564324be369c75d6460238891e7f7163dcafe3516922"
        ),
        .binaryTarget(
            name: "NuggetJumbo",
            url: "https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.2-Jumbo/NuggetJumbo.xcframework.zip",
            checksum: "7ba9883d3361002b33d9e093e6b67fabddea03180410f5aedfa3e6ab44e4a83a"
        ),
        .binaryTarget(
            name: "NuggetApiManager",
            url: "https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/99.0.7-NuggetApiManager/ZApiManager.xcframework.zip",
            checksum: "c0739d668a823ece16357bd85dbe514b6e3b3ed2063a3dcd46f4e71c124cd7f3"
        ),
        .target(
            name: "NuggetSDK",
            dependencies: [
                "Nugget", // Main binary
                // Binaries from former NuggetInternalDependency
                "NuggetFoundation",
                "NuggetJumbo",
                "NuggetApiManager",
            ]
        ),
        .testTarget(
            name: "NuggetSDKTests",
            dependencies: ["NuggetSDK"]),
    ]
)
