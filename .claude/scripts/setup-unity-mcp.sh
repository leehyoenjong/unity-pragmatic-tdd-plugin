#!/bin/bash

# Unity-MCP 설정 및 실행 스크립트
# MCP 서버를 실행하고 Unity/Claude Code와 연결합니다.
#
# 사용법:
#   .claude/scripts/setup-unity-mcp.sh [명령어] [Unity프로젝트경로]
#
# 명령어:
#   start    - MCP 서버 시작 (기본)
#   stop     - MCP 서버 중지
#   status   - 전체 연결 상태 확인
#   register - Claude Code에 MCP 등록
#   setup    - 전체 설정 (서버 시작 + Claude Code 등록)
#
# 사전 요구사항:
# 1. Unity에 AI-Game-Dev-Installer.unitypackage 임포트
# 2. Unity 에디터 한 번 실행 (서버 자동 빌드)

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
MCP_NAME="unity-mcp"

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
INSTALLER_PATH="$UNITY_PROJECT_PATH/AI-Game-Dev-Installer.unitypackage"

# macOS에서 md5sum 대신 md5 사용
if [[ "$(uname -s)" == "Darwin" ]]; then
    PID_FILE="/tmp/unity-mcp-server-$(echo "$UNITY_PROJECT_PATH" | md5 -q).pid"
else
    PID_FILE="/tmp/unity-mcp-server-$(echo "$UNITY_PROJECT_PATH" | md5sum | cut -d' ' -f1).pid"
fi

# Windows 처리
if [[ "$PLATFORM" == "win-x64" ]]; then
    MCP_SERVER_PATH="${MCP_SERVER_PATH}.exe"
fi

# ===== 유틸리티 함수 =====

# 서버 프로세스 상태 확인
check_server_status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "running"
            return 0
        fi
    fi
    if pgrep -f "unity-mcp-server" > /dev/null 2>&1; then
        echo "running"
        return 0
    fi
    echo "stopped"
    return 1
}

# Claude Code MCP 등록 상태 확인
check_claude_mcp_status() {
    if command -v claude &> /dev/null; then
        if claude mcp list 2>/dev/null | grep -q "$MCP_NAME"; then
            echo "registered"
            return 0
        fi
    fi
    echo "not_registered"
    return 1
}

# Unity 설정 파일 포트 수정
fix_unity_port() {
    if [ -f "$UNITY_CONFIG_PATH" ]; then
        CURRENT_HOST=$(grep -o '"host": "[^"]*"' "$UNITY_CONFIG_PATH" 2>/dev/null | sed 's/"host": "//;s/"//')
        CURRENT_PORT=$(echo "$CURRENT_HOST" | sed 's/.*://;s/[^0-9].*//')

        if [ -n "$CURRENT_PORT" ] && [ "$CURRENT_PORT" != "$MCP_PORT" ]; then
            echo -e "${YELLOW}⚠️  Unity 포트($CURRENT_PORT) → 서버 포트($MCP_PORT)로 수정${NC}"
            if [[ "$(uname -s)" == "Darwin" ]]; then
                sed -i '' "s|\"host\": \"http://localhost:[0-9]*\"|\"host\": \"http://localhost:$MCP_PORT\"|" "$UNITY_CONFIG_PATH"
            else
                sed -i "s|\"host\": \"http://localhost:[0-9]*\"|\"host\": \"http://localhost:$MCP_PORT\"|" "$UNITY_CONFIG_PATH"
            fi
            echo -e "${GREEN}✅ Unity 설정 수정 완료${NC}"
            return 0
        fi
    fi
    return 1
}

