#!/bin/bash
# Subagent Question Blocker - PreToolUse hook (before Task)
# 서브에이전트가 불필요한 질문하는 것 방지

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Extract tool info
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
    AGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // ""' 2>/dev/null)
    TASK_PROMPT=$(echo "$INPUT" | jq -r '.tool_input.prompt // ""' 2>/dev/null)
else
    exit 0
fi

# Only check Task tool
if [[ "$TOOL_NAME" != "Task" ]]; then
    exit 0
fi

# Check if prompt might cause agent to ask questions
PROMPT_LOWER=$(echo "$TASK_PROMPT" | tr '[:upper:]' '[:lower:]')

WARNING_PATTERNS=(
    "무엇을"
    "어떻게"
    "확인해"
    "what should"
    "how should"
    "should i"
    "do you want"
)

POTENTIAL_QUESTION=0
for pattern in "${WARNING_PATTERNS[@]}"; do
    if [[ "$PROMPT_LOWER" == *"$pattern"* ]]; then
        POTENTIAL_QUESTION=1
        break
    fi
done

if [ "$POTENTIAL_QUESTION" -eq 1 ]; then
    echo "[subagent-question-blocker] Warning: Task prompt may cause agent to ask questions"
    echo "  Agent: $AGENT_TYPE"
    echo "  Tip: Make the prompt more directive and specific"
    echo "  - Instead of 'What should I do?' -> 'Do X, Y, Z'"
    echo "  - Include all necessary context in the prompt"
fi

# Check for missing context that might cause questions
if [[ ${#TASK_PROMPT} -lt 100 ]]; then
    echo "[subagent-question-blocker] Warning: Short prompt may lack context"
    echo "  Consider adding more details to avoid agent confusion"
fi

exit 0
