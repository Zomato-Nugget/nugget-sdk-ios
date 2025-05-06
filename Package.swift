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
        .package(url: "https://github.com/BudhirajaRajesh/NuggetExternalDependecy", .exact("1.1.4")),
        .package(url: "https://github.com/BudhirajaRajesh/NuggetInternalDependency", .exact("1.1.4")),
    ],
    targets: [
        .binaryTarget(
            name: "Nugget",
            url: "https://github.com/BudhirajaRajesh/NuggetInternalDependency/releases/download/1.1.13-Nugget/Nugget.xcframework.zip",
            checksum: "81d0508f089f177c726f96607084d1d575911fe9c99aaec2590ff1b5fac8f781"
        ),
        .target(
            name: "NuggetSDK",
            dependencies: [
                .product(name: "NuggetInternalDependency", package: "NuggetInternalDependency"),
                .product(name: "NuggetExternalDependency", package: "NuggetExternalDependecy"),
                "Nugget"
            ]),
        .testTarget(
            name: "NuggetSDKTests",
            dependencies: ["NuggetSDK"]),
    ]
)
