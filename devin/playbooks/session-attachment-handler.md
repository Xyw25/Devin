# Session Attachment-Handler — Work Item Attachment Operations

## Purpose

Handle attachment operations on work items: list attachments, download them for
analysis, and upload new attachments (screenshots, logs, evidence files).

**Schedule:** On-demand (called by other sessions or standalone)
**Target ACU:** <= 2

---

## Procedure

### Step 1: Read work item and list attachments

```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/get-attachments.sh "$WORK_ITEM_ID"
```

Output is a JSON array of attachment objects. For each: name, URL, size.

### Step 2: Download requested attachments

For each attachment that needs to be downloaded:

```bash
bash scripts/ado/work-items/download-attachment.sh "$ATTACHMENT_URL" "/tmp/${FILENAME}"
```

Organize downloads by type:
- Images (`.png`, `.jpg`, `.gif`): save to `/tmp/attachments/images/`
- Logs (`.log`, `.txt`): save to `/tmp/attachments/logs/`
- Other: save to `/tmp/attachments/other/`

### Step 3: Analyze downloaded content

For each downloaded file:
- **Images:** Note what the screenshot shows (if identifiable from filename/context)
- **Logs:** Scan for error patterns, exceptions, stack traces
- **Other:** Note the file type and apparent purpose

### Step 4: Upload new attachments (if requested)

```bash
bash scripts/ado/work-items/add-attachment.sh "$WORK_ITEM_ID" "$FILE_PATH" "$COMMENT"
```

The script handles both steps: blob upload and work item linking.

### Step 5: Post summary comment

```bash
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p>Attachment operations complete. Downloaded: ${DOWNLOAD_COUNT}. Uploaded: ${UPLOAD_COUNT}.</p>"
```

---

## Specifications

- **ACU Budget:** <= 2
- **PATs:** `ADO_PAT_WORKITEMS`
- **Inputs:** Work item ID, optional file paths to upload
- **Outputs:** Downloaded files in `/tmp/attachments/`, upload confirmations, summary comment

### Exit Conditions

| Condition | Action |
|-----------|--------|
| All operations complete | Post summary, exit |
| No attachments found | Post comment noting this, exit |
| Download fails (403/404) | Log error, continue with other attachments |
| Upload fails (413 too large) | Log error, note max size in comment |

---

## Advice

- Check attachment size before downloading — skip very large files (>50MB) unless specifically requested
- The 2-step upload process is handled by `add-attachment.sh` — never try to upload in a single call
- Attachment blob URLs require auth headers — they are not publicly accessible
- Use descriptive comments when uploading: "Build log from CI run #1234" not "log file"

---

## Forbidden Actions

- **Never download all attachments blindly** — check sizes and types first
- **Never upload files containing credentials or sensitive data**
- **Never delete existing attachments** — only add new ones
- **Never exceed 130MB per file upload** (default org limit)

---

## Required from User

- Work item ID
- `ADO_PAT_WORKITEMS` configured in Devin Secrets Manager
- File paths for any uploads
