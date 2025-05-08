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
            url: "https://github.com/BudhirajaRajesh/NuggetSDK/releases/download/0.0.2-Nugget/Nugget.xcframework.zip",
            checksum: "5cee653c3c62fd569867126d54f1a88237e491cd87265f8edc898d657a195717"
        ),
        // Binary targets previously for NuggetInternalDependency, now direct dependencies for NuggetSDK
        .binaryTarget(
            name: "NuggetFoundation",
            url: "https://github.com/BudhirajaRajesh/NuggetSDK/releases/download/0.0.1-NuggetFoundation/NuggetFoundation.xcframework.zip",
            checksum: "ca1d32c7fb127fbc615221396187b4b972917704bb6c26c7b8b5f3f10c2d2bd5"
        ),
        .binaryTarget(
            name: "NuggetJumbo",
            url: "https://github.com/BudhirajaRajesh/NuggetSDK/releases/download/0.0.2-NuggetJumbo/NuggetJumbo.xcframework.zip",
            checksum: "83d9db10df77a0ceaffd7a6eeec97595d77aab8fabae7af29a7849592c5d09c4"
        ),
        .binaryTarget(
            name: "NuggetApiManager",
            url: "https://github.com/BudhirajaRajesh/NuggetSDK/releases/download/0.0.1-ZApiManager/ZApiManager.xcframework.zip",
            checksum: "81463946199f2a6c0abc5226ca8282af64b5435c4ad365473440b9a4b25b99ef"
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
