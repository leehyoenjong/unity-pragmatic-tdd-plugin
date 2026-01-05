# Unity Pragmatic TDD 플러그인 초기 설정

## 실행 순서

### 1. PROJECT_CONTEXT.md 확인
프로젝트 루트에 PROJECT_CONTEXT.md 파일이 있는지 확인합니다.
- 있으면: 내용을 읽고 프로젝트 단계를 파악
- 없으면: 사용자에게 프로젝트 단계를 물어보고 생성

### 2. Unity 프로젝트 확인
Assets 폴더 또는 Packages/manifest.json이 있는지 확인합니다.

Unity 프로젝트인 경우:
- Unity-MCP 설치 여부 확인 (Packages/manifest.json에서 com.ivanmurzak.unity.mcp 검색)
- 설치되어 있지 않으면 AskUserQuestion 도구로 설치 여부를 물어봅니다:
  - 질문: "Unity-MCP를 설치하시겠습니까?"
  - 옵션:
    - "설치하기" - Unity-MCP Installer를 다운로드하고 설치 안내를 표시
    - "나중에" - 건너뛰기

### 3. Unity-MCP 설치 (사용자가 선택한 경우)
다음 명령어로 다운로드:
```bash
curl -fsSL -o AI-Game-Dev-Installer.unitypackage https://github.com/IvanMurzak/Unity-MCP/releases/latest/download/AI-Game-Dev-Installer.unitypackage
```

다운로드 후 안내:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Unity-MCP 설치 단계 (수동):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Unity 에디터에 AI-Game-Dev-Installer.unitypackage 드래그앤드롭
2. Unity 에디터 한 번 실행 (MCP 서버 빌드)
3. 터미널에서: .claude/scripts/setup-unity-mcp.sh setup
4. Unity > Window > AI Game Developer > Connect
5. Claude Code 재시작
```

### 4. .clauderules 생성
프로젝트 루트에 .clauderules 파일 생성:
```
Read and follow all instructions in CLAUDE.md.
Always check PROJECT_CONTEXT.md before starting work.
```

### 5. 완료 메시지
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 초기 설정 완료!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
