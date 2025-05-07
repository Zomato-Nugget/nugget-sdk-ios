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
        .package(url: "https://github.com/kean/Nuke.git", .exact("12.8.0")),
        .package(url: "https://github.com/BudhirajaRajesh/ZMarkupParser.git", .exact("2.0.0")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2"))
    ],
    targets: [
        // Main Nugget binary
        .binaryTarget(
            name: "Nugget",
            url: "https://github.com/BudhirajaRajesh/NuggetSDK/releases/download/0.0.1-Nugget/Nugget.xcframework.zip",
            checksum: "81d0508f089f177c726f96607084d1d575911fe9c99aaec2590ff1b5fac8f781"
        ),
        // Binary targets previously for NuggetInternalDependency, now direct dependencies for NuggetSDK
        .binaryTarget(
            name: "NuggetFoundation",
            url: "https://github.com/BudhirajaRajesh/NuggetSDK/releases/download/0.0.1-NuggetFoundation/NuggetFoundation.xcframework.zip",
            checksum: "ca1d32c7fb127fbc615221396187b4b972917704bb6c26c7b8b5f3f10c2d2bd5"
        ),
        .binaryTarget(
            name: "NuggetJumbo",
            url: "https://github.com/BudhirajaRajesh/NuggetSDK/releases/download/0.0.1-NuggetJumbo/NuggetJumbo.xcframework.zip",
            checksum: "0ead7121dc34fc978abcbadd5200527cce731634c4c8fdbc3435a0ff60217ee6"
        ),
        .binaryTarget(
            name: "NuggetApiManager",
            url: "https://github.com/BudhirajaRajesh/NuggetSDK/releases/download/0.0.1-ZApiManager/ZApiManager.xcframework.zip",
            checksum: "706d25f4546aaad59ea6933416b7274a206f696c4c81ca3e9b76ce20a4f01d03"
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
                .product(name: "NukeExtensions", package: "Nuke"),
                .product(name: "ZMarkupParser", package: "ZMarkupParser"),
                .product(name: "Alamofire", package: "Alamofire")
            ]
        ),
        .testTarget(
            name: "NuggetSDKTests",
            dependencies: ["NuggetSDK"]),
    ]
)
