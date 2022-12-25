// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RyujinxKit",
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "RyujinxKit",
      targets: ["RyujinxKit"])
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "RyujinxKit",
      dependencies: [
        "RJlibcoreclr",
        "RJlibclrjit",
        "RJlibSystem_Globalization_Native",
        "RJlibSystem_IO_Compression_Native",
        "RJlibSystem_IO_Ports_Native",
        "RJlibSystem_Native",
        "RJlibSystem_Net_Security_Native",
        "RJlibSystem_Security_Cryptography_Native_Apple",
        "RJlibMoltenVK",
        "SDL2",
        "FrameworkHeaders",
      ],
      resources: [.copy("res")]),
    .testTarget(
      name: "RyujinxKitTests",
      dependencies: ["RyujinxKit"]),
    .target(
      name: "FrameworkHeaders"
    ),
    .binaryTarget(
      name: "RJlibcoreclr",
      path: "../RJlibcoreclr.xcframework"
    ),
    .binaryTarget(
      name: "RJlibclrjit",
      path: "../RJlibclrjit.xcframework"
    ),
    .binaryTarget(
      name: "RJlibSystem_Globalization_Native",
      path: "../RJlibSystem_Globalization_Native.xcframework"
    ),
    .binaryTarget(
      name: "RJlibSystem_IO_Compression_Native",
      path: "../RJlibSystem_IO_Compression_Native.xcframework"
    ),
    .binaryTarget(
      name: "RJlibSystem_IO_Ports_Native",
      path: "../RJlibSystem_IO_Ports_Native.xcframework"
    ),
    .binaryTarget(
      name: "RJlibSystem_Native",
      path: "../RJlibSystem_Native.xcframework"
    ),
    .binaryTarget(
      name: "RJlibSystem_Net_Security_Native",
      path: "../RJlibSystem_Net_Security_Native.xcframework"
    ),
    .binaryTarget(
      name: "RJlibSystem_Security_Cryptography_Native_Apple",
      path: "../RJlibSystem_Security_Cryptography_Native_Apple.xcframework"
    ),
    .binaryTarget(name: "RJlibMoltenVK", path: "../RJlibMoltenVK.xcframework"),
    .binaryTarget(
      name: "SDL2",
      path: "../../SDL2.xcframework"
    ),
  ]
)
