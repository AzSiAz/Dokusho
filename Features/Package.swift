// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "Common", targets: ["Common"]),
        .library(name: "Reader", targets: ["Reader"]),
        .library(name: "NewReader", targets: ["NewReader"]),
        .library(name: "DataKit", targets: ["DataKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.2.2"),
         .package(url: "https://github.com/groue/GRDB.swift.git", from: "5.24.0"),
         .package(url: "https://github.com/groue/GRDBQuery.git", from: "0.2.0"),
         .package(url: "https://github.com/kean/Nuke", branch: "master"),
         .package(url: "https://github.com/kean/NukeUI", from: "0.8.1"),
         .package(url: "https://github.com/AzSiAz/MangaScraper", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Common",
            dependencies: [
                .byName(name: "Nuke")
            ]),
        .testTarget(
            name: "CommonTests",
            dependencies: ["Common"]),

        
        .target(
            name: "Reader",
            dependencies: [
                .byName(name: "Common"),
                .byName(name: "DataKit"),
                .byName(name: "Nuke"),
                .byName(name: "NukeUI")
            ]),
        .testTarget(
            name: "ReaderTests",
            dependencies: ["Reader"]),

        .target(
            name: "NewReader",
            dependencies: [
                .byName(name: "Kingfisher"),
                .byName(name: "DataKit")
            ]),
        
        .target(
            name: "DataKit",
            dependencies: [
                .byName(name: "Common"),
                .byName(name: "MangaScraper"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .byName(name: "GRDBQuery")
            ]),
        .testTarget(
            name: "DataKitTests",
            dependencies: ["DataKit"]),
    ]
)
