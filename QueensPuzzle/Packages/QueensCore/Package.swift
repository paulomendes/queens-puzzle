// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "QueensCore",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "QueensCore", targets: ["QueensCore"])
    ],
    targets: [
        .target(name: "QueensCore"),
        .testTarget(name: "QueensCoreTests", dependencies: ["QueensCore"])
    ]
)
