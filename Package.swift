// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ResponsiveLayoutKit",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "ResponsiveLayoutKit",
            targets: ["ResponsiveLayoutKit"]
        ),
    ],
    targets: [
        .target(
            name: "ResponsiveLayoutKit"
        ),
        // The runnable demo lives in Demo/ as a standalone Xcode app project
        // (SwiftPM cannot build an iOS .app). It references this package as a
        // local dependency and is never part of any product, so consumers of
        // the library never build or link it. See Demo/README or the root
        // README for setup.
        .testTarget(
            name: "ResponsiveLayoutKitTests",
            dependencies: ["ResponsiveLayoutKit"]
        ),
    ]
)
