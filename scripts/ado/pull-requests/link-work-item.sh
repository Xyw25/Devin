#!/usr/bin/env bash
# link-work-item.sh — Link a work item to an existing PR (post-creation)
# Usage: bash scripts/ado/pull-requests/link-work-item.sh <work-item-id> <repo-id> <pr-id>
# Links via ArtifactLink relation on the work item pointing to the PR
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

WORK_ITEM_ID="${1:?Usage: link-work-item.sh <work-item-id> <repo-id> <pr-id>}"
REPO_ID="${2:?Usage: link-work-item.sh <work-item-id> <repo-id> <pr-id>}"
PR_ID="${3:?Usage: link-work-item.sh <work-item-id> <repo-id> <pr-id>}"

# Construct the artifact link URL for a PR
# Format: vstfs:///Git/PullRequestId/{projectId}%2F{repoId}%2F{prId}
ARTIFACT_URL="vstfs:///Git/PullRequestId/${ADO_PROJECT}%2F${REPO_ID}%2F${PR_ID}"

BODY=$(jq -n \
  --arg url "$ARTIFACT_URL" \
  '[{
    "op": "add",
    "path": "/relations/-",
    "value": {
      "rel": "ArtifactLink",
      "url": $url,
      "attributes": {
        "name": "Pull Request",
        "comment": "Linked by Devin automation"
      }
    }
  }]')

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X PATCH \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json-patch+json" \
  -d "${BODY}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/${WORK_ITEM_ID}?api-version=7.1")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
RESP_BODY=$(echo "$RESPONSE" | sed '$d')
if [[ "$HTTP_CODE" =~ ^2 ]]; then
  echo "$RESP_BODY"
else
  echo "ERROR: Work item link failed (HTTP ${HTTP_CODE})" >&2
  echo "$RESP_BODY" >&2
  exit 1
fi
