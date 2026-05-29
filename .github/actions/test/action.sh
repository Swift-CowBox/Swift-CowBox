#!/bin/bash

set -euox pipefail

function main() {
  swift --version
  swift package resolve
  swift package resolve --version ${INPUT_SWIFT_SYNTAX_VERSION} swift-syntax
  swift test --configuration ${INPUT_CONFIGURATION}
}

main
