#!/usr/bin/env bash
# get-page.sh — GET wiki page + capture ETag
# Usage: bash scripts/ado/wiki/get-page.sh <page-path>
# Example: bash get-page.sh "/FunctionalityIndex"
# Outputs: JSON response body to stdout, ETag to stderr (capture with 2>etag.txt)
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_WIKI_ID, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

PAGE_PATH="${1:?Usage: get-page.sh <page-path>}"

# URL-encode the path
ENCODED_PATH=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${PAGE_PATH}', safe=''))" 2>/dev/null \
  || echo -n "$PAGE_PATH" | sed 's|/|%2F|g')

RESPONSE_FILE=$(mktemp)
HEADER_FILE=$(mktemp)

HTTP_CODE=$(curl -s -w "%{http_code}" \
  -o "${RESPONSE_FILE}" \
  -D "${HEADER_FILE}" \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wiki/wikis/${ADO_WIKI_ID}/pages?path=${ENCODED_PATH}&includeContent=true&api-version=7.1")

# Extract ETag from headers (case-insensitive)
ETAG=$(grep -i "^etag:" "${HEADER_FILE}" | sed 's/^[eE][tT][aA][gG]: *//' | tr -d '\r\n' || true)

# Output ETag to stderr for capture
if [ -n "${ETAG}" ]; then
  echo "${ETAG}" >&2
fi

# Output response body to stdout
cat "${RESPONSE_FILE}"

# Cleanup
rm -f "${RESPONSE_FILE}" "${HEADER_FILE}"

# Exit with error if not 200
if [ "${HTTP_CODE}" != "200" ]; then
  exit 1
fi
