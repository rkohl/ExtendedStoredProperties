// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "ExtendedStoredProperties",
  platforms: [
    .iOS(.v10),
    .watchOS(.v6),
    .macOS(.v11)]
  ,
  products: [
    .library(
      name: "ExtendedStoredProperties",
      targets: ["ExtendedStoredProperties"]),
  ],
  targets: [
    .target(
      name: "ExtendedStoredProperties",
      dependencies: []),
  ]
)
