import ProjectDescription

private let developmentTeam: SettingValue = "67RAULRX93"
private let marketingVersion: String = "3.1.5001"

let project = Project(
    name: "OpenSSL",
    targets: [
        .target(
            name: "OpenSSL (iOS)",
            destinations: [.iPhone, .iPad],
            product: .framework,
            productName: "OpenSSL",
            bundleId: "com.github.krzyzanowskim.OpenSSL",
            deploymentTargets: .iOS("12.0"),
            infoPlist: .file(path: .relativeToRoot("support/iphoneos/Info.plist")),
            sources: [],
            resources: [
                "support/PrivacyInfo.xcprivacy"
            ],
            headers: .headers(
                public: .list([.glob("iphoneos/include/OpenSSL/*.h", excluding: "**/asn1_mac.h"), "support/iphoneos/OpenSSL.h"])
            ),
            dependencies: [
                .library(path: .relativeToRoot("iphoneos/lib/libcrypto.a"), publicHeaders: .relativeToRoot("iphoneos/include/OpenSSL"), swiftModuleMap: nil, condition: nil),
                .library(path: .relativeToRoot("iphoneos/lib/libssl.a"), publicHeaders: .relativeToRoot("iphoneos/include/OpenSSL"), swiftModuleMap: nil, condition: nil)
            ],
            settings: .settings(base: SettingsDictionary()
                .marketingVersion(marketingVersion)
                .currentProjectVersion("1")
                .bitcodeEnabled(false)
                .otherLinkerFlags([
                    "-Xlinker -all_load"
                ])
                .merging([
                    "SUPPORTED_PLATFORMS": "iphoneos",

                    "BUILD_LIBRARY_FOR_DISTRIBUTION": "YES",
                    "APPLICATION_EXTENSION_API_ONLY": "YES",
                    "DEFINES_MODULE": "YES",

                    "SKIP_INSTALL": "NO",
                    "COPY_PHASE_STRIP": "NO",

                    "DEVELOPMENT_TEAM": developmentTeam,
                    "CODE_SIGN_IDENTITY": "Apple Distribution",
                    "CODE_SIGN_STYLE": "Manual"
                ])
            )
        ),
        .target(
            name: "OpenSSL (iOS Simulator)",
            destinations: [.iPhone, .iPad],
            product: .framework,
            productName: "OpenSSL",
            bundleId: "com.github.krzyzanowskim.OpenSSL",
            deploymentTargets: .iOS("12.0"),
            infoPlist: .file(path: .relativeToRoot("support/iphonesimulator/Info.plist")),
            sources: [],
            resources: [
                "support/PrivacyInfo.xcprivacy"
            ],
            headers: .headers(
                public: .list([.glob("iphonesimulator/include/OpenSSL/*.h", excluding: "**/asn1_mac.h"), "support/iphonesimulator/OpenSSL.h"])
            ),
            dependencies: [
                .library(path: .relativeToRoot("iphonesimulator/lib/libcrypto.a"), publicHeaders:  .relativeToRoot("iphonesimulator/include/OpenSSL"), swiftModuleMap: nil, condition: nil),
                .library(path: .relativeToRoot("iphonesimulator/lib/libssl.a"), publicHeaders:  .relativeToRoot("iphonesimulator/include/OpenSSL"), swiftModuleMap: nil, condition: nil)
            ],
            settings: .settings(base: SettingsDictionary()
                .marketingVersion(marketingVersion)
                .currentProjectVersion("1")
                .bitcodeEnabled(false)
                .otherLinkerFlags([
                    "-Xlinker -all_load"
                ])
                .merging([
                    "SUPPORTED_PLATFORMS": "iphonesimulator",

                    "BUILD_LIBRARY_FOR_DISTRIBUTION": "YES",
                    "APPLICATION_EXTENSION_API_ONLY": "YES",
                    "DEFINES_MODULE": "YES",

                    "SKIP_INSTALL": "NO",
                    "COPY_PHASE_STRIP": "NO",

                    "DEVELOPMENT_TEAM": developmentTeam,
                    "CODE_SIGN_IDENTITY": "iPhone Distribution",
                    "CODE_SIGN_STYLE": "Manual"
                ])
            )
        ),
        .target(
            name: "OpenSSL (macOS)",
            destinations: [.mac],
            product: .framework,
            productName: "OpenSSL",
            bundleId: "com.github.krzyzanowskim.OpenSSL",
            deploymentTargets: .macOS("10.15"),
            infoPlist: .file(path: .relativeToRoot("support/macos/Info.plist")),
            sources: [],
            resources: [
                "support/PrivacyInfo.xcprivacy"
            ],
            headers: .headers(
                public: .list([.glob("macosx/include/OpenSSL/*.h", excluding: "**/asn1_mac.h"), "support/macos/OpenSSL.h"])
            ),
            dependencies: [
                .library(path: .relativeToRoot("macosx/lib/libcrypto.a"), publicHeaders:  .relativeToRoot("macosx/include/OpenSSL"), swiftModuleMap: nil, condition: nil),
                .library(path: .relativeToRoot("macosx/lib/libssl.a"), publicHeaders:  .relativeToRoot("macosx/include/OpenSSL"), swiftModuleMap: nil, condition: nil)
            ],
            settings: .settings(base: SettingsDictionary()
                .marketingVersion(marketingVersion)
                .currentProjectVersion("1")
                .bitcodeEnabled(false)
                .otherLinkerFlags([
                    "-Xlinker -all_load"
                ])
                .merging([
                    "BUILD_LIBRARY_FOR_DISTRIBUTION": "YES",
                    "APPLICATION_EXTENSION_API_ONLY": "YES",
                    "DEFINES_MODULE": "YES",

                    "SKIP_INSTALL": "NO",
                    "COPY_PHASE_STRIP": "NO",

                    "DEVELOPMENT_TEAM": developmentTeam,
                    "CODE_SIGN_IDENTITY": "Developer ID Application",
                    "CODE_SIGN_STYLE": "Manual"
                ])
            )
        ),
        .target(
            name: "OpenSSL (Catalyst)",
            destinations: [.macCatalyst, .macWithiPadDesign],
            product: .framework,
            productName: "OpenSSL",
            bundleId: "com.github.krzyzanowskim.OpenSSL",
            deploymentTargets: .iOS("12.0"),
            infoPlist: .file(path: .relativeToRoot("support/macos_catalyst/Info.plist")),
            sources: [],
            resources: [
                "support/PrivacyInfo.xcprivacy"
            ],
            headers: .headers(
                public: .list([.glob("macosx_catalyst/include/OpenSSL/*.h", excluding: "**/asn1_mac.h"), "support/macos_catalyst/OpenSSL.h"])
            ),
            dependencies: [
                .library(path: .relativeToRoot("macosx_catalyst/lib/libcrypto.a"), publicHeaders:  .relativeToRoot("macosx_catalyst/include/OpenSSL"), swiftModuleMap: nil, condition: nil),
                .library(path: .relativeToRoot("macosx_catalyst/lib/libssl.a"), publicHeaders:  .relativeToRoot("macosx_catalyst/include/OpenSSL"), swiftModuleMap: nil, condition: nil)
            ],
            settings: .settings(base: SettingsDictionary()
                .marketingVersion(marketingVersion)
                .currentProjectVersion("1")
                .bitcodeEnabled(false)
                .otherLinkerFlags([
                    "-Xlinker -all_load"
                ])
                .merging([
                    "DERIVE_MACCATALYST_PRODUCT_BUNDLE_IDENTIFIER": "NO",
                    "BUILD_LIBRARY_FOR_DISTRIBUTION": "YES",
                    "APPLICATION_EXTENSION_API_ONLY": "YES",
                    "DEFINES_MODULE": "YES",

                    "SKIP_INSTALL": "NO",
                    "COPY_PHASE_STRIP": "NO",

                    "DEVELOPMENT_TEAM": developmentTeam,
                    "CODE_SIGN_IDENTITY": "Developer ID Application",
                    "CODE_SIGN_STYLE": "Manual"
                ])
            )
        )
    ]
)



