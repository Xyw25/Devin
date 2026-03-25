#!/usr/bin/env bash
# get-plans.sh — GET test plans
# Usage: bash scripts/ado/tests/get-plans.sh
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

curl -s \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/test/plans?api-version=7.1"
