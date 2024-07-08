#!/bin/bash

ensure_jq_installed() {
  if ! command -v jq &> /dev/null; then
    printf "jq not found. Installing jq...\n"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      brew install jq || { printf "Error: jq installation failed\n" >&2; return 1; }
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo apt-get update && sudo apt-get install -y jq || { printf "Error: jq installation failed\n" >&2; return 1; }
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

main() {
  ensure_jq_installed || exit 1
  get_flutter_version || exit 1
}

main