import ProjectDescription

private let developmentTeam: SettingValue = "67RAULRX93"
private let marketingVersion: String = "3.3.2000"

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
                public: .list([.glob("iphoneos/include/OpenSSL/*.h", excluding: "**/asn1_mac.h"), "support/OpenSSL.h"])
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
                public: .list([.glob("iphonesimulator/include/OpenSSL/*.h", excluding: "**/asn1_mac.h"), "support/OpenSSL.h"])
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
                public: .list([.glob("macosx/include/OpenSSL/*.h", excluding: "**/asn1_mac.h"), "support/OpenSSL.h"])
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
                public: .list([.glob("macosx_catalyst/include/OpenSSL/*.h", excluding: "**/asn1_mac.h"), "support/OpenSSL.h"])
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
        ),
        .target(
            name: "OpenSSL (visionOS)",
            destinations: [.appleVision],
            product: .framework,
            productName: "OpenSSL",
            bundleId: "com.github.krzyzanowskim.OpenSSL",
            deploymentTargets: .visionOS("1.3"),
            infoPlist: .file(path: .relativeToRoot("support/visionos/Info.plist")),
            sources: [],
            resources: [
                "support/PrivacyInfo.xcprivacy"
            ],
            headers: .headers(
                public: .list([.glob("visionos/include/OpenSSL/*.h", excluding: "**/asn1_mac.h"), "support/OpenSSL.h"])
            ),
            dependencies: [
                .library(path: .relativeToRoot("visionos/lib/libcrypto.a"), publicHeaders: .relativeToRoot("visionos/include/OpenSSL"), swiftModuleMap: nil, condition: nil),
                .library(path: .relativeToRoot("visionos/lib/libssl.a"), publicHeaders: .relativeToRoot("visionos/include/OpenSSL"), swiftModuleMap: nil, condition: nil)
            ],
            settings: .settings(base: SettingsDictionary()
                .marketingVersion(marketingVersion)
                .currentProjectVersion("1")
                .bitcodeEnabled(false)
                .otherLinkerFlags([
                    "-Xlinker -all_load"
                ])
                .merging([
                    "SUPPORTED_PLATFORMS": "xros",

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
            name: "OpenSSL (visionOS Simulator)",
            destinations: [.appleVision],
            product: .framework,
            productName: "OpenSSL",
            bundleId: "com.github.krzyzanowskim.OpenSSL",
            deploymentTargets: .visionOS("1.0"),
            infoPlist: .file(path: .relativeToRoot("support/visionsimulator/Info.plist")),
            sources: [],
            resources: [
                "support/PrivacyInfo.xcprivacy"
            ],
            headers: .headers(
                public: .list([.glob("visionsimulator/include/OpenSSL/*.h", excluding: "**/asn1_mac.h"), "support/OpenSSL.h"])
            ),
            dependencies: [
                .library(path: .relativeToRoot("visionsimulator/lib/libcrypto.a"), publicHeaders: .relativeToRoot("visionsimulator/include/OpenSSL"), swiftModuleMap: nil, condition: nil),
                .library(path: .relativeToRoot("visionsimulator/lib/libssl.a"), publicHeaders: .relativeToRoot("visionsimulator/include/OpenSSL"), swiftModuleMap: nil, condition: nil)
            ],
            settings: .settings(base: SettingsDictionary()
                .marketingVersion(marketingVersion)
                .currentProjectVersion("1")
                .bitcodeEnabled(false)
                .otherLinkerFlags([
                    "-Xlinker -all_load"
                ])
                .merging([
                    "SUPPORTED_PLATFORMS": "xrsimulator",

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
            name: "OpenSSL (tvOS)",
            destinations: [.appleTv],
            product: .framework,
            productName: "OpenSSL",
            bundleId: "com.github.krzyzanowskim.OpenSSL",
            deploymentTargets: .tvOS("12.0"),
            infoPlist: .file(path: .relativeToRoot("support/appletvos/Info.plist")),
            sources: [],
            resources: [
                "support/PrivacyInfo.xcprivacy"
            ],
            headers: .headers(
                public: .list([.glob("appletvos/include/OpenSSL/*.h", excluding: "**/asn1_mac.h"), "support/OpenSSL.h"])
            ),
            dependencies: [
                .library(path: .relativeToRoot("appletvos/lib/libcrypto.a"), publicHeaders: .relativeToRoot("appletvos/include/OpenSSL"), swiftModuleMap: nil, condition: nil),
                .library(path: .relativeToRoot("appletvos/lib/libssl.a"), publicHeaders: .relativeToRoot("appletvos/include/OpenSSL"), swiftModuleMap: nil, condition: nil)
            ],
            settings: .settings(base: SettingsDictionary()
                .marketingVersion(marketingVersion)
                .currentProjectVersion("1")
                .bitcodeEnabled(false)
                .otherLinkerFlags([
                    "-Xlinker -all_load"
                ])
                .merging([
                    "SUPPORTED_PLATFORMS": "appletvos",

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
            name: "OpenSSL (tvOS Simulator)",
            destinations: [.appleTv],
            product: .framework,
            productName: "OpenSSL",
            bundleId: "com.github.krzyzanowskim.OpenSSL",
            deploymentTargets: .tvOS("12.0"),
            infoPlist: .file(path: .relativeToRoot("support/appletvsimulator/Info.plist")),
            sources: [],
            resources: [
                "support/PrivacyInfo.xcprivacy"
            ],
            headers: .headers(
                public: .list([.glob("appletvsimulator/include/OpenSSL/*.h", excluding: "**/asn1_mac.h"), "support/OpenSSL.h"])
            ),
            dependencies: [
                .library(path: .relativeToRoot("appletvsimulator/lib/libcrypto.a"), publicHeaders: .relativeToRoot("appletvsimulator/include/OpenSSL"), swiftModuleMap: nil, condition: nil),
                .library(path: .relativeToRoot("appletvsimulator/lib/libssl.a"), publicHeaders: .relativeToRoot("appletvsimulator/include/OpenSSL"), swiftModuleMap: nil, condition: nil)
            ],
            settings: .settings(base: SettingsDictionary()
                .marketingVersion(marketingVersion)
                .currentProjectVersion("1")
                .bitcodeEnabled(false)
                .otherLinkerFlags([
                    "-Xlinker -all_load"
                ])
                .merging([
                    "SUPPORTED_PLATFORMS": "appletvsimulator",

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
            name: "OpenSSL (watchOS)",
            destinations: [.appleWatch],
            product: .framework,
            productName: "OpenSSL",
            bundleId: "com.github.krzyzanowskim.OpenSSL",
            deploymentTargets: .watchOS("8.0"),
            infoPlist: .file(path: .relativeToRoot("support/watchos/Info.plist")),
            sources: [],
            resources: [
                "support/PrivacyInfo.xcprivacy"
            ],
            headers: .headers(
                public: .list([.glob("watchos/include/OpenSSL/*.h", excluding: "**/asn1_mac.h"), "support/OpenSSL.h"])
            ),
            dependencies: [
                .library(path: .relativeToRoot("watchos/lib/libcrypto.a"), publicHeaders: .relativeToRoot("watchos/include/OpenSSL"), swiftModuleMap: nil, condition: nil),
                .library(path: .relativeToRoot("watchos/lib/libssl.a"), publicHeaders: .relativeToRoot("watchos/include/OpenSSL"), swiftModuleMap: nil, condition: nil)
            ],
            settings: .settings(base: SettingsDictionary()
                .marketingVersion(marketingVersion)
                .currentProjectVersion("1")
                .bitcodeEnabled(false)
                .otherLinkerFlags([
                    "-Xlinker -all_load"
                ])
                .merging([
                    "SUPPORTED_PLATFORMS": "watchos",

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
            name: "OpenSSL (watchOS Simulator)",
            destinations: [.appleWatch],
            product: .framework,
            productName: "OpenSSL",
            bundleId: "com.github.krzyzanowskim.OpenSSL",
            deploymentTargets: .watchOS("8.0"),
            infoPlist: .file(path: .relativeToRoot("support/watchsimulator/Info.plist")),
            sources: [],
            resources: [
                "support/PrivacyInfo.xcprivacy"
            ],
            headers: .headers(
                public: .list([.glob("watchsimulator/include/OpenSSL/*.h", excluding: "**/asn1_mac.h"), "support/OpenSSL.h"])
            ),
            dependencies: [
                .library(path: .relativeToRoot("watchsimulator/lib/libcrypto.a"), publicHeaders: .relativeToRoot("watchsimulator/include/OpenSSL"), swiftModuleMap: nil, condition: nil),
                .library(path: .relativeToRoot("watchsimulator/lib/libssl.a"), publicHeaders: .relativeToRoot("watchsimulator/include/OpenSSL"), swiftModuleMap: nil, condition: nil)
            ],
            settings: .settings(base: SettingsDictionary()
                .marketingVersion(marketingVersion)
                .currentProjectVersion("1")
                .bitcodeEnabled(false)
                .otherLinkerFlags([
                    "-Xlinker -all_load"
                ])
                .merging([
                    "SUPPORTED_PLATFORMS": "watchsimulator",

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
        )
    ]
)



