#!/usr/bin/env bash
# get-case-detail.sh — GET full details of a test case work item
# Usage: bash scripts/ado/tests/get-case-detail.sh <test-case-id>
# Returns the test case work item with all fields including steps XML
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

TEST_CASE_ID="${1:?Usage: get-case-detail.sh <test-case-id>}"

# Test cases are work items — use the work items API with fields expansion
curl -s \
  -H "${ADO_AUTH_HEADER}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/${TEST_CASE_ID}?%24expand=all&api-version=7.1"
