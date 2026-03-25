#!/usr/bin/env bash
# add-comment.sh — POST a comment thread on a PR
# Usage: bash scripts/ado/pull-requests/add-comment.sh <repo-id> <pr-id> <comment-text> [status]
# status: "active" (default), "fixed", "pending", "wontFix", "closed"
# For inline comments, add threadContext to the body (see devin/knowledge/ado-pr-comments.md)
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

REPO_ID="${1:?Usage: add-comment.sh <repo-id> <pr-id> <comment-text> [status]}"
PR_ID="${2:?Usage: add-comment.sh <repo-id> <pr-id> <comment-text> [status]}"
COMMENT_TEXT="${3:?Usage: add-comment.sh <repo-id> <pr-id> <comment-text> [status]}"
STATUS="${4:-active}"

# Map status string to integer
case "$STATUS" in
  active)  STATUS_INT=1 ;;
  fixed)   STATUS_INT=2 ;;
  wontFix) STATUS_INT=3 ;;
  closed)  STATUS_INT=4 ;;
  pending) STATUS_INT=5 ;;
  *)       STATUS_INT=1 ;;
esac

BODY=$(jq -n \
  --arg text "$COMMENT_TEXT" \
  --argjson status "$STATUS_INT" \
  '{
    "comments": [{"parentCommentId": 0, "content": $text, "commentType": 1}],
    "status": $status
  }')

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json" \
  -d "${BODY}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/git/repositories/${REPO_ID}/pullrequests/${PR_ID}/threads?api-version=7.1")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
RESP_BODY=$(echo "$RESPONSE" | sed '$d')
if [[ "$HTTP_CODE" =~ ^2 ]]; then
  echo "$RESP_BODY"
else
  echo "ERROR: PR comment failed (HTTP ${HTTP_CODE})" >&2
  echo "$RESP_BODY" >&2
  exit 1
fi
