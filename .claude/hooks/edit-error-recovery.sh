#!/bin/bash
# Edit Error Recovery - PostToolUse hook (after Edit)
# 편집 에러 자동 복구 시도

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
NOTEPADS_DIR="$PROJECT_DIR/.claude/notepads"

mkdir -p "$NOTEPADS_DIR"

# Extract tool info
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
    TOOL_ERROR=$(echo "$INPUT" | jq -r '.error // ""' 2>/dev/null)
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)
    OLD_STRING=$(echo "$INPUT" | jq -r '.tool_input.old_string // ""' 2>/dev/null)
else
    exit 0
fi

# Only handle Edit errors
if [[ "$TOOL_NAME" != "Edit" || -z "$TOOL_ERROR" ]]; then
    exit 0
fi

echo "[edit-error-recovery] Edit failed on $FILE_PATH"
echo "  Error: $TOOL_ERROR"

# Log the error for analysis
cat >> "$NOTEPADS_DIR/edit-errors.log" << EOF

---
**Time**: $(date '+%Y-%m-%d %H:%M:%S')
**File**: $FILE_PATH
**Error**: $TOOL_ERROR
**old_string length**: ${#OLD_STRING}

### Suggestions
- Check if old_string exists exactly in file
- Verify file hasn't changed since last read
- Try reading the file again before editing
EOF

# Check common issues
if [[ "$TOOL_ERROR" == *"not found"* || "$TOOL_ERROR" == *"unique"* ]]; then
    echo "[edit-error-recovery] Suggestion: The old_string may not exist or is not unique"
    echo "  - Re-read the file to get current content"
    echo "  - Use a longer/more specific old_string"
fi

if [[ "$TOOL_ERROR" == *"permission"* ]]; then
    echo "[edit-error-recovery] Suggestion: Permission denied"
    echo "  - Check file permissions"
    echo "  - File may be read-only or locked"
fi

exit 0
