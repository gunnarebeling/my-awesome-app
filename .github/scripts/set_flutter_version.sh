#!/bin/bash

# Halt execution after any return of a non-zero value
set -e

main() {
  initialize
  set_flutter_version "$(get_flutter_version)"
}

initialize() {
  # Allow storing Flutter SDK
  git config --global --add safe.directory /home/flutter/flutter-sdk

  # Add FVM to current shell for immediate usage
  export PATH="$PATH:$HOME/.pub-cache/bin"

  # If string is not empty
  if [[ -n "$GITHUB_PATH" ]]; then
    # Add FVM to Github path for later usage
    echo "${HOME}/.pub-cache/bin" >> "$GITHUB_PATH"
  fi
}

get_flutter_version() {
  local file=".fvmrc"

  # If file does not exist or is not a regular file (i.e., a directory, symbolic link, or special file)
  if [[ ! -f "$file" ]]; then
    handle_error "$file not found"
  fi

  # This regex returns whatever value is between the next set of
  # quotes after the flutter keyword
  local version=$(sed -n 's/.*"flutter": *"\([^"]*\)".*/\1/p' "$file")
  # If version is an empty string
  if [[ -z "$version" ]]; then
    handle_error "Error parsing version from $file"
  fi

  printf "%s" "$version"
}

set_flutter_version() {
  local version="$1"

  # If fvm is not installed or is unavailable
  if ! command -v fvm &> /dev/null; then
    printf "fvm not found. Installing fvm...\n"
    dart pub global activate fvm || handle_error "fvm installation failed"
  fi

  printf "Setting Flutter version to %s using fvm...\n" "$version"
  fvm install "$version" || handle_error "fvm install failed for version $version"
  fvm use "$version" || handle_error "fvm use failed for version $version"

  # If string is not empty
  if [[ -n "$GITHUB_ENV" ]]; then
    # Append Flutter version to GITHUB_ENV
    echo "FLUTTER_VERSION=$version" >> "$GITHUB_ENV"
  fi
}

handle_error() {
  local message="$1"

  # Log error to stderr
  printf "Error: %s\n" "$message" >&2

  # Exit script
  return 1
}

main