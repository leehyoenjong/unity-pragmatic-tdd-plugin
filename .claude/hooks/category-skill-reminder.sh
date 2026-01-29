#!/bin/bash
# Category Skill Reminder - UserPromptSubmit hook
# 카테고리 및 스킬 사용 리마인더

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Extract user prompt
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    USER_PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null)
else
    USER_PROMPT="$INPUT"
fi

PROMPT_LOWER=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')

# Detect potential category matches
SUGGESTED_CATEGORY=""
SUGGESTED_SKILL=""

# Visual/UI work
if [[ "$PROMPT_LOWER" == *"ui"* ]] || \
   [[ "$PROMPT_LOWER" == *"화면"* ]] || \
   [[ "$PROMPT_LOWER" == *"디자인"* ]] || \
   [[ "$PROMPT_LOWER" == *"애니메이션"* ]]; then
    SUGGESTED_CATEGORY="visual"
    echo "[category-skill-reminder] Detected UI/visual work"
    echo "  Suggested category: visual (minimal testing, visual verification)"
fi

# Complex architecture
if [[ "$PROMPT_LOWER" == *"아키텍처"* ]] || \
   [[ "$PROMPT_LOWER" == *"architecture"* ]] || \
   [[ "$PROMPT_LOWER" == *"설계"* ]] || \
   [[ "$PROMPT_LOWER" == *"design pattern"* ]]; then
    SUGGESTED_CATEGORY="ultrabrain"
    echo "[category-skill-reminder] Detected architecture work"
    echo "  Suggested category: ultrabrain (deep analysis)"
fi

# Simple fixes
if [[ "$PROMPT_LOWER" == *"오타"* ]] || \
   [[ "$PROMPT_LOWER" == *"typo"* ]] || \
   [[ "$PROMPT_LOWER" == *"간단히"* ]] || \
   [[ "$PROMPT_LOWER" == *"simple fix"* ]]; then
    SUGGESTED_CATEGORY="quick"
    echo "[category-skill-reminder] Detected simple fix"
    echo "  Suggested category: quick (fast execution)"
fi

# Feature implementation
if [[ "$PROMPT_LOWER" == *"시스템"* ]] || \
   [[ "$PROMPT_LOWER" == *"system"* ]] || \
   [[ "$PROMPT_LOWER" == *"기능"* ]] || \
   [[ "$PROMPT_LOWER" == *"feature"* ]]; then
    SUGGESTED_SKILL="/eee_feature"
    echo "[category-skill-reminder] Detected feature implementation"
    echo "  Suggested skill: /eee_feature (parallel pipeline)"
fi

# TDD work
if [[ "$PROMPT_LOWER" == *"테스트"* ]] || \
   [[ "$PROMPT_LOWER" == *"test"* ]] || \
   [[ "$PROMPT_LOWER" == *"tdd"* ]]; then
    SUGGESTED_CATEGORY="tdd"
    echo "[category-skill-reminder] Detected test-related work"
    echo "  Suggested category: tdd (test-first approach)"
fi

exit 0
