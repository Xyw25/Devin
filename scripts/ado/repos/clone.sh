#!/usr/bin/env bash
# clone.sh — Clone an ADO repository using PAT authentication
# Usage: bash scripts/ado/repos/clone.sh <repo-name-or-id> [target-directory]
# Constructs the authenticated clone URL from ADO_ORG_URL
# Requires: ADO_ORG_URL, ADO_PROJECT, ADO_PAT_CODE

set -euo pipefail

REPO="${1:?Usage: clone.sh <repo-name-or-id> [target-directory]}"
TARGET_DIR="${2:-${REPO}}"

# Extract org from ADO_ORG_URL (e.g., https://dev.azure.com/myorg -> myorg)
ORG=$(echo "$ADO_ORG_URL" | sed -E 's|https://dev\.azure\.com/([^/]+).*|\1|')

# Construct authenticated clone URL
# Format: https://PAT@dev.azure.com/org/project/_git/repo
CLONE_URL="https://${ADO_PAT_CODE}@dev.azure.com/${ORG}/${ADO_PROJECT}/_git/${REPO}"

git clone "$CLONE_URL" "$TARGET_DIR"

echo "Cloned ${REPO} to ${TARGET_DIR}"
