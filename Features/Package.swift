// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "Common", targets: ["Common"]),
        .library(name: "SharedUI", targets: ["SharedUI"]),
        .library(name: "DataKit", targets: ["DataKit"]),
        .library(name: "Reader", targets: ["Reader"]),
        .library(name: "SerieDetail", targets: ["SerieDetail"]),
        .library(name: "SerieScraper", targets: ["SerieScraper"]),
        .library(name: "SettingsTab", targets: ["SettingsTab"]),
        .library(name: "HistoryTab", targets: ["HistoryTab"]),
        .library(name: "Backup", targets: ["Backup"]),
        .library(name: "DynamicCollection", targets: ["DynamicCollection"]),
        .library(name: "LibraryTab", targets: ["LibraryTab"]),
        .library(name: "ExploreTab", targets: ["ExploreTab"]),
    ],
    dependencies: [
         .package(url: "https://github.com/kean/Nuke", exact: "12.1.6"),
         .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", branch: "master"),
         .package(url: "https://github.com/scinfu/SwiftSoup.git", branch: "master"),
         .package(url: "https://github.com/apple/swift-collections.git", exact: "1.0.5"),
         .package(url: "https://github.com/muukii/JAYSON", exact: "2.5.0"),
         .package(url: "https://github.com/apptekstudios/SwiftUILayouts", branch: "main"),
         .package(url: "https://github.com/groue/GRDB.swift.git", exact: "6.21.0"),
         .package(url: "https://github.com/groue/GRDBQuery", exact: "0.7.0"),
         .package(url: "https://github.com/aaronpearce/Harmony", branch: "main"),
    ],
    targets: [
        .target(
            name: "SerieScraper",
            dependencies: [
                .byName(name: "SwiftSoup"),
                .byName(name: "JAYSON"),
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .testTarget(name: "SerieScraperTests", dependencies: ["SerieScraper"]),

        .target(
            name: "Common",
            dependencies: [
                .product(name: "Nuke", package: "Nuke"),
            ]
        ),

        .target(
            name: "SharedUI",
            dependencies: [
                .byName(name: "Common"),
                .byName(name: "SwiftUIX"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke")
            ]
        ),
        
        .target(
            name: "Reader",
            dependencies: [
                .byName(name: "Common"),
                .byName(name: "DataKit"),
                .byName(name: "SerieScraper"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke")
            ]
        ),
        
        .target(
            name: "DataKit",
            dependencies: [
                .byName(name: "Common"),
                .byName(name: "SerieScraper"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .byName(name: "GRDBQuery"),
                .product(name: "Harmony", package: "Harmony")
            ]
        ),
        
        .target(
            name: "SerieDetail",
            dependencies: [
                .byName(name: "SerieScraper"),
                .byName(name: "DataKit"),
                .byName(name: "Common"),
                .byName(name: "SharedUI"),
                .byName(name: "Reader"),
                .byName(name: "SwiftUILayouts")
            ]
        ),
        
        .target(
            name: "SettingsTab",
            dependencies: [
                .byName(name: "DataKit"),
                .byName(name: "Common"),
                .byName(name: "SharedUI"),
                .byName(name: "Backup"),
                .product(name: "Nuke", package: "Nuke")
            ]
        ),
        
        .target(
            name: "HistoryTab",
            dependencies: [
                .byName(name: "DataKit"),
                .byName(name: "SharedUI"),
                .byName(name: "SerieDetail")
            ]
        ),
        
        .target(
            name: "Backup",
            dependencies: [
                .byName(name: "DataKit"),
                .byName(name: "Common")
            ]
        ),
        
        .target(
            name: "DynamicCollection",
            dependencies: [
                .byName(name: "DataKit"),
                .byName(name: "Common"),
                .byName(name: "SharedUI"),
                .byName(name: "SerieDetail"),
                .byName(name: "SerieScraper")
            ]
        ),
        
        .target(
            name: "LibraryTab",
            dependencies: [
                .byName(name: "DataKit"),
                .byName(name: "Common"),
                .byName(name: "SharedUI"),
                .byName(name: "SerieDetail"),
                .byName(name: "SerieScraper"),
                .byName(name: "DynamicCollection")
            ]
        ),
        
        .target(
            name: "ExploreTab",
            dependencies: [
                .byName(name: "DataKit"),
                .byName(name: "Common"),
                .byName(name: "SharedUI"),
                .byName(name: "SerieDetail"),
                .byName(name: "SerieScraper"),
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
    ]
)
