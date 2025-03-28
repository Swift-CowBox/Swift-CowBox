// swift-tools-version: 5.10

import CompilerPluginSupport
import PackageDescription

let platforms: [SupportedPlatform] = [
  .macOS(.v10_15),
  .iOS(.v13),
  .tvOS(.v13),
  .watchOS(.v6),
  .macCatalyst(.v13),
]

let products: [Product] = [
  .library(
    name: "CowBox",
    targets: ["CowBox"]
  ),
  .executable(
    name: "CowBoxClient",
    targets: ["CowBoxClient"]
  ),
]

let dependencies: [Package.Dependency] = [
  .package(
    url: "https://github.com/apple/swift-syntax.git",
    "510.0.0"..<"602.0.0"
  )
]

let targets: [Target] = [
  // Macro implementation that performs the source transformation of a macro.
  .macro(
    name: "CowBoxMacros",
    dependencies: [
      .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
      .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
    ]
  ),
  // Library that exposes a macro as part of its API, which is used in client programs.
  .target(
    name: "CowBox",
    dependencies: ["CowBoxMacros"]
  ),
  // A client of the library, which is able to use the macro in its own code.
  .executableTarget(
    name: "CowBoxClient",
    dependencies: ["CowBox"]
  ),
  // A test target used to develop the macro implementation.
  .testTarget(
    name: "CowBoxTests",
    dependencies: [
      "CowBox",
      "CowBoxMacros",
      .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
    ]
  ),
]

let package = Package(
  name: "swift-cowbox",
  platforms: platforms,
  products: products,
  dependencies: dependencies,
  targets: targets
)
