# 작업 노트 시스템 (Work Notes System)

Oh My OpenCode의 `.sisyphus/notes/` 시스템을 기반으로 한 작업 노트 관리 시스템입니다.

## 디렉토리 구조

```
.claude/
├── notes/          # 영구 저장 노트 (세션 간 유지)
├── drafts/         # 작업 중인 문서 (계획, 설계)
├── notepads/       # 임시 메모 (에이전트 간 통신)
└── rules/          # 조건부 규칙 파일
```

---

## 1. Notes (영구 노트)

### 용도
- 중요한 발견 사항
- 아키텍처 결정 기록
- 세션 요약
- 학습된 패턴

### 파일 명명 규칙
```
{YYYY-MM-DD}_{topic}.md      # 일별/주제별
session_{timestamp}.md        # 세션 요약
discovery_{topic}.md          # 중요 발견
decision_{topic}.md           # 결정 기록
```

### 예시
```markdown
# 2026-01-29_inventory-system.md

## 발견 사항
- 기존 ItemData 클래스가 03_Systems/02_Item/에 존재
- IItem 인터페이스 패턴 이미 사용 중

## 결정
- 기존 패턴 재사용
- IInventorySlot 인터페이스 추가

## 다음 단계
- [ ] InventoryController 구현
- [ ] 테스트 작성
```

---

## 2. Drafts (작업 초안)

### 용도
- Planner가 작성 중인 계획
- Momus 검토 대기 문서
- 코드 초안
- 아키텍처 제안

### 파일 명명 규칙
```
plan_{system_name}.md         # 계획 초안
design_{system_name}.md       # 설계 초안
review_{system_name}.md       # 검토 대기
```

### 라이프사이클
```
1. 생성 (Planner)
   ↓
2. 검토 (Momus/Metis)
   ↓
3. 승인 → 구현으로 이동
   또는
3. 거부 → 수정 후 재검토
```

---

## 3. Notepads (임시 메모)

### 용도
- 빠른 계산/참조
- 에이전트 간 메모 전달
- 임시 데이터 저장

### 파일 명명 규칙
```
{agent_name}_scratch.md       # 에이전트별 스크래치
quick_{topic}.md              # 빠른 메모
temp_{timestamp}.md           # 임시 파일
```

### 정리
- 세션 종료 시 자동 정리 가능
- 중요한 내용은 notes/로 이동

---

## 4. Rules (조건부 규칙)

### 용도
- 특정 조건에서 활성화되는 규칙
- 디렉토리별 컨텍스트 주입
- 트리거 기반 행동 변경

### 파일 명명 규칙
```
on_{trigger}.md               # 트리거 규칙
always_{name}.md              # 항상 활성화
{directory}_rules.md          # 디렉토리 규칙
```

### 예시: on_beta.md
```markdown
# Beta 단계 규칙

이 프로젝트가 Beta 단계일 때 적용됩니다.

## 추가 제약
- 새 인터페이스 생성 최소화
- 기존 확장 포인트 우선 활용
- 모든 변경에 안전성 검토 필수

## 필수 체크
- [ ] 회귀 테스트 실행
- [ ] 기존 테스트 통과 확인
```

---

## 에이전트별 노트 사용

### Planner
```markdown
저장 위치: .claude/drafts/plan_{system}.md
내용: 계획 초안, 인터뷰 결과, Clearance Checklist
```

### Lead Architect
```markdown
저장 위치: .claude/notes/design_{system}.md
내용: 설계 결정, 작업 분배, 인터페이스 정의
```

### Implementer
```markdown
저장 위치: .claude/notepads/{impl-N}_scratch.md
내용: 구현 중 발견 사항, 컴파일 에러 로그
```

### Reviewer/QA
```markdown
저장 위치: .claude/notes/review_{system}.md
내용: 검토 결과, 발견된 이슈, 권장 사항
```

---

## 자동 노트 생성 트리거

| 이벤트 | 생성되는 노트 |
|-------|-------------|
| 새 시스템 생성 시작 | drafts/plan_{system}.md |
| 설계 완료 | notes/design_{system}.md |
| 3회 실패 발생 | notes/failure_{system}_{date}.md |
| 세션 종료 | notes/session_{timestamp}.md |
| 중요 결정 | notes/decision_{topic}.md |

---

## 노트 활용 명령어

### 노트 확인
```
"최근 노트 보여줘"
"인벤토리 관련 노트 찾아줘"
```

### 노트 생성
```
"이 결정 기록해줘"
"세션 요약 저장해줘"
```

### 노트 정리
```
"오래된 노트 정리해줘"
"notepads 비워줘"
```

---

## 통합 워크플로우

```
┌─────────────────────────────────────────────┐
│  작업 시작                                    │
│  → drafts/에 계획 초안 생성                   │
└─────────────────────┬───────────────────────┘
                      ↓
┌─────────────────────────────────────────────┐
│  계획 검토 (Momus)                           │
│  → drafts/ 파일 검토                         │
│  → notepads/에 피드백 메모                   │
└─────────────────────┬───────────────────────┘
                      ↓
┌─────────────────────────────────────────────┐
│  구현 진행                                    │
│  → notepads/에 임시 메모                     │
│  → 중요 발견 시 notes/로 이동                │
└─────────────────────┬───────────────────────┘
                      ↓
┌─────────────────────────────────────────────┐
│  완료                                        │
│  → notes/에 최종 기록                        │
│  → drafts/ 정리                              │
│  → notepads/ 정리                            │
└─────────────────────────────────────────────┘
```
