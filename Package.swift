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
        // Demo app: buildable/runnable from this project (select the
        // ResponsiveLayoutKitDemo scheme), but not part of any product, so
        // consumers of the library never build or link it.
        .executableTarget(
            name: "ResponsiveLayoutKitDemo",
            dependencies: ["ResponsiveLayoutKit"]
        ),
        .testTarget(
            name: "ResponsiveLayoutKitTests",
            dependencies: ["ResponsiveLayoutKit"]
        ),
    ]
)
