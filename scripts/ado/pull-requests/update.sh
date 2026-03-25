#!/usr/bin/env bash
# update.sh — PATCH PR status or completion options
# Usage: bash scripts/ado/pull-requests/update.sh <repo-id> <pr-id> <json-body>
# Example: bash update.sh repo-guid 123 '{"status":"completed","completionOptions":{"deleteSourceBranch":true}}'
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

REPO_ID="${1:?Usage: update.sh <repo-id> <pr-id> <json-body>}"
PR_ID="${2:?Usage: update.sh <repo-id> <pr-id> <json-body>}"
BODY="${3:?Usage: update.sh <repo-id> <pr-id> <json-body>}"

curl -s \
  -X PATCH \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json" \
  -d "${BODY}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/git/repositories/${REPO_ID}/pullrequests/${PR_ID}?api-version=7.1"
