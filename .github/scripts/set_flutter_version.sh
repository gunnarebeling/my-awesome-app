#!/bin/bash

# Halt execution after returning non-zero
set -e

main() {
  initialize
  local flutter_version
  flutter_version=$(get_flutter_version) || exit 1
  set_flutter_version "$flutter_version" || exit 1
}

initialize() {
  # Allow storing Flutter SDK
  git config --global --add safe.directory /home/flutter/flutter-sdk

  # Add FVM to current shell for immediate usage
  export PATH="$PATH:$HOME/.pub-cache/bin"

  # Add FVM to Github path for later usage
  if [[ -n "$GITHUB_PATH" ]]; then
    echo "${HOME}/.pub-cache/bin" >> "$GITHUB_PATH"
  fi
}

get_flutter_version() {
  local file=".fvmrc"

  if [[ ! -f "$file" ]]; then
    printf "Error: %s not found\n" "$file" >&2
    return 1
  fi

  local version
  version=$(sed -n 's/.*"flutter": *"\([^"]*\)".*/\1/p' "$file") # This regex returns whatever value is between the next set of quotes after the flutter keyword
  if [[ -z "$version" ]]; then
    printf "Error parsing version from %s\n" "$file" >&2
    return 1
  fi

  printf "%s" "$version"
}

set_flutter_version() {
  local version="$1"

  if ! command -v fvm &> /dev/null; then
    printf "fvm not found. Installing fvm...\n"
    dart pub global activate fvm || { printf "Error: fvm installation failed\n" >&2; return 1; }
  fi

  printf "Setting Flutter version to %s using fvm...\n" "$version"
  fvm install "$version" || { printf "Error: fvm install failed for version %s\n" "$version" >&2; return 1; }
  fvm use "$version" || { printf "Error: fvm use failed for version %s\n" "$version" >&2; return 1; }

  # Optionally, set the version as an environment variable for Github Actions
  if [[ -n "$GITHUB_ENV" ]]; then
    echo "FLUTTER_VERSION=$version" >> "$GITHUB_ENV"
  fi
}

main