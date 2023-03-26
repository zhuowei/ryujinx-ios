#!/bin/sh
set -e
tar cJf prebuilts.tar.xz SDL2.xcframework swiftpkgs/*.xcframework swiftpkgs/RyujinxKit/Sources/RyujinxKit/res
