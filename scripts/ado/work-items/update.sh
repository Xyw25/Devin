#!/usr/bin/env bash
# update.sh — PATCH work item fields
# Usage: bash scripts/ado/work-items/update.sh <work-item-id> <json-patch-body>
# Example: bash update.sh 12345 '[{"op":"replace","path":"/fields/System.Title","value":"New Title"}]'
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

WORK_ITEM_ID="${1:?Usage: update.sh <work-item-id> <json-patch-body>}"
BODY="${2:?Usage: update.sh <work-item-id> <json-patch-body>}"

curl -s \
  -X PATCH \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json-patch+json" \
  -d "${BODY}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/${WORK_ITEM_ID}?api-version=7.1"
