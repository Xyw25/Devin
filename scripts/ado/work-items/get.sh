#!/usr/bin/env bash
# get.sh — GET work item by ID
# Usage: bash scripts/ado/work-items/get.sh <work-item-id>
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

WORK_ITEM_ID="${1:?Usage: get.sh <work-item-id>}"

curl -s \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/${WORK_ITEM_ID}?%24expand=all&api-version=7.1"
