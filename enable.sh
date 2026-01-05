#!/bin/bash
# 현재 프로젝트에 unity-pragmatic-tdd 플러그인 활성화

PLUGIN_NAME="unity-pragmatic-tdd@leehyoenjong-plugins"
FORCE=false

# 옵션 파싱
while getopts "f" opt; do
    case $opt in
        f) FORCE=true ;;
    esac
done

# 현재 디렉토리 확인
if [ ! -d ".git" ] && [ ! -f "*.csproj" ] && [ ! -d "Assets" ]; then
    if [ "$FORCE" = false ]; then
        echo "⚠️  프로젝트 루트 디렉토리가 아닌 것 같습니다."
        read -p "계속 진행하시겠습니까? (y/n): " confirm
        if [ "$confirm" != "y" ]; then
            echo "취소되었습니다."
            exit 1
        fi
    fi
fi

# .claude 폴더 생성
mkdir -p .claude

# settings.local.json 파일 생성 또는 업데이트
SETTINGS_FILE=".claude/settings.local.json"

if [ -f "$SETTINGS_FILE" ]; then
    # 기존 파일이 있으면 플러그인 추가
    if command -v jq &> /dev/null; then
        # jq가 있으면 JSON 병합
        jq --arg plugin "$PLUGIN_NAME" '.enabledPlugins[$plugin] = true' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
    else
        # jq가 없으면 덮어쓰기
        cat > "$SETTINGS_FILE" << EOF
{
  "enabledPlugins": {
    "$PLUGIN_NAME": true
  }
}
EOF
    fi
else
    # 새 파일 생성
    cat > "$SETTINGS_FILE" << EOF
{
  "enabledPlugins": {
    "$PLUGIN_NAME": true
  }
}
EOF
fi

echo "✅ 플러그인 활성화 완료!"
echo "   프로젝트: $(pwd)"
echo "   설정 파일: $SETTINGS_FILE"
echo ""
echo "💡 Claude Code를 재시작하면 플러그인이 적용됩니다."
