# OpenSSL-Universal

OpenSSL [CocoaPods](https://cocoapods.org/), [Carthage](https://github.com/Carthage/Carthage) and [Swift Package Manager](https://swift.org/package-manager/) package for iOS and macOS. Complete solution to OpenSSL on iOS and macOS. Package comes with precompiled libraries, and includes a script to build newer versions if necessary.

Current version contains binaries built with latest iOS SDK (target 7.0), and latest macOS SDK (target 10.10) for all supported architectures (including macOS Catalyst).

### Support

It takes some time to keep it all for your convenience, so maybe spare $1, so I can keep working on that. There are more than 8000 clones daily. If I'd get $1/month from each company that uses my work here, I'd say we're even. Hurry up, find the [Sponsorship](https://github.com/users/krzyzanowskim/sponsorship) button, and fulfill your duty.

### Architectures

- iOS with architectures: arm64 + simulator (x86_64, arm64)
- macOS with architectures: x86_64, arm64 (including Catalyst target)

#### Output Formats

- Static library [libcrypto.a, libssl.a](iphoneos/lib/)
- [OpenSSL.framework](Frameworks/)
- [OpenSSL.xcframework](Frameworks/)

### Why?

[Apple says](https://developer.apple.com/library/mac/documentation/security/Conceptual/cryptoservices/GeneralPurposeCrypto/GeneralPurposeCrypto.html):
"Although OpenSSL is commonly used in the open source community, OpenSSL does not provide a stable API from version to version. For this reason, although OS X provides OpenSSL libraries, the OpenSSL libraries in OS X are deprecated, and OpenSSL has never been provided as part of iOS."

### Installation

#### Build

You don't have to use pre-built binaries I provide. You can build it locally on your trusted machine.

```
$ git clone https://github.com/krzyzanowskim/OpenSSL.git
$ cd OpenSSL
$ make
```

The result of a build process is put inside [Frameworks](Frameworks/) directory.

### Hardened Runtime (macOS) and Xcode

Binary `OpenSSL.xcframework` (Used by the Swift Package Manager package integration) won't load properly in your app if the app uses **Sign to Run Locally**  Signing Certificate with Hardened Runtime enabled. It is possible to setup Xcode like this. To solve the problem you have two options:
- Use proper Signing Certificate, eg. *Development* <- this is the proper action
- Use `Disable Library Validation` aka `com.apple.security.cs.disable-library-validation` entitlement

### Swift Package Manager

```
dependencies: [
    .package(url: "https://github.com/krzyzanowskim/OpenSSL.git", .upToNextMinor(from: "1.1.1700"))
]
```

### CocoaPods

````
pod 'OpenSSL-Universal'
````

### Carthage

* If building from source is preferred:

```
github "krzyzanowskim/OpenSSL"
```

* If using a prebuilt framework is preferred:

```
binary "https://raw.githubusercontent.com/krzyzanowskim/OpenSSL/master/OpenSSL.json"
```

### Authors

[Marcin Krzyżanowski](https://twitter.com/krzyzanowskim)

## FAQ etc.
#### Where can I use OpenSSL-Universal?
These libraries work for both iOS and macOS. It is your prerogative to check. Ask yourself, are you trying to write an app for old devices? new devices only? all iOS devices? only macOS?, etc ::

#### What is XCFramework?

OpenSSL.xcframework is distributed as a multiplatform XCFramework bundle, for mor information chekout the documentation [Distributing Binary Frameworks as Swift Packages](https://developer.apple.com/documentation/xcode/distributing-binary-frameworks-as-swift-packages)

