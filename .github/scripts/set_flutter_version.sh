#!/bin/bash

ensure_jq_installed() {
  if ! command -v jq &> /dev/null; then
    printf "jq not found. Installing jq...\n"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      brew install jq || { printf "Error: jq installation failed\n" >&2; return 1; }
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      apt-get update && apt-get install -y jq || { printf "Error: jq installation failed\n" >&2; return 1; }
    else
      printf "Error: Unsupported OS type\n" >&2
      return 1
    fi
  fi
}

get_flutter_version() {
  local file=".fvmrc"

  if [[ ! -f "$file" ]]; then
    printf "Error: %s not found\n" "$file" >&2
    return 1
  fi

  local version
  if ! version=$(jq -r '.flutter' "$file"); then
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

main() {
  ensure_jq_installed || exit 1
  local flutter_version
  flutter_version=$(get_flutter_version) || exit 1
  set_flutter_version "$flutter_version" || exit 1
}

main