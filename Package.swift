// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "nanosvg",

  products: [
    .library(name: "NanoSVG", targets: ["NanoSVG"])
  ],

  targets: [
    .target(
      name: "NanoSVG",
      dependencies: ["CNanoSVG"],
      path: "Swift/Sources",
    ),
    .target(
      name: "CNanoSVG",
      path: "src",
      publicHeadersPath: "."
    ),
    .testTarget(
      name: "NanoSVGTests",
      dependencies: ["NanoSVG"],
      path: "Swift/Tests",
    ),
  ]
)
