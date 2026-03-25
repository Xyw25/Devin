# ADO Attachments — Knowledge Item

## Trigger Description
ADO work item attachment, download attachment, upload file to work item, read attachment

## Attachment Operations

Attachments on work items are stored as blob resources linked via `AttachedFile` relations.

### List Attachments
Fetch the work item with `$expand=relations`, then filter for `rel == "AttachedFile"`.
Each attachment has: `url` (blob URL), `attributes.name` (filename), `attributes.resourceSize` (bytes).

### Download Attachment
GET the blob URL directly with the auth header. Binary content is returned.

### Upload Attachment (2-Step Process)
**This is the most common mistake — uploading is NOT a single call.**

1. **Upload blob:** POST the file binary to the attachments endpoint
   ```
   POST /_apis/wit/attachments?fileName={name}&api-version=7.1
   Content-Type: application/octet-stream
   Body: raw file bytes
   ```
   Response includes the `url` of the stored blob.

2. **Link to work item:** PATCH the work item to add an `AttachedFile` relation pointing to the blob URL
   ```
   PATCH /_apis/wit/workitems/{id}?api-version=7.1
   Content-Type: application/json-patch+json
   ```

## Rules

- Always use the 2-step process for uploads — there is no single-call upload
- Attachment blob URLs are temporary-auth — always include the auth header when downloading
- Max attachment size depends on org settings (default: 130MB per file)
- Check `docs/error-catalog.md` for 413 errors (file too large)

## Scripts

- `scripts/ado/work-items/get-attachments.sh` — list attachments on a work item
- `scripts/ado/work-items/download-attachment.sh` — download by URL
- `scripts/ado/work-items/add-attachment.sh` — upload and link (handles both steps)
