#!/bin/bash
# Auto Slash Command - UserPromptSubmit hook
# 슬래시 명령어 자동 감지 및 안내

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Extract user prompt
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    USER_PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null)
else
    USER_PROMPT="$INPUT"
fi

# Check if prompt looks like it should use a slash command
PROMPT_LOWER=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')

# Feature creation patterns
if [[ "$PROMPT_LOWER" == *"시스템 만들어"* ]] || \
   [[ "$PROMPT_LOWER" == *"system 구현"* ]] || \
   [[ "$PROMPT_LOWER" == *"새 기능"* ]] || \
   [[ "$PROMPT_LOWER" == *"new feature"* ]]; then
    echo "[auto-slash-command] Tip: Use '/eee_feature <SystemName>' for parallel implementation pipeline"
fi

# Start work patterns
if [[ "$PROMPT_LOWER" == *"작업 시작"* ]] || \
   [[ "$PROMPT_LOWER" == *"start work"* ]] || \
   [[ "$PROMPT_LOWER" == *"이어서"* ]] || \
   [[ "$PROMPT_LOWER" == *"continue"* ]]; then
    echo "[auto-slash-command] Tip: Use '/eee_start-work' to load context and resume"
fi

# Deep analysis patterns
if [[ "$PROMPT_LOWER" == *"전체 분석"* ]] || \
   [[ "$PROMPT_LOWER" == *"코드베이스"* ]] || \
   [[ "$PROMPT_LOWER" == *"codebase"* ]] || \
   [[ "$PROMPT_LOWER" == *"deep analysis"* ]]; then
    echo "[auto-slash-command] Tip: Use '/eee_init-deep' for deep codebase analysis"
fi

# Ultrawork patterns
if [[ "$PROMPT_LOWER" == *"최대 성능"* ]] || \
   [[ "$PROMPT_LOWER" == *"full power"* ]] || \
   [[ "$PROMPT_LOWER" == *"빠르게 완료"* ]]; then
    echo "[auto-slash-command] Tip: Use '/eee_ultrawork' for maximum performance mode"
fi

# Notes patterns
if [[ "$PROMPT_LOWER" == *"노트"* ]] || \
   [[ "$PROMPT_LOWER" == *"note"* ]] || \
   [[ "$PROMPT_LOWER" == *"메모"* ]] || \
   [[ "$PROMPT_LOWER" == *"기록"* ]]; then
    echo "[auto-slash-command] Tip: Use '/eee_notes' to manage work notes"
fi

exit 0
