#!/bin/bash
# Cross-platform notification script for Claude Code
# Supports: macOS, Windows (Git Bash/PowerShell)

TITLE="Claude Code"
MESSAGE="작업이 완료되었습니다"

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
