#!/bin/bash
# Keyword Detector - UserPromptSubmit hook
# 특수 키워드 감지 및 모드 활성화

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
NOTEPADS_DIR="$PROJECT_DIR/.claude/notepads"

mkdir -p "$NOTEPADS_DIR"

# Extract user prompt
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    USER_PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null)
else
    USER_PROMPT="$INPUT"
fi

# Convert to lowercase for matching
PROMPT_LOWER=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')

DETECTED_MODES=""

# Ultrawork mode detection
if [[ "$PROMPT_LOWER" == *"ultrawork"* ]] || \
   [[ "$PROMPT_LOWER" == *"울트라워크"* ]] || \
   [[ "$PROMPT_LOWER" == *"full power"* ]] || \
   [[ "$PROMPT_LOWER" == *"all out"* ]]; then
    DETECTED_MODES="$DETECTED_MODES ultrawork"
    echo "[keyword-detector] Ultrawork mode keyword detected"
fi

# Ralph loop detection
if [[ "$PROMPT_LOWER" == *"ralph loop"* ]] || \
   [[ "$PROMPT_LOWER" == *"랄프 루프"* ]] || \
   [[ "$PROMPT_LOWER" == *"완료될 때까지"* ]] || \
   [[ "$PROMPT_LOWER" == *"until done"* ]]; then
    DETECTED_MODES="$DETECTED_MODES ralph-loop"
    echo "[keyword-detector] Ralph loop keyword detected"
fi

# Deep mode detection
if [[ "$PROMPT_LOWER" == *"deep"* ]] || \
   [[ "$PROMPT_LOWER" == *"심층"* ]] || \
   [[ "$PROMPT_LOWER" == *"thorough"* ]] || \
   [[ "$PROMPT_LOWER" == *"꼼꼼히"* ]]; then
    DETECTED_MODES="$DETECTED_MODES deep"
    echo "[keyword-detector] Deep mode keyword detected"
fi

# Quick mode detection
if [[ "$PROMPT_LOWER" == *"quick"* ]] || \
   [[ "$PROMPT_LOWER" == *"빠르게"* ]] || \
   [[ "$PROMPT_LOWER" == *"간단히"* ]] || \
   [[ "$PROMPT_LOWER" == *"fast"* ]]; then
    DETECTED_MODES="$DETECTED_MODES quick"
    echo "[keyword-detector] Quick mode keyword detected"
fi

# TDD mode detection
if [[ "$PROMPT_LOWER" == *"tdd"* ]] || \
   [[ "$PROMPT_LOWER" == *"테스트 먼저"* ]] || \
   [[ "$PROMPT_LOWER" == *"test first"* ]]; then
    DETECTED_MODES="$DETECTED_MODES tdd"
    echo "[keyword-detector] TDD mode keyword detected"
fi

# Think mode detection (ultrathink, think deeply)
if [[ "$PROMPT_LOWER" == *"ultrathink"* ]] || \
   [[ "$PROMPT_LOWER" == *"울트라씽크"* ]] || \
   [[ "$PROMPT_LOWER" == *"think deeply"* ]] || \
   [[ "$PROMPT_LOWER" == *"깊이 생각"* ]] || \
   [[ "$PROMPT_LOWER" == *"심층 분석"* ]] || \
   [[ "$PROMPT_LOWER" == *"deep thinking"* ]]; then
    DETECTED_MODES="$DETECTED_MODES think"
    echo "[keyword-detector] Think mode activated - Extended reasoning enabled"
    echo "[keyword-detector] Use maximum analytical depth for this request"
fi

# Search/Find mode detection
if [[ "$PROMPT_LOWER" == *"search"* ]] || \
   [[ "$PROMPT_LOWER" == *"find"* ]] || \
   [[ "$PROMPT_LOWER" == *"찾아"* ]] || \
   [[ "$PROMPT_LOWER" == *"검색"* ]]; then
    DETECTED_MODES="$DETECTED_MODES search"
    echo "[keyword-detector] Search mode - Use parallel exploration"
fi

# Analyze/Investigate mode detection
if [[ "$PROMPT_LOWER" == *"analyze"* ]] || \
   [[ "$PROMPT_LOWER" == *"investigate"* ]] || \
   [[ "$PROMPT_LOWER" == *"분석"* ]] || \
   [[ "$PROMPT_LOWER" == *"조사"* ]]; then
    DETECTED_MODES="$DETECTED_MODES analyze"
    echo "[keyword-detector] Analyze mode - Deep investigation enabled"
fi

# Save detected modes
if [ -n "$DETECTED_MODES" ]; then
    echo "$DETECTED_MODES" > "$NOTEPADS_DIR/active-modes.txt"
    echo "[keyword-detector] Active modes:$DETECTED_MODES"
fi

exit 0
