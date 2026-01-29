#!/bin/bash
# Tool Output Truncator - PostToolUse hook
# 도구 출력이 너무 길면 축약 알림

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Extract tool info
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
    TOOL_RESULT=$(echo "$INPUT" | jq -r '.result // ""' 2>/dev/null)
else
    exit 0
fi

# Check output length
OUTPUT_LENGTH=${#TOOL_RESULT}
TRUNCATION_THRESHOLD=20000

if [ "$OUTPUT_LENGTH" -gt "$TRUNCATION_THRESHOLD" ]; then
    echo "[tool-output-truncator] Warning: Large output from $TOOL_NAME ($OUTPUT_LENGTH chars)"
    echo "  Consider:"
    echo "  - Using more specific queries"
    echo "  - Adding filters or limits"
    echo "  - Breaking into smaller operations"

    # Log truncation event
    NOTEPADS_DIR="$PROJECT_DIR/.claude/notepads"
    mkdir -p "$NOTEPADS_DIR"

    cat >> "$NOTEPADS_DIR/truncation.log" << EOF

---
**Time**: $(date '+%Y-%m-%d %H:%M:%S')
**Tool**: $TOOL_NAME
**Output Size**: $OUTPUT_LENGTH characters
**Threshold**: $TRUNCATION_THRESHOLD characters
EOF
fi

exit 0
