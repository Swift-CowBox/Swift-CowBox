#!/bin/sh

set -euox pipefail

package() {
  local subcommand="$1"
  
  local versions="510.0.0 510.0.1 510.0.2 510.0.3 600.0.0 600.0.1"
  
  for version in $versions; do
    swift package reset
    swift package resolve
    swift package resolve --version "$version" swift-syntax
    swift ${subcommand} --configuration debug
    swift package clean
    swift ${subcommand} --configuration release
    swift package clean
  done
}

#test() {
#  local configurations="debug release"
#  
#  for configuration in $configurations; do
#    swift build --configuration ${configuration}
#    swift test --configuration ${configuration}
#    swift package clean
#  done
#}

#package() {
#  local versions="510.0.0 510.0.1 510.0.2 510.0.3 600.0.0 600.0.1"
#  
#  for version in $versions; do
#    swift package reset
#    swift package resolve
#    swift package resolve --version "$version" swift-syntax
#    test
#  done
#}

main() {
  local toolchains="Xcode_15.4 Xcode_16 Xcode_16.1 Xcode_16.2 Xcode_16.3_beta"
  
  for toolchain in $toolchains; do
    sudo xcode-select --switch /Applications/${toolchain}.app
    swift --version
    package test
  done
  
  sudo xcode-select --reset
}

main
