#!/usr/bin/env bash
# get-attachments.sh — List attachments on a work item
# Usage: bash scripts/ado/work-items/get-attachments.sh <work-item-id>
# Returns: JSON array of attachment objects with url, name, and attributes
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

WORK_ITEM_ID="${1:?Usage: get-attachments.sh <work-item-id>}"

# Fetch work item with relations expanded, then filter for AttachedFile relations
curl -s \
  -H "${ADO_AUTH_HEADER}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/${WORK_ITEM_ID}?%24expand=relations&api-version=7.1" \
  | jq '[.relations[]? | select(.rel == "AttachedFile") | {
      url: .url,
      name: .attributes.name,
      comment: .attributes.comment,
      resourceSize: .attributes.resourceSize
    }]'
