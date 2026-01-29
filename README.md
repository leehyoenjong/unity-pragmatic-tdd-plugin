# Unity Pragmatic TDD Plugin

Claude Code 플러그인 - Unity 게임 개발을 위한 실용적 TDD 및 SOLID 가이드

[![Version](https://img.shields.io/badge/version-8.0-blue.svg)](./docs/versions/VERSION-HISTORY.md)
[![Oh My OpenCode](https://img.shields.io/badge/inspired%20by-Oh%20My%20OpenCode-purple.svg)](https://github.com/code-yeongyu/oh-my-opencode)

## 개요

프로젝트 단계(Prototype/Alpha/Beta/Live)에 따라 적절한 수준의 TDD와 SOLID 원칙을 적용하도록 안내합니다.

"무조건 TDD"가 아닌, 게임 개발 현실에 맞는 **실용적 접근**을 제공합니다.

### v8.0 주요 기능 (Oh My OpenCode 완전 이식)

| 기능 | 설명 |
|-----|------|
| 🚀 **Ultrawork 모드** | 최대 성능, 최소 확인, 완전 자율 실행 |
| 🔄 **Ralph Loop** | "DONE"까지 자동 반복 (최대 10회) |
| 📝 **작업 노트 시스템** | 세션 간 영구 저장 (.claude/notes/) |
| ✅ **TODO Continuation** | 미완료 작업 자동 계속 |
| 📂 **카테고리 시스템** | quick/standard/deep/ultrabrain |
| 👶 **Junior 에이전트** | 경량 작업 전용 (haiku 모델) |

## 주요 기능

### 서브에이전트 파이프라인

#### 개발 파이프라인 (병렬 구현 시스템)
`/feature XX` 또는 "XX 시스템 만들어줘" 요청 시 자동으로 실행:

```
1. 스크립트 → 폴더/파일 생성 (컨텍스트 0)
2. lead-architect (DESIGN) → 인터페이스 설계 + 작업 분배
3. implementer-1, 2, 3 → 병렬 구현 + 테스트 (동시 실행!)
4. lead-architect (REVIEW) → 코드 검토, 필요시 재작업 요청
5. lead-architect (INTEGRATE) → 최종 통합
```

**병렬 구현 워크플로우:**
```
         ┌─ implementer-1 (클래스A + 테스트) ─┐
lead ────┼─ implementer-2 (클래스B + 테스트) ─┼──→ lead (검토) ──→ 통합
         └─ implementer-3 (클래스C + 테스트) ─┘
              병렬 실행 (속도 3배)
```

#### QA 파이프라인
"XX QA 해줘" 또는 `/eee_qa-full` 요청 시 자동으로 실행:

```
1. qa-tech → 기술적 버그 분석
2. qa-security → 보안 취약점 분석
3. qa-balance → 밸런스 분석 (선택적)
4. qa-tc → TC 문서 생성
5. 종합 리포트 출력
```

**장점:**
- 컨텍스트 효율: 기존 대비 ~85% 절약
- 병렬 구현: 순차 대비 속도 3배
- 일관된 구조: XX_FolderName 규칙 자동 적용
- 코드 리뷰 + 재작업 루프 포함
- 체계적인 QA 프로세스

### 서브에이전트 (14종)

#### 개발 에이전트 (병렬 구현 지원)

| 에이전트 | 역할 | 모델 |
|---------|-----|-----|
| `planner` | 전략적 계획, Interview Mode, 의도 분류 | opus |
| `lead-architect` | 설계 총괄, 작업 분배, 코드 검토, 통합 | opus |
| `implementer-1` | Pure C# 구현 + TDD (병렬 구현자 1) | opus |
| `implementer-2` | Pure C# 구현 + TDD (병렬 구현자 2) | opus |
| `implementer-3` | Pure C# 구현 + TDD (병렬 구현자 3) | opus |
| `junior` | 경량 작업 전용 (파일 생성, 단순 수정) | haiku |
| `reviewer` | SOLID 검토, 안전성 평가 | opus |

#### 상담/검토 에이전트 (Prometheus Style)

| 에이전트 | 역할 | 모델 |
|---------|-----|-----|
| `metis` | 계획 검토, 위험 요소 분석, 스코프 크리프 경고 | opus |
| `momus` | 계획 검증, 문서화 품질, 90% 신뢰도 기준 | opus |
| `oracle` | 아키텍처 상담, 트레이드오프 분석 (읽기 전용) | opus |

#### QA 에이전트

| 에이전트 | 역할 | 모델 |
|---------|-----|-----|
| `qa-tc` | TC 작성, 테스트 피라미드 설계 (GQA) | opus |
| `qa-tech` | 코드 분석, 기술적 버그 탐지 (TQA) | opus |
| `qa-balance` | 밸런스, 경제 시스템, 데이터 분석 (FQA+DQA) | opus |
| `qa-security` | 어뷰징 방지, 보안 취약점 (CQA) | opus |
| `qa-release` | 런칭 체크리스트, 패치 검증 (PQA+SQA) | opus |

### 스크립트

| 스크립트 | 용도 |
|---------|-----|
| `create-structure.sh` | 폴더/빈 파일 생성 (XX_ 규칙 적용) |

### 알림 (Hooks)

Claude Code 작업 완료 시 자동으로 알림을 표시합니다.

```
test 프로젝트 작업이 완료되었습니다
```

**지원 플랫폼:**
- macOS: 다이얼로그 + 사운드
- Windows: MessageBox + 사운드
- Linux: notify-send + 사운드

**알림 내용:**

| 상태 | 메시지 |
|------|--------|
| `end_turn` | {프로젝트명} 프로젝트 작업이 완료되었습니다 |
| `max_tokens` | {프로젝트명} 프로젝트 토큰 한도에 도달했습니다 |
| `tool_use` | {프로젝트명} 프로젝트 도구 사용이 완료되었습니다 |
| `interrupt` | {프로젝트명} 프로젝트 사용자에 의해 중단되었습니다 |

## 설치

### Step 1: 마켓플레이스 등록 (최초 1회)

```bash
/plugin marketplace add leehyoenjong/unity-pragmatic-tdd-plugin
```

### Step 2: 플러그인 설치

사용할 프로젝트에서 실행:

```bash
/plugin install unity-pragmatic-tdd
```

설치 범위 선택:
- **User scope** - 모든 프로젝트에서 사용
- **Project scope** - 팀원과 공유
- **Local scope** - 이 프로젝트에서만

### Step 3: 초기 설정

Claude Code 재시작 후:

```bash
/eee_init
```

초기 설정에서 수행하는 작업:
- PROJECT_CONTEXT.md 생성 (프로젝트 단계 설정)
- 추가 도구 설치 안내 (Unity-MCP, claude-mem)

## 사용법

### 시스템 생성 (병렬 구현 파이프라인)

**방법 1: 슬래시 명령어 (권장)**
```bash
/eee_feature Inventory
/eee_feature Combat "데미지 계산, 크리티컬, 버프/디버프"
/eee_feature Quest "퀘스트 수락, 진행, 완료, 보상"
```

**방법 2: 자연어 요청**
```
"인벤토리 시스템 만들어줘"
"Combat System 구현해줘"
"새로운 Quest 기능 추가해줘"
```

→ 자동으로 병렬 구현 파이프라인 실행

### 슬래시 명령어 (16개)

#### 필수

| 명령어 | 설명 |
|--------|------|
| `/eee_init` | 초기 설정 (PROJECT_CONTEXT, 추가 도구 설치 안내) |
| `/eee_transition` | 프로젝트 단계 전환 |

#### 개발

| 명령어 | 설명 |
|--------|------|
| `/eee_feature <시스템명>` | **새 시스템 생성 (병렬 구현 파이프라인)** |
| `/eee_tdd` | TDD 워크플로우 적용 |
| `/eee_review` | 코드 리뷰 (SOLID + 안티패턴 + Beta 안전성) |

#### 세션 관리 (v8.0 신규)

| 명령어 | 설명 |
|--------|------|
| `/eee_start-work` | 작업 세션 시작, 컨텍스트 로드, 이전 세션 복원 |
| `/eee_init-deep` | 심층 분석 모드, 전체 코드베이스 분석 |
| `/eee_notes` | 작업 노트 관리 (확인/생성/검색) |

#### 자동화 모드 (v8.0 신규)

| 명령어 | 설명 |
|--------|------|
| `/eee_ultrawork` | **Ultrawork 모드** - 최대 성능, 최소 확인 |
| `/eee_ralph` | **Ralph Loop** - DONE까지 자동 반복 |

#### Git

| 명령어 | 설명 |
|--------|------|
| `/eee_commit` | Git 커밋 (Conventional Commits) |
| `/eee_sync` | Git 커밋 + 푸시 |

#### QA

| 명령어 | 설명 |
|--------|------|
| `/eee_bug-check` | 기술적 버그 분석 - 6가지 버그 패턴 |
| `/eee_security` | 보안 취약점 분석 - 어뷰징, 돈복사 방지 |
| `/eee_qa-full` | 전체 QA 파이프라인 실행 |
| `/eee_precommit` | 커밋 전 빠른 QA 검증 (Critical/High만) |

## 폴더 구조

파이프라인으로 생성되는 구조:

```
Assets/
├── 01_Scripts/
│   ├── 03_Systems/
│   │   └── 01_Score/              # 예시
│   │       ├── 01_Interfaces/
│   │       │   └── IScore.cs
│   │       ├── 02_Core/
│   │       │   ├── ScoreController.cs
│   │       │   └── LinearComboStrategy.cs
│   │       └── 03_Mono/
│   └── 05_Tests/
│       └── Score/
│           └── ScoreControllerTests.cs
```

## 프로젝트 단계별 가이드

| Stage | TDD | SOLID | Refactoring |
|-------|-----|-------|-------------|
| Prototype | ~10% | Minimal | Almost none |
| Alpha | 40-60% | Apply to extendable systems | Active |
| Beta | 60-80% | Leverage existing | Bug fixes only |
| Live | 80-100% | Use extension points | Almost never |

### 핵심 인사이트

> "Alpha에서 SOLID를 적용해야 Beta/Live에서 안전하게 기능을 추가할 수 있다"

```csharp
// Alpha에서 OCP 적용
public class Player
{
    private List<IStatModifier> modifiers; // 확장 포인트

    public int GetAttack()
    {
        int value = baseAttack;
        foreach (var mod in modifiers)
            value += mod.GetModifier(StatType.Attack);
        return value;
    }
}

// Beta에서 펫 추가 - Player 수정 없이 가능!
public class Pet : IStatModifier
{
    public int GetModifier(StatType type) => type == StatType.Attack ? 5 : 0;
}
```

## 포함 내용

### Skills
- `tdd-implement` - TDD 워크플로우 및 예제
- `solid-review` - SOLID 원칙 상세 리뷰
- `beta-safety-check` - Beta 단계 기능 안전성 체크
- `stage-transition` - 단계 전환 절차
- `code-review` - 안티패턴 체크리스트

### Docs
- `unity-test-setup.md` - Unity 테스트 환경 설정
- `di-guide.md` - 의존성 주입 가이드 (VContainer, 수동 DI, ScriptableObject)
- `async-testing.md` - UniTask 및 비동기 테스트
- `ci-cd-guide.md` - GitHub Actions CI/CD 통합
- `anti-patterns.md` - Unity 개발 흔한 실수들
- `troubleshooting.md` - 문제 해결 가이드
- `performance-solid.md` - SOLID 성능 고려사항 (GC, Hot Path 최적화)

### Agents & Pipelines

#### 개발 에이전트 (병렬 구현 시스템)
- `.claude/agents/planner.md` - 전략적 계획 + Interview Mode
- `.claude/agents/lead-architect.md` - 설계 총괄 + 작업 분배 + 검토 + 통합
- `.claude/agents/implementer-1.md` - 병렬 구현자 1
- `.claude/agents/implementer-2.md` - 병렬 구현자 2
- `.claude/agents/implementer-3.md` - 병렬 구현자 3
- `.claude/agents/junior.md` - 경량 작업 전용 (haiku)
- `.claude/agents/reviewer.md` - SOLID 검토 에이전트

#### 상담/검토 에이전트 (Prometheus Style)
- `.claude/agents/metis.md` - 계획 검토, 위험 분석
- `.claude/agents/momus.md` - 계획 검증, 90% 신뢰도
- `.claude/agents/oracle.md` - 아키텍처 상담 (읽기 전용)

#### QA 에이전트
- `.claude/agents/qa-tc.md` - TC 작성 에이전트 (GQA)
- `.claude/agents/qa-tech.md` - 기술 버그 탐지 에이전트 (TQA)
- `.claude/agents/qa-balance.md` - 밸런스/경제 분석 에이전트 (FQA+DQA)
- `.claude/agents/qa-security.md` - 보안/어뷰징 방지 에이전트 (CQA)
- `.claude/agents/qa-release.md` - 런칭/패치 검수 에이전트 (PQA+SQA)

#### Rules (조건부 규칙)
- `.claude/rules/todo-continuation.md` - 미완료 작업 자동 계속
- `.claude/rules/ultrawork-mode.md` - 최대 성능 모드
- `.claude/rules/ralph-loop.md` - DONE까지 자동 반복
- `.claude/rules/categories.md` - 작업 카테고리 시스템

#### Pipelines & Scripts
- `.claude/pipelines/new-system.md` - 새 시스템 생성 파이프라인 (병렬 구현)
- `.claude/pipelines/qa-pipeline.md` - 전체 QA 검증 파이프라인
- `.claude/scripts/create-structure.sh` - 폴더 구조 생성 스크립트

#### Notes System
- `.claude/notes/` - 영구 저장 노트
- `.claude/drafts/` - 작업 중 문서
- `.claude/notepads/` - 임시 메모

## 함께 사용하면 좋은 도구

> `/eee_init` 실행 시 설치 여부를 물어봅니다.

### [Unity-MCP](https://github.com/IvanMurzak/Unity-MCP)

Unity 에디터를 Claude Code에서 직접 제어할 수 있는 MCP 서버입니다.

#### 주요 기능

- Unity 에디터 직접 제어 (씬, 에셋, 오브젝트)
- C# 스크립트 생성 및 실행
- 자연어로 Unity 작업 요청
- Editor & Runtime 모두 지원

#### 설치 방법

`/eee_init` 실행 시 Unity 프로젝트로 감지되면 설치 여부를 물어봅니다.

**수동 설치:**

```bash
# 1. Installer 다운로드
curl -fsSL -o AI-Game-Dev-Installer.unitypackage https://github.com/IvanMurzak/Unity-MCP/releases/latest/download/AI-Game-Dev-Installer.unitypackage

# 2. Unity에 임포트 (드래그앤드롭)
# 3. Unity 에디터 한 번 실행 (MCP 서버 빌드)
# 4. 설정
.claude/scripts/setup-unity-mcp.sh setup

# 5. Unity > Window > AI Game Developer > Connect
# 6. Claude Code 재시작
```

#### 스크립트 명령어

```bash
.claude/scripts/setup-unity-mcp.sh [명령어]
```

| 명령어 | 설명 |
|--------|------|
| `start` | MCP 서버 시작 |
| `stop` | MCP 서버 중지 |
| `status` | 전체 연결 상태 확인 |
| `register` | Claude Code에 MCP 등록 |
| `setup` | 전체 설정 (start + register) |

#### 사용 예시

```
"씬에 큐브 3개를 원형으로 배치해줘"
"골드 메탈릭 머티리얼 만들어줘"
"Player 스크립트에 점프 기능 추가해줘"
```

---

### [claude-mem](https://github.com/thedotmack/claude-mem)

세션 간 컨텍스트를 자동으로 기억하는 메모리 시스템입니다.

#### 설치 방법

`/eee_init` 실행 시 설치 여부를 물어봅니다.

**수동 설치:**

```bash
/plugin marketplace add thedotmack/claude-mem
/plugin install claude-mem
```

> **전역 설치 권장**: 모든 프로젝트에서 사용 가능

#### 장점

- **세션 연속성**: "어제 작업하던 거 이어서 해줘"가 가능
- **패턴 학습**: 이전에 만든 시스템의 설계 패턴을 새 시스템에 적용
- **리뷰 히스토리**: 과거 SOLID 리뷰 피드백을 기반으로 개선
- **프로젝트 간 공유**: 다른 Unity 프로젝트의 경험도 검색 가능

#### 주의사항

| 항목 | 설명 |
|------|------|
| **설치 위치** | 전역 설치 권장 (프로젝트별 설치 X) |
| **포트 사용** | Worker Service가 37777 포트 사용 |
| **저장 공간** | `~/.claude-mem/`에 SQLite DB 저장 |
| **민감 정보** | `<private>` 태그로 저장 제외 가능 |

---

### 시너지 효과

| unity-pragmatic-tdd | + Unity-MCP | + claude-mem | 결과 |
|---------------------|-------------|--------------|------|
| 인터페이스 설계 | 코드 생성 | 패턴 기억 | 일관된 설계 자동 적용 |
| TDD 테스트 작성 | 에디터 제어 | 히스토리 | 테스트 → 구현 자동화 |
| SOLID 리뷰 | 리팩토링 | 피드백 기억 | 반복 실수 방지 |

## 업데이트

```bash
/plugin marketplace update
```

변경 내역은 [CHANGELOG.md](./CHANGELOG.md)를 참고하세요.

## 빠른 시작 요약

```bash
# 1. 마켓플레이스 등록 (최초 1회)
/plugin marketplace add leehyoenjong/unity-pragmatic-tdd-plugin

# 2. 플러그인 설치 (프로젝트에서)
/plugin install unity-pragmatic-tdd

# 3. Claude Code 재시작 후 초기 설정
/eee_init
```

## 고급 자동화 기능 (v8.0)

### Ultrawork 모드

최대 성능으로 작업을 수행하는 모드입니다.

```bash
/eee_ultrawork 인벤토리 시스템 완성해줘
```

**특징**:
- 확인 질문 최소화
- 병렬 처리 최대화
- 체크포인트 자동 통과
- 에러 즉시 자동 수정

### Ralph Loop

"DONE"이 나올 때까지 자동으로 반복합니다.

```bash
/eee_ralph 모든 테스트 통과할 때까지
```

**특징**:
- 최대 10회 반복
- 중단/재개 가능 (`/eee_ralph stop`, `/eee_ralph continue`)
- 진행 상황 실시간 보고

### 작업 노트 시스템

세션 간 작업 컨텍스트를 유지합니다.

```
.claude/
├── notes/      # 영구 저장 노트
├── drafts/     # 작업 중 문서
├── notepads/   # 임시 메모
└── rules/      # 조건부 규칙
```

### 카테고리 시스템

작업 유형에 따라 최적의 깊이를 선택합니다.

| 카테고리 | 설명 | 사용 예 |
|---------|------|--------|
| `quick` | 빠른 수정 | 오타, 단순 버그 |
| `standard` | 일반 작업 | 기능 구현 |
| `deep` | 심층 분석 | 아키텍처 변경 |
| `ultrabrain` | 최대 사고력 | 복잡한 설계 결정 |

---

## 버전 히스토리

상세한 버전별 개선 사항은 [VERSION-HISTORY.md](./docs/versions/VERSION-HISTORY.md)를 참고하세요.

| 버전 | 주요 기능 | 날짜 |
|-----|----------|------|
| v8.0 | Oh My OpenCode 완전 이식 | 2026-01-29 |
| v7.0 | Prometheus Style 도입 | 2026-01-29 |
| v5.0 | 병렬 구현 시스템 | 2026-01-13 |
| v4.0 | QA 에이전트 5종 | 2026-01 |

---

## 참고 자료

이 플러그인의 서브에이전트, 스킬, 스크립트 구조는 다음 자료를 참고하여 개발되었습니다:

- [Oh My OpenCode](https://github.com/code-yeongyu/oh-my-opencode) - v7.0, v8.0 기능 참고
- [Claude Code 서브에이전트 활용 영상](https://www.youtube.com/watch?v=GL3LXWBZfy0) - 서브에이전트, 스킬, 스크립트 구조 참고

### 추가 참고 문서

- [Claude Code Subagents 공식 문서](https://code.claude.com/docs/en/sub-agents)
- [Skills vs Commands vs Subagents 비교](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/)

## 라이선스

MIT
