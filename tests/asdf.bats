#!/usr/bin/env bats

setup_file() {
  PLUGIN_DIR="${ASDF_PNPM_PLUGIN_REPO}"
  export PLUGIN_DIR
}

# Helper function to test a specific major version of plugin
# Usage: test_version <major_version>
test_version() {
  local major_version="$1"
  local version

  # Resolve latest version for this major (asdf plugin test doesn't support latest:X syntax in Go version)
  version=$("$PLUGIN_DIR/bin/latest-stable" "$major_version")
  [[ -n $version ]] || {
    echo "Failed to resolve latest v${major_version} version"
    return 1
  }

  # Remove any leftover test plugin
  asdf plugin remove "test-v${major_version}" 2>/dev/null || true

  echo "Testing v${major_version} with version ${version}" >&2

  asdf plugin test \
    "test-v${major_version}" \
    "$PLUGIN_DIR" \
    --asdf-tool-version="$version" \
    "mono --version"
}

@test "asdf plugin test v5" {
  test_version 5
}

@test "asdf plugin test v6" {
  test_version 6
}
