#!/usr/bin/env bash
# clone.sh — Clone an ADO repository using PAT authentication
# Usage: bash scripts/ado/repos/clone.sh <repo-name-or-id> [target-directory]
# If target directory already exists, pulls latest instead of cloning.
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_PAT_CODE

set -euo pipefail

REPO="${1:?Usage: clone.sh <repo-name-or-id> [target-directory]}"
TARGET_DIR="${2:-${REPO}}"

# Extract org from ADO_ORG_URL (e.g., https://dev.azure.com/myorg -> myorg)
ORG=$(echo "$ADO_ORG_URL" | sed -E 's|https://dev\.azure\.com/([^/]+).*|\1|')

# Construct authenticated clone URL
CLONE_URL="https://${ADO_PAT_CODE}@dev.azure.com/${ORG}/${ADO_PROJECT}/_git/${REPO}"

if [ -d "$TARGET_DIR/.git" ]; then
  # Directory exists and is a git repo — pull instead of clone
  echo "Repository already exists at ${TARGET_DIR}, pulling latest..."
  cd "$TARGET_DIR"
  git pull 2>/dev/null || {
    echo "ERROR: git pull failed for ${REPO} at ${TARGET_DIR}" >&2
    exit 1
  }
  echo "Updated ${REPO} at ${TARGET_DIR}"
else
  # Clone fresh — redirect stderr to avoid leaking PAT in error messages
  ERR_FILE=$(mktemp)
  if git clone "$CLONE_URL" "$TARGET_DIR" 2>"$ERR_FILE"; then
    rm -f "$ERR_FILE"
    echo "Cloned ${REPO} to ${TARGET_DIR}"
  else
    # Sanitize error message — remove PAT from URL before displaying
    SANITIZED=$(sed "s|${ADO_PAT_CODE}|***|g" "$ERR_FILE")
    rm -f "$ERR_FILE"
    echo "ERROR: Clone failed for ${REPO}" >&2
    echo "$SANITIZED" >&2
    exit 1
  fi
fi
