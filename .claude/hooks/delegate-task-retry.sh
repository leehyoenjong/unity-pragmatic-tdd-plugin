#!/bin/bash
# Delegate Task Retry - PostToolUse hook (after Task)
# 위임 작업 실패 시 재시도 정보 기록

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
NOTEPADS_DIR="$PROJECT_DIR/.claude/notepads"

mkdir -p "$NOTEPADS_DIR"

# Extract tool info
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
    TOOL_ERROR=$(echo "$INPUT" | jq -r '.error // ""' 2>/dev/null)
    AGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // ""' 2>/dev/null)
    TASK_DESC=$(echo "$INPUT" | jq -r '.tool_input.description // ""' 2>/dev/null)
    TASK_PROMPT=$(echo "$INPUT" | jq -r '.tool_input.prompt // ""' 2>/dev/null)
else
    exit 0
fi

# Only handle Task errors
if [[ "$TOOL_NAME" != "Task" ]] || [[ -z "$TOOL_ERROR" ]]; then
    exit 0
fi

echo "[delegate-task-retry] Task failed: $TASK_DESC"
echo "  Agent: $AGENT_TYPE"
echo "  Error: $TOOL_ERROR"

# Track retry count
RETRY_FILE="$NOTEPADS_DIR/task-retry-count.txt"
RETRY_KEY="${AGENT_TYPE}_${TASK_DESC}"
RETRY_COUNT=0

if [ -f "$RETRY_FILE" ]; then
    RETRY_COUNT=$(grep -c "$RETRY_KEY" "$RETRY_FILE" 2>/dev/null || echo 0)
fi

echo "$RETRY_KEY" >> "$RETRY_FILE"
RETRY_COUNT=$((RETRY_COUNT + 1))

# Log failure details
cat >> "$NOTEPADS_DIR/task-failures.log" << EOF

---
**Time**: $(date '+%Y-%m-%d %H:%M:%S')
**Agent**: $AGENT_TYPE
**Description**: $TASK_DESC
**Error**: $TOOL_ERROR
**Retry Count**: $RETRY_COUNT

### Prompt (truncated)
${TASK_PROMPT:0:500}...
EOF

# Warning for repeated failures
if [ "$RETRY_COUNT" -ge 3 ]; then
    echo "[delegate-task-retry] WARNING: Task has failed $RETRY_COUNT times"
    echo "  Consider: "
    echo "  - Consulting Oracle agent"
    echo "  - Changing approach"
    echo "  - Breaking into smaller tasks"

    # Create warning note
    cat > "$NOTEPADS_DIR/task-failure-warning.md" << EOF
# Repeated Task Failure Warning

**Agent**: $AGENT_TYPE
**Task**: $TASK_DESC
**Failures**: $RETRY_COUNT times

## Recommendations
1. Consult Oracle agent for alternative approach
2. Break the task into smaller subtasks
3. Check for missing dependencies or context

## Last Error
$TOOL_ERROR
EOF
fi

exit 0
