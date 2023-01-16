#!/bin/bash
set -e
mkdir -p makenet
git clone --branch ios https://github.com/zhuowei/dotnet-runtime.git makenet/runtime
git clone --branch ios-2.26.1 https://github.com/zhuowei/SDL.git
git clone --branch iospls https://github.com/zhuowei/MoltenVK.git
git clone https://github.com/zhuowei/SingleFileExtractor.git
# needs arm64 build device?
# git clone --branch iosbin-hacks https://github.com/zhuowei/Ryujinx.git
