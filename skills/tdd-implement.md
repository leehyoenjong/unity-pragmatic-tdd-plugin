# TDD Implementation Skill

이 skill은 TDD(Test-Driven Development)로 기능을 구현할 때 사용합니다.

## TDD 워크플로우

### Pure C# 클래스 (테스트 가능한 로직)
1. **Red**: 실패하는 테스트 작성
2. **Green**: 테스트를 통과하는 최소 코드 구현
3. **Refactor**: 테스트 통과 상태에서 리팩토링
4. SOLID 원칙 적용 (특히 OCP)
5. 커밋: `feat: Add combo calculation logic [TESTED]`

### Unity 의존 기능
1. 시각적 검증으로 기능 구현
2. 테스트 가능한 로직을 별도 클래스로 추출
3. 추출된 로직에 SOLID 적용
4. 추출된 로직에 대한 테스트 작성
5. Unity 컴포넌트가 테스트된 로직 사용하도록 리팩토링
6. 커밋:
   - `feat: Add jump mechanic (visual)`
   - `test: Add tests for jump physics calculations`

### 프로토타입
1. 게임플레이 검증을 위해 빠르게 구현
2. 기능이 승인되면:
   - 핵심 로직 추출
   - SOLID 적용
   - 중요 부분 테스트 추가
   - 유지보수성 위한 리팩토링

---

## TDD 적용 기준

### 반드시 TDD 적용 ✅
- 게임 로직 (점수, 콤보, 매칭 알고리즘)
- 데이터 직렬화 (저장/로드, JSON 파싱)
- 수학 계산, 유틸리티 함수
- 네트워크 동기화 로직
- 경제 시스템 (IAP, 재화, 인벤토리)
- 버그 비용이 높은 핵심 비즈니스 로직

### TDD 생략 또는 최소화 ❌
- 시각적 요소 (UI 레이아웃, 파티클, 셰이더)
- 애니메이션 전환/블렌딩
- "느낌" 테스트가 필요한 물리 기반 인터랙션
- 빠른 프로토타이핑 단계
- 플레이테스트 피드백으로 자주 변경되는 기능

---

## 테스트 작성 예제

### 좋은 TDD 후보
```csharp
public class InventorySystem
{
    public bool AddItem(Item item, int quantity) { }
    public bool RemoveItem(string itemId, int quantity) { }
    public int GetItemCount(string itemId) { }
}
// ✅ 순수 로직, 명확한 입출력, 게임플레이에 중요
```

### 나쁜 TDD 후보
```csharp
public class UIFeedbackAnimator : MonoBehaviour
{
    public void PlayCollectAnimation(Vector3 startPos) { }
}
// ❌ 시각적 검증 필요, 테스트 가치 낮음
```

### 하이브리드 접근
```csharp
// MonoBehaviour 래퍼 (테스트 X)
public class EnemyAI : MonoBehaviour
{
    private EnemyBehaviorLogic logic; // ← 이것을 테스트

    void Update()
    {
        var decision = logic.DecideNextAction(playerPos, health);
        ExecuteAction(decision); // 시각적, 테스트 X
    }
}

// 테스트 가능한 로직 (테스트 O)
public class EnemyBehaviorLogic
{
    private List<IBehavior> behaviors; // OCP 적용

    public EnemyAction DecideNextAction(Vector3 playerPos, float health)
    {
        foreach (var behavior in behaviors)
        {
            if (behavior.CanExecute(playerPos, health))
            {
                return behavior.GetAction();
            }
        }
        return EnemyAction.Idle;
    }
}
```

---

## 테스트 구조

### Edit Mode 테스트 (순수 로직)
```csharp
using NUnit.Framework;

[TestFixture]
public class ScoreCalculatorTests
{
    private ScoreCalculator calculator;

    [SetUp]
    public void SetUp()
    {
        calculator = new ScoreCalculator();
    }

    [Test]
    public void Calculate_WithZeroCombo_ReturnsBaseScore()
    {
        // Arrange
        int baseScore = 100;
        int comboCount = 0;

        // Act
        int result = calculator.Calculate(baseScore, comboCount);

        // Assert
        Assert.AreEqual(100, result);
    }

    // 파라미터화 테스트
    [TestCase(100, 0, 100)]
    [TestCase(100, 5, 150)]
    [TestCase(100, 10, 200)]
    public void Calculate_WithVariousCombos_ReturnsExpectedScore(
        int baseScore, int combo, int expected)
    {
        int result = calculator.Calculate(baseScore, combo);
        Assert.AreEqual(expected, result);
    }
}
```

### 의미 있는 테스트 작성

```csharp
// ❌ 무의미한 테스트
[Test]
public void Player_Name_ReturnsName()
{
    var player = new Player { Name = "Test" };
    Assert.AreEqual("Test", player.Name); // getter만 테스트
}

// ✅ 의미 있는 테스트
[Test]
public void Player_TakeDamage_AppliesArmorReduction()
{
    var player = new Player(health: 100, armor: 50);
    player.TakeDamage(100);
    Assert.AreEqual(50, player.CurrentHealth); // 비즈니스 로직 테스트
}

[Test]
public void Player_TakeDamage_NeverGoesBelowZero()
{
    var player = new Player(health: 10);
    player.TakeDamage(100);
    Assert.AreEqual(0, player.CurrentHealth);
    Assert.IsTrue(player.IsDead);
}
```
