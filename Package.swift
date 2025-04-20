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
        .package(url: "https://github.com/BudhirajaRajesh/NuggetInternalDependency", .exact("1.0.1")),
        .package(url: "https://github.com/BudhirajaRajesh/NuggetExternalDependecy", .exact("1.0.0"))
    ],
    targets: [
        .binaryTarget(
            name: "Nugget",
            url: "https://github.com/BudhirajaRajesh/Nugget/releases/download/1.0.0/Nugget.xcframework.zip",
            checksum: "d5c15910269d5f5c750bfd245fc2a6e522ded5c07c84e0ee46088102257de60f"
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
