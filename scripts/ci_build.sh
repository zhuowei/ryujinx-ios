#!/bin/bash
set -e
# intended to be run from a clean checkout on GitHub Actions.
sudo xcode-select -s "/Applications/Xcode_14.2.app"
brew install ninja
bash scripts/clone_repos.sh
bash scripts/download_binaries.sh
# GitHub Actions has .Net SDK already
# export PATH="$PWD/dotnet:$PATH"
bash scripts/build_dependencies.sh
bash scripts/extract_ryujinx.sh
bash scripts/build_ryujinxapp.sh
