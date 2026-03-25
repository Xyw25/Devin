#!/usr/bin/env bash
# get-comments.sh — List comments on a work item
# Usage: bash scripts/ado/work-items/get-comments.sh <work-item-id> [top] [order]
# top: max number of comments (default: 200)
# order: "asc" or "desc" (default: "desc" — newest first)
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

WORK_ITEM_ID="${1:?Usage: get-comments.sh <work-item-id> [top] [order]}"
TOP="${2:-200}"
ORDER="${3:-desc}"

curl -s \
  -H "${ADO_AUTH_HEADER}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/${WORK_ITEM_ID}/comments?%24top=${TOP}&order=${ORDER}&api-version=7.1-preview.4"