# ===== 메인 명령어 =====

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

    echo -e "프로젝트: ${YELLOW}$(basename "$UNITY_PROJECT_PATH")${NC}"
    echo -e "플랫폼: ${YELLOW}$PLATFORM${NC}"
    echo ""

    # MCP 서버 파일 확인
    if [ ! -f "$MCP_SERVER_PATH" ]; then
        echo -e "${RED}오류: MCP 서버 파일이 없습니다.${NC}"
        echo ""
        echo -e "${YELLOW}📋 필요한 단계:${NC}"
        if [ -f "$INSTALLER_PATH" ]; then
            echo "  1. $INSTALLER_PATH 를 Unity에 드래그앤드롭"
        else
            echo "  1. AI-Game-Dev-Installer.unitypackage를 Unity에 임포트"
        fi
        echo "  2. Unity 에디터 실행 (서버 자동 빌드)"
        echo "  3. 이 스크립트 다시 실행"
        exit 1
    fi

    # 이미 실행 중인지 확인
    if [ "$(check_server_status)" == "running" ]; then
        echo -e "${GREEN}✅ MCP 서버가 이미 실행 중입니다.${NC}"
        show_next_steps
        return 0
    fi

    # Unity 포트 수정
    fix_unity_port

    # 서버 시작
    echo -e "${CYAN}🚀 MCP 서버 시작 중... (포트: $MCP_PORT)${NC}"
    cd "$MCP_SERVER_DIR"
    nohup ./unity-mcp-server > /tmp/unity-mcp-server.log 2>&1 &
    SERVER_PID=$!
    echo "$SERVER_PID" > "$PID_FILE"

    sleep 2
    if ps -p "$SERVER_PID" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ MCP 서버 시작 완료 (PID: $SERVER_PID)${NC}"
        echo ""
        show_next_steps
    else
        echo -e "${RED}❌ MCP 서버 시작 실패${NC}"
        echo "로그: cat /tmp/unity-mcp-server.log"
        rm -f "$PID_FILE"
        exit 1
    fi
}

# 다음 단계 안내
show_next_steps() {
    echo -e "${GREEN}📋 다음 단계:${NC}"

    # Claude Code MCP 등록 상태 확인
    if [ "$(check_claude_mcp_status)" != "registered" ]; then
        echo -e "  ${YELLOW}1. Claude Code에 MCP 등록 (필수):${NC}"
        echo "     .claude/scripts/setup-unity-mcp.sh register"
        echo ""
        echo -e "  ${CYAN}2. Unity에서 Connect:${NC}"
        echo "     Window > AI Game Developer > Connect"
    else
        echo -e "  ${CYAN}1. Unity에서 Connect:${NC}"
        echo "     Window > AI Game Developer > Connect"
        echo ""
        echo -e "  ${GREEN}✅ Claude Code MCP 이미 등록됨${NC}"
    fi
    echo ""
    echo -e "${CYAN}서버 로그: tail -f /tmp/unity-mcp-server.log${NC}"
}

# 서버 중지
stop_server() {
    echo -e "${GREEN}=== Unity-MCP 서버 중지 ===${NC}"
    echo ""

    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            kill "$PID" 2>/dev/null || true
            echo -e "${GREEN}✅ MCP 서버 중지 (PID: $PID)${NC}"
        fi
        rm -f "$PID_FILE"
    fi

    pkill -f "unity-mcp-server" 2>/dev/null || true
    echo -e "${GREEN}✅ 완료${NC}"
}

# Claude Code에 MCP 등록
register_mcp() {
    echo -e "${GREEN}=== Claude Code에 MCP 등록 ===${NC}"
    echo ""

    if [ ! -f "$MCP_SERVER_PATH" ]; then
        echo -e "${RED}오류: MCP 서버 파일이 없습니다.${NC}"
        echo "먼저 Unity-MCP를 설치하고 Unity를 한 번 실행해주세요."
        exit 1
    fi

    if ! command -v claude &> /dev/null; then
        echo -e "${RED}오류: claude 명령어를 찾을 수 없습니다.${NC}"
        echo ""
        echo "수동으로 등록하세요:"
        echo "  claude mcp add $MCP_NAME \"$MCP_SERVER_PATH\""
        exit 1
    fi

    # 이미 등록되어 있는지 확인
    if claude mcp list 2>/dev/null | grep -q "$MCP_NAME"; then
        echo -e "${YELLOW}⚠️  '$MCP_NAME'이 이미 등록되어 있습니다.${NC}"
        echo ""
        echo "재등록하려면:"
        echo "  claude mcp remove $MCP_NAME"
        echo "  .claude/scripts/setup-unity-mcp.sh register"
        return 0
    fi

    # MCP 등록
    echo -e "등록 중: ${CYAN}$MCP_NAME${NC}"
    echo -e "서버: ${CYAN}$MCP_SERVER_PATH${NC}"
    echo ""

    if claude mcp add "$MCP_NAME" "$MCP_SERVER_PATH" 2>/dev/null; then
        echo -e "${GREEN}✅ Claude Code에 MCP 등록 완료${NC}"
        echo ""
        echo -e "${YELLOW}⚠️  중요: Claude Code를 재시작해야 MCP가 활성화됩니다.${NC}"
    else
        echo -e "${RED}❌ 등록 실패${NC}"
        echo ""
        echo "수동으로 등록하세요:"
        echo "  claude mcp add $MCP_NAME \"$MCP_SERVER_PATH\""
    fi
}

