#!/usr/bin/env bash
# update-page.sh — PUT update wiki page with ETag and retry on conflict
# Usage: bash scripts/ado/wiki/update-page.sh <page-path> <markdown-content> <etag>
# CRITICAL: ETag is required. Always GET the page first to obtain it.
# On 409/412 conflict: automatically re-GETs fresh ETag and retries (max 2 attempts).
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

BASE_URL="${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wiki/wikis/${ADO_WIKI_ID}/pages?path=${ENCODED_PATH}&api-version=7.1"

MAX_RETRIES=2
ATTEMPT=0
CURRENT_ETAG="$ETAG"

while [ $ATTEMPT -le $MAX_RETRIES ]; do
  RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X PUT \
    -H "${ADO_AUTH_HEADER}" \
    -H "Content-Type: application/json" \
    -H "If-Match: ${CURRENT_ETAG}" \
    -d "${JSON_BODY}" \
    "$BASE_URL")

  HTTP_CODE=$(echo "$RESPONSE" | tail -1)
  BODY=$(echo "$RESPONSE" | sed '$d')

  if [[ "$HTTP_CODE" =~ ^2 ]]; then
    echo "$BODY"
    exit 0
  fi

  if [ "$HTTP_CODE" = "409" ] || [ "$HTTP_CODE" = "412" ]; then
    ATTEMPT=$((ATTEMPT + 1))
    if [ $ATTEMPT -gt $MAX_RETRIES ]; then
      echo "ERROR: Wiki update failed after ${MAX_RETRIES} retries (HTTP ${HTTP_CODE} — ETag conflict). Page: ${PAGE_PATH}" >&2
      echo "$BODY" >&2
      exit 1
    fi
    echo "WARN: ETag conflict (HTTP ${HTTP_CODE}), re-fetching fresh ETag (attempt ${ATTEMPT}/${MAX_RETRIES})..." >&2
    # Re-GET page for fresh ETag
    HEADER_FILE=$(mktemp)
    curl -s -D "$HEADER_FILE" -o /dev/null \
      -H "${ADO_AUTH_HEADER}" \
      "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wiki/wikis/${ADO_WIKI_ID}/pages?path=${ENCODED_PATH}&includeContent=true&api-version=7.1"
    CURRENT_ETAG=$(grep -i "^etag:" "$HEADER_FILE" | tr -d '\r' | sed 's/^[Ee][Tt][Aa][Gg]: *//')
    rm -f "$HEADER_FILE"
    if [ -z "$CURRENT_ETAG" ]; then
      echo "ERROR: Could not retrieve fresh ETag for ${PAGE_PATH}" >&2
      exit 1
    fi
    continue
  fi

  # Non-retryable error
  echo "ERROR: Wiki update failed (HTTP ${HTTP_CODE}). Page: ${PAGE_PATH}" >&2
  echo "$BODY" >&2
  exit 1
done
