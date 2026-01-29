# /eee_ultrawork 명령어

Ultrawork 모드를 활성화하는 명령어입니다.

## 용도

- 최대 속도로 작업
- 불필요한 확인 최소화
- 완전한 자율 실행

---

## 활성화

```
/eee_ultrawork
```

또는

```
/eee_ultrawork [작업 설명]
```

---

## 모드 특성

### 활성화 시 변경

| 항목 | 변경 |
|-----|------|
| 확인 질문 | 최소화 |
| 병렬 처리 | 최대화 |
| 체크포인트 | 자동 통과 |
| 에러 복구 | 즉시 자동 |

---

## 출력 형식

### 활성화 시
```markdown
---
🚀 **ULTRAWORK MODE ACTIVATED**

설정:
- 확인 최소화 ✅
- 병렬 처리 최대 ✅
- 자동 진행 ✅

작업을 시작합니다...
---
```

### 비활성화
```
/eee_ultrawork off
```

```markdown
---
⏸️ **ULTRAWORK MODE DEACTIVATED**

일반 모드로 전환합니다.
---
```

---

## 상세 규칙

`.claude/rules/ultrawork-mode.md` 참조
