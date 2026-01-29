#!/bin/bash
# Rules Injector - UserPromptSubmit hook
# 조건부 규칙 주입

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
RULES_DIR="$PROJECT_DIR/.claude/rules"

# Check PROJECT_CONTEXT.md for project stage
PROJECT_CONTEXT="$PROJECT_DIR/PROJECT_CONTEXT.md"
PROJECT_STAGE="unknown"

if [ -f "$PROJECT_CONTEXT" ]; then
    # Extract stage from PROJECT_CONTEXT.md
    PROJECT_STAGE=$(grep -i "stage:" "$PROJECT_CONTEXT" 2>/dev/null | head -1 | awk -F: '{print $2}' | tr -d ' ' | tr '[:upper:]' '[:lower:]')
fi

echo "[rules-injector] Project stage: $PROJECT_STAGE"

# List applicable rules
APPLICABLE_RULES=""

# Always-on rules
for rule in "$RULES_DIR"/always_*.md; do
    if [ -f "$rule" ]; then
        APPLICABLE_RULES="$APPLICABLE_RULES $(basename "$rule")"
    fi
done

# Stage-specific rules
case "$PROJECT_STAGE" in
    "prototype")
        if [ -f "$RULES_DIR/on_prototype.md" ]; then
            APPLICABLE_RULES="$APPLICABLE_RULES on_prototype.md"
        fi
        ;;
    "alpha")
        if [ -f "$RULES_DIR/on_alpha.md" ]; then
            APPLICABLE_RULES="$APPLICABLE_RULES on_alpha.md"
        fi
        ;;
    "beta")
        if [ -f "$RULES_DIR/on_beta.md" ]; then
            APPLICABLE_RULES="$APPLICABLE_RULES on_beta.md"
        fi
        ;;
    "live")
        if [ -f "$RULES_DIR/on_live.md" ]; then
            APPLICABLE_RULES="$APPLICABLE_RULES on_live.md"
        fi
        ;;
esac

# Core rules (always loaded via CLAUDE.md context)
CORE_RULES="todo-continuation.md ultrawork-mode.md ralph-loop.md categories.md"

if [ -n "$APPLICABLE_RULES" ]; then
    echo "[rules-injector] Applicable rules:$APPLICABLE_RULES"
fi

exit 0
