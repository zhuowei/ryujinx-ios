import sys
with open(sys.argv[1], "rb") as infile:
    indata = infile.read()
# backport the fix to reserve x18 from https://github.com/Ryujinx/Ryujinx/pull/4114
# GetIntAvailableRegisters
# GetIntCalleeSavedRegisters
outdata = indata.replace(b"\x20\xff\xff\xfd\x1f", b"\x20\xff\xff\xf9\x1f")
with open(sys.argv[2], "wb") as outfile:
    outfile.write(outdata)
