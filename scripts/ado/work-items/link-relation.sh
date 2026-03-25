#!/usr/bin/env bash
# link-relation.sh — PATCH to add a relation (e.g., TestedBy) to a work item
# Usage: bash scripts/ado/work-items/link-relation.sh <source-work-item-id> <relation-type> <target-work-item-id> [comment]
# Example: bash link-relation.sh 12345 "Microsoft.VSTS.Common.TestedBy-Forward" 67890
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

SOURCE_ID="${1:?Usage: link-relation.sh <source-id> <relation-type> <target-id> [comment]}"
RELATION_TYPE="${2:?Usage: link-relation.sh <source-id> <relation-type> <target-id> [comment]}"
TARGET_ID="${3:?Usage: link-relation.sh <source-id> <relation-type> <target-id> [comment]}"
COMMENT="${4:-Linked by Devin automation}"

TARGET_URL="${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/${TARGET_ID}"

BODY=$(jq -n \
  --arg rel "$RELATION_TYPE" \
  --arg url "$TARGET_URL" \
  --arg comment "$COMMENT" \
  '[{
    "op": "add",
    "path": "/relations/-",
    "value": {
      "rel": $rel,
      "url": $url,
      "attributes": {
        "comment": $comment
      }
    }
  }]')

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X PATCH \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json-patch+json" \
  -d "${BODY}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/${SOURCE_ID}?api-version=7.1")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
RESP_BODY=$(echo "$RESPONSE" | sed '$d')
if [[ "$HTTP_CODE" =~ ^2 ]]; then
  echo "$RESP_BODY"
else
  echo "ERROR: Relation link failed (HTTP ${HTTP_CODE})" >&2
  echo "$RESP_BODY" >&2
  exit 1
fi
