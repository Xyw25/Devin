#!/usr/bin/env bash
# check-api-versions.sh — Detect deprecated API versions in scripts
# Usage: bash scripts/maintenance/check-api-versions.sh
# Scans all .sh files in scripts/ado/ for API version strings and reports any
# that do not match the pinned version (7.1).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/../ado" && pwd)"
PINNED_VERSION="7.1"
ISSUES_FOUND=0

echo "Checking API versions in scripts (pinned: ${PINNED_VERSION})..."
echo "---"

while IFS= read -r file; do
  # Find all api-version parameters
  while IFS= read -r match; do
    VERSION=$(echo "$match" | grep -oP 'api-version=\K[0-9.]+(-preview[0-9.]*)?')
    if [ -n "$VERSION" ]; then
      # Allow 7.1-preview.* for comments API only
      if [[ "$VERSION" == "${PINNED_VERSION}" ]]; then
        continue
      elif [[ "$VERSION" == "${PINNED_VERSION}-preview."* ]]; then
        echo "INFO: ${file}: uses preview version ${VERSION} (acceptable for preview-only endpoints)"
      else
        echo "WARNING: ${file}: uses api-version=${VERSION} (expected ${PINNED_VERSION})"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
      fi
    fi
  done < <(grep -n "api-version=" "$file" 2>/dev/null || true)
done < <(find "$SCRIPT_DIR" -name "*.sh" -type f)

echo "---"
if [ $ISSUES_FOUND -eq 0 ]; then
  echo "All scripts use the pinned API version (${PINNED_VERSION})."
else
  echo "Found ${ISSUES_FOUND} script(s) with non-standard API versions."
  exit 1
fi
