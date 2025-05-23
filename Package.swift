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
            url: "https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.6-Nugget/Nugget.xcframework.zip",
            checksum: "8e76690a7c9c03f0c964e9b1dfe736ef8e208089755f41b1e68f4327eaf8601e"
        ),
        // Binary targets previously for NuggetInternalDependency, now direct dependencies for NuggetSDK
        .binaryTarget(
            name: "NuggetFoundation",
            url: "https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.1-Foundation/NuggetFoundation.xcframework.zip",
            checksum: "7173cf9d6b428f9903605ddb53a4376e73adf6dbb60342a3d385d9fb5a7a41b7"
        ),
        .binaryTarget(
            name: "NuggetJumbo",
            url: "https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.1-Jumbo/NuggetJumbo.xcframework.zip",
            checksum: "3d31b79dcda091b9ece81a2a76d8b32b6350e539f38202ab5786733ac65202c5"
        ),
        .binaryTarget(
            name: "NuggetApiManager",
            url: "https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.1-ApiManager/ZApiManager.xcframework.zip",
            checksum: "7fce6112c32948830046c82ce045590327c8c442a6aee00d7aef773db6f6b0cb"
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
