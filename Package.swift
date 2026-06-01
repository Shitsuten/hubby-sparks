// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HubbySparks",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "HubbySparks", targets: ["HubbySparks"])
    ],
    targets: [
        .target(
            name: "HubbySparks",
            path: "Sources"
        )
    ]
)
