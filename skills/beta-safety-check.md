# Beta Safety Check Skill

이 skill은 Beta 단계에서 새 기능 추가 요청이 왔을 때 안전성을 검토합니다.

---

## Beta 단계 원칙

**목적**: 버그 수정, 밸런싱, 최적화
- 코드 품질: 높음 (자유롭게 변경 불가)
- 리팩토링: **신중하게, 버그 수정용으로만** ⚠️
- TDD: 60-80%
- SOLID: **기존 구조 활용**

### ✅ 안전하게 추가 가능
- 기존 시스템을 사용하는 새 콘텐츠
- 데이터 추가 (아이템, 스테이지 등)
- 구조 변경 없는 작은 기능

### ❌ 추가 위험
- 구조 변경이 필요한 기능
- 시스템 전반 리팩토링
- 대규모 아키텍처 변경

---

## 안전성 검토 체크리스트

새 기능 요청 시 다음을 모두 확인:

| 질문 | Yes | No |
|------|-----|-----|
| 기존 시스템 구조 사용? | 안전 ✅ | 위험 ⚠️ |
| 수정 파일 10개 미만? | 안전 ✅ | 위험 ⚠️ |
| 데이터 구조 유지? | 안전 ✅ | 위험 ⚠️ |
| 1주일 내 완료 가능? | 안전 ✅ | 위험 ⚠️ |
| 롤백 용이? | 안전 ✅ | 위험 ⚠️ |

**모두 YES**: Beta에서 추가 가능
**하나라도 NO**: 다음 버전으로 미루기 권장

---

## 기존 구조 분석 템플릿

새 기능 요청 시 다음을 분석:

```
[기존 코드 분석]

Stat 시스템:
✅/❌ IStatModifier 확장 포인트 있음
✅/❌ 동적 modifier 추가 가능

Skill 시스템:
✅/❌ ISkill 인터페이스 있음
✅/❌ 동적 스킬 추가 지원

UI 시스템:
✅/❌ 동적 프리팹 인스턴스화

Save 시스템:
✅/❌ 유연한 JSON 구조

안전성 평가: SAFE ✅ / HIGH RISK ⚠️⚠️⚠️
```

---

## 응답 템플릿

### 구조가 지원하는 경우 (안전)
```
기존 구조가 [기능명] 추가를 안전하게 지원합니다.

구현 계획:
- NewFeature.cs (새 파일)
- NewFeatureDatabase.cs (새 파일)
- NewFeatureController.cs (새 파일)

수정 없음:
- Player.cs
- StatSystem.cs
- 기존 핵심 시스템

예상 소요: 3일
진행할까요? (y/n)
```

### 구조가 지원하지 않는 경우 (위험)
```
⚠️ WARNING: [기능명]은 구조적 변경이 필요합니다

필요한 변경:
- Player.cs: 대규모 리팩토링 (200+ 줄)
- StatSystem.cs: 재설계 필요
- 모든 전투 로직: 수정 필요
- 전체 밸런싱 필요
- 전체 회귀 테스트 필요

위험도: 높음 ⚠️⚠️⚠️
예상 소요: 2-3주
출시 지연: 가능성 높음

권장사항:
1. 출시 후 업데이트 (강력 권장)
   → 출시 후 안전하게 구조 리팩토링 가능
   → Version 1.1로 추가

2. 매우 제한된 버전 (스탯 보너스만, 스킬 없음)
   → 3일 내 추가 가능
   → 기능 매우 제한적

3. 출시 연기하고 지금 추가
   → 권장하지 않음
   → 버그 및 지연 위험 높음

어떻게 진행할까요?
```

---

## 안전한 기능 예시

```csharp
// ✅ Beta에서 안전 - 기존 구조 사용
public class NewStage : BaseStage  // 기존 베이스 클래스
{
    protected override void SetupObstacles()
    {
        // 새 장애물 배치만
    }
}

// ✅ Beta에서 안전 - 데이터 추가만
new Item {
    id = "mega_potion",
    effect = "heal_full"
}

// ✅ Beta에서 안전 - 기존 인터페이스 구현
public class NewPet : IStatModifier, ISkill
{
    // 기존 시스템 확장
}
```

## 위험한 기능 예시

```csharp
// ❌ Beta에서 위험 - 구조적 변경
// 단일 재화 → 다중 재화 시스템
public class CurrencySystem  // 기존: ScoreSystem
{
    private Dictionary<CurrencyType, int> currencies; // 기존: int score
    // 모든 점수 관련 코드 변경 필요!
}

// ❌ Beta에서 위험 - 기존 시스템 수정
public class Player
{
    // 펫 시스템을 위해 기존 코드 대거 수정 필요
    private List<Pet> pets; // 새로 추가
    // Attack(), TakeDamage() 등 모든 메서드 수정...
}
```

---

## 안전한 기능 vs 위험한 기능

### 안전한 기능
- 새 스테이지/레벨
- 새 아이템 (기존 ItemSystem 사용)
- 새 스킬 (기존 SkillSystem 사용)
- 비주얼 변형

### 위험한 기능
- 멀티플레이어 모드
- 캐릭터 클래스 시스템
- 경제 시스템 전면 재설계
- 기존에 없는 완전히 새로운 시스템
