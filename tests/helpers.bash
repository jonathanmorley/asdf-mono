#!/usr/bin/env bash

# Shared test helpers for asdf-pnpm bats tests

# Patch shebangs in asdf directory for Nix compatibility
patchAsdf() {
  if command -v patchShebangs &>/dev/null; then
    patchShebangs "$HOME/.asdf"
  fi
}

# Cache file for list-all results
CACHE_FILE="${BATS_FILE_TMPDIR:-/tmp}/asdf-versions-cache"

# Cache the list-all output to avoid repeated network calls
cache_versions() {
  if [[ ! -f $CACHE_FILE ]]; then
    echo "Testing direct curl..." >&2
    local curl_out
    curl_out=$(curl -Lqs https://download.mono-project.com/archive/ 2>&1 | head -3)
    echo "Curl output (first 3 lines): $curl_out" >&2

    if ! output=$("$PLUGIN_DIR/bin/list-all" 2>&1); then
      echo "Failed to run list-all. Exit code: $?" >&2
      echo "Output: $output" >&2
      return 1
    fi
    if [[ -z $output ]]; then
      echo "list-all returned empty output" >&2
      return 1
    fi
    echo "$output" >"$CACHE_FILE"
  fi
}

# Get cached versions (call cache_versions in setup_file first)
get_cached_versions() {
  cat "$CACHE_FILE"
}
