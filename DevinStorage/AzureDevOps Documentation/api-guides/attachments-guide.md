# Azure DevOps Attachments API Guide

> Created: 2026-03-25
> API Version: 7.1
> PAT Required: `ADO_PAT_WORKITEMS` (Work Items: Read & Write)

## Overview

Attaching files to work items is a **2-step process**: first upload the binary blob, then link the resulting URL to a work item.

## Step 1: Upload the Blob

**POST** `{ADO_ORG_URL}/{ADO_PROJECT}/_apis/wit/attachments?fileName={name}&api-version=7.1`

The request body is the raw file content with `Content-Type: application/octet-stream`.

```bash
UPLOAD_RESPONSE=$(curl -s -X POST \
  -u ":${ADO_PAT_WORKITEMS}" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @"${FILE_PATH}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/attachments?fileName=$(basename "${FILE_PATH}")&api-version=7.1")

ATTACHMENT_URL=$(echo "${UPLOAD_RESPONSE}" | jq -r '.url')
echo "Blob URL: ${ATTACHMENT_URL}"
```

The response contains:
- `id` — GUID of the uploaded blob
- `url` — full URL to the blob (used in Step 2)

## Step 2: Link the Blob to a Work Item

**PATCH** `{ADO_ORG_URL}/{ADO_PROJECT}/_apis/wit/workitems/{workItemId}?api-version=7.1`

Add an `AttachedFile` relation pointing to the blob URL from Step 1.

```bash
curl -s -X PATCH \
  -u ":${ADO_PAT_WORKITEMS}" \
  -H "Content-Type: application/json-patch+json" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/${WORK_ITEM_ID}?api-version=7.1" \
  -d "[
    {
      \"op\": \"add\",
      \"path\": \"/relations/-\",
      \"value\": {
        \"rel\": \"AttachedFile\",
        \"url\": \"${ATTACHMENT_URL}\",
        \"attributes\": {
          \"comment\": \"Uploaded via API\"
        }
      }
    }
  ]"
```

## Download an Attachment

**GET** the blob URL directly, providing the authorization header.

```bash
curl -s -u ":${ADO_PAT_WORKITEMS}" \
  -o "${OUTPUT_FILE}" \
  "${ATTACHMENT_URL}"
```

## List Attachments on a Work Item

**GET** `{ADO_ORG_URL}/{ADO_PROJECT}/_apis/wit/workitems/{workItemId}?$expand=relations&api-version=7.1`

Filter the `relations` array for entries where `rel` equals `AttachedFile`.

```bash
curl -s -u ":${ADO_PAT_WORKITEMS}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/${WORK_ITEM_ID}?\$expand=relations&api-version=7.1" \
  | jq '.relations[] | select(.rel == "AttachedFile") | {url, attributes}'
```

## Size Limits

- Default maximum file size: **130 MB** per file
- Organization administrators can adjust this limit

## Error Handling

| Status Code | Meaning | Resolution |
|-------------|---------|------------|
| **413** | Request entity too large | File exceeds the size limit. Compress or split the file. |
| **404** | Blob not found | The attachment URL is invalid or the blob was deleted. Re-upload. |
| **401** | Unauthorized | PAT is expired or lacks the `Work Items (Read & Write)` scope. |

## Related Scripts

| Script | Purpose |
|--------|---------|
| `scripts/ado/work-items/add-attachment.sh` | Upload a file and link it to a work item |
| `scripts/ado/work-items/get-attachments.sh` | List all attachments on a work item |
| `scripts/ado/work-items/download-attachment.sh` | Download an attachment by its blob URL |
