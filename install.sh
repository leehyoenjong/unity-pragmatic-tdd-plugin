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
UNITY_MCP_GIT_URL="https://github.com/IvanMurzak/Unity-MCP.git"

if [ -f "$MANIFEST_PATH" ]; then
    echo ""
    echo -e "${CYAN}🎮 Unity 프로젝트 감지됨${NC}"

    # Unity-MCP가 이미 설치되어 있는지 확인
    if grep -q "$UNITY_MCP_PACKAGE" "$MANIFEST_PATH" 2>/dev/null; then
        echo -e "${GREEN}✅ Unity-MCP가 이미 설치되어 있습니다.${NC}"
    else
        echo -e "${YELLOW}Unity-MCP를 manifest.json에 추가하시겠습니까? (y/n)${NC}"
        read -r INSTALL_MCP

        if [ "$INSTALL_MCP" = "y" ] || [ "$INSTALL_MCP" = "Y" ]; then
            # manifest.json에 Unity-MCP 추가
            # jq가 있으면 사용, 없으면 sed 사용
            if command -v jq &> /dev/null; then
                # jq를 사용한 안전한 JSON 수정
                jq --arg pkg "$UNITY_MCP_PACKAGE" --arg url "$UNITY_MCP_GIT_URL" \
                   '.dependencies[$pkg] = $url' "$MANIFEST_PATH" > "${MANIFEST_PATH}.tmp" && \
                   mv "${MANIFEST_PATH}.tmp" "$MANIFEST_PATH"
                echo -e "${GREEN}✅ Unity-MCP가 manifest.json에 추가되었습니다.${NC}"
            else
                # sed를 사용한 JSON 수정 (jq 없을 때)
                if grep -q '"dependencies"' "$MANIFEST_PATH"; then
                    sed -i.bak 's/"dependencies": {/"dependencies": {\n    "'"$UNITY_MCP_PACKAGE"'": "'"$UNITY_MCP_GIT_URL"'",/' "$MANIFEST_PATH"
                    rm -f "${MANIFEST_PATH}.bak"
                    echo -e "${GREEN}✅ Unity-MCP가 manifest.json에 추가되었습니다.${NC}"
                else
                    echo -e "${RED}❌ manifest.json 형식을 인식할 수 없습니다.${NC}"
                    echo "   수동으로 추가해주세요: $UNITY_MCP_GIT_URL"
                fi
            fi

            echo ""
            echo -e "${YELLOW}⚠️  다음 단계:${NC}"
            echo "   1. Unity 에디터를 열면 패키지가 자동으로 설치됩니다."
            echo "   2. Window > AI Game Developer (Unity-MCP) > Build Server"
            echo "   3. .claude/scripts/setup-unity-mcp.sh 실행"
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
echo "   1. Unity 에디터에서 패키지 설치:"
echo "      Package Manager > Add package from git URL:"
echo "      https://github.com/IvanMurzak/Unity-MCP.git"
echo ""
echo "   2. MCP 서버 빌드:"
echo "      Window > AI Game Developer (Unity-MCP) > Build Server"
echo ""
echo "   3. Claude Code 연결:"
echo "      .claude/scripts/setup-unity-mcp.sh 실행"
echo ""
echo "   자세한 정보: https://github.com/IvanMurzak/Unity-MCP"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}🔄 업데이트: cd .claude-plugin && git pull${NC}"
