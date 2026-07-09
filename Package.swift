// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "zosconnectforswift",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "zosconnectforswift", targets: ["zosconnectforswift"]),
    ],
    targets: [
        .target(name: "zosconnectforswift"),
        .testTarget(name: "zosconnectforswiftTests", dependencies: ["zosconnectforswift"]),
    ]
)