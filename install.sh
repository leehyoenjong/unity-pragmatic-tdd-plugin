#!/bin/bash

# Unity Pragmatic TDD Plugin 설치 스크립트
# 사용법: curl -fsSL https://raw.githubusercontent.com/leehyoenjong/unity-pragmatic-tdd-plugin/main/install.sh | bash

set -e

REPO_URL="https://github.com/leehyoenjong/unity-pragmatic-tdd-plugin.git"
PLUGIN_DIR=".claude-plugin"

echo "🎮 Unity Pragmatic TDD Plugin 설치 중..."

# Git submodule로 추가
if [ -d "$PLUGIN_DIR" ]; then
    echo "⚠️  .claude-plugin 폴더가 이미 존재합니다. 업데이트합니다..."
    cd "$PLUGIN_DIR" && git pull && cd ..
else
    git submodule add "$REPO_URL" "$PLUGIN_DIR" 2>/dev/null || git clone "$REPO_URL" "$PLUGIN_DIR"
fi

# .claude 폴더 생성 및 심볼릭 링크
mkdir -p .claude

# 기존 링크/폴더 제거 후 생성
rm -rf .claude/skills .claude/docs 2>/dev/null || true
ln -s ../$PLUGIN_DIR/skills .claude/skills
ln -s ../$PLUGIN_DIR/docs .claude/docs

# CLAUDE.md 복사
cp "$PLUGIN_DIR/CLAUDE.md" ./CLAUDE.md

echo "✅ 설치 완료!"
echo ""
echo "📁 구조:"
echo "   CLAUDE.md"
echo "   .claude/skills -> .claude-plugin/skills"
echo "   .claude/docs -> .claude-plugin/docs"
echo ""
echo "🔄 업데이트: cd .claude-plugin && git pull"
