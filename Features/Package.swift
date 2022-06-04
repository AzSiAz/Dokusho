// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "Common", targets: ["Common"]),
        .library(name: "SharedUI", targets: ["SharedUI"]),
        .library(name: "DataKit", targets: ["DataKit"]),
        .library(name: "Reader", targets: ["Reader"]),
        .library(name: "MangaDetail", targets: ["MangaDetail"]),
        .library(name: "MangaScraper", targets: ["MangaScraper"])
    ],
    dependencies: [
         .package(url: "https://github.com/groue/GRDB.swift.git", from: "5.24.0"),
         .package(url: "https://github.com/groue/GRDBQuery.git", from: "0.2.0"),
         .package(url: "https://github.com/kean/Nuke", branch: "master"),
         .package(url: "https://github.com/kean/NukeUI", from: "0.8.1"),
         .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", branch: "master"),
         .package(url: "https://github.com/scinfu/SwiftSoup.git", branch: "master"),
         .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),
         .package(url: "https://github.com/muukii/JAYSON", exact: "2.4.0"),
         .package(url: "https://github.com/gh123man/SwiftUI-Refresher", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "MangaScraper",
            dependencies: [
                "SwiftSoup",
                "JAYSON",
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .testTarget(
            name: "MangaScraperTests",
            dependencies: ["MangaScraper"]),

        .target(
            name: "Common",
            dependencies: [
                .byName(name: "Nuke")
            ]
        ),

        .target(
            name: "SharedUI",
            dependencies: [
                .byName(name: "Common"),
                .byName(name: "SwiftUIX"),
                .byName(name: "Nuke"),
                .byName(name: "NukeUI"),
            ]
        ),
        
        .target(
            name: "Reader",
            dependencies: [
                .byName(name: "DataKit"),
                .byName(name: "Nuke")
            ]
        ),
        
        .target(
            name: "DataKit",
            dependencies: [
                .byName(name: "Common"),
                .byName(name: "MangaScraper"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .byName(name: "GRDBQuery")
            ]
        ),
        
        .target(
            name: "MangaDetail",
            dependencies: [
                .byName(name: "MangaScraper"),
                .byName(name: "DataKit"),
                .byName(name: "GRDBQuery"),
                .byName(name: "Common"),
                .byName(name: "SharedUI"),
                .byName(name: "Reader"),
                .product(name: "Refresher", package: "SwiftUI-Refresher")
            ]
        )
    ]
)
