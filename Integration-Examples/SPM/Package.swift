// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "OpenSSL-test",
    platforms: [
        .macOS(.v10_12)
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/OpenSSL.git", .branch("marcin/1.1.1-lts")),
    ],
    targets: [
        .target(
            name: "OpenSSL-test",
            dependencies: ["OpenSSL"])
    ]
)
