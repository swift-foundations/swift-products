// swift-tools-version: 6.4

import PackageDescription

extension String {
    static let products: Self = "Products"
    var live: Self { self + " Live" }
    var tests: Self { self + " Tests" }
}

extension Target.Dependency {
    static var products: Self { .target(name: .products) }
    static var dependencies: Self { .product(name: "Dependencies", package: "swift-dependencies") }
    static var entitlement: Self { .product(name: "Entitlement", package: "swift-entitlement") }
    static var tagged: Self {
        .product(name: "Tagged Primitives", package: "swift-tagged-primitives")
    }
    static var witnesses: Self { .product(name: "Witnesses", package: "swift-witnesses") }
}

let package = Package(
    name: "swift-products",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .macCatalyst(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: .products,
            targets: [.products]
        ),
        .library(
            name: .products.live,
            targets: [.products.live]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-foundations/swift-dependencies.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-foundations/swift-entitlement.git", branch: "main"),
        .package(
            url: "https://github.com/swift-primitives/swift-tagged-primitives.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-foundations/swift-witnesses.git", branch: "main"),
    ],
    targets: [
        .target(
            name: .products,
            dependencies: [
                .dependencies,
                .entitlement,
                .tagged,
                .witnesses,
            ]
        ),
        .target(
            name: .products.live,
            dependencies: [
                .products,
                .dependencies,
            ]
        ),
        .testTarget(
            name: .products.tests,
            dependencies: [
                .products,
                .product(name: "Dependencies Test Support", package: "swift-dependencies"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableExperimentalFeature("LifetimeDependence"),
            .enableExperimentalFeature("Lifetimes"),
                .enableUpcomingFeature("InferIsolatedConformances"),
            .enableUpcomingFeature("LifetimeDependence"),
        ]
}
