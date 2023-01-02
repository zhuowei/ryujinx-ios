#!/bin/bash
set -e
mkdir -p makenet
git clone --branch ios https://github.com/zhuowei/dotnet-runtime.git makenet/runtime
git clone --branch release-2.26.1 https://github.com/libsdl-org/SDL.git
git clone --branch iospls https://github.com/zhuowei/MoltenVK.git
git clone https://github.com/zhuowei/SingleFileExtractor.git
git clone --branch iosbin-hacks https://github.com/zhuowei/Ryujinx.git
