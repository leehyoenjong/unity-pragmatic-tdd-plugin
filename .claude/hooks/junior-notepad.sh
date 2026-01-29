#!/bin/bash
# Junior Notepad - PostToolUse hook (after Task with junior agent)
# Junior 에이전트 작업 결과 기록

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
NOTEPADS_DIR="$PROJECT_DIR/.claude/notepads"

mkdir -p "$NOTEPADS_DIR"

# Extract tool info
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
    AGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // ""' 2>/dev/null)
    TASK_DESC=$(echo "$INPUT" | jq -r '.tool_input.description // ""' 2>/dev/null)
    TASK_RESULT=$(echo "$INPUT" | jq -r '.result // ""' 2>/dev/null)
else
    exit 0
fi

# Only handle Junior agent tasks
if [[ "$TOOL_NAME" != "Task" ]] || [[ "$AGENT_TYPE" != "junior" ]]; then
    exit 0
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Log Junior's work
cat >> "$NOTEPADS_DIR/junior-work.log" << EOF

---
**Time**: $TIMESTAMP
**Task**: $TASK_DESC

### Result Summary
${TASK_RESULT:0:1000}
EOF

echo "[junior-notepad] Junior task logged: $TASK_DESC"

exit 0
