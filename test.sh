#!/bin/bash

set -eu

main() {
  toolchains="swift-5.10-RELEASE swift-5.10.1-RELEASE swift-6.0-RELEASE swift-6.0.1-RELEASE swift-6.0.2-RELEASE swift-6.0.3-RELEASE"
  versions="510.0.0 510.0.1 510.0.2 510.0.3 600.0.0 600.0.1"
  
  for toolchain in $toolchains; do
    export TOOLCHAINS="$(plutil -extract CFBundleIdentifier raw /Library/Developer/Toolchains/${toolchain}.xctoolchain/Info.plist)"
    for version in $versions; do
      swift --version
      swift package resolve
      swift package resolve --version "$version" swift-syntax
      swift test
      swift package reset
    done
  done
}

main
