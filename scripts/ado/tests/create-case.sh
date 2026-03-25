#!/usr/bin/env bash
# create-case.sh — POST new test case work item
# Usage: bash scripts/ado/tests/create-case.sh <title> <area-path> <steps-xml>
# Note: Test cases are work items of type $Test%20Case, created via the work items API
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

TITLE="${1:?Usage: create-case.sh <title> <area-path> <steps-xml>}"
AREA_PATH="${2:?Usage: create-case.sh <title> <area-path> <steps-xml>}"
STEPS_XML="${3:?Usage: create-case.sh <title> <area-path> <steps-xml>}"

BODY=$(jq -n \
  --arg title "$TITLE" \
  --arg area "$AREA_PATH" \
  --arg steps "$STEPS_XML" \
  '[
    {"op": "add", "path": "/fields/System.Title", "value": $title},
    {"op": "add", "path": "/fields/System.AreaPath", "value": $area},
    {"op": "add", "path": "/fields/Microsoft.VSTS.TCM.Steps", "value": $steps}
  ]')

curl -s \
  -X POST \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json-patch+json" \
  -d "${BODY}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/\$Test%20Case?api-version=7.1"
