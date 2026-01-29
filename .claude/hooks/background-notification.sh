#!/bin/bash
# Background Notification - PostToolUse hook (after Task)
# 백그라운드 작업 완료 알림

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_DIR")

# Extract tool info
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
    RUN_IN_BG=$(echo "$INPUT" | jq -r '.tool_input.run_in_background // false' 2>/dev/null)
    TASK_DESC=$(echo "$INPUT" | jq -r '.tool_input.description // "Background task"' 2>/dev/null)
    TASK_RESULT=$(echo "$INPUT" | jq -r '.result // ""' 2>/dev/null)
else
    exit 0
fi

# Only handle background Task completions
if [[ "$TOOL_NAME" != "Task" ]] || [[ "$RUN_IN_BG" != "true" ]]; then
    exit 0
fi

# Check if task completed
if [[ -n "$TASK_RESULT" ]]; then
    TITLE="Background Task Complete"
    MESSAGE="$PROJECT_NAME: $TASK_DESC"

    echo "[background-notification] Task completed: $TASK_DESC"

    # macOS notification
    if [ "$(uname -s)" = "Darwin" ]; then
        osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"Glass\"" &
    fi

    # Linux notification (if notify-send available)
    if command -v notify-send &> /dev/null; then
        notify-send "$TITLE" "$MESSAGE" &
    fi

    # Windows notification via PowerShell (WSL)
    if grep -qi microsoft /proc/version 2>/dev/null; then
        powershell.exe -Command "
            [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
            \$notify = New-Object System.Windows.Forms.NotifyIcon
            \$notify.Icon = [System.Drawing.SystemIcons]::Information
            \$notify.Visible = \$true
            \$notify.ShowBalloonTip(5000, '$TITLE', '$MESSAGE', 'Info')
        " 2>/dev/null &
    fi
fi

exit 0
