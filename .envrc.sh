#!/bin/bash

# Dependencies:
# - bash
# - nix

function develop() {
  # Start Development Environment.
  nix develop \
    --experimental-features 'nix-command flakes' \
    --show-trace \
    --verbose \
    # NOTE: asciinema requires X configuration.
    # --ignore-environment \
    "."
}

