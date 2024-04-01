// swift-tools-version: 5.9.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Benchmarks",
  platforms: [
    .macOS(.v13)
  ],
  dependencies: [
    .package(
      name: "CowBox",
      path: ".."
    ),
    .package(
      url: "https://github.com/apple/swift-collections.git",
      branch: "main"
    ),
    .package(
      url: "https://github.com/ordo-one/package-benchmark",
      branch: "main"
    ),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .executableTarget(
      name: "Benchmarks",
      dependencies: [
        "CowBox",
        .product(
          name: "Collections",
          package: "swift-collections"
        ),
        .product(
          name: "Benchmark",
          package: "package-benchmark"
        ),
      ],
      plugins: [
        .plugin(
          name: "BenchmarkPlugin",
          package: "package-benchmark"
        ),
      ]
    ),
  ]
)
