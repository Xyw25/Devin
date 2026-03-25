# Attachment Upload/Download Workflow

> Created: 2026-03-25

## Upload Workflow

Attaching a file to a work item requires two API calls. There is no single-step upload endpoint.

### Step 1: Upload the Binary Blob

Send the raw file as the request body with `application/octet-stream` content type.

```bash
UPLOAD_RESPONSE=$(curl -s -X POST \
  -u ":${ADO_PAT_CODE}" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @"${FILE_PATH}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/attachments?fileName=$(basename "${FILE_PATH}")&api-version=7.1")
```

**Validate the response:**

```bash
ATTACHMENT_URL=$(echo "${UPLOAD_RESPONSE}" | jq -r '.url')
if [ "${ATTACHMENT_URL}" = "null" ] || [ -z "${ATTACHMENT_URL}" ]; then
  echo "ERROR: Upload failed"
  echo "${UPLOAD_RESPONSE}" | jq .
  exit 1
fi
echo "Upload successful: ${ATTACHMENT_URL}"
```

**Error handling for Step 1:**
- **413 Payload Too Large** — File exceeds the 130 MB default limit. Compress or split the file before retrying.
- **401 Unauthorized** — PAT is missing, expired, or lacks the required scope.
- **400 Bad Request** — Missing `fileName` query parameter or malformed request.

### Step 2: Link the Blob to the Work Item

Use a JSON Patch operation to add an `AttachedFile` relation.

```bash
LINK_RESPONSE=$(curl -s -X PATCH \
  -u ":${ADO_PAT_CODE}" \
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
          \"comment\": \"Uploaded via automation\"
        }
      }
    }
  ]")
```

**Validate the response:**

```bash
LINKED_ID=$(echo "${LINK_RESPONSE}" | jq -r '.id')
if [ "${LINKED_ID}" = "null" ]; then
  echo "ERROR: Failed to link attachment to work item ${WORK_ITEM_ID}"
  echo "${LINK_RESPONSE}" | jq .
  exit 1
fi
echo "Attachment linked to work item ${LINKED_ID}"
```

**Error handling for Step 2:**
- **404 Not Found** — Work item ID does not exist or the blob URL is invalid.
- **400 Bad Request** — Incorrect `rel` type or malformed JSON Patch body.

## Download Workflow

### Step 1: Retrieve Attachment URLs from the Work Item

```bash
RELATIONS=$(curl -s -u ":${ADO_PAT_CODE}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/${WORK_ITEM_ID}?\$expand=relations&api-version=7.1" \
  | jq '[.relations[] | select(.rel == "AttachedFile")]')

echo "${RELATIONS}" | jq '.[].url'
```

### Step 2: Download Each Attachment

```bash
ATTACHMENT_URL="<url from step 1>"

curl -s -u ":${ADO_PAT_CODE}" \
  -o "${OUTPUT_FILENAME}" \
  "${ATTACHMENT_URL}"

if [ ! -s "${OUTPUT_FILENAME}" ]; then
  echo "ERROR: Download produced an empty file"
  exit 1
fi
echo "Downloaded: ${OUTPUT_FILENAME}"
```

**Error handling for download:**
- **404 Not Found** — The blob has been deleted or the URL is malformed.
- **401 Unauthorized** — Authentication header is missing. The blob URL alone is not sufficient.

## Common Mistakes

1. **Trying a single-step upload.** There is no API that accepts a file and links it to a work item in one call. You must upload the blob first, then link it.
2. **Forgetting auth on download.** The blob URL returned by the upload API is not publicly accessible. Always include the `-u ":${ADO_PAT_CODE}"` authentication header when downloading.
3. **Wrong Content-Type on upload.** The upload endpoint expects `application/octet-stream`, not `multipart/form-data` or `application/json`.
4. **Using `Content-Type: application/json-patch+json` for the blob upload.** This content type is only for the work item update in Step 2.
