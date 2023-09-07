// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "OpenSSL-test",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // .package(url: "https://github.com/krzyzanowskim/OpenSSL.git", .branch("main")),
        .package(path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "OpenSSL-test",
            dependencies: ["OpenSSL"])
    ]
)
