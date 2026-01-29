#!/bin/bash
# Comment Checker - PostToolUse hook (after Edit/Write)
# 코드 주석 품질 검증 (TODO, FIXME, HACK 등)

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Extract tool info
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)
else
    exit 0
fi

# Only check after Edit or Write operations
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
    exit 0
fi

# Only check code files
case "$FILE_PATH" in
    *.cs|*.ts|*.js|*.py|*.java|*.cpp|*.c|*.h)
        ;;
    *)
        exit 0
        ;;
esac

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# Count problematic comments
TODO_COUNT=$(grep -c "TODO" "$FILE_PATH" 2>/dev/null || echo 0)
FIXME_COUNT=$(grep -c "FIXME" "$FILE_PATH" 2>/dev/null || echo 0)
HACK_COUNT=$(grep -c "HACK" "$FILE_PATH" 2>/dev/null || echo 0)
XXX_COUNT=$(grep -c "XXX" "$FILE_PATH" 2>/dev/null || echo 0)

TOTAL=$((TODO_COUNT + FIXME_COUNT + HACK_COUNT + XXX_COUNT))

if [ "$TOTAL" -gt 0 ]; then
    echo "[comment-checker] Warning: Found $TOTAL problematic comments in $FILE_PATH"
    echo "  - TODO: $TODO_COUNT"
    echo "  - FIXME: $FIXME_COUNT"
    echo "  - HACK: $HACK_COUNT"
    echo "  - XXX: $XXX_COUNT"

    # Log to notepads
    NOTEPADS_DIR="$PROJECT_DIR/.claude/notepads"
    mkdir -p "$NOTEPADS_DIR"

    cat >> "$NOTEPADS_DIR/comment-checker.log" << EOF

---
**File**: $FILE_PATH
**Time**: $(date '+%Y-%m-%d %H:%M:%S')
- TODO: $TODO_COUNT
- FIXME: $FIXME_COUNT
- HACK: $HACK_COUNT
- XXX: $XXX_COUNT
EOF
fi

exit 0
