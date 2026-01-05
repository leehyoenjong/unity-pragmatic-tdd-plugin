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

# Unity 프로젝트 감지 및 Unity-MCP 안내
MANIFEST_PATH="Packages/manifest.json"
UNITY_MCP_PACKAGE="com.ivanmurzak.unity.mcp"

if [ -d "Assets" ] || [ -f "$MANIFEST_PATH" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎮 Unity 프로젝트 감지됨"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Unity-MCP 설치 여부 확인
    MCP_INSTALLED=false
    if [ -f "$MANIFEST_PATH" ] && grep -q "$UNITY_MCP_PACKAGE" "$MANIFEST_PATH" 2>/dev/null; then
        MCP_INSTALLED=true
    elif [ -d "Packages/$UNITY_MCP_PACKAGE" ] || [ -d "Assets/Plugins/Unity-MCP" ]; then
        MCP_INSTALLED=true
    fi

    if [ "$MCP_INSTALLED" = true ]; then
        echo "✅ Unity-MCP가 이미 설치되어 있습니다."
        echo ""
        echo "📋 Unity-MCP 설정 확인:"
        echo "   1. Unity 에디터에서 Window > AI Game Developer 열기"
        echo "   2. Connect 버튼 클릭"
        echo "   3. Claude Code 재시작"
    else
        echo "📦 Unity-MCP를 설치하면 Claude Code에서 Unity를 직접 제어할 수 있습니다."
        echo ""

        if [ "$FORCE" = false ]; then
            read -p "Unity-MCP Installer를 다운로드하시겠습니까? (y/n): " INSTALL_MCP
        else
            INSTALL_MCP="n"
            echo "💡 Unity-MCP 설치는 대화형 모드에서 진행해주세요:"
            echo "   bash ~/.claude/plugins/cache/leehyoenjong-plugins/unity-pragmatic-tdd/1.0.0/enable.sh"
        fi

        if [ "$INSTALL_MCP" = "y" ] || [ "$INSTALL_MCP" = "Y" ]; then
            echo ""
            echo "🔍 Unity-MCP 최신 버전 확인 중..."

            UNITY_MCP_VERSION_URL="https://api.github.com/repos/IvanMurzak/Unity-MCP/releases/latest"
            UNITY_MCP_LATEST=$(curl -s "$UNITY_MCP_VERSION_URL" 2>/dev/null | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' || echo "")

            if [ -n "$UNITY_MCP_LATEST" ]; then
                INSTALLER_URL="https://github.com/IvanMurzak/Unity-MCP/releases/download/${UNITY_MCP_LATEST}/AI-Game-Dev-Installer.unitypackage"
                echo "📦 최신 버전: $UNITY_MCP_LATEST"
            else
                INSTALLER_URL="https://github.com/IvanMurzak/Unity-MCP/releases/latest/download/AI-Game-Dev-Installer.unitypackage"
                echo "⚠️  버전 확인 실패, 최신 릴리즈 다운로드 시도..."
            fi

            INSTALLER_PATH="AI-Game-Dev-Installer.unitypackage"

            echo "📥 다운로드 중..."
            if curl -fsSL -o "$INSTALLER_PATH" "$INSTALLER_URL" 2>/dev/null; then
                echo "✅ 다운로드 완료: $INSTALLER_PATH"
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "📋 다음 단계 (수동):"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "1. Unity 에디터에 $INSTALLER_PATH 드래그앤드롭"
                echo "2. Unity 에디터 한 번 실행 (MCP 서버 빌드)"
                echo "3. 터미널에서: .claude/scripts/setup-unity-mcp.sh setup"
                echo "4. Unity > Window > AI Game Developer > Connect"
                echo "5. Claude Code 재시작"
            else
                echo "❌ 다운로드 실패. 수동으로 설치해주세요:"
                echo "   https://github.com/IvanMurzak/Unity-MCP/releases"
            fi
        else
            echo ""
            echo "💡 나중에 Unity-MCP를 설치하려면:"
            echo "   https://github.com/IvanMurzak/Unity-MCP"
        fi
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 설정 완료!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
