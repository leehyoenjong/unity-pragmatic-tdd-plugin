# Unity Pragmatic TDD Plugin

Claude Code 플러그인 - Unity 게임 개발을 위한 실용적 TDD 및 SOLID 가이드

## 개요

프로젝트 단계(Prototype/Alpha/Beta/Live)에 따라 적절한 수준의 TDD와 SOLID 원칙을 적용하도록 안내합니다.

"무조건 TDD"가 아닌, 게임 개발 현실에 맞는 **실용적 접근**을 제공합니다.

## 주요 기능

### 서브에이전트 파이프라인

"XX 시스템 만들어줘" 요청 시 자동으로 파이프라인 실행:

```
1. 스크립트 → 폴더/파일 생성 (컨텍스트 0)
2. architect → 인터페이스 설계 (독립 컨텍스트)
3. implementer → 구현 + 테스트 (독립 컨텍스트)
4. reviewer → SOLID 검토 (독립 컨텍스트)
```

**장점:**
- 컨텍스트 효율: 기존 대비 ~80% 절약
- 일관된 구조: XX_FolderName 규칙 자동 적용
- SOLID 검토 필수 포함

### 서브에이전트

| 에이전트 | 역할 | 모델 |
|---------|-----|-----|
| `architect` | 시스템 설계, 인터페이스, OCP 확장점 | opus |
| `implementer` | Pure C# 구현, TDD 테스트 작성 | opus |
| `reviewer` | SOLID 검토, 안전성 평가 | opus |

### 스크립트

| 스크립트 | 용도 |
|---------|-----|
| `create-structure.sh` | 폴더/빈 파일 생성 (XX_ 규칙 적용) |

## 설치

```bash
# 프로젝트 루트에서 실행
cd /tmp && rm -rf unity-pragmatic-tdd-plugin 2>/dev/null && git clone --depth 1 \
  git@github.com:leehyoenjong/unity-pragmatic-tdd-plugin.git && rm -rf \
  unity-pragmatic-tdd-plugin/.git && cd - && rm -rf .claude-plugin 2>/dev/null && mv \
  /tmp/unity-pragmatic-tdd-plugin .claude-plugin && bash .claude-plugin/install.sh
```

## 사용법

### 시스템 생성 (자동 파이프라인)

```
"인벤토리 시스템 만들어줘"
"Combat System 구현해줘"
"새로운 Quest 기능 추가해줘"
```

→ 자동으로 파이프라인 실행

### 슬래시 명령어

| 명령어 | 설명 |
|--------|------|
| `/eee_init` | 첫 셋팅 |
| `/eee_tdd` | TDD 워크플로우 적용 |
| `/eee_solid` | SOLID 원칙 검토 |
| `/eee_safety-check` | Beta 단계 기능 안전성 체크 |
| `/eee_transition` | 프로젝트 단계 전환 |
| `/eee_review` | 코드 리뷰 (안티패턴 체크) |
| `/eee_commit` | Git 커밋 (Conventional Commits) |
| `/eee_push` | Git 푸시 |

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
- `.claude/agents/architect.md` - 시스템 설계 에이전트
- `.claude/agents/implementer.md` - 구현 에이전트
- `.claude/agents/reviewer.md` - 리뷰 에이전트
- `.claude/pipelines/new-system.md` - 새 시스템 생성 파이프라인
- `.claude/scripts/create-structure.sh` - 폴더 구조 생성 스크립트

## 함께 사용하면 좋은 플러그인

### [claude-mem](https://github.com/thedotmack/claude-mem)

세션 간 컨텍스트를 자동으로 기억하는 메모리 시스템입니다.

#### 설치 (전역 설치 권장)

```bash
# Claude Code에서 실행
/plugin marketplace add thedotmack/claude-mem
/plugin install claude-mem
```

> **전역 설치**: `~/.claude/plugins/`에 설치되어 모든 프로젝트에서 사용 가능

#### 시너지 효과

| unity-pragmatic-tdd-plugin | + claude-mem | 결과 |
|---------------------------|--------------|------|
| 서브에이전트 파이프라인 | 세션 기억 | 이전 시스템 설계 패턴 자동 참조 |
| PROJECT_CONTEXT.md | 히스토리 검색 | 단계 전환 이력 추적 |
| SOLID 리뷰 | 과거 피드백 기억 | 반복 실수 방지 |

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

#### 병렬 작업 시 참고

여러 터미널에서 동시 작업 시:

```
터미널 1: Inventory 시스템     터미널 2: Combat 시스템
        ↓                           ↓
    ┌─────────────────────────────────────┐
    │   claude-mem 공유 DB                 │
    │   (서로의 작업 내역 검색 가능)          │
    └─────────────────────────────────────┘
```

⚠️ **같은 파일 동시 수정은 피할 것** - 서로 다른 시스템/폴더 작업 시에만 병렬 작업 권장

## 업데이트

```bash
cd .claude-plugin && git pull
```

## 라이선스

MIT
