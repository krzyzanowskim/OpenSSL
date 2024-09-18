# OpenSSL-Universal

OpenSSL [CocoaPods](https://cocoapods.org/), [Carthage](https://github.com/Carthage/Carthage) and [Swift Package Manager](https://swift.org/package-manager/) package for iOS, macOS, Catalyst, tvOS, visionOS, watchOS. A complete solution to OpenSSL. The package comes with precompiled libraries and includes a script to build newer versions if necessary.

### Support & Sponsors

The financial sustainability of the project is possible thanks to the ongoing contributions from our [GitHub Sponsors](https://github.com/sponsors/krzyzanowskim)

### Premium Sponsors

  [Emerge Tools](https://www.emergetools.com/) is a suite of revolutionary products designed to supercharge mobile apps and the teams that build them.

  ![emerge-tools-black](https://github.com/krzyzanowskim/OpenSSL/assets/758033/a21f5ac1-ef39-4b56-a8d2-575adeb7fe55)

### Architectures

- iOS with architectures: arm64 + simulator (x86_64, arm64)
- macOS with architectures: x86_64, arm64 (including Catalyst target)
- tvOS with architectures: arm64
- visionOS with archtectures: arm64
- watchOS with architectures: arm64, arm64_32

#### Output Formats

- Static library [libcrypto.a, libssl.a](iphoneos/lib/)
- Frameworks [OpenSSL.framework](Frameworks/)
- XCFramework [OpenSSL.xcframework](https://github.com/krzyzanowskim/OpenSSL/releases/latest/download/OpenSSL.xcframework.zip)

### Why?

[Apple says](https://developer.apple.com/library/mac/documentation/security/Conceptual/cryptoservices/GeneralPurposeCrypto/GeneralPurposeCrypto.html):
"Although OpenSSL is commonly used in the open source community, OpenSSL does not provide a stable API from version to version. For this reason, although OS X provides OpenSSL libraries, the OpenSSL libraries in OS X are deprecated, and OpenSSL has never been provided as part of iOS."

### Installation

#### Build

You don't have to use the pre-built binaries I provide. You can build it locally on your trusted machine.

```
$ git clone https://github.com/krzyzanowskim/OpenSSL.git
$ cd OpenSSL
$ make SIGNING_IDENTITY="Apple Distribution"
```

The result of a build process is put inside [Frameworks](Frameworks/) directory.

### Swift Package Manager

I advised you to use [OpenSSL-Package](https://github.com/krzyzanowskim/OpenSSL-Package) which is a pure binary distribution that distribute the very same binary but avoid fetching this git repository which is significant in size.

```swift
dependencies: [
    .package(url: "https://github.com/krzyzanowskim/OpenSSL-Package.git", from: "3.3.2000")
]
```

and then as a dependency for the Package target utilizing OpenSSL:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "OpenSSL", package: "OpenSSL-Package")
    ]
),
```

### CocoaPods

```
pod 'OpenSSL-Universal'
```

### Carthage

* Using a prebuilt framework is preferred:

```
binary "https://raw.githubusercontent.com/krzyzanowskim/OpenSSL/main/OpenSSL.json"
```

### Authors

[Marcin Krzyżanowski](https://x.com/krzyzanowskim)

## FAQ etc.
#### Where can I use OpenSSL-Universal?
These libraries work for iOS, macOS, appleTV, visionOS, watchOS. It is your prerogative to check. Ask yourself, are you trying to write an app for old devices? new devices only? all iOS devices? only macOS?, etc ::

#### What is XCFramework?

OpenSSL.xcframework is distributed as a multiplatform XCFramework bundle, for more information checkout the documentation [Distributing Binary Frameworks as Swift Packages](https://developer.apple.com/documentation/xcode/distributing-binary-frameworks-as-swift-packages)
