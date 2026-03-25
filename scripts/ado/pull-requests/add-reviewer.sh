#!/usr/bin/env bash
# add-reviewer.sh — PUT reviewer by AAD Object ID
# Usage: bash scripts/ado/pull-requests/add-reviewer.sh <repo-id> <pr-id> <reviewer-aad-id>
# IMPORTANT: reviewer-aad-id must be the AAD Object ID (GUID), not display name or email
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

REPO_ID="${1:?Usage: add-reviewer.sh <repo-id> <pr-id> <reviewer-aad-id>}"
PR_ID="${2:?Usage: add-reviewer.sh <repo-id> <pr-id> <reviewer-aad-id>}"
REVIEWER_ID="${3:?Usage: add-reviewer.sh <repo-id> <pr-id> <reviewer-aad-id>}"

curl -s \
  -X PUT \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json" \
  -d '{"vote": 0}' \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/git/repositories/${REPO_ID}/pullrequests/${PR_ID}/reviewers/${REVIEWER_ID}?api-version=7.1"
