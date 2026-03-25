#!/usr/bin/env bash
# add-attachment.sh — Upload and attach a file to a work item (2-step process)
# Step 1: Upload the file blob to ADO attachment storage
# Step 2: Link the uploaded blob to the work item via PATCH
# Usage: bash scripts/ado/work-items/add-attachment.sh <work-item-id> <file-path> [comment]
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

WORK_ITEM_ID="${1:?Usage: add-attachment.sh <work-item-id> <file-path> [comment]}"
FILE_PATH="${2:?Usage: add-attachment.sh <work-item-id> <file-path> [comment]}"
COMMENT="${3:-Uploaded by Devin automation}"

FILENAME=$(basename "$FILE_PATH")

# Step 1: Upload blob
UPLOAD_RESPONSE=$(curl -s \
  -X POST \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/octet-stream" \
  --data-binary "@${FILE_PATH}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/attachments?fileName=${FILENAME}&api-version=7.1")

ATTACHMENT_URL=$(echo "$UPLOAD_RESPONSE" | jq -r '.url')

if [ -z "$ATTACHMENT_URL" ] || [ "$ATTACHMENT_URL" = "null" ]; then
  echo "ERROR: Failed to upload attachment. Response:" >&2
  echo "$UPLOAD_RESPONSE" >&2
  exit 1
fi

# Step 2: Link blob to work item
BODY=$(jq -n \
  --arg url "$ATTACHMENT_URL" \
  --arg name "$FILENAME" \
  --arg comment "$COMMENT" \
  '[{
    "op": "add",
    "path": "/relations/-",
    "value": {
      "rel": "AttachedFile",
      "url": $url,
      "attributes": {
        "name": $name,
        "comment": $comment
      }
    }
  }]')

curl -s \
  -X PATCH \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json-patch+json" \
  -d "${BODY}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/${WORK_ITEM_ID}?api-version=7.1"
