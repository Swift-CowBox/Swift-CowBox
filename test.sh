#!/bin/bash

set -euox pipefail

main() {
  local toolchains="Xcode_15.4 Xcode_16 Xcode_16.1 Xcode_16.2 Xcode_16.3_beta"
  local versions="510.0.0 510.0.1 510.0.2 510.0.3 600.0.0 600.0.1"
  
  for toolchain in $toolchains; do
    sudo xcode-select --switch /Applications/${toolchain}.app
    for version in $versions; do
      swift --version
      swift package reset
      swift package resolve
      swift package resolve --version "$version" swift-syntax
      swift build
      swift test
    done
  done
  
  sudo xcode-select --reset
}

main
