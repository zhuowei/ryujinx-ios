#!/usr/bin/env python3
import os
import subprocess

DOTNET_DYLIBS = [
    "libcoreclr.dylib",
    "libclrjit.dylib",
    "libSystem.Globalization.Native.dylib",
    "libSystem.IO.Compression.Native.dylib",
    "libSystem.IO.Ports.Native.dylib",
    "libSystem.Native.dylib",
    "libSystem.Net.Security.Native.dylib",
    "libSystem.Security.Cryptography.Native.Apple.dylib",
]
library_paths = [
    "../makenet/runtime/artifacts/bin/coreclr/OSX.arm64.Release/" + a
    for a in DOTNET_DYLIBS
] + ["../vulkansdk/MoltenVK/dylib/iOS/libMoltenVK.dylib"]
library_args = []
for library_path in library_paths:
    library_name = os.path.basename(library_path)
    library_tag = library_name[:library_name.rfind(".")]
    framework_name = "RJ" + library_tag.replace(".", "_") + ".xcframework"
    subprocess.call(["rm", "-r", framework_name])
    subprocess.check_call([
        "xcodebuild", "-create-xcframework", "-output", framework_name,
        "-library", library_path
    ])
