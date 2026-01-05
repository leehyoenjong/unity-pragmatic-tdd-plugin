#!/bin/bash
# macOS notification script for Claude Code

# Read JSON from stdin (Claude Code passes hook data via stdin)
INPUT=$(cat)

# Extract project folder name
PROJECT_NAME=$(basename "${CLAUDE_PROJECT_DIR:-$(pwd)}")

# Extract stop reason from JSON input (if available)
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    STOP_REASON=$(echo "$INPUT" | jq -r '.reason // "completed"' 2>/dev/null)
else
    STOP_REASON="completed"
fi

# Map stop reasons to Korean descriptions
case "$STOP_REASON" in
    "end_turn")
        REASON_TEXT="작업이 완료되었습니다"
        ;;
    "max_tokens")
        REASON_TEXT="토큰 한도에 도달했습니다"
        ;;
    "tool_use")
        REASON_TEXT="도구 사용이 완료되었습니다"
        ;;
    "interrupt")
        REASON_TEXT="사용자에 의해 중단되었습니다"
        ;;
    *)
        REASON_TEXT="작업이 완료되었습니다"
        ;;
esac

TITLE="Claude Code"
MESSAGE="$PROJECT_NAME 프로젝트 $REASON_TEXT"

# macOS only
if [ "$(uname -s)" = "Darwin" ]; then
    osascript -e "display dialog \"$MESSAGE\" with title \"$TITLE\" buttons {\"확인\"} default button 1 giving up after 5" &
    afplay /System/Library/Sounds/Glass.aiff &
fi

exit 0
