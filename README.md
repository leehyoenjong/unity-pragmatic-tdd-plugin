# Unity Pragmatic TDD Plugin

Claude Code 플러그인 - Unity 게임 개발을 위한 실용적 TDD 및 SOLID 가이드

## 개요

프로젝트 단계(Prototype/Alpha/Beta/Live)에 따라 적절한 수준의 TDD와 SOLID 원칙을 적용하도록 안내합니다.

"무조건 TDD"가 아닌, 게임 개발 현실에 맞는 **실용적 접근**을 제공합니다.

## 설치

```bash
# Unity 프로젝트 루트에서 실행
curl -fsSL https://raw.githubusercontent.com/leehyoenjong/unity-pragmatic-tdd-plugin/main/install.sh | bash
```

## 슬래시 명령어

설치 후 Claude Code에서 다음 명령어를 사용할 수 있습니다:

| 명령어 | 설명 |
|--------|------|
| `/utdd_tdd` | TDD 워크플로우 적용 |
| `/utdd_solid` | SOLID 원칙 검토 |
| `/utdd_safety-check` | Beta 단계 기능 안전성 체크 |
| `/utdd_transition` | 프로젝트 단계 전환 |
| `/utdd_review` | 코드 리뷰 (안티패턴 체크) |

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

## 업데이트

```bash
cd .claude-plugin && git pull
```

## 라이선스

MIT
