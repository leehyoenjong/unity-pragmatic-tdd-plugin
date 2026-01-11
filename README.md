# Unity Pragmatic TDD Plugin

Claude Code 플러그인 - Unity 게임 개발을 위한 실용적 TDD 및 SOLID 가이드

## 개요

프로젝트 단계(Prototype/Alpha/Beta/Live)에 따라 적절한 수준의 TDD와 SOLID 원칙을 적용하도록 안내합니다.

"무조건 TDD"가 아닌, 게임 개발 현실에 맞는 **실용적 접근**을 제공합니다.

## 주요 기능

### 서브에이전트 파이프라인

#### 개발 파이프라인
"XX 시스템 만들어줘" 요청 시 자동으로 실행:

```
1. 스크립트 → 폴더/파일 생성 (컨텍스트 0)
2. architect → 인터페이스 설계 (독립 컨텍스트)
3. implementer → 구현 + 테스트 (독립 컨텍스트)
4. reviewer → SOLID 검토 (독립 컨텍스트)
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
- 컨텍스트 효율: 기존 대비 ~80% 절약
- 일관된 구조: XX_FolderName 규칙 자동 적용
- SOLID 검토 필수 포함
- 체계적인 QA 프로세스

### 서브에이전트

#### 개발 에이전트

| 에이전트 | 역할 | 모델 |
|---------|-----|-----|
| `architect` | 시스템 설계, 인터페이스, OCP 확장점 | opus |
| `implementer` | Pure C# 구현, TDD 테스트 작성 | opus |
| `reviewer` | SOLID 검토, 안전성 평가 | opus |

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
| `enable.sh` | 프로젝트별 플러그인 활성화 |

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

### Step 1: 마켓플레이스 등록 & 설치

Claude Code에서 실행:

```bash
/plugin marketplace add leehyoenjong/unity-pragmatic-tdd-plugin
/plugin install unity-pragmatic-tdd
```

> **참고**: 설치 시 **"Install for you, in this repo only (local scope)"** 선택 권장

### Step 2: 프로젝트별 활성화

플러그인을 사용할 각 프로젝트에서 활성화가 필요합니다.

**방법 1: 스크립트 사용 (권장)**

```bash
# 프로젝트 루트에서 실행
bash ~/.claude/plugins/cache/leehyoenjong-plugins/unity-pragmatic-tdd/1.0.0/enable.sh

# 확인 없이 강제 실행
bash ~/.claude/plugins/cache/leehyoenjong-plugins/unity-pragmatic-tdd/1.0.0/enable.sh -f
```

**방법 2: alias 설정 (편리)**

`~/.zshrc` 또는 `~/.bashrc`에 추가:

```bash
alias enable-tdd='bash ~/.claude/plugins/cache/leehyoenjong-plugins/unity-pragmatic-tdd/1.0.0/enable.sh'
```

이후 프로젝트에서:

```bash
cd /path/to/unity/project
enable-tdd -f
```

**방법 3: 수동 생성**

프로젝트 루트에 `.claude/settings.local.json` 파일 생성:

```json
{
  "enabledPlugins": {
    "unity-pragmatic-tdd@leehyoenjong-plugins": true
  }
}
```

> **참고**: 활성화 후 Claude Code 재시작 필요

### Step 3: 초기 설정

Claude Code 재시작 후 실행:

```bash
/eee_init
```

초기 설정에서 수행하는 작업:
- PROJECT_CONTEXT.md 생성 (프로젝트 단계 설정)
- 추가 도구 설치 안내 (Unity-MCP, claude-mem)
- .clauderules 파일 생성

## 사용법

### 시스템 생성 (자동 파이프라인)

```
"인벤토리 시스템 만들어줘"
"Combat System 구현해줘"
"새로운 Quest 기능 추가해줘"
```

→ 자동으로 파이프라인 실행

### 슬래시 명령어 (10개)

#### 필수

| 명령어 | 설명 |
|--------|------|
| `/eee_init` | 초기 설정 (PROJECT_CONTEXT, 추가 도구 설치 안내) |
| `/eee_transition` | 프로젝트 단계 전환 |

#### 개발

| 명령어 | 설명 |
|--------|------|
| `/eee_tdd` | TDD 워크플로우 적용 |
| `/eee_review` | 코드 리뷰 (SOLID + 안티패턴 + Beta 안전성) |

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

#### 개발 에이전트
- `.claude/agents/architect.md` - 시스템 설계 에이전트
- `.claude/agents/implementer.md` - 구현 에이전트
- `.claude/agents/reviewer.md` - 리뷰 에이전트

#### QA 에이전트
- `.claude/agents/qa-tc.md` - TC 작성 에이전트 (GQA)
- `.claude/agents/qa-tech.md` - 기술 버그 탐지 에이전트 (TQA)
- `.claude/agents/qa-balance.md` - 밸런스/경제 분석 에이전트 (FQA+DQA)
- `.claude/agents/qa-security.md` - 보안/어뷰징 방지 에이전트 (CQA)
- `.claude/agents/qa-release.md` - 런칭/패치 검수 에이전트 (PQA+SQA)

#### Pipelines & Scripts
- `.claude/pipelines/new-system.md` - 새 시스템 생성 파이프라인
- `.claude/pipelines/qa-pipeline.md` - 전체 QA 검증 파이프라인
- `.claude/scripts/create-structure.sh` - 폴더 구조 생성 스크립트

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
# 1. 플러그인 설치 (최초 1회)
/plugin marketplace add leehyoenjong/unity-pragmatic-tdd-plugin
/plugin install unity-pragmatic-tdd  # local scope 선택

# 2. 프로젝트 활성화 (프로젝트마다)
bash ~/.claude/plugins/cache/leehyoenjong-plugins/unity-pragmatic-tdd/1.0.0/enable.sh -f

# 3. Claude Code 재시작

# 4. 초기 설정
/eee_init
```

## 참고 자료

이 플러그인의 서브에이전트, 스킬, 스크립트 구조는 다음 자료를 참고하여 개발되었습니다:

- [Claude Code 서브에이전트 활용 영상](https://www.youtube.com/watch?v=GL3LXWBZfy0) - 서브에이전트, 스킬, 스크립트 구조 참고

### 추가 참고 문서

- [Claude Code Subagents 공식 문서](https://code.claude.com/docs/en/sub-agents)
- [Skills vs Commands vs Subagents 비교](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/)

## 라이선스

MIT
