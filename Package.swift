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
    dependencies: [
        // Dependencies previously managed by NuggetExternalDependency, now direct
        .package(url: "https://github.com/patchthecode/JTAppleCalendar", .exact("8.0.5")),
        .package(url: "https://github.com/kean/Nuke.git", .exact("10.7.1")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2"))
    ],
    targets: [
        // Main Nugget binary
        .binaryTarget(
            name: "Nugget",
            url: "https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.8-Nugget/Nugget.xcframework.zip",
            checksum: "a402dadc9e0159a641c5b7a6adea438c0a3ecd1ccb874f59b32869d4161760bb"
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
            checksum: "f948156ca7185014e7a9fde0efb1222a8201e677c51a37ffc94902db06cb1b2d"
        ),
        .binaryTarget(
            name: "NuggetApiManager",
            url: "https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.2-ApiManager/ZApiManager.xcframework.zip",
            checksum: "8d2d4cd17a4988a0c68b2950a100d73a2fc3233822ceb4f573cabc6733e58015"
        ),
        .target(
            name: "NuggetSDK",
            dependencies: [
                "Nugget", // Main binary
                // Binaries from former NuggetInternalDependency
                "NuggetFoundation",
                "NuggetJumbo",
                "NuggetApiManager",
                // Products from former NuggetExternalDependency
                .product(name: "JTAppleCalendar", package: "JTAppleCalendar"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "Alamofire", package: "Alamofire")
            ]
        ),
        .testTarget(
            name: "NuggetSDKTests",
            dependencies: ["NuggetSDK"]),
    ]
)
