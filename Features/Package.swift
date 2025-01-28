// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "Common", targets: ["Common"]),
        .library(name: "SharedUI", targets: ["SharedUI"]),
        .library(name: "DataKit", targets: ["DataKit"]),
        .library(name: "Reader", targets: ["Reader"]),
        .library(name: "MangaDetail", targets: ["MangaDetail"]),
        .library(name: "MangaScraper", targets: ["MangaScraper"]),
        .library(name: "SettingsTab", targets: ["SettingsTab"]),
        .library(name: "HistoryTab", targets: ["HistoryTab"]),
        .library(name: "Backup", targets: ["Backup"]),
        .library(name: "DynamicCollection", targets: ["DynamicCollection"]),
        .library(name: "LibraryTab", targets: ["LibraryTab"]),
        .library(name: "ExploreTab", targets: ["ExploreTab"]),
    ],
    dependencies: [
         .package(url: "https://github.com/groue/GRDB.swift.git", exact: "6.29.3"),
         .package(url: "https://github.com/groue/GRDBQuery.git", exact: "0.7.0"),
         .package(url: "https://github.com/kean/Nuke", exact: "11.3.1"),
         .package(url: "https://github.com/scinfu/SwiftSoup.git", branch: "master"),
         .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.3")),
         .package(url: "https://github.com/muukii/JAYSON", exact: "2.5.0"),
         .package(url: "https://github.com/apptekstudios/SwiftUILayouts", branch: "main"),
    ],
    targets: [
        .target(
            name: "MangaScraper",
            dependencies: [
                .byName(name: "SwiftSoup"),
                .byName(name: "JAYSON"),
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .testTarget(name: "MangaScraperTests", dependencies: ["MangaScraper"]),

        .target(
            name: "Common",
            dependencies: [
                .product(name: "Nuke", package: "Nuke")
            ]
        ),

        .target(
            name: "SharedUI",
            dependencies: [
                .byName(name: "Common"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke")
            ]
        ),
        
        .target(
            name: "Reader",
            dependencies: [
                .byName(name: "Common"),
                .byName(name: "DataKit"),
                .byName(name: "MangaScraper"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke")
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
                .byName(name: "SwiftUILayouts"),
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
                .byName(name: "GRDBQuery"),
                .byName(name: "SharedUI"),
                .byName(name: "MangaDetail")
            ]
        ),
        
        .target(
            name: "Backup",
            dependencies: [
                .byName(name: "DataKit"),
                .byName(name: "Common"),
            ]
        ),
        
        .target(
            name: "DynamicCollection",
            dependencies: [
                .byName(name: "DataKit"),
                .byName(name: "Common"),
                .byName(name: "GRDBQuery"),
                .byName(name: "SharedUI"),
                .byName(name: "MangaDetail"),
                .byName(name: "MangaScraper")
            ]
        ),
        
        .target(
            name: "LibraryTab",
            dependencies: [
                .byName(name: "DataKit"),
                .byName(name: "Common"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .byName(name: "GRDBQuery"),
                .byName(name: "SharedUI"),
                .byName(name: "MangaDetail"),
                .byName(name: "MangaScraper"),
                .byName(name: "DynamicCollection"),
            ]
        ),
        
        .target(
            name: "ExploreTab",
            dependencies: [
                .byName(name: "DataKit"),
                .byName(name: "Common"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .byName(name: "GRDBQuery"),
                .byName(name: "SharedUI"),
                .byName(name: "MangaDetail"),
                .byName(name: "MangaScraper"),
                .product(name: "Collections", package: "swift-collections"),
            ]
        ),
    ],
    swiftLanguageModes: [.version("6")]
)
