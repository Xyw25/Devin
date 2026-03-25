#!/usr/bin/env bash
# get.sh — GET PR details or list PRs in a repository
# Usage: bash scripts/ado/pull-requests/get.sh <repo-id> [pr-id]
# Without pr-id: lists active PRs in the repository
# With pr-id: gets full details of a specific PR
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

REPO_ID="${1:?Usage: get.sh <repo-id> [pr-id]}"
PR_ID="${2:-}"

if [ -n "$PR_ID" ]; then
  # Get specific PR
  curl -s \
    -H "${ADO_AUTH_HEADER}" \
    "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/git/repositories/${REPO_ID}/pullrequests/${PR_ID}?api-version=7.1"
else
  # List active PRs
  curl -s \
    -H "${ADO_AUTH_HEADER}" \
    "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/git/repositories/${REPO_ID}/pullrequests?searchCriteria.status=active&api-version=7.1"
fi
