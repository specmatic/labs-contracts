#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LICENSE_DIR="${HOME}/.specmatic"
LINTER_CONFIG="specmatic-linter.yaml"

cd "$ROOT_DIR"

OPENAPI_SPECS=()
SPEC_CANDIDATES=()
SKIPPED_SPECS=()

if [ "$#" -gt 0 ]; then
  SPEC_CANDIDATES=("$@")
else
  while IFS= read -r spec_path; do
    SPEC_CANDIDATES+=("$spec_path")
  done < <(find common/openapi openapi -type f \( -iname '*.yaml' -o -iname '*.yml' -o -iname '*.json' \) | sort)
fi

for spec_path in "${SPEC_CANDIDATES[@]}"; do
  should_skip=false
  if [ "${#SKIPPED_SPECS[@]}" -gt 0 ]; then
    for skipped_spec in "${SKIPPED_SPECS[@]}"; do
      if [ "$spec_path" = "$skipped_spec" ]; then
        should_skip=true
        break
      fi
    done
  fi

  if [ "$should_skip" = true ]; then
    continue
  fi

  if [ -f "$spec_path" ] && grep -Eq '^(openapi|swagger):' "$spec_path"; then
    OPENAPI_SPECS+=("$spec_path")
  fi
done

if [ "${#OPENAPI_SPECS[@]}" -eq 0 ]; then
  echo "No OpenAPI spec files found under common/openapi or openapi."
  exit 0
fi

echo "Running Specmatic linter on ${#OPENAPI_SPECS[@]} OpenAPI specs."

docker run --rm \
  -v "$ROOT_DIR:/usr/src/app" \
  -v "$LICENSE_DIR:/root/.specmatic:ro" \
  -w /usr/src/app \
  specmatic/enterprise \
  lint "${OPENAPI_SPECS[@]}" --config "$LINTER_CONFIG"
