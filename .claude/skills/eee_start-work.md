---
name: eee_start-work
description: 작업 시작 명령어 - 컨텍스트 로드, 이전 세션 복원, 작업 준비
---

# /eee_start-work 명령어

작업 세션을 시작할 때 사용하는 명령어입니다.

## 용도

- 프로젝트 컨텍스트 로드
- 이전 세션 노트 확인
- 미완료 작업 복원
- 작업 환경 준비

---

## 실행 단계

### 1단계: 프로젝트 컨텍스트 로드
```
1. PROJECT_CONTEXT.md 읽기
   - 프로젝트 단계 확인 (Prototype/Alpha/Beta/Live)
   - 현재 작업 상태 확인

2. CLAUDE.md 읽기
   - 프로젝트 규칙 확인
   - 폴더 구조 확인
```

### 2단계: 이전 세션 확인
```
1. .claude/notes/ 최근 파일 확인
   - 마지막 세션 요약
   - 중요 결정 사항

2. .claude/drafts/ 미완료 계획 확인
   - 진행 중이던 설계
   - 검토 대기 문서
```

### 3단계: 미완료 작업 복원
```
1. Task 목록 확인
   - pending 상태 작업
   - in_progress 상태 작업

2. TODO 항목 확인
   - 코드 내 TODO/FIXME
   - 체크리스트 미완료 항목
```

### 4단계: 작업 준비 보고
```
프로젝트 상태, 남은 작업, 권장 다음 단계 출력
```

---

## 출력 형식

```markdown
---
🚀 **작업 세션 시작**

## 프로젝트 상태
- 이름: {{project_name}}
- 단계: {{stage}}
- 마지막 작업: {{last_session_date}}

## 이전 세션 요약
{{previous_session_summary}}

## 미완료 작업
{{pending_tasks}}

## 권장 다음 단계
{{recommended_next_steps}}

---
무엇을 도와드릴까요?
```

---

## 옵션

### 기본 (옵션 없음)
```
/eee_start-work
```
전체 컨텍스트 로드

### 빠른 시작
```
/eee_start-work quick
```
최소 컨텍스트만 로드

### 특정 시스템
```
/eee_start-work Inventory
```
특정 시스템 관련 컨텍스트만 로드

---

## 자동 트리거

다음 상황에서 자동 실행 권장:

1. **새 세션 시작 시**
2. **컨텍스트 초기화 후**
3. **오랜 휴식 후 재개 시**

---

## 연관 명령어

| 명령어 | 용도 |
|-------|------|
| `/eee_start-work` | 작업 시작 |
| `/eee_init-deep` | 심층 분석 모드로 시작 |
| `/eee_feature` | 새 기능 구현 |
