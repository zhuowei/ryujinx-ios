// swift-tools-version: 5.6

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import AppleProductTypes
import PackageDescription

let package = Package(
  name: "RyujinxApp",
  platforms: [
    .iOS("15.0")
  ],
  products: [
    .iOSApplication(
      name: "RyujinxApp",
      targets: ["AppModule"],
      bundleIdentifier: "com.worthdoingbadly.RyujinxApp",
      teamIdentifier: "3D7RY4393N",
      displayVersion: "1.0",
      bundleVersion: "1",
      appIcon: .placeholder(icon: .coffee),
      accentColor: .presetColor(.cyan),
      supportedDeviceFamilies: [
        .pad,
        .phone,
      ],
      supportedInterfaceOrientations: [
        .portrait,
        .landscapeRight,
        .landscapeLeft,
        .portraitUpsideDown(.when(deviceFamilies: [.pad])),
      ],
      additionalInfoPlistContentFilePath: "MoreInfo.plist"
    )
  ],
  dependencies: [
    .package(path: "../RyujinxKit")
  ],
  targets: [
    .executableTarget(
      name: "AppModule",
      dependencies: [.product(name: "RyujinxKit", package: "RyujinxKit")],
      path: ".",
      linkerSettings: [.unsafeFlags(["-rpath", "@executable_path/Frameworks"])]
    )
  ]
)
