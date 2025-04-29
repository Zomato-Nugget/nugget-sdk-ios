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
            url: "https://github.com/BudhirajaRajesh/NuggetInternalDependency/releases/download/1.1.10-Nugget/Nugget.xcframework.zip",
            checksum: "54f4bd38b2c789c46aa61ddaf9f61763b2fe70c315c1413a9d76bf28e6c94faa"
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
