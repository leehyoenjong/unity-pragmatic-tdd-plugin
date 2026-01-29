#!/bin/bash
# Context Limit Recovery - Stop hook
# 컨텍스트 한계 도달 시 복구 정보 저장

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
NOTES_DIR="$PROJECT_DIR/.claude/notes"
NOTEPADS_DIR="$PROJECT_DIR/.claude/notepads"

mkdir -p "$NOTES_DIR" "$NOTEPADS_DIR"

# Extract stop reason
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    STOP_REASON=$(echo "$INPUT" | jq -r '.reason // "unknown"' 2>/dev/null)
else
    STOP_REASON="unknown"
fi

# Check if stopped due to context limit
if [[ "$STOP_REASON" == "max_tokens" ]] || [[ "$STOP_REASON" == "context_length_exceeded" ]]; then
    echo "[context-limit-recovery] Context limit reached - saving recovery info"

    TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

    # Create recovery note
    cat > "$NOTES_DIR/context-recovery_$TIMESTAMP.md" << EOF
# Context Limit Recovery

**Time**: $(date '+%Y-%m-%d %H:%M:%S')
**Reason**: $STOP_REASON

## Recovery Steps

1. Start a new session
2. Use \`/eee_start-work\` to load context
3. Review incomplete work in:
   - \`.claude/drafts/\` for plans
   - \`.claude/notepads/\` for scratch notes

## Recommended Actions

- Summarize completed work before continuing
- Break remaining tasks into smaller chunks
- Use \`/compact\` if available to reduce context

## Notes

This session ended due to context window limits.
The work in progress may be incomplete.
EOF

    # Save current state to notepads for quick reference
    cat > "$NOTEPADS_DIR/last-session-state.md" << EOF
# Last Session State

**Ended**: $(date '+%Y-%m-%d %H:%M:%S')
**Reason**: Context limit reached

Check \`.claude/notes/context-recovery_$TIMESTAMP.md\` for details.
EOF

    echo "[context-limit-recovery] Recovery info saved to notes/"
fi

exit 0
