#!/usr/bin/env bats

load helpers

setup_file() {
  PLUGIN_DIR="${ASDF_PNPM_PLUGIN_REPO}"
  export PLUGIN_DIR
  cache_versions
}

@test "list-all returns versions" {
  VERSIONS=$(get_cached_versions)
  [ -n "$VERSIONS" ]
}

@test "list-all returns at least 100 versions" {
  VERSIONS=$(get_cached_versions)
  VERSION_COUNT=$(echo "$VERSIONS" | wc -w | tr -d ' ')
  [ "$VERSION_COUNT" -ge 100 ]
}

@test "list-all returns space-separated versions" {
  VERSIONS=$(get_cached_versions)
  # Should not contain newlines within the output
  [[ $VERSIONS != *$'\n'* ]]
}

@test "list-all includes known versions" {
  VERSIONS=$(get_cached_versions)
  [[ " $VERSIONS " == *" 1.1.9 "* ]]
  [[ " $VERSIONS " == *" 2.0 "* ]]
  [[ " $VERSIONS " == *" 3.0.0 "* ]]
  [[ " $VERSIONS " == *" 4.0.0 "* ]]
  [[ " $VERSIONS " == *" 5.0.0 "* ]]
  [[ " $VERSIONS " == *" 6.0.0 "* ]]
}

@test "list-all returns versions in ascending order" {
  VERSIONS=$(get_cached_versions)
  FIRST_VERSION=$(echo "$VERSIONS" | cut -d' ' -f1)
  LAST_VERSION=$(echo "$VERSIONS" | awk '{print $NF}')

  FIRST_MAJOR=$(echo "$FIRST_VERSION" | cut -d. -f1)
  LAST_MAJOR=$(echo "$LAST_VERSION" | cut -d. -f1)

  # First major version should be less than or equal to last
  [ "$FIRST_MAJOR" -le "$LAST_MAJOR" ]
}
