#!/bin/bash
set -e
cd makenet/runtime
bash ../../scripts/coreclr_runbuild.sh
cd ../..
xcodebuild -project SDL/Xcode/SDL/SDL.xcodeproj -scheme xcFramework-iOS
cp -a SDL/Xcode/SDL/Products/SDL2.xcframework ./
cd MoltenVK
./fetchDependencies --ios
make ios
cd ..
