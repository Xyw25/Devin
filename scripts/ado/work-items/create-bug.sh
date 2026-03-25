#!/usr/bin/env bash
# create-bug.sh — POST new Bug with reproduction steps
# Usage: bash scripts/ado/work-items/create-bug.sh <title> <repro-steps-html> [severity] [priority] [area-path]
# Severity: "1 - Critical", "2 - High", "3 - Medium", "4 - Low"
# Priority: 1, 2, 3, 4
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

TITLE="${1:?Usage: create-bug.sh <title> <repro-steps-html> [severity] [priority] [area-path]}"
REPRO_STEPS="${2:?Usage: create-bug.sh <title> <repro-steps-html> [severity] [priority] [area-path]}"
SEVERITY="${3:-3 - Medium}"
PRIORITY="${4:-2}"
AREA_PATH="${5:-${ADO_DEFAULT_AREA:-}}"

BODY=$(jq -n \
  --arg title "$TITLE" \
  --arg repro "$REPRO_STEPS" \
  --arg severity "$SEVERITY" \
  --argjson priority "$PRIORITY" \
  --arg area "$AREA_PATH" \
  '[
    {"op": "add", "path": "/fields/System.Title", "value": $title},
    {"op": "add", "path": "/fields/Microsoft.VSTS.TCM.ReproSteps", "value": $repro},
    {"op": "add", "path": "/fields/Microsoft.VSTS.Common.Severity", "value": $severity},
    {"op": "add", "path": "/fields/Microsoft.VSTS.Common.Priority", "value": $priority}
  ] + (if $area != "" then [{"op": "add", "path": "/fields/System.AreaPath", "value": $area}] else [] end)')

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json-patch+json" \
  -d "${BODY}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/\$Bug?api-version=7.1")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
RESP_BODY=$(echo "$RESPONSE" | sed '$d')
if [[ "$HTTP_CODE" =~ ^2 ]]; then
  echo "$RESP_BODY"
else
  echo "ERROR: Bug creation failed (HTTP ${HTTP_CODE})" >&2
  echo "$RESP_BODY" >&2
  exit 1
fi
