#!/bin/bash
# Agent Usage Reminder - UserPromptSubmit hook
# 적절한 에이전트 사용 리마인더

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Extract user prompt
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    USER_PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null)
else
    USER_PROMPT="$INPUT"
fi

PROMPT_LOWER=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')

# Detect scenarios where specific agents should be used
SUGGESTED_AGENT=""

# Architecture questions -> Oracle
if [[ "$PROMPT_LOWER" == *"어떤 게 나을까"* ]] || \
   [[ "$PROMPT_LOWER" == *"which is better"* ]] || \
   [[ "$PROMPT_LOWER" == *"트레이드오프"* ]] || \
   [[ "$PROMPT_LOWER" == *"trade-off"* ]] || \
   [[ "$PROMPT_LOWER" == *"장단점"* ]]; then
    SUGGESTED_AGENT="oracle"
    echo "[agent-usage-reminder] Architecture decision detected"
    echo "  Suggested: Use Oracle agent for trade-off analysis"
fi

# Plan review -> Metis
if [[ "$PROMPT_LOWER" == *"검토"* ]] || \
   [[ "$PROMPT_LOWER" == *"review"* ]] || \
   [[ "$PROMPT_LOWER" == *"위험"* ]] || \
   [[ "$PROMPT_LOWER" == *"risk"* ]]; then
    SUGGESTED_AGENT="metis"
    echo "[agent-usage-reminder] Review request detected"
    echo "  Suggested: Use Metis agent for risk analysis"
fi

# Plan validation -> Momus
if [[ "$PROMPT_LOWER" == *"검증"* ]] || \
   [[ "$PROMPT_LOWER" == *"validate"* ]] || \
   [[ "$PROMPT_LOWER" == *"확인"* ]] || \
   [[ "$PROMPT_LOWER" == *"정확"* ]]; then
    SUGGESTED_AGENT="momus"
    echo "[agent-usage-reminder] Validation request detected"
    echo "  Suggested: Use Momus agent for plan validation"
fi

# Simple file creation -> Junior
if [[ "$PROMPT_LOWER" == *"빈 파일"* ]] || \
   [[ "$PROMPT_LOWER" == *"empty file"* ]] || \
   [[ "$PROMPT_LOWER" == *"폴더 구조"* ]] || \
   [[ "$PROMPT_LOWER" == *"folder structure"* ]] || \
   [[ "$PROMPT_LOWER" == *"템플릿"* ]]; then
    SUGGESTED_AGENT="junior"
    echo "[agent-usage-reminder] Simple task detected"
    echo "  Suggested: Use Junior agent for lightweight work"
fi

# QA related
if [[ "$PROMPT_LOWER" == *"버그"* ]] || \
   [[ "$PROMPT_LOWER" == *"bug"* ]] || \
   [[ "$PROMPT_LOWER" == *"보안"* ]] || \
   [[ "$PROMPT_LOWER" == *"security"* ]]; then
    SUGGESTED_AGENT="qa-tech or qa-security"
    echo "[agent-usage-reminder] QA-related request detected"
    echo "  Suggested: Use QA agents for analysis"
fi

exit 0
