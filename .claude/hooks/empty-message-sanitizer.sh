#!/bin/bash
# Empty Message Sanitizer - PreToolUse hook
# 빈 메시지로 인한 API 에러 방지
# Based on oh-my-opencode's empty-message-sanitizer

INPUT=$(cat)

# Check if input is empty
if [ -z "$INPUT" ]; then
    echo "[empty-message-sanitizer] Warning: Empty input detected"
    exit 0
fi

# Extract message content if available
if command -v jq &> /dev/null; then
    MESSAGE=$(echo "$INPUT" | jq -r '.message // .content // ""' 2>/dev/null)

    # Check if message is empty or whitespace only
    if [ -z "$(echo "$MESSAGE" | tr -d '[:space:]')" ]; then
        echo "[empty-message-sanitizer] Warning: Empty or whitespace-only message detected"
    fi
fi

exit 0
