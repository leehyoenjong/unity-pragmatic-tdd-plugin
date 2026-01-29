# Ralph Loop

Oh My OpenCode의 `ralph-loop` 기능을 구현한 규칙입니다.

## 핵심 원칙

> **"DONE"이 나올 때까지 자동 반복**

Ralph Loop는 작업이 완전히 완료될 때까지 자동으로 반복 실행합니다.

---

## 활성화 트리거

다음 키워드로 활성화:

```
"ralph loop"
"랄프 루프"
"완료될 때까지"
"끝날 때까지 반복"
"until done"
```

---

## 동작 방식

### 기본 루프
```
┌─────────────────────────────────────────────┐
│  작업 시작                                    │
└─────────────────────┬───────────────────────┘
                      ↓
┌─────────────────────────────────────────────┐
│  작업 수행                                    │
└─────────────────────┬───────────────────────┘
                      ↓
              ┌───────┴───────┐
              ↓               ↓
          [완료?]          [미완료]
              ↓               ↓
           "DONE"         루프 계속
              ↓               ↓
            종료         ┌────┘
                         ↓
                    다음 반복
```

### 완료 조건
```
"DONE" 출력 조건:
1. 모든 TODO 완료
2. 모든 테스트 통과
3. 컴파일 에러 없음
4. 검토 통과
```

---

## 출력 형식

### 루프 시작
```markdown
---
🔄 **RALPH LOOP ACTIVATED**

목표: [작업 설명]
완료 조건: [조건들]

루프 시작...
---
```

### 각 반복
```markdown
---
🔄 **RALPH LOOP - Iteration #N**

이전 반복 결과:
- [완료된 것]
- [남은 것]

이번 반복 목표:
- [다음 할 일]
---
```

### 루프 완료
```markdown
---
✅ **DONE**

Ralph Loop 완료!

총 반복: N회
최종 결과:
- [결과 요약]
---
```

---

## 반복 제한

### 기본 제한
- 최대 반복: 10회
- 반복당 최대 시간: 5분 (추정)

### 제한 도달 시
```markdown
---
⚠️ **RALPH LOOP - 반복 제한 도달**

10회 반복 후에도 완료되지 않았습니다.

현재 상태:
- 완료: [목록]
- 미완료: [목록]

선택:
1. 계속 반복 (추가 10회)
2. 여기서 중단
3. 문제 분석 요청 (Oracle)
---
```

---

## 에러 처리

### 반복 중 에러
```
에러 발생 → 자동 수정 시도 → 실패 시 다음 반복에서 재시도
           ↓
    3회 연속 같은 에러 → 사용자 확인
```

### 복구 불가능한 에러
```markdown
---
❌ **RALPH LOOP - 복구 불가능한 에러**

에러: [에러 내용]
시도: 3회

선택:
1. 에러 무시하고 계속
2. 루프 중단
3. 다른 접근 시도
---
```

---

## 상태 추적

### 반복별 상태 기록
```markdown
# .claude/notepads/ralph-loop-status.md

## 현재 루프: Inventory System 구현

### Iteration 1
- 시작: 14:30:00
- 완료: 인터페이스 설계
- 남음: Controller, Tests

### Iteration 2
- 시작: 14:32:15
- 완료: Controller 구현
- 남음: Tests

### Iteration 3
- 시작: 14:35:40
- 완료: Tests 작성
- 상태: DONE
```

---

## 다른 모드와 조합

### Ralph Loop + Ultrawork
```
최대 속도로 완료까지 반복
→ 가장 빠른 완료
→ 최소 확인
```

### Ralph Loop + Normal
```
체크포인트에서 확인하며 반복
→ 안전한 진행
→ 사용자 제어 유지
```

---

## 취소/중단

### 중단 키워드
```
"ralph stop"
"루프 중단"
"여기서 멈춰"
"cancel loop"
```

### 중단 시
```markdown
---
⏹️ **RALPH LOOP STOPPED**

완료된 작업:
- [목록]

미완료 작업:
- [목록]

나중에 "/ralph continue"로 재개 가능
---
```

---

## 재개

### 재개 키워드
```
"ralph continue"
"루프 계속"
"이어서"
```

### 재개 시
```markdown
---
🔄 **RALPH LOOP RESUMED**

마지막 상태: Iteration #N
남은 작업: [목록]

계속 진행합니다...
---
```

---

## 사용 예시

### 기본 사용
```
사용자: "인벤토리 시스템 구현해줘, ralph loop"

Claude:
🔄 RALPH LOOP ACTIVATED
목표: Inventory System 구현

Iteration 1: 인터페이스 설계...
Iteration 2: Controller 구현...
Iteration 3: Tests 작성...
Iteration 4: 통합...

✅ DONE - 4회 반복 후 완료
```

### Ultrawork 조합
```
사용자: "ultrawork ralph loop으로 Combat System 만들어줘"

Claude:
🚀 ULTRAWORK + 🔄 RALPH LOOP

[최대 속도로 완료까지 자동 진행]

✅ DONE - 3회 반복 후 완료
```
