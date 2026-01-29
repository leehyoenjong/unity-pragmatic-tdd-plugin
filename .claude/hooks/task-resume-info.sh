#!/bin/bash
# Task Resume Info - UserPromptSubmit hook
# 작업 재개 정보 표시

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
NOTEPADS_DIR="$PROJECT_DIR/.claude/notepads"
DRAFTS_DIR="$PROJECT_DIR/.claude/drafts"

# Check for resumable work

# 1. Check active modes
if [ -f "$NOTEPADS_DIR/active-modes.txt" ]; then
    ACTIVE_MODES=$(cat "$NOTEPADS_DIR/active-modes.txt")
    if [ -n "$ACTIVE_MODES" ]; then
        echo "[task-resume-info] Active modes from previous session:$ACTIVE_MODES"
    fi
fi

# 2. Check Ralph Loop status
if [ -f "$NOTEPADS_DIR/ralph-loop-status.md" ]; then
    echo "[task-resume-info] Ralph Loop was active in previous session"
    echo "  Use '/eee_ralph continue' to resume"
fi

# 3. Check incomplete plans
INCOMPLETE_PLANS=$(ls "$DRAFTS_DIR"/plan_*.md 2>/dev/null | wc -l)
if [ "$INCOMPLETE_PLANS" -gt 0 ]; then
    echo "[task-resume-info] Found $INCOMPLETE_PLANS incomplete plan(s)"
    ls "$DRAFTS_DIR"/plan_*.md 2>/dev/null | while read plan; do
        echo "  - $(basename "$plan")"
    done
fi

# 4. Check task retry counts (might indicate stuck work)
if [ -f "$NOTEPADS_DIR/task-retry-count.txt" ]; then
    RETRY_COUNT=$(wc -l < "$NOTEPADS_DIR/task-retry-count.txt")
    if [ "$RETRY_COUNT" -gt 5 ]; then
        echo "[task-resume-info] Warning: Multiple task retries detected ($RETRY_COUNT)"
        echo "  Consider reviewing task-failures.log"
    fi
fi

# 5. Check for session recovery note
if [ -f "$NOTEPADS_DIR/session-recovery.md" ]; then
    echo "[task-resume-info] Session recovery note found"
    echo "  Review: .claude/notepads/session-recovery.md"
fi

exit 0
