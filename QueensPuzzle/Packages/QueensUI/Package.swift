// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "QueensUI",
    defaultLocalization: "en",
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
                .process("Resources/Images.xcassets"),
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "QueensUITests",
            dependencies: ["QueensUI"]
        )
    ]
)
