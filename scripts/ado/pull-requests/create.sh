#!/usr/bin/env bash
# create.sh — POST new PR with reviewers and work item links
# Usage: bash scripts/ado/pull-requests/create.sh <repo-id> <source-branch> <target-branch> <title> <description> [reviewer-ids] [work-item-ids]
# reviewer-ids: comma-separated AAD Object ID GUIDs
# work-item-ids: comma-separated work item IDs
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_AUTH_HEADER (source auth.sh first)

set -euo pipefail

REPO_ID="${1:?Usage: create.sh <repo-id> <source-branch> <target-branch> <title> <description> [reviewer-ids] [work-item-ids]}"
SOURCE_BRANCH="${2:?Missing source branch}"
TARGET_BRANCH="${3:?Missing target branch}"
TITLE="${4:?Missing PR title}"
DESCRIPTION="${5:?Missing PR description}"
REVIEWER_IDS="${6:-}"
WORK_ITEM_IDS="${7:-}"

# Ensure branch refs have full prefix
if [[ "$SOURCE_BRANCH" != refs/heads/* ]]; then
  SOURCE_BRANCH="refs/heads/${SOURCE_BRANCH}"
fi
if [[ "$TARGET_BRANCH" != refs/heads/* ]]; then
  TARGET_BRANCH="refs/heads/${TARGET_BRANCH}"
fi

# Build reviewers array
REVIEWERS="[]"
if [ -n "$REVIEWER_IDS" ]; then
  REVIEWERS=$(echo "$REVIEWER_IDS" | tr ',' '\n' | jq -R '{id: .}' | jq -s '.')
fi

# Build work item refs array
WORK_ITEMS="[]"
if [ -n "$WORK_ITEM_IDS" ]; then
  WORK_ITEMS=$(echo "$WORK_ITEM_IDS" | tr ',' '\n' | jq -R '{id: .}' | jq -s '.')
fi

BODY=$(jq -n \
  --arg src "$SOURCE_BRANCH" \
  --arg tgt "$TARGET_BRANCH" \
  --arg title "$TITLE" \
  --arg desc "$DESCRIPTION" \
  --argjson reviewers "$REVIEWERS" \
  --argjson workItems "$WORK_ITEMS" \
  '{
    sourceRefName: $src,
    targetRefName: $tgt,
    title: $title,
    description: $desc,
    reviewers: $reviewers,
    workItemRefs: $workItems
  }')

curl -s \
  -X POST \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json" \
  -d "${BODY}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/git/repositories/${REPO_ID}/pullrequests?api-version=7.1"
