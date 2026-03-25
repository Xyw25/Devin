#!/usr/bin/env bash
# validate-scripts.sh — Smoke-test all scripts for syntax errors
# Usage: bash scripts/maintenance/validate-scripts.sh
# Checks all .sh files in scripts/ado/ for bash syntax errors.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS_FOUND=0

echo "Validating script syntax..."
echo "---"

while IFS= read -r file; do
  if bash -n "$file" 2>/dev/null; then
    echo "OK: ${file}"
  else
    echo "ERROR: ${file} — syntax error"
    bash -n "$file" 2>&1 | sed 's/^/  /'
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
  fi
done < <(find "$SCRIPT_DIR" -name "*.sh" -type f | sort)

echo "---"
if [ $ERRORS_FOUND -eq 0 ]; then
  echo "All scripts passed syntax validation."
else
  echo "Found ${ERRORS_FOUND} script(s) with syntax errors."
  exit 1
fi
