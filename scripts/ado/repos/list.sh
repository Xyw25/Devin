#!/usr/bin/env bash
# list.sh — List all repositories in the project
# Usage: bash scripts/ado/repos/list.sh
# Returns: JSON with repository names, IDs, and default branch
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

curl -s \
  -H "${ADO_AUTH_HEADER}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/git/repositories?api-version=7.1" \
  | jq '.value[] | {id: .id, name: .name, defaultBranch: .defaultBranch, webUrl: .webUrl}'
