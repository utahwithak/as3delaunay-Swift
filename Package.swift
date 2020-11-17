// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "Delaunay",
  products: [
    .library(
      name: "Delaunay",
      targets: ["Delaunay"]),
  ],
  targets: [
    .target(name: "Delaunay"),
    .testTarget(
      name: "DelaunayTests",
      dependencies: ["Delaunay"]
    ),
  ]
)
