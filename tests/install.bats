#!/usr/bin/env bats

load helpers

setup_file() {
  PLUGIN_DIR="${ASDF_PNPM_PLUGIN_REPO}"
  export PLUGIN_DIR
  cache_versions
}

teardown() {
  if [ -n "${ASDF_INSTALL_PATH:-}" ]; then
    rm -rf "$ASDF_INSTALL_PATH"
  fi
}

install_mono() {
  local version="$1"
  export ASDF_INSTALL_VERSION="$version"
  export ASDF_INSTALL_TYPE="version"

  ASDF_INSTALL_PATH="$(mktemp -d)"
  export ASDF_INSTALL_PATH

  bash "$PLUGIN_DIR/bin/install"
}

get_versions_to_test() {
  # Get latest stable version of major versions 8, 9, 10
  # list-all returns versions in sorted order, so tail -1 gives the latest
  local all_versions
  all_versions=$(get_cached_versions | tr ' ' '\n')
  for major in 5 6; do
    echo "$all_versions" | grep -E "^${major}\.[0-9]+\.[0-9]+$" | tail -1
  done
}

@test "install script exists and is executable" {
  [ -f "$PLUGIN_DIR/bin/install" ]
  [ -x "$PLUGIN_DIR/bin/install" ]
}

@test "install and verify all major versions" {
  for version in $(get_versions_to_test); do
    echo "# Testing mono $version" >&3
    install_mono "$version"

    [ -x "$ASDF_INSTALL_PATH/bin/mono" ]

    "$ASDF_INSTALL_PATH/bin/mono" --version

    [[ "$("$ASDF_INSTALL_PATH/bin/mono" --version)" =~ Mono\ JIT\ compiler\ version\ $version ]]

    rm -rf "$ASDF_INSTALL_PATH"
  done
}
