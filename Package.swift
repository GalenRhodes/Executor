// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

//@f:0
let package = Package(
    name: "Executor",
    platforms: [ .macOS(.v10_15), .tvOS(.v13), .iOS(.v13), .watchOS(.v6), ],
    products: [ .library(name: "Executor", targets: [ "Executor", ]), ],
    dependencies: [ .package(name: "Rubicon", url: "https://github.com/GalenRhodes/Rubicon", .upToNextMinor(from: "0.2.54")), ],
    targets: [
        .target(name: "Executor", dependencies: [ "Rubicon", ], exclude: [ "Info.plist", ]),
        .testTarget(name: "ExecutorTests", dependencies: [ "Executor", ], exclude: [ "Info.plist", ]),
    ]
)
//@f:1
