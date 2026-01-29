# Hooks 시스템

Oh My OpenCode의 hooks 시스템을 Claude Code 형식으로 구현한 것입니다.

## 개요

hooks는 Claude Code의 라이프사이클 이벤트에 반응하여 자동으로 실행됩니다.

### 이벤트 타입

| 이벤트 | 설명 | 실행 시점 |
|-------|------|----------|
| `UserPromptSubmit` | 사용자 입력 제출 | 프롬프트 전송 시 |
| `PreToolUse` | 도구 사용 전 | 도구 호출 직전 |
| `PostToolUse` | 도구 사용 후 | 도구 실행 완료 후 |
| `Stop` | 작업 완료 | 응답 종료 시 |

---

## Hook 목록

### UserPromptSubmit Hooks (8개)

| Hook | 설명 |
|------|------|
| `context-window-monitor.sh` | 컨텍스트 윈도우 사용량 모니터링 |
| `session-recovery.sh` | 이전 세션 미완료 작업 확인 |
| `keyword-detector.sh` | 특수 키워드 감지 (ultrawork, ralph 등) |
| `rules-injector.sh` | 프로젝트 단계별 규칙 주입 |
| `category-skill-reminder.sh` | 카테고리/스킬 사용 리마인더 |
| `agent-usage-reminder.sh` | 적절한 에이전트 사용 안내 |
| `task-resume-info.sh` | 작업 재개 정보 표시 |
| `auto-slash-command.sh` | 슬래시 명령어 자동 안내 |

### PreToolUse Hooks (1개)

| Hook | Matcher | 설명 |
|------|---------|------|
| `subagent-question-blocker.sh` | Task | 서브에이전트 질문 방지 |

### PostToolUse Hooks (6개)

| Hook | Matcher | 설명 |
|------|---------|------|
| `comment-checker.sh` | Edit, Write | 코드 주석 품질 검증 |
| `edit-error-recovery.sh` | Edit | 편집 에러 복구 정보 |
| `delegate-task-retry.sh` | Task | 위임 작업 재시도 추적 |
| `background-notification.sh` | Task | 백그라운드 작업 완료 알림 |
| `junior-notepad.sh` | Task | Junior 에이전트 작업 기록 |
| `tool-output-truncator.sh` | (all) | 대용량 출력 경고 |

### Stop Hooks (3개)

| Hook | 설명 |
|------|------|
| `notify.sh` | 작업 완료 알림 (기존) |
| `empty-task-response-detector.sh` | 빈/불완전 응답 감지 |
| `context-limit-recovery.sh` | 컨텍스트 한계 복구 정보 |

---

## 조건부 규칙 (Rules)

`.claude/rules/` 폴더에 프로젝트 단계별 규칙이 있습니다.

| 규칙 | 조건 |
|-----|------|
| `on_prototype.md` | PROJECT_CONTEXT.md stage = Prototype |
| `on_alpha.md` | PROJECT_CONTEXT.md stage = Alpha |
| `on_beta.md` | PROJECT_CONTEXT.md stage = Beta |
| `on_live.md` | PROJECT_CONTEXT.md stage = Live |

### 항상 활성화된 규칙

| 규칙 | 설명 |
|-----|------|
| `todo-continuation.md` | 미완료 작업 자동 계속 |
| `ultrawork-mode.md` | Ultrawork 모드 동작 |
| `ralph-loop.md` | Ralph Loop 동작 |
| `categories.md` | 카테고리 시스템 |

---

## 설정

hooks 설정은 `.claude/settings.json`에 정의되어 있습니다.

### 설정 구조

```json
{
  "hooks": {
    "UserPromptSubmit": [...],
    "PreToolUse": [...],
    "PostToolUse": [...],
    "Stop": [...]
  }
}
```

### Hook 비활성화

특정 hook을 비활성화하려면 settings.json에서 해당 항목을 제거하세요.

---

## 로그 위치

hooks가 생성하는 로그 파일들:

| 로그 | 위치 |
|-----|------|
| 컨텍스트 모니터 | `.claude/notepads/context-monitor.log` |
| 주석 체크 | `.claude/notepads/comment-checker.log` |
| 편집 에러 | `.claude/notepads/edit-errors.log` |
| 작업 실패 | `.claude/notepads/task-failures.log` |
| 출력 축약 | `.claude/notepads/truncation.log` |
| 응답 이슈 | `.claude/notepads/response-issues.log` |

---

## 문제 해결

### Hooks가 실행되지 않을 때

1. 스크립트 실행 권한 확인: `chmod +x .claude/hooks/*.sh`
2. bash 경로 확인
3. settings.json 문법 확인

### Windows에서 사용 시

WSL 환경에서 실행됩니다. PowerShell 버전은 `notify.ps1`만 제공됩니다.

---

## 커스터마이징

### 새 Hook 추가

1. `.claude/hooks/` 폴더에 shell 스크립트 생성
2. `chmod +x` 로 실행 권한 부여
3. `.claude/settings.json`에 등록

### 예시

```bash
#!/bin/bash
# my-custom-hook.sh

INPUT=$(cat)
# 로직 작성
exit 0
```

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/my-custom-hook.sh"
          }
        ]
      }
    ]
  }
}
```
