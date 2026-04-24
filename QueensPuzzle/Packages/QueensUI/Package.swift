// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "QueensUI",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "QueensUI", targets: ["QueensUI"])
    ],
    dependencies: [
        .package(path: "../QueensCore")
    ],
    targets: [
        .target(
            name: "QueensUI",
            dependencies: ["QueensCore"],
            resources: [
                .process("Resources/Colors.xcassets"),
                .process("Resources/Images.xcassets")
            ]
        ),
        .testTarget(
            name: "QueensUITests",
            dependencies: ["QueensUI"]
        )
    ]
)
