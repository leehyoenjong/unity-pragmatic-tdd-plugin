#!/bin/bash

# Unity-MCP 설정 스크립트
# Claude Code에서 Unity-MCP 서버를 자동으로 설정합니다.
#
# 사용법: .claude/scripts/setup-unity-mcp.sh [Unity프로젝트경로]
#
# 사전 요구사항:
# 1. Unity 프로젝트에 Unity-MCP 패키지가 설치되어 있어야 함
#    - Unity 에디터에서: Window > AI Game Developer (Unity-MCP) > Install
#    - 또는 OpenUPM: openupm add com.ivanmurzak.unity.mcp
#
# 2. Unity 에디터에서 MCP 서버가 빌드되어 있어야 함
#    - Window > AI Game Developer (Unity-MCP) > Build Server

set -e

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Unity 프로젝트 경로 (인자 또는 현재 디렉토리)
UNITY_PROJECT_PATH="${1:-$(pwd)}"

# 플랫폼 감지
detect_platform() {
    case "$(uname -s)" in
        Darwin)
            if [[ "$(uname -m)" == "arm64" ]]; then
                echo "osx-arm64"
            else
                echo "osx-x64"
            fi
            ;;
        Linux)
            echo "linux-x64"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "win-x64"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

PLATFORM=$(detect_platform)
MCP_SERVER_PATH="$UNITY_PROJECT_PATH/Library/mcp-server/$PLATFORM/unity-mcp-server"

echo -e "${GREEN}=== Unity-MCP 설정 스크립트 ===${NC}"
echo ""

# Unity 프로젝트 확인
if [ ! -d "$UNITY_PROJECT_PATH/Assets" ]; then
    echo -e "${RED}오류: Unity 프로젝트를 찾을 수 없습니다.${NC}"
    echo "경로: $UNITY_PROJECT_PATH"
    echo ""
    echo "사용법: ./setup-unity-mcp.sh [Unity프로젝트경로]"
    exit 1
fi

echo -e "Unity 프로젝트: ${YELLOW}$UNITY_PROJECT_PATH${NC}"
echo -e "플랫폼: ${YELLOW}$PLATFORM${NC}"
echo ""

# MCP 서버 확인
if [ ! -f "$MCP_SERVER_PATH" ] && [ ! -f "${MCP_SERVER_PATH}.exe" ]; then
    echo -e "${YELLOW}⚠️  Unity-MCP 서버를 찾을 수 없습니다.${NC}"
    echo ""
    echo "다음 단계를 따라주세요:"
    echo ""
    echo "1. Unity 에디터에서 Unity-MCP 패키지 설치:"
    echo "   - Package Manager > Add package from git URL:"
    echo "   - https://github.com/IvanMurzak/Unity-MCP.git"
    echo "   또는"
    echo "   - openupm add com.ivanmurzak.unity.mcp"
    echo ""
    echo "2. Unity 에디터에서 MCP 서버 빌드:"
    echo "   - Window > AI Game Developer (Unity-MCP)"
    echo "   - 'Build Server' 버튼 클릭"
    echo ""
    echo "3. 이 스크립트 다시 실행"
    exit 1
fi

echo -e "${GREEN}✅ Unity-MCP 서버 발견${NC}"
echo ""

# Claude Code MCP 설정
echo "Claude Code에 MCP 서버 등록 중..."

# Windows 처리
if [[ "$PLATFORM" == "win-x64" ]]; then
    MCP_SERVER_PATH="${MCP_SERVER_PATH}.exe"
fi

# claude mcp add 명령 실행
if command -v claude &> /dev/null; then
    claude mcp add unity-mcp "$MCP_SERVER_PATH" --transport stdio 2>/dev/null && {
        echo -e "${GREEN}✅ Claude Code에 Unity-MCP 등록 완료${NC}"
    } || {
        echo -e "${YELLOW}⚠️  자동 등록 실패. 수동으로 등록해주세요:${NC}"
        echo ""
        echo "claude mcp add unity-mcp \"$MCP_SERVER_PATH\" --transport stdio"
    }
else
    echo -e "${YELLOW}⚠️  claude 명령을 찾을 수 없습니다.${NC}"
    echo "Claude Code에서 다음 명령을 실행하세요:"
    echo ""
    echo "claude mcp add unity-mcp \"$MCP_SERVER_PATH\" --transport stdio"
fi

echo ""
echo -e "${GREEN}=== Unity-MCP 설정 완료 ===${NC}"
echo ""
echo "사용 방법:"
echo "  Claude Code에서 자연어로 Unity 작업을 요청하세요:"
echo "  - \"씬에 큐브 3개를 원형으로 배치해줘\""
echo "  - \"골드 메탈릭 머티리얼 만들어줘\""
echo ""
echo "참고: https://github.com/IvanMurzak/Unity-MCP"
