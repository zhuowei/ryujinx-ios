#!/bin/sh
set -e
rm -r build_output.xcarchive ipa_make || true
cd swiftpkgs
./make_xcframework.py
./copy_res.sh
cd RyujinxApp.swiftpm
xcodebuild archive -archivePath "$PWD/../../build_output" -scheme RyujinxApp -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO
cd ../../
mkdir -p ipa_make/Payload
cp -a build_output.xcarchive/Products/Applications/RyujinxApp.app ipa_make/Payload/
cd ipa_make
7z -tzip a RyujinxApp.ipa Payload
