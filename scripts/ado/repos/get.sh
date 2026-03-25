#!/usr/bin/env bash
# get.sh — GET repository details by name or ID
# Usage: bash scripts/ado/repos/get.sh <repo-name-or-id>
# Returns: Full repository JSON including ID, clone URLs, and default branch
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

REPO="${1:?Usage: get.sh <repo-name-or-id>}"

curl -s \
  -H "${ADO_AUTH_HEADER}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/git/repositories/${REPO}?api-version=7.1"
