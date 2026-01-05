#!/bin/bash
# Cross-platform notification script for Claude Code
# Supports: macOS, Windows (Git Bash/PowerShell)

# Read JSON from stdin (Claude Code passes hook data via stdin)
INPUT=$(cat)

# Extract project folder name
PROJECT_NAME=$(basename "${CLAUDE_PROJECT_DIR:-$(pwd)}")

# Extract stop reason from JSON input (if available)
# JSON format: {"stop_hook_active": true, "reason": "end_turn", ...}
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    STOP_REASON=$(echo "$INPUT" | jq -r '.reason // "completed"' 2>/dev/null)
else
    STOP_REASON="completed"
fi

# Map stop reasons to Korean descriptions
case "$STOP_REASON" in
    "end_turn")
        REASON_TEXT="응답 완료"
        ;;
    "max_tokens")
        REASON_TEXT="토큰 한도 도달"
        ;;
    "tool_use")
        REASON_TEXT="도구 사용 완료"
        ;;
    "interrupt")
        REASON_TEXT="사용자 중단"
        ;;
    *)
        REASON_TEXT="응답 완료"
        ;;
esac

TITLE="Claude Code"
MESSAGE="[$PROJECT_NAME] $REASON_TEXT"

# Detect OS and send notification
case "$(uname -s)" in
    Darwin)
        # macOS - Dialog with sound (auto-close after 5 seconds)
        osascript -e "display dialog \"$MESSAGE\" with title \"$TITLE\" buttons {\"확인\"} default button 1 giving up after 5" &
        afplay /System/Library/Sounds/Glass.aiff &
        ;;
    MINGW*|MSYS*|CYGWIN*)
        # Windows (Git Bash, MSYS, Cygwin)
        powershell.exe -Command "
            [System.Media.SystemSounds]::Asterisk.Play()
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show('$MESSAGE', '$TITLE', 'OK', 'Information')
        " 2>/dev/null
        ;;
    Linux)
        # Linux (optional support)
        if command -v notify-send &> /dev/null; then
            notify-send "$TITLE" "$MESSAGE"
            paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || true
        fi
        ;;
esac

exit 0
