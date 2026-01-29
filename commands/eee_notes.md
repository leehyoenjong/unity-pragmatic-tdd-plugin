# /eee_notes 명령어

작업 노트를 관리하는 명령어입니다.

## 용도

- 노트 확인
- 노트 생성
- 노트 검색
- 노트 정리

---

## 사용법

### 최근 노트 보기
```
/eee_notes
/eee_notes recent
```

### 노트 검색
```
/eee_notes search [키워드]
/eee_notes search inventory
```

### 노트 생성
```
/eee_notes create [제목]
/eee_notes create "인벤토리 설계 결정"
```

### 세션 요약 저장
```
/eee_notes save-session
```

### 노트 정리
```
/eee_notes cleanup
```

---

## 출력 형식

### 노트 목록
```markdown
---
📝 **최근 노트**

1. 2026-01-29_inventory-system.md
   - 인벤토리 시스템 설계 결정

2. 2026-01-28_session-summary.md
   - 어제 세션 요약

3. decision_combo-strategy.md
   - 콤보 전략 결정
---
```

### 노트 내용
```markdown
---
📝 **노트: 2026-01-29_inventory-system.md**

## 발견 사항
...

## 결정
...
---
```

---

## 디렉토리 구조

```
.claude/
├── notes/      # 영구 노트
├── drafts/     # 작업 중 문서
└── notepads/   # 임시 메모
```

---

## 상세 가이드

`.claude/docs/notes-system.md` 참조
