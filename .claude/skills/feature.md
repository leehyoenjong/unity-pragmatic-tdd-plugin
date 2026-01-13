---
name: feature
description: Unity 시스템/기능 생성 파이프라인 실행
user_invocable: true
args: <system_name> [requirements]
---

# /feature - Unity 시스템 생성

새로운 Unity 시스템을 병렬 구현 파이프라인으로 생성합니다.

## 사용법

```
/feature <시스템명>
/feature <시스템명> <요구사항>
```

## 예시

```
/feature Inventory
/feature Inventory "아이템 추가, 제거, 조회, 정렬 기능"
/feature Combat "데미지 계산, 크리티컬, 버프/디버프 시스템"
/feature Quest "퀘스트 수락, 진행, 완료, 보상 시스템"
```

## 실행 시 동작

이 명령어 실행 시 다음 파이프라인이 자동으로 실행됩니다:

```
1단계: 폴더/파일 구조 생성
    ↓
2단계: Lead Architect - 설계 + 작업 분배
    ↓
3단계: Implementer 1, 2, 3 - 병렬 구현
    ↓
4단계: Lead Architect - 코드 검토 (필요시 재작업)
    ↓
5단계: Lead Architect - 최종 통합
```

## 프로젝트 단계별 동작

| 단계 | 동작 |
|-----|------|
| Prototype | 간소화된 파이프라인 (단일 구현자) |
| Alpha | 전체 파이프라인 (병렬 구현 + 검토) |
| Beta/Live | 경고 후 사용자 확인 필요 |

---

# 실행 지시사항

아래 단계를 순서대로 실행하세요:

## Step 1: 입력 파싱

```
system_name = args의 첫 번째 단어
requirements = args의 나머지 부분 (없으면 빈 문자열)
```

## Step 2: PROJECT_CONTEXT.md 확인

프로젝트 루트에서 PROJECT_CONTEXT.md를 읽어 현재 단계 확인:
- 없으면 사용자에게 단계 질문 후 생성
- 있으면 project_stage 추출

## Step 3: 단계별 분기

### Prototype 단계:
```
1. create-structure.sh 실행
2. lead-architect (DESIGN, 간소화)
3. implementer-1만 실행
4. lead-architect (INTEGRATE)
```

### Alpha 단계:
```
1. create-structure.sh 실행
2. lead-architect (DESIGN)
3. implementer-1, 2, 3 **병렬 실행**
4. lead-architect (REVIEW)
5. 필요시 재작업 루프
6. lead-architect (INTEGRATE)
```

### Beta/Live 단계:
```
⚠️ 경고: "Beta/Live 단계에서 새 시스템 생성은 권장하지 않습니다.
기존 확장 포인트 활용을 먼저 검토하세요."

사용자 확인 후 진행 또는 중단
```

## Step 4: 파이프라인 실행

`.claude/pipelines/new-system.md` 참고하여 실행

### 에이전트 호출 순서:

**2단계 - 설계:**
```
Task tool 호출:
- subagent_type: lead-architect
- prompt: |
    MODE: DESIGN
    system_name: {{system_name}}
    requirements: {{requirements}}
    project_stage: {{project_stage}}

    1. 인터페이스 설계
    2. 작업 분배 계획 작성 (클래스별 담당자 지정)
```

**3단계 - 병렬 구현:**
```
Task tool 3개 동시 호출:
- subagent_type: implementer-1, implementer-2, implementer-3
- 각각 lead-architect가 분배한 클래스 담당
```

**4단계 - 검토:**
```
Task tool 호출:
- subagent_type: lead-architect
- prompt: |
    MODE: REVIEW
    모든 구현 파일 검토
    문제 발견 시 재작업 지시
```

**5단계 - 통합:**
```
Task tool 호출:
- subagent_type: lead-architect
- prompt: |
    MODE: INTEGRATE
    최종 통합 및 문서화
```

## Step 5: 결과 보고

최종 결과를 사용자에게 요약:
```markdown
## {{system_name}} 시스템 생성 완료

### 생성된 파일
- [파일 목록]

### 다음 단계
- [ ] Unity 에디터에서 컴파일 확인
- [ ] 테스트 실행
- [ ] MonoBehaviour 래퍼 필요시 추가
```
