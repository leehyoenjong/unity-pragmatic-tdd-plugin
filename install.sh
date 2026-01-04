#!/bin/bash

# Unity Pragmatic TDD Plugin 설치 스크립트
# 사용법: curl -fsSL https://raw.githubusercontent.com/leehyoenjong/unity-pragmatic-tdd-plugin/main/install.sh | bash

set -e

REPO_URL="https://github.com/leehyoenjong/unity-pragmatic-tdd-plugin.git"
PLUGIN_DIR=".claude-plugin"
UNITY_MCP_VERSION_URL="https://api.github.com/repos/IvanMurzak/Unity-MCP/releases/latest"

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}🎮 Unity Pragmatic TDD Plugin 설치 중...${NC}"
echo ""

# Git submodule로 추가
if [ -d "$PLUGIN_DIR" ]; then
    echo -e "${YELLOW}⚠️  .claude-plugin 폴더가 이미 존재합니다. 업데이트합니다...${NC}"
    cd "$PLUGIN_DIR" && git pull && cd ..
else
    git submodule add "$REPO_URL" "$PLUGIN_DIR" 2>/dev/null || git clone "$REPO_URL" "$PLUGIN_DIR"
fi

# .claude 폴더 생성 및 심볼릭 링크
mkdir -p .claude

# 기존 링크/폴더 제거 후 생성
rm -rf .claude/skills .claude/docs .claude/commands .claude/scripts .claude/hooks 2>/dev/null || true
ln -s ../$PLUGIN_DIR/skills .claude/skills
ln -s ../$PLUGIN_DIR/docs .claude/docs
ln -s ../$PLUGIN_DIR/commands .claude/commands
ln -s ../$PLUGIN_DIR/.claude/scripts .claude/scripts
ln -s ../$PLUGIN_DIR/.claude/hooks .claude/hooks

# settings.json 병합 (hooks 설정 추가)
if [ -f ".claude/settings.json" ]; then
    # 기존 settings.json이 있으면 hooks 설정만 추가
    if ! grep -q '"hooks"' .claude/settings.json 2>/dev/null; then
        echo -e "${YELLOW}⚠️  기존 settings.json에 hooks 설정을 수동으로 추가해주세요.${NC}"
        echo "   참고: $PLUGIN_DIR/.claude/settings.json"
    fi
else
    # settings.json이 없으면 복사
    cp "$PLUGIN_DIR/.claude/settings.json" .claude/settings.json
fi

# CLAUDE.md 복사
cp "$PLUGIN_DIR/CLAUDE.md" ./CLAUDE.md

echo -e "${GREEN}✅ 플러그인 설치 완료!${NC}"
echo ""

