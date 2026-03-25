#!/usr/bin/env bash
# create.sh — POST new work item
# Usage: bash scripts/ado/work-items/create.sh <work-item-type> <json-patch-body>
# Example: bash create.sh "Bug" '[{"op":"add","path":"/fields/System.Title","value":"Title"}]'
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

WI_TYPE="${1:?Usage: create.sh <work-item-type> <json-patch-body>}"
BODY="${2:?Usage: create.sh <work-item-type> <json-patch-body>}"

# URL-encode the type (spaces become %20)
ENCODED_TYPE=$(echo -n "$WI_TYPE" | sed 's/ /%20/g')

curl -s \
  -X POST \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json-patch+json" \
  -d "${BODY}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/\$${ENCODED_TYPE}?api-version=7.1"
