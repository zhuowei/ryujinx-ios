#!/usr/bin/env python3
import sys
with open(sys.argv[1], "rb") as infile:
    # yes I know this is 110MB
    indata = infile.read()
# https://py7zr.readthedocs.io/en/latest/archive_format.html
magic_7z = b"7z\xbc\xaf\x27\x1c"
helpers_7z = indata.find(magic_7z)
vulkan_7z = indata.find(magic_7z, helpers_7z + 1)
with open(sys.argv[2], "wb") as outfile:
    outfile.write(indata[vulkan_7z:])
