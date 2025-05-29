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
        .package(url: "https://github.com/BudhirajaRajesh/ZMarkupParser.git", .exact("2.0.0")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2"))
    ],
    targets: [
        // Main Nugget binary
        .binaryTarget(
            name: "Nugget",
            url: "https://github.com/BudhirajaRajesh/NuggetSDK/releases/download/0.1.2-Nugget/Nugget.xcframework.zip",
            checksum: "25a301c4bb30fc253834cfe6d3c8d7eef6149ef147b8838faf42ebc786ec6041"
        ),
        // Binary targets previously for NuggetInternalDependency, now direct dependencies for NuggetSDK
        .binaryTarget(
            name: "NuggetFoundation",
            url: "https://github.com/BudhirajaRajesh/NuggetSDK/releases/download/0.1.2-NuggetFoundation/NuggetFoundation.xcframework.zip",
            checksum: "7daad184becf5a19f4d4a8657fe11187e2354de3d72eb1dfd7c49645487e4f03"
        ),
        .binaryTarget(
            name: "NuggetJumbo",
            url: "https://github.com/BudhirajaRajesh/NuggetSDK/releases/download/0.1.2-NuggetJumbo/NuggetJumbo.xcframework.zip",
            checksum: "85a1b62bfbf84c4b7422f720683fedf66a8fa7579cfbe3315eac850f643550f7"
        ),
        .binaryTarget(
            name: "NuggetApiManager",
            url: "https://github.com/BudhirajaRajesh/NuggetSDK/releases/download/0.1.2-ZApiManager/ZApiManager.xcframework.zip",
            checksum: "9999ca464cadd3751ace81e33d6b6d18c6cc3d92b1dcc53662bc750e4c51b017"
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
                .product(name: "ZMarkupParser", package: "ZMarkupParser"),
                .product(name: "Alamofire", package: "Alamofire")
            ]
        ),
        .testTarget(
            name: "NuggetSDKTests",
            dependencies: ["NuggetSDK"]),
    ]
)
