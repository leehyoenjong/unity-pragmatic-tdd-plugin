#!/bin/bash
# Context Window Monitor - UserPromptSubmit hook
# 컨텍스트 윈도우 사용량 모니터링 및 경고

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
NOTES_DIR="$PROJECT_DIR/.claude/notepads"

# Ensure notepads directory exists
mkdir -p "$NOTES_DIR"

# Extract session info if available
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    # Note: Claude Code doesn't provide token count directly
    # This hook prepares for future token monitoring
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)
    PROMPT_LENGTH=${#INPUT}

    # Log prompt size for monitoring
    echo "$(date '+%Y-%m-%d %H:%M:%S') | prompt_size: $PROMPT_LENGTH" >> "$NOTES_DIR/context-monitor.log"

    # Warning threshold (characters, rough estimate)
    WARNING_THRESHOLD=50000

    if [ "$PROMPT_LENGTH" -gt "$WARNING_THRESHOLD" ]; then
        echo "[context-window-monitor] Warning: Large prompt detected ($PROMPT_LENGTH chars)"

        # Create warning note
        cat > "$NOTES_DIR/context-warning.md" << EOF
# Context Window Warning

**Time**: $(date '+%Y-%m-%d %H:%M:%S')
**Prompt Size**: $PROMPT_LENGTH characters

## Recommendations
- Consider summarizing the conversation
- Use /compact if available
- Break down complex tasks
EOF
    fi
fi

exit 0
