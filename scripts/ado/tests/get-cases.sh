#!/usr/bin/env bash
# get-cases.sh — GET test cases in a suite
# Usage: bash scripts/ado/tests/get-cases.sh <plan-id> <suite-id>
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

PLAN_ID="${1:?Usage: get-cases.sh <plan-id> <suite-id>}"
SUITE_ID="${2:?Usage: get-cases.sh <plan-id> <suite-id>}"

curl -s \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/test/plans/${PLAN_ID}/suites/${SUITE_ID}/testcases?api-version=7.1"
