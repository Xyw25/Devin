#!/usr/bin/env bash
# query.sh — Execute a WIQL query to find work items
# Usage: bash scripts/ado/work-items/query.sh <wiql-query>
# Example: bash query.sh "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.Tags] CONTAINS 'devin-process' AND [System.State] <> 'Closed'"
# Returns: JSON with work item IDs and optional fields
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

WIQL_QUERY="${1:?Usage: query.sh <wiql-query>}"

BODY=$(jq -n --arg query "$WIQL_QUERY" '{"query": $query}')

curl -s \
  -X POST \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json" \
  -d "${BODY}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/wiql?api-version=7.1"
