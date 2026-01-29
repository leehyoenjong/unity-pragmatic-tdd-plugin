---
name: eee_ralph
description: Ralph Loop 활성화 - DONE이 나올 때까지 자동 반복
---

# /eee_ralph 명령어

Ralph Loop를 활성화하는 명령어입니다.

## 용도

- 작업 완료까지 자동 반복
- 수동 개입 최소화
- 완전 자동화 실행

---

## 사용법

### 기본 사용
```
/eee_ralph [작업 설명]
```

### 예시
```
/eee_ralph 인벤토리 시스템 구현
/eee_ralph 모든 테스트 통과할 때까지
```

---

## 출력 형식

### 시작
```markdown
---
🔄 **RALPH LOOP ACTIVATED**

목표: [작업]
완료까지 자동 반복합니다.
---
```

### 반복 중
```markdown
🔄 Iteration #N: [현재 작업]
```

### 완료
```markdown
---
✅ **DONE**

총 반복: N회
---
```

---

## 제어

### 중단
```
/eee_ralph stop
```

### 재개
```
/eee_ralph continue
```

---

## 상세 규칙

`.claude/rules/ralph-loop.md` 참조
