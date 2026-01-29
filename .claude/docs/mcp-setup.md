# MCP 설정 가이드

Claude Code에서 MCP (Model Context Protocol) 서버를 활용하여 기능을 확장합니다.

## 권장 MCP 서버

### 1. Context7 (공식 문서 검색) - 필수

Unity, C#, .NET 공식 문서를 실시간으로 검색합니다.

**설치:**
```bash
# Claude Code 설정에서 MCP 추가
claude mcp add context7
```

**활용:**
- Unity API 문서 조회
- C# 언어 스펙 확인
- NuGet 패키지 문서

---

### 2. Exa (웹 검색) - 필수

최신 정보, 튜토리얼, 문제 해결책을 검색합니다.

**설치:**
```bash
# API 키 필요: https://exa.ai
export EXA_API_KEY="your-api-key"
claude mcp add exa
```

**활용:**
- 최신 Unity 버전 정보
- 커뮤니티 해결책
- 베스트 프랙티스

---

### 3. GitHub (GitHub API) - 권장

GitHub 저장소, PR, Issue에 직접 접근합니다.

**설치:**
```bash
# GitHub 토큰 필요
export GITHUB_TOKEN="your-github-token"
claude mcp add github
```

**활용:**
- 오픈소스 코드 참조
- PR/Issue 관리
- 코드 검색

---

### 4. grep.app (GitHub 코드 검색) - 권장

GitHub 전체에서 코드 패턴을 검색합니다.

**설치:**
```bash
claude mcp add grep-app
```

**활용:**
- 특정 패턴 구현 예시 찾기
- 라이브러리 사용법 확인
- 유사 문제 해결 코드

---

## 설정 파일

### ~/.claude/mcp.json (글로벌)

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-context7"]
    },
    "exa": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-exa"],
      "env": {
        "EXA_API_KEY": "${EXA_API_KEY}"
      }
    }
  }
}
```

### 프로젝트별 설정

`.claude/mcp-config.example.json` 참조

---

## Unity 개발 활용 시나리오

### 시나리오 1: API 사용법 확인

```
"UniTask의 WhenAll 사용법 알려줘"
→ Context7이 UniTask 문서 검색
→ 정확한 API 정보 제공
```

### 시나리오 2: 패턴 참조

```
"인벤토리 시스템 구현 패턴 찾아줘"
→ grep.app이 GitHub에서 검색
→ 오픈소스 구현 예시 제공
```

### 시나리오 3: 최신 정보

```
"Unity 6의 새 기능 알려줘"
→ Exa가 웹 검색
→ 최신 릴리스 정보 제공
```

---

## 에이전트 연동

### Librarian 에이전트

Librarian 에이전트가 MCP를 활용합니다:

```markdown
Librarian 호출 시:
1. Context7로 공식 문서 검색
2. Exa로 커뮤니티 자료 검색
3. grep.app으로 코드 예시 검색
4. 결과 종합하여 제공
```

---

## 비용 고려

| MCP | 비용 | 비고 |
|-----|------|-----|
| Context7 | 무료 | 공식 문서만 |
| Exa | 유료 | API 호출당 과금 |
| GitHub | 무료 | 토큰 필요 |
| grep.app | 무료 | 제한적 |

**권장:** Context7 + GitHub로 시작, 필요시 Exa 추가

---

## 문제 해결

### MCP 연결 실패

```bash
# MCP 상태 확인
claude mcp list

# 로그 확인
claude mcp logs context7
```

### API 키 문제

```bash
# 환경변수 확인
echo $EXA_API_KEY
echo $GITHUB_TOKEN
```
