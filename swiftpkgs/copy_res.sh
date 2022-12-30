#!/bin/bash
set -e
rm -r RyujinxKit/Sources/RyujinxKit/res || true
mkdir -p RyujinxKit/Sources/RyujinxKit/res/
cp ../dotnetarm64/shared/Microsoft.NETCore.App/7.0.1/*.dll RyujinxKit/Sources/RyujinxKit/res/
cp ../makenet/runtime/artifacts/bin/coreclr/OSX.arm64.Release/System.Private.CoreLib.dll RyujinxKit/Sources/RyujinxKit/res/
cp ../helloworldpls/bin/Debug/net7.0/helloworldpls.dll RyujinxKit/Sources/RyujinxKit/res/
cp ../ryujinx_arm64_build/build/*.dll RyujinxKit/Sources/RyujinxKit/res/
cp ../binaryrel/arm64out/Ryujinx*.dll \
	../binaryrel/arm64out/ARMeilleure.dll \
	../binaryrel/arm64out/Spv.Generator.dll \
	../binaryrel/arm64out/NetCoreServer*.dll \
	../binaryrel/arm64out/SixLabors.ImageSharp*.dll \
	../binaryrel/arm64out/Open.Nat*.dll \
	RyujinxKit/Sources/RyujinxKit/res/
cp /Users/zhuowei/Downloads/hbmenu.nro RyujinxKit/Sources/RyujinxKit/res/
