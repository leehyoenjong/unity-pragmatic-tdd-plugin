# Unity Test Environment Setup

## 테스트 프레임워크 선택

Unity는 NUnit 기반 Unity Test Framework를 기본 제공합니다.

**설치:**
1. Window → Package Manager → Unity Test Framework (기본 포함)
2. 권장 추가: NSubstitute (Mock 라이브러리)

```json
// Packages/manifest.json
{
  "dependencies": {
    "com.unity.test-framework": "1.3.9"
  }
}
```

---

## Edit Mode vs Play Mode 테스트

| 분류 | Edit Mode | Play Mode |
|------|-----------|-----------|
| 환경 | 에디터 | 런타임 시뮬레이션 |
| 속도 | 빠름 (밀리초) | 느림 (프레임 대기) |
| MonoBehaviour | 제한적 | 완전 지원 |
| 코루틴 | 불가 | 가능 |
| 물리/충돌 | 불가 | 가능 |
| 권장 용도 | 순수 로직 | 통합 테스트 |

---

## 폴더 구조

```
Assets/
├── Scripts/
│   ├── Core/                    # 순수 C# 로직
│   └── GamePlay/                # MonoBehaviour
└── Tests/
    ├── EditMode/                # Edit Mode 테스트
    │   ├── EditMode.asmdef
    │   ├── ScoreCalculatorTests.cs
    │   └── StatSystemTests.cs
    └── PlayMode/                # Play Mode 테스트
        ├── PlayMode.asmdef
        ├── PlayerControllerTests.cs
        └── GameFlowTests.cs
```

---

## Assembly Definition 설정 (EditMode.asmdef)

```json
{
    "name": "EditModeTests",
    "rootNamespace": "",
    "references": [
        "GUID:your-main-assembly-guid"
    ],
    "includePlatforms": [
        "Editor"
    ],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": true,
    "precompiledReferences": [
        "nunit.framework.dll",
        "NSubstitute.dll"
    ],
    "defineConstraints": [
        "UNITY_INCLUDE_TESTS"
    ]
}
```

---

## Edit Mode 테스트 작성

### 기본 구조
```csharp
using NUnit.Framework;

namespace Tests.EditMode
{
    [TestFixture]
    public class ScoreCalculatorTests
    {
        private ScoreCalculator calculator;

        [SetUp]
        public void SetUp()
        {
            calculator = new ScoreCalculator();
        }

        [TearDown]
        public void TearDown()
        {
            calculator = null;
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
}
```

### 예외 테스트
```csharp
[Test]
public void Calculate_WithNegativeScore_ThrowsArgumentException()
{
    Assert.Throws<ArgumentException>(() =>
        calculator.Calculate(-100, 0));
}

[Test]
public void Calculate_WithNegativeCombo_ThrowsArgumentException()
{
    var ex = Assert.Throws<ArgumentException>(() =>
        calculator.Calculate(100, -1));

    Assert.That(ex.Message, Does.Contain("combo"));
}
```

---

## Play Mode 테스트 작성

### 기본 구조
```csharp
using System.Collections;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;

namespace Tests.PlayMode
{
    public class PlayerControllerTests
    {
        private GameObject playerObject;
        private PlayerController player;

        [SetUp]
        public void SetUp()
        {
            playerObject = new GameObject("Player");
            player = playerObject.AddComponent<PlayerController>();
        }

        [TearDown]
        public void TearDown()
        {
            Object.Destroy(playerObject);
        }

        [UnityTest]
        public IEnumerator Move_WithPositiveInput_MovesRight()
        {
            Vector3 startPos = player.transform.position;

            player.SetMoveInput(1f);

            yield return null;
            yield return null;
            yield return null;

            Assert.Greater(player.transform.position.x, startPos.x);
        }

        [UnityTest]
        public IEnumerator Jump_WhenGrounded_AppliesUpwardForce()
        {
            var rb = playerObject.AddComponent<Rigidbody2D>();
            rb.gravityScale = 0;

            yield return null;

            player.Jump();
            yield return new WaitForFixedUpdate();

            Assert.Greater(rb.velocity.y, 0);
        }
    }
}
```

### 시간 기반 테스트
```csharp
[UnityTest]
public IEnumerator Buff_ExpiresAfterDuration()
{
    var buffSystem = playerObject.AddComponent<BuffSystem>();
    var buff = new SpeedBuff(duration: 2f);

    buffSystem.ApplyBuff(buff);
    Assert.IsTrue(buffSystem.HasBuff<SpeedBuff>());

    yield return new WaitForSeconds(2.1f);

    Assert.IsFalse(buffSystem.HasBuff<SpeedBuff>());
}
```

---

## Mock/Stub 전략

### NSubstitute 설치
1. NuGet에서 NSubstitute 다운로드
2. DLL을 `Assets/Plugins/` 폴더에 배치
3. EditMode.asmdef의 precompiledReferences에 추가

### Mock 사용 예시
```csharp
using NSubstitute;
using NUnit.Framework;

[TestFixture]
public class CombatSystemTests
{
    private CombatSystem combat;
    private IStatProvider mockStats;
    private IDamageCalculator mockCalculator;

    [SetUp]
    public void SetUp()
    {
        mockStats = Substitute.For<IStatProvider>();
        mockCalculator = Substitute.For<IDamageCalculator>();
        combat = new CombatSystem(mockStats, mockCalculator);
    }

    [Test]
    public void Attack_CallsDamageCalculator_WithCorrectStats()
    {
        mockStats.GetStat(StatType.Attack).Returns(50);
        mockStats.GetStat(StatType.CritChance).Returns(10);

        combat.Attack(targetId: 1);

        mockCalculator.Received(1).Calculate(
            Arg.Is(50),
            Arg.Any<int>(),
            Arg.Is(10)
        );
    }
}
```

### 수동 Test Double 구현
```csharp
public class FakeStatProvider : IStatProvider
{
    private Dictionary<StatType, int> stats = new();

    public void SetStat(StatType type, int value) => stats[type] = value;
    public int GetStat(StatType type) => stats.GetValueOrDefault(type, 0);
}

[Test]
public void Attack_WithHighAttack_DealsMoreDamage()
{
    var fakeStats = new FakeStatProvider();
    fakeStats.SetStat(StatType.Attack, 100);

    var combat = new CombatSystem(fakeStats);
    int damage = combat.CalculateDamage();

    Assert.Greater(damage, 50);
}
```

---

## 테스트 실행

**에디터에서:**
- Window → General → Test Runner
- EditMode / PlayMode 탭 선택
- Run All 또는 개별 테스트 실행

**커맨드 라인:**
```bash
# Edit Mode 테스트
Unity -batchmode -projectPath /path/to/project -runTests \
  -testPlatform EditMode -testResults edit-results.xml

# Play Mode 테스트
Unity -batchmode -projectPath /path/to/project -runTests \
  -testPlatform PlayMode -testResults play-results.xml
```
