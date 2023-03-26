#!/bin/sh
set -e
rm -r build_output.xcarchive ipa_make || true
cd swiftpkgs
./make_xcframework.py
./copy_res.sh
cd ../xcode/Ryujinx
xcodebuild archive -archivePath "$PWD/../../build_output" -scheme Ryujinx -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO
cd ../../
mkdir -p ipa_make/Payload
cp -a build_output.xcarchive/Products/Applications/Ryujinx.app ipa_make/Payload/
cd ipa_make
7z -tzip a Ryujinx.ipa Payload
