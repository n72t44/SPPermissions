// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SPPermissions",
    platforms: [
        .iOS(.v15), .tvOS(.v15)
    ],
    products: [
        .library(name: "SPPermissions", targets: ["SPPermissions"])
    ],
    targets: [
        .target(
            name: "SPPermissions",
            path: "Source/SPPermissions",
            swiftSettings: [
                // Equivalent of the SPPermissions/Location and
                // SPPermissions/Notification CocoaPods subspecs.
                .define("SPPERMISSION_LOCATION"),
                .define("SPPERMISSION_NOTIFICATION")
            ]
        )
    ]
)
