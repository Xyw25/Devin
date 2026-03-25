#!/usr/bin/env bash
# comment.sh — POST comment on work item
# Usage: bash scripts/ado/work-items/comment.sh <work-item-id> <html-comment-text>
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

WORK_ITEM_ID="${1:?Usage: comment.sh <work-item-id> <html-comment-text>}"
COMMENT_TEXT="${2:?Usage: comment.sh <work-item-id> <html-comment-text>}"

# Build JSON payload — escape double quotes in comment text
JSON_BODY=$(jq -n --arg text "$COMMENT_TEXT" '{"text": $text}')

curl -s \
  -X POST \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json" \
  -d "${JSON_BODY}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/${WORK_ITEM_ID}/comments?api-version=7.1-preview.4"
