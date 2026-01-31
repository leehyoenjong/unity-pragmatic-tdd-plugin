#!/bin/bash
# Thinking Block Validator - PreToolUse hook
# thinking 블록 검증으로 API 에러 방지
# Based on oh-my-opencode's thinking-block-validator

INPUT=$(cat)

# Skip if no input
if [ -z "$INPUT" ]; then
    exit 0
fi

# Check for malformed thinking blocks
if command -v jq &> /dev/null; then
    CONTENT=$(echo "$INPUT" | jq -r '.content // ""' 2>/dev/null)

    # Check for unclosed thinking tags
    OPEN_COUNT=$(echo "$CONTENT" | grep -o '<thinking>' | wc -l)
    CLOSE_COUNT=$(echo "$CONTENT" | grep -o '</thinking>' | wc -l)

    if [ "$OPEN_COUNT" -ne "$CLOSE_COUNT" ]; then
        echo "[thinking-block-validator] Warning: Unbalanced thinking blocks detected"
        echo "[thinking-block-validator] Open tags: $OPEN_COUNT, Close tags: $CLOSE_COUNT"
    fi

    # Check for nested thinking blocks (not allowed)
    if echo "$CONTENT" | grep -q '<thinking>.*<thinking>'; then
        echo "[thinking-block-validator] Warning: Nested thinking blocks detected"
    fi
fi

exit 0
