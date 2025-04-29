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
        .package(url: "https://github.com/BudhirajaRajesh/NuggetExternalDependecy", .exact("1.1.1")),
        .package(url: "https://github.com/BudhirajaRajesh/NuggetInternalDependency", .exact("1.1.4")),
    ],
    targets: [
        .binaryTarget(
            name: "Nugget",
            url: "https://github.com/BudhirajaRajesh/NuggetInternalDependency/releases/download/1.1.6-Nugget/Nugget.xcframework.zip",
            checksum: "a23f5efae76b6672f99a1c9d50c6d4651bfaaa1a6013f5534582839be5a2e490"
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