# 전체 설정 (서버 시작 + MCP 등록)
full_setup() {
    echo -e "${GREEN}=== Unity-MCP 전체 설정 ===${NC}"
    echo ""

    start_server
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    register_mcp
}

# 상태 확인
show_status() {
    echo -e "${GREEN}=== Unity-MCP 연결 상태 ===${NC}"
    echo ""
    echo -e "프로젝트: ${YELLOW}$(basename "$UNITY_PROJECT_PATH")${NC}"
    echo -e "경로: ${CYAN}$UNITY_PROJECT_PATH${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # 1. Installer 상태
    echo -n "1. Unity-MCP 패키지: "
    if [ -d "$UNITY_PROJECT_PATH/Assets/com.IvanMurzak" ] || [ -f "$UNITY_CONFIG_PATH" ]; then
        echo -e "${GREEN}설치됨 ✅${NC}"
    elif [ -f "$INSTALLER_PATH" ]; then
        echo -e "${YELLOW}다운로드됨 (임포트 필요) ⚠️${NC}"
    else
        echo -e "${RED}미설치 ❌${NC}"
    fi

    # 2. 서버 파일 상태
    echo -n "2. MCP 서버 파일: "
    if [ -f "$MCP_SERVER_PATH" ]; then
        echo -e "${GREEN}있음 ✅${NC}"
    else
        echo -e "${RED}없음 (Unity 실행 필요) ❌${NC}"
    fi

    # 3. 서버 실행 상태
    echo -n "3. MCP 서버 프로세스: "
    if [ "$(check_server_status)" == "running" ]; then
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            echo -e "${GREEN}실행 중 (PID: $PID) ✅${NC}"
        else
            echo -e "${GREEN}실행 중 ✅${NC}"
        fi
    else
        echo -e "${RED}중지됨 ❌${NC}"
    fi

    # 4. Unity 설정 상태
    echo -n "4. Unity 포트 설정: "
    if [ -f "$UNITY_CONFIG_PATH" ]; then
        CURRENT_HOST=$(grep -o '"host": "[^"]*"' "$UNITY_CONFIG_PATH" 2>/dev/null | sed 's/"host": "//;s/"//')
        CURRENT_PORT=$(echo "$CURRENT_HOST" | sed 's/.*://;s/[^0-9].*//')
        if [ "$CURRENT_PORT" == "$MCP_PORT" ]; then
            echo -e "${GREEN}$CURRENT_PORT (정상) ✅${NC}"
        else
            echo -e "${YELLOW}$CURRENT_PORT (서버: $MCP_PORT) ⚠️${NC}"
        fi
    else
        echo -e "${YELLOW}설정 파일 없음${NC}"
    fi

    # 5. Claude Code MCP 등록 상태
    echo -n "5. Claude Code MCP: "
    if command -v claude &> /dev/null; then
        if claude mcp list 2>/dev/null | grep -q "$MCP_NAME"; then
            echo -e "${GREEN}등록됨 ✅${NC}"
        else
            echo -e "${RED}미등록 ❌${NC}"
        fi
    else
        echo -e "${YELLOW}확인 불가 (claude 명령어 없음)${NC}"
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${CYAN}명령어:${NC}"
    echo "  start    - MCP 서버 시작"
    echo "  stop     - MCP 서버 중지"
    echo "  register - Claude Code에 MCP 등록"
    echo "  setup    - 전체 설정 (start + register)"
}

# ===== 명령어 처리 =====
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
    register)
        register_mcp
        ;;
    setup)
        full_setup
        ;;
    *)
        echo "Unity-MCP 설정 스크립트"
        echo ""
        echo "사용법: $0 [명령어] [Unity프로젝트경로]"
        echo ""
        echo "명령어:"
        echo "  start    - MCP 서버 시작 (기본)"
        echo "  stop     - MCP 서버 중지"
        echo "  status   - 전체 연결 상태 확인"
        echo "  register - Claude Code에 MCP 등록"
        echo "  setup    - 전체 설정 (start + register)"
        exit 1
        ;;
esac
