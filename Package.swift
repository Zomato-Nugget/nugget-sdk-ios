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
            checksum: "5d6aabb58f6084b6262f3a248a48553340863c1c8521eec47646cc2ce2d961b1"
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
