#!/bin/bash
# Session Recovery - UserPromptSubmit hook
# 세션 복구 및 이전 작업 상태 확인

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
NOTES_DIR="$PROJECT_DIR/.claude/notes"
DRAFTS_DIR="$PROJECT_DIR/.claude/drafts"
NOTEPADS_DIR="$PROJECT_DIR/.claude/notepads"

# Ensure directories exist
mkdir -p "$NOTES_DIR" "$DRAFTS_DIR" "$NOTEPADS_DIR"

# Check for incomplete work from previous sessions
check_incomplete_work() {
    local incomplete=0
    local message=""

    # Check for draft plans
    if ls "$DRAFTS_DIR"/plan_*.md 1> /dev/null 2>&1; then
        incomplete=1
        message="$message\n- Incomplete plans in drafts/"
    fi

    # Check for TODO notes
    if ls "$NOTES_DIR"/*_todo.md 1> /dev/null 2>&1; then
        incomplete=1
        message="$message\n- Pending TODOs in notes/"
    fi

    # Check for scratch notes (might indicate interrupted work)
    if ls "$NOTEPADS_DIR"/*_scratch.md 1> /dev/null 2>&1; then
        incomplete=1
        message="$message\n- Scratch notes from previous session"
    fi

    if [ $incomplete -eq 1 ]; then
        echo "[session-recovery] Incomplete work detected:$message"

        # Create recovery note
        cat > "$NOTEPADS_DIR/session-recovery.md" << EOF
# Session Recovery Info

**Time**: $(date '+%Y-%m-%d %H:%M:%S')

## Detected Incomplete Work
$message

## Recommended Actions
1. Check drafts/ for incomplete plans
2. Review notes/ for pending TODOs
3. Clear notepads/ after reviewing

---
Use \`/eee_start-work\` to properly resume.
EOF
    fi
}

check_incomplete_work

exit 0
