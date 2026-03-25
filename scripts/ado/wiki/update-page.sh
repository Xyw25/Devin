#!/usr/bin/env bash
# update-page.sh — PUT update wiki page with ETag
# Usage: bash scripts/ado/wiki/update-page.sh <page-path> <markdown-content> <etag>
# CRITICAL: ETag is required. Always GET the page first to obtain it.
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_WIKI_ID, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

PAGE_PATH="${1:?Usage: update-page.sh <page-path> <markdown-content> <etag>}"
CONTENT="${2:?Usage: update-page.sh <page-path> <markdown-content> <etag>}"
ETAG="${3:?Usage: update-page.sh <page-path> <markdown-content> <etag> — ETag is REQUIRED for updates}"

# URL-encode the path
ENCODED_PATH=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${PAGE_PATH}', safe=''))" 2>/dev/null \
  || echo -n "$PAGE_PATH" | sed 's|/|%2F|g')

# Build JSON payload
JSON_BODY=$(jq -n --arg content "$CONTENT" '{"content": $content}')

curl -s \
  -X PUT \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json" \
  -H "If-Match: ${ETAG}" \
  -d "${JSON_BODY}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wiki/wikis/${ADO_WIKI_ID}/pages?path=${ENCODED_PATH}&api-version=7.1"
