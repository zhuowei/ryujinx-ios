#!/bin/bash
set -e
mkdir downloaded_binaries
cd downloaded_binaries
# uncomment if you need dotnet sdk...
# if [[ "$(uname -p)" != "arm" ]]
# 	wget https://download.visualstudio.microsoft.com/download/pr/58c27f9f-f988-4a42-be1a-0747657952f0/32c855c8c0ff149e4b3662ff3bc3e632/dotnet-sdk-7.0.101-osx-x64.tar.gz
# fi
wget https://download.visualstudio.microsoft.com/download/pr/d9df94f7-3ea2-41b6-abde-dcb9caa87056/9df759093dcdbc1a1b98feede2da8aaa/dotnet-sdk-7.0.101-osx-arm64.tar.gz
wget https://github.com/Ryujinx/release-channel-macos/releases/download/1.1.0-macos1/Ryujinx-1.1.0-macos1-macos_universal.app.tar.gz
wget https://github.com/zhuowei/Ryujinx/releases/download/v0.0.1/ryujinx_arm64_build.tar.xz
cd ..
mkdir dotnetarm64 binaryrel
# uncomment if you need dotnet sdk...
# if [[ "$(uname -p)" = "arm" ]]
# then
# 	ln -s dotnetarm64 dotnet
# else
# 	mkdir dotnet
# 	cd dotnet
# 	tar xf ../downloaded_binaries/dotnet-sdk-7.0.101-osx-x64.tar.gz
# 	cd ..
# fi
cd dotnetarm64
tar xf ../downloaded_binaries/dotnet-sdk-7.0.101-osx-arm64.tar.gz
cd ../binaryrel
tar xf ../downloaded_binaries/Ryujinx-1.1.0-macos1-macos_universal.app.tar.gz
cd ..
tar xf downloaded_binaries/ryujinx_arm64_build.tar.xz
