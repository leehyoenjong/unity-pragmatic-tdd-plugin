#!/bin/bash

# Unity-MCP 설정 및 실행 스크립트
# MCP 서버를 실행하고 Unity와 연결합니다.
#
# 사용법:
#   .claude/scripts/setup-unity-mcp.sh [start|stop|status] [Unity프로젝트경로]
#
# 명령어:
#   start  - MCP 서버 시작 (기본)
#   stop   - MCP 서버 중지
#   status - MCP 서버 상태 확인
#
# 사전 요구사항:
# 1. Unity 프로젝트에 Unity-MCP 패키지가 설치되어 있어야 함
#    - install.sh 실행 시 자동 다운로드
#    - AI-Game-Dev-Installer.unitypackage를 Unity에 임포트
#
# 2. Unity 에디터를 한 번 실행해야 MCP 서버가 빌드됨
#    - Library/mcp-server/ 폴더에 서버 파일 생성

set -e

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# 기본값
COMMAND="${1:-start}"
MCP_PORT=8080

# 명령어가 경로처럼 보이면 경로로 처리
if [[ "$COMMAND" == /* ]] || [[ "$COMMAND" == ./* ]]; then
    UNITY_PROJECT_PATH="$COMMAND"
    COMMAND="start"
else
    UNITY_PROJECT_PATH="${2:-$(pwd)}"
fi

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
MCP_SERVER_DIR="$UNITY_PROJECT_PATH/Library/mcp-server/$PLATFORM"
MCP_SERVER_PATH="$MCP_SERVER_DIR/unity-mcp-server"
UNITY_CONFIG_PATH="$UNITY_PROJECT_PATH/Assets/Resources/AI-Game-Developer-Config.json"
PID_FILE="/tmp/unity-mcp-server-$(echo "$UNITY_PROJECT_PATH" | md5sum | cut -d' ' -f1).pid"

# Windows 처리
if [[ "$PLATFORM" == "win-x64" ]]; then
    MCP_SERVER_PATH="${MCP_SERVER_PATH}.exe"
fi

# 서버 상태 확인
check_server_status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "running"
            return 0
        fi
    fi

    # PID 파일 없어도 프로세스 확인
    if pgrep -f "unity-mcp-server" > /dev/null 2>&1; then
        echo "running"
        return 0
    fi

    echo "stopped"
    return 1
}

# 서버 시작
start_server() {
    echo -e "${GREEN}=== Unity-MCP 서버 시작 ===${NC}"
    echo ""

    # Unity 프로젝트 확인
    if [ ! -d "$UNITY_PROJECT_PATH/Assets" ]; then
        echo -e "${RED}오류: Unity 프로젝트를 찾을 수 없습니다.${NC}"
        echo "경로: $UNITY_PROJECT_PATH"
        exit 1
    fi

    echo -e "Unity 프로젝트: ${YELLOW}$UNITY_PROJECT_PATH${NC}"
    echo -e "플랫폼: ${YELLOW}$PLATFORM${NC}"
    echo ""

    # MCP 서버 확인
    if [ ! -f "$MCP_SERVER_PATH" ]; then
        echo -e "${RED}오류: Unity-MCP 서버를 찾을 수 없습니다.${NC}"
        echo ""
        echo "다음 단계를 따라주세요:"
        echo "  1. AI-Game-Dev-Installer.unitypackage를 Unity에 임포트"
        echo "  2. Unity 에디터를 한 번 실행 (서버 자동 빌드)"
        echo "  3. 이 스크립트 다시 실행"
        exit 1
    fi

    # 이미 실행 중인지 확인
    if [ "$(check_server_status)" == "running" ]; then
        echo -e "${YELLOW}⚠️  MCP 서버가 이미 실행 중입니다.${NC}"
        echo ""
        echo "서버 중지: .claude/scripts/setup-unity-mcp.sh stop"
        return 0
    fi

    # Unity 설정 파일 포트 확인 및 수정
    if [ -f "$UNITY_CONFIG_PATH" ]; then
        CURRENT_HOST=$(grep -o '"host": "[^"]*"' "$UNITY_CONFIG_PATH" | sed 's/"host": "//;s/"//')
        CURRENT_PORT=$(echo "$CURRENT_HOST" | sed 's/.*://;s/[^0-9].*//')

        if [ "$CURRENT_PORT" != "$MCP_PORT" ]; then
            echo -e "${YELLOW}⚠️  Unity 설정 포트($CURRENT_PORT)와 서버 포트($MCP_PORT)가 다릅니다.${NC}"
            echo -e "${CYAN}Unity 설정을 포트 $MCP_PORT으로 수정합니다...${NC}"

            if [[ "$(uname -s)" == "Darwin" ]]; then
                sed -i '' "s|\"host\": \"http://localhost:[0-9]*\"|\"host\": \"http://localhost:$MCP_PORT\"|" "$UNITY_CONFIG_PATH"
            else
                sed -i "s|\"host\": \"http://localhost:[0-9]*\"|\"host\": \"http://localhost:$MCP_PORT\"|" "$UNITY_CONFIG_PATH"
            fi
            echo -e "${GREEN}✅ Unity 설정 수정 완료${NC}"
            echo ""
        fi
    fi

    # 서버 시작
    echo -e "${CYAN}🚀 MCP 서버 시작 중... (포트: $MCP_PORT)${NC}"
    cd "$MCP_SERVER_DIR"
    nohup ./unity-mcp-server > /tmp/unity-mcp-server.log 2>&1 &
    SERVER_PID=$!
    echo "$SERVER_PID" > "$PID_FILE"

    # 시작 확인
    sleep 2
    if ps -p "$SERVER_PID" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ MCP 서버 시작 완료 (PID: $SERVER_PID)${NC}"
        echo ""
        echo -e "${GREEN}📋 다음 단계:${NC}"
        echo "  1. Unity 에디터에서 Window > AI Game Developer"
        echo "  2. Connect 버튼 클릭"
        echo ""
        echo -e "${CYAN}서버 로그: tail -f /tmp/unity-mcp-server.log${NC}"
        echo -e "${CYAN}서버 중지: .claude/scripts/setup-unity-mcp.sh stop${NC}"
    else
        echo -e "${RED}❌ MCP 서버 시작 실패${NC}"
        echo "로그 확인: cat /tmp/unity-mcp-server.log"
        rm -f "$PID_FILE"
        exit 1
    fi
}

# 서버 중지
stop_server() {
    echo -e "${GREEN}=== Unity-MCP 서버 중지 ===${NC}"
    echo ""

    # PID 파일로 중지
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            kill "$PID" 2>/dev/null || true
            echo -e "${GREEN}✅ MCP 서버 중지 완료 (PID: $PID)${NC}"
        fi
        rm -f "$PID_FILE"
    fi

    # 남은 프로세스 정리
    pkill -f "unity-mcp-server" 2>/dev/null || true
    echo -e "${GREEN}✅ 모든 MCP 서버 프로세스 정리 완료${NC}"
}

# 서버 상태 출력
show_status() {
    echo -e "${GREEN}=== Unity-MCP 서버 상태 ===${NC}"
    echo ""
    echo -e "Unity 프로젝트: ${YELLOW}$UNITY_PROJECT_PATH${NC}"
    echo -e "플랫폼: ${YELLOW}$PLATFORM${NC}"
    echo ""

    if [ "$(check_server_status)" == "running" ]; then
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            echo -e "상태: ${GREEN}실행 중${NC} (PID: $PID)"
        else
            echo -e "상태: ${GREEN}실행 중${NC}"
        fi
        echo -e "포트: ${CYAN}$MCP_PORT${NC}"
    else
        echo -e "상태: ${RED}중지됨${NC}"
    fi

    echo ""
    if [ -f "$MCP_SERVER_PATH" ]; then
        echo -e "서버 파일: ${GREEN}있음${NC}"
    else
        echo -e "서버 파일: ${RED}없음${NC}"
    fi

    if [ -f "$UNITY_CONFIG_PATH" ]; then
        echo -e "Unity 설정: ${GREEN}있음${NC}"
        CURRENT_HOST=$(grep -o '"host": "[^"]*"' "$UNITY_CONFIG_PATH" | sed 's/"host": "//;s/"//')
        echo -e "Unity 호스트: ${CYAN}$CURRENT_HOST${NC}"
    else
        echo -e "Unity 설정: ${RED}없음${NC}"
    fi
}

# 명령어 처리
case "$COMMAND" in
    start)
        start_server
        ;;
    stop)
        stop_server
        ;;
    status)
        show_status
        ;;
    *)
        echo "사용법: $0 [start|stop|status] [Unity프로젝트경로]"
        echo ""
        echo "명령어:"
        echo "  start  - MCP 서버 시작 (기본)"
        echo "  stop   - MCP 서버 중지"
        echo "  status - MCP 서버 상태 확인"
        exit 1
        ;;
esac
