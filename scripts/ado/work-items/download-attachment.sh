#!/usr/bin/env bash
# download-attachment.sh — Download an attachment by URL
# Usage: bash scripts/ado/work-items/download-attachment.sh <attachment-url> <output-path>
# The attachment-url comes from get-attachments.sh output
# Requires: ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

ATTACHMENT_URL="${1:?Usage: download-attachment.sh <attachment-url> <output-path>}"
OUTPUT_PATH="${2:?Usage: download-attachment.sh <attachment-url> <output-path>}"

curl -s \
  -H "${ADO_AUTH_HEADER}" \
  -o "${OUTPUT_PATH}" \
  "${ATTACHMENT_URL}"

echo "Downloaded to: ${OUTPUT_PATH}"