# Unity-MCP 최신 버전 확인
echo -e "${CYAN}🔍 Unity-MCP 최신 버전 확인 중...${NC}"
UNITY_MCP_LATEST=$(curl -s "$UNITY_MCP_VERSION_URL" 2>/dev/null | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' || echo "확인 실패")

if [ "$UNITY_MCP_LATEST" != "확인 실패" ] && [ -n "$UNITY_MCP_LATEST" ]; then
    echo -e "${GREEN}📦 Unity-MCP 최신 버전: ${YELLOW}$UNITY_MCP_LATEST${NC}"
else
    echo -e "${YELLOW}⚠️  Unity-MCP 버전 확인 실패 (네트워크 오류)${NC}"
    UNITY_MCP_LATEST=""
fi

# Unity 프로젝트 감지 및 Unity-MCP 자동 설치
MANIFEST_PATH="Packages/manifest.json"
UNITY_MCP_PACKAGE="com.ivanmurzak.unity.mcp"

if [ -f "$MANIFEST_PATH" ]; then
    echo ""
    echo -e "${CYAN}🎮 Unity 프로젝트 감지됨${NC}"

    # Unity-MCP가 이미 설치되어 있는지 확인 (manifest.json 또는 Packages 폴더)
    if grep -q "$UNITY_MCP_PACKAGE" "$MANIFEST_PATH" 2>/dev/null || [ -d "Packages/$UNITY_MCP_PACKAGE" ] || [ -d "Assets/Plugins/Unity-MCP" ]; then
        echo -e "${GREEN}✅ Unity-MCP가 이미 설치되어 있습니다.${NC}"
    else
        echo -e "${YELLOW}Unity-MCP Installer를 다운로드하시겠습니까? (y/n)${NC}"
        read -r INSTALL_MCP

        if [ "$INSTALL_MCP" = "y" ] || [ "$INSTALL_MCP" = "Y" ]; then
            # 최신 버전 unitypackage URL 생성
            if [ -n "$UNITY_MCP_LATEST" ]; then
                INSTALLER_URL="https://github.com/IvanMurzak/Unity-MCP/releases/download/${UNITY_MCP_LATEST}/AI-Game-Dev-Installer.unitypackage"
            else
                INSTALLER_URL="https://github.com/IvanMurzak/Unity-MCP/releases/latest/download/AI-Game-Dev-Installer.unitypackage"
            fi

            INSTALLER_PATH="AI-Game-Dev-Installer.unitypackage"

            echo -e "${CYAN}📥 Unity-MCP Installer 다운로드 중...${NC}"
            if curl -fsSL -o "$INSTALLER_PATH" "$INSTALLER_URL" 2>/dev/null; then
                echo -e "${GREEN}✅ 다운로드 완료: $INSTALLER_PATH${NC}"

                # Unity 에디터 경로 찾기 (macOS)
                UNITY_EDITOR=""
                if [[ "$(uname -s)" == "Darwin" ]]; then
                    # Unity Hub에서 설치된 에디터 찾기
                    if [ -d "/Applications/Unity/Hub/Editor" ]; then
                        UNITY_VERSION=$(ls -1 "/Applications/Unity/Hub/Editor" 2>/dev/null | sort -V | tail -1)
                        if [ -n "$UNITY_VERSION" ]; then
                            UNITY_EDITOR="/Applications/Unity/Hub/Editor/$UNITY_VERSION/Unity.app/Contents/MacOS/Unity"
                        fi
                    fi
                elif [[ "$(uname -s)" == "MINGW"* ]] || [[ "$(uname -s)" == "MSYS"* ]]; then
                    # Windows
                    if [ -d "C:/Program Files/Unity/Hub/Editor" ]; then
                        UNITY_VERSION=$(ls -1 "C:/Program Files/Unity/Hub/Editor" 2>/dev/null | sort -V | tail -1)
                        if [ -n "$UNITY_VERSION" ]; then
                            UNITY_EDITOR="C:/Program Files/Unity/Hub/Editor/$UNITY_VERSION/Editor/Unity.exe"
                        fi
                    fi
                fi

                # 자동 임포트 시도 여부 확인
                if [ -n "$UNITY_EDITOR" ] && [ -f "$UNITY_EDITOR" ]; then
                    echo ""
                    echo -e "${YELLOW}Unity 에디터를 찾았습니다: $UNITY_VERSION${NC}"
                    echo -e "${YELLOW}자동으로 임포트를 시도하시겠습니까? (y/n)${NC}"
                    echo -e "${CYAN}   (Unity가 실행 중이면 'n'을 선택하세요)${NC}"
                    read -r AUTO_IMPORT

                    if [ "$AUTO_IMPORT" = "y" ] || [ "$AUTO_IMPORT" = "Y" ]; then
                        echo -e "${CYAN}🔄 Unity 에디터로 패키지 임포트 중... (시간이 걸릴 수 있습니다)${NC}"
                        PROJECT_PATH="$(pwd)"
                        "$UNITY_EDITOR" -projectPath "$PROJECT_PATH" -importPackage "$PROJECT_PATH/$INSTALLER_PATH" -quit -batchmode 2>/dev/null && {
                            echo -e "${GREEN}✅ Unity-MCP 패키지 임포트 완료!${NC}"
                            rm -f "$INSTALLER_PATH"
                        } || {
                            echo -e "${YELLOW}⚠️  자동 임포트 실패. 수동으로 임포트해주세요.${NC}"
                        }
                    fi
                fi

                # 수동 임포트 안내 (자동 실패 또는 선택 안함)
                if [ -f "$INSTALLER_PATH" ]; then
                    echo ""
                    echo -e "${GREEN}📦 다음 단계:${NC}"
                    echo "   1. Unity 에디터를 엽니다"
                    echo "   2. $INSTALLER_PATH 파일을 Unity에 드래그앤드롭"
                    echo "      또는 Assets > Import Package > Custom Package"
                    echo "   3. Import 클릭"
                    echo ""
                    echo -e "${YELLOW}⚠️  임포트 후 연결 방법:${NC}"
                    echo "   1. .claude/scripts/setup-unity-mcp.sh start  (서버 시작)"
                    echo "   2. Unity > Window > AI Game Developer > Connect 클릭"
                fi
            else
                echo -e "${RED}❌ 다운로드 실패. 수동으로 설치해주세요.${NC}"
                echo "   URL: $INSTALLER_URL"
            fi
        else
            echo -e "${CYAN}Unity-MCP 설치를 건너뜁니다.${NC}"
        fi
    fi
else
    echo ""
    echo -e "${YELLOW}⚠️  Unity 프로젝트가 아닌 것 같습니다. (Packages/manifest.json 없음)${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}📁 설치된 구조:${NC}"
echo "   CLAUDE.md"
echo "   .claude/skills -> .claude-plugin/skills"
echo "   .claude/docs -> .claude-plugin/docs"
echo "   .claude/commands -> .claude-plugin/commands"
echo "   .claude/scripts -> .claude-plugin/.claude/scripts"
echo ""
echo -e "${GREEN}📌 사용 가능한 슬래시 명령어:${NC}"
echo "   /eee_init          - 첫 셋팅"
echo "   /eee_tdd           - TDD 워크플로우 적용"
echo "   /eee_solid         - SOLID 원칙 검토"
echo "   /eee_safety-check  - Beta 단계 기능 안전성 체크"
echo "   /eee_transition    - 프로젝트 단계 전환"
echo "   /eee_review        - 코드 리뷰 (안티패턴 체크)"
echo "   /eee_commit        - Git 커밋"
echo "   /eee_push          - Git 푸시"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${CYAN}🤖 Unity-MCP 수동 설정 (필요시):${NC}"
echo ""
echo "   1. Installer 다운로드:"
echo "      https://github.com/IvanMurzak/Unity-MCP/releases/latest"
echo "      → AI-Game-Dev-Installer.unitypackage 다운로드"
echo ""
echo "   2. Unity에 임포트:"
echo "      다운로드한 파일을 Unity 에디터에 드래그앤드롭"
echo ""
echo "   3. MCP 서버 시작:"
echo "      .claude/scripts/setup-unity-mcp.sh start"
echo ""
echo "   4. Unity에서 연결:"
echo "      Window > AI Game Developer > Connect 클릭"
echo ""
echo "   서버 관리:"
echo "      시작: .claude/scripts/setup-unity-mcp.sh start"
echo "      중지: .claude/scripts/setup-unity-mcp.sh stop"
echo "      상태: .claude/scripts/setup-unity-mcp.sh status"
echo ""
echo "   자세한 정보: https://github.com/IvanMurzak/Unity-MCP"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}🔄 업데이트: cd .claude-plugin && git pull${NC}"
