#!/bin/sh

set -euox pipefail

function package() {
  local subcommand=${1}
  
  local versions="510.0.0 510.0.1 510.0.2 510.0.3 600.0.0 600.0.1 601.0.0"
  
  for version in ${versions}; do
    swift package reset
    swift package resolve
    swift package resolve --version ${version} swift-syntax
    swift ${subcommand} --configuration debug
    swift package clean
    swift ${subcommand} --configuration release
    swift package clean
  done
}

function main() {
  local versions="15.4 16.0 16.1 16.2 16.3"
  
  for version in ${versions}; do
    export DEVELOPER_DIR="/Applications/Xcode_${version}.app"
    package test
  done
}

main
