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
            url: "https://github.com/BudhirajaRajesh/NuggetInternalDependency/releases/download/1.1.13-Nugget/Nugget.xcframework.zip",
            checksum: "81d0508f089f177c726f96607084d1d575911fe9c99aaec2590ff1b5fac8f781"
        ),
        // Binary targets previously for NuggetInternalDependency, now direct dependencies for NuggetSDK
        .binaryTarget(
            name: "NuggetFoundation",
            url: "https://github.com/BudhirajaRajesh/NuggetInternalDependency/releases/download/1.1.3-NuggetFoundation/NuggetFoundation.xcframework.zip",
            checksum: "9409ffb6a4ae1e236463d450286bfb5cdad3b9654aa7339a43b0c487e2ad2620"
        ),
        .binaryTarget(
            name: "NuggetJumbo",
            url: "https://github.com/BudhirajaRajesh/NuggetInternalDependency/releases/download/1.1.3-NuggetJumbo/NuggetJumbo.xcframework.zip",
            checksum: "8057fb2cfaa8630f8d7a254bbb04a6503b4840a5c4551575eb08ef0f7ae8e8c4"
        ),
        .binaryTarget(
            name: "NuggetApiManager",
            url: "https://github.com/BudhirajaRajesh/NuggetInternalDependency/releases/download/1.1.3-ZApiManager/ZApiManager.xcframework.zip",
            checksum: "25c020bb8f02ee9daebe72229bd60749ea8eb5c4d7b549f7d668feb35beadb29"
        ),
        // NuggetInternalDependency and NuggetExternalDependency targets are removed.
        // Their sources should be copied into Sources/NuggetSDK/
        // and their dependencies are now direct dependencies of the NuggetSDK target.
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
            // Sources for NuggetSDK will now also include sources from
            // what were NuggetInternalDependency and NuggetExternalDependency.
            // Assumed to be in Sources/NuggetSDK/
        ),
        .testTarget(
            name: "NuggetSDKTests",
            dependencies: ["NuggetSDK"]),
    ]
)
