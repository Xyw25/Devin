#!/usr/bin/env bash
# create-page.sh — PUT new wiki page (no ETag needed for creation)
# Usage: bash scripts/ado/wiki/create-page.sh <page-path> <markdown-content>
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_WIKI_ID, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

PAGE_PATH="${1:?Usage: create-page.sh <page-path> <markdown-content>}"
CONTENT="${2:?Usage: create-page.sh <page-path> <markdown-content>}"

# URL-encode the path
ENCODED_PATH=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${PAGE_PATH}', safe=''))" 2>/dev/null \
  || echo -n "$PAGE_PATH" | sed 's|/|%2F|g')

# Build JSON payload
JSON_BODY=$(jq -n --arg content "$CONTENT" '{"content": $content}')

curl -s \
  -X PUT \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json" \
  -d "${JSON_BODY}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wiki/wikis/${ADO_WIKI_ID}/pages?path=${ENCODED_PATH}&api-version=7.1"
