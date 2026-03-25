#!/usr/bin/env bash
# auth.sh — PAT base64 encoding helper
# Usage: source scripts/ado/auth.sh "$PAT_VALUE"
# Sets: ADO_AUTH_HEADER for use in subsequent curl calls

set -euo pipefail

PAT="${1:?Usage: source auth.sh \$PAT_VALUE}"

ADO_AUTH_HEADER="Authorization: Basic $(echo -n ":${PAT}" | base64 -w 0 2>/dev/null || echo -n ":${PAT}" | base64)"

export ADO_AUTH_HEADER
