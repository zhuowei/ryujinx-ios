#!/bin/bash
set -e
rm -rf binaryrel/arm64out || true
# can build sfextract from source...
# cd SingleFileExtractor
# dotnet build
# dotnet src/SingleFileExtractor.CLI/bin/Debug/net7.0/SingleFileExtractor.CLI.dll -o ../binaryrel/arm64out ../binaryrel/Ryujinx.app/Contents/MacOS/Ryujinx
# or use binary install
dotnet tool install --global sfextract --version 1.0.0
lipo -thin arm64 -output binaryrel/ryujinx_arm64 binaryrel/Ryujinx.app/Contents/MacOS/Ryujinx
sfextract -o binaryrel/arm64out binaryrel/ryujinx_arm64
