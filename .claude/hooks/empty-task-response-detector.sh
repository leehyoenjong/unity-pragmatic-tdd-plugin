#!/bin/bash
# Empty Task Response Detector - Stop hook
# 빈 응답 또는 불완전한 작업 감지

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
NOTEPADS_DIR="$PROJECT_DIR/.claude/notepads"

mkdir -p "$NOTEPADS_DIR"

# Extract stop reason
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    STOP_REASON=$(echo "$INPUT" | jq -r '.reason // "unknown"' 2>/dev/null)
    RESPONSE_LENGTH=$(echo "$INPUT" | jq -r '.response | length // 0' 2>/dev/null)
else
    STOP_REASON="unknown"
    RESPONSE_LENGTH=0
fi

# Check for problematic stop conditions
ISSUE_DETECTED=0
ISSUE_TYPE=""

case "$STOP_REASON" in
    "max_tokens")
        ISSUE_DETECTED=1
        ISSUE_TYPE="Token limit reached - response may be incomplete"
        ;;
    "interrupt")
        ISSUE_DETECTED=1
        ISSUE_TYPE="User interrupted - check for pending work"
        ;;
esac

# Check for very short responses (might indicate issues)
if [ "$RESPONSE_LENGTH" -lt 50 ] && [ "$STOP_REASON" == "end_turn" ]; then
    ISSUE_DETECTED=1
    ISSUE_TYPE="Very short response - may indicate confusion or missing context"
fi

if [ "$ISSUE_DETECTED" -eq 1 ]; then
    echo "[empty-task-response-detector] Issue detected: $ISSUE_TYPE"

    # Log the issue
    cat >> "$NOTEPADS_DIR/response-issues.log" << EOF

---
**Time**: $(date '+%Y-%m-%d %H:%M:%S')
**Stop Reason**: $STOP_REASON
**Response Length**: $RESPONSE_LENGTH
**Issue**: $ISSUE_TYPE

### Recommended Action
- Review the last response
- Check if task was completed
- Consider rephrasing the request
EOF
fi

exit 0
