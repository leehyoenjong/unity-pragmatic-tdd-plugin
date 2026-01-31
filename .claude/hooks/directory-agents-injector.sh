#!/bin/bash
# Directory AGENTS.md Injector - PostToolUse hook
# 파일 읽기 시 해당 디렉토리의 AGENTS.md 자동 주입
# Based on oh-my-opencode's directory-agents-injector

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Extract tool name and file path from input
if command -v jq &> /dev/null && [ -n "$INPUT" ]; then
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null)
else
    exit 0
fi

# Only process Read tool
if [[ "$TOOL_NAME" != "Read" ]]; then
    exit 0
fi

# Skip if no file path
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Get directory of the file being read
FILE_DIR=$(dirname "$FILE_PATH")

# Skip if reading from .claude directory itself
if [[ "$FILE_DIR" == *".claude"* ]]; then
    exit 0
fi

# Collect AGENTS.md files from file directory up to project root
AGENTS_FILES=""
CURRENT_DIR="$FILE_DIR"

while [[ "$CURRENT_DIR" == "$PROJECT_DIR"* ]] && [ "$CURRENT_DIR" != "/" ]; do
    AGENTS_PATH="$CURRENT_DIR/AGENTS.md"
    if [ -f "$AGENTS_PATH" ]; then
        AGENTS_FILES="$AGENTS_PATH $AGENTS_FILES"
    fi
    CURRENT_DIR=$(dirname "$CURRENT_DIR")
done

# Check project root
if [ -f "$PROJECT_DIR/AGENTS.md" ]; then
    if [[ "$AGENTS_FILES" != *"$PROJECT_DIR/AGENTS.md"* ]]; then
        AGENTS_FILES="$PROJECT_DIR/AGENTS.md $AGENTS_FILES"
    fi
fi

# Output found AGENTS.md files
if [ -n "$AGENTS_FILES" ]; then
    echo "[directory-agents-injector] Found AGENTS.md files for context:"
    for AGENTS_FILE in $AGENTS_FILES; do
        REL_PATH="${AGENTS_FILE#$PROJECT_DIR/}"
        echo "  - $REL_PATH"
    done
    echo "[directory-agents-injector] Consider reading these files for additional context"
fi

exit 0
