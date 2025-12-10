# Troubleshooting Guide

## MonoBehaviour 테스트 문제

**Q: MonoBehaviour를 어떻게 테스트하나요?**

**A:** 로직을 순수 C# 클래스로 분리하세요.

```csharp
// ❌ 테스트 어려움
public class Enemy : MonoBehaviour
{
    public int health = 100;

    void Update()
    {
        if (health <= 0)
        {
            Destroy(gameObject);
        }
    }

    public void TakeDamage(int damage)
    {
        health -= damage;
        GetComponent<Animator>().SetTrigger("Hit");
    }
}

// ✅ 테스트 가능하게 분리
public class EnemyHealth // 순수 C# - 테스트 가능
{
    public int CurrentHealth { get; private set; }
    public bool IsDead => CurrentHealth <= 0;

    public event Action OnDeath;
    public event Action<int> OnDamaged;

    public EnemyHealth(int maxHealth)
    {
        CurrentHealth = maxHealth;
    }

    public void TakeDamage(int damage)
    {
        CurrentHealth = Mathf.Max(0, CurrentHealth - damage);
        OnDamaged?.Invoke(damage);

        if (IsDead)
        {
            OnDeath?.Invoke();
        }
    }
}

public class Enemy : MonoBehaviour // 얇은 래퍼
{
    private EnemyHealth health;

    void Awake()
    {
        health = new EnemyHealth(100);
        health.OnDeath += () => Destroy(gameObject);
        health.OnDamaged += _ => GetComponent<Animator>().SetTrigger("Hit");
    }

    public void TakeDamage(int damage) => health.TakeDamage(damage);
}

// 테스트
[Test]
public void TakeDamage_WithLethalDamage_TriggersDeathEvent()
{
    var health = new EnemyHealth(100);
    bool died = false;
    health.OnDeath += () => died = true;

    health.TakeDamage(100);

    Assert.IsTrue(died);
}
```

---

## 싱글톤 테스트 문제

**Q: 싱글톤에 의존하는 코드를 테스트할 수 없습니다.**

**A:** 인터페이스를 추출하고 주입하세요.

```csharp
// ❌ 테스트 불가
public class SaveManager
{
    public static SaveManager Instance { get; private set; }

    void Awake() => Instance = this;

    public void Save(GameData data) { /* 파일 저장 */ }
}

public class Player
{
    public void SaveProgress()
    {
        SaveManager.Instance.Save(GetData()); // 직접 의존
    }
}

// ✅ 테스트 가능
public interface ISaveService
{
    void Save(GameData data);
    GameData Load();
}

public class SaveManager : MonoBehaviour, ISaveService
{
    public static ISaveService Instance { get; private set; }

    void Awake() => Instance = this;

    public void Save(GameData data) { /* 파일 저장 */ }
    public GameData Load() { /* 파일 로드 */ }
}

public class Player
{
    private readonly ISaveService saveService;

    // 생성자 주입 (테스트용)
    public Player(ISaveService saveService)
    {
        this.saveService = saveService;
    }

    // 기본 생성자 (런타임용)
    public Player() : this(SaveManager.Instance) { }

    public void SaveProgress()
    {
        saveService.Save(GetData());
    }
}

// 테스트
[Test]
public void SaveProgress_CallsSaveService()
{
    var mockSave = Substitute.For<ISaveService>();
    var player = new Player(mockSave);

    player.SaveProgress();

    mockSave.Received(1).Save(Arg.Any<GameData>());
}
```

---

## 비동기 코드 테스트 문제

**Q: Edit Mode에서 코루틴을 테스트하고 싶습니다.**

**A:** UniTask로 변환하거나 로직을 분리하세요.

```csharp
// ❌ 코루틴 - Edit Mode 테스트 불가
public IEnumerator LoadDataCoroutine()
{
    yield return new WaitForSeconds(1f);
    // 로드 로직
}

// ✅ 옵션 1: UniTask 사용
public async UniTask LoadDataAsync()
{
    await UniTask.Delay(1000);
    // 로드 로직
}

// ✅ 옵션 2: 로직 분리
public class DataLoader
{
    // 순수 로직 - Edit Mode 테스트 가능
    public GameData ParseData(string json)
    {
        return JsonUtility.FromJson<GameData>(json);
    }
}

public class DataLoaderMono : MonoBehaviour
{
    private DataLoader loader = new();

    public IEnumerator LoadDataCoroutine(string path)
    {
        var request = Resources.LoadAsync<TextAsset>(path);
        yield return request;

        var json = (request.asset as TextAsset).text;
        var data = loader.ParseData(json); // 테스트된 로직 사용
    }
}

// 테스트
[Test]
public void ParseData_WithValidJson_ReturnsData()
{
    var loader = new DataLoader();
    var json = "{\"level\": 5}";

    var data = loader.ParseData(json);

    Assert.AreEqual(5, data.Level);
}
```

---

## Unity API 의존 문제

**Q: Vector3, Mathf를 사용하는 코드는 어떻게 처리하나요?**

**A:** Unity 구조체는 Edit Mode에서 작동합니다.

```csharp
// ✅ Vector3, Quaternion 등은 Edit Mode에서 작동
[Test]
public void CalculateDirection_ReturnsNormalized()
{
    var calculator = new MovementCalculator();

    var dir = calculator.GetDirection(Vector3.zero, new Vector3(10, 0, 0));

    Assert.AreEqual(Vector3.right, dir);
}

// ✅ Mathf도 작동
[Test]
public void ClampHealth_NeverExceedsMax()
{
    var health = new HealthSystem(maxHealth: 100);

    health.Heal(1000);

    Assert.AreEqual(100, health.Current);
}

// ❌ 사용 불가: GetComponent, Instantiate, Physics 등
// Play Mode 테스트 또는 Mock 필요
```

---

## 테스트 실행 순서 문제

**Q: 테스트 실행 순서가 결과에 영향을 줍니다.**

**A:** 각 테스트는 독립적이어야 합니다.

```csharp
// ❌ 공유 상태 문제
public class BadTests
{
    private static int sharedCounter = 0;

    [Test]
    public void Test1()
    {
        sharedCounter++;
        Assert.AreEqual(1, sharedCounter); // 실패할 수 있음
    }

    [Test]
    public void Test2()
    {
        sharedCounter++;
        Assert.AreEqual(1, sharedCounter); // 순서에 의존
    }
}

// ✅ 독립적인 테스트
public class GoodTests
{
    private ScoreSystem system;

    [SetUp]
    public void SetUp()
    {
        system = new ScoreSystem(); // 각 테스트마다 새 인스턴스
    }

    [TearDown]
    public void TearDown()
    {
        system = null;
    }

    [Test]
    public void Test1()
    {
        system.AddScore(100);
        Assert.AreEqual(100, system.Total);
    }

    [Test]
    public void Test2()
    {
        system.AddScore(200);
        Assert.AreEqual(200, system.Total); // 항상 성공
    }
}
```

---

## Play Mode 테스트가 너무 느림

**Q: Play Mode 테스트가 너무 느립니다.**

**A:** 가능한 많은 테스트를 Edit Mode로 옮기세요.

```csharp
// 우선순위:
// 1. Edit Mode (밀리초) - 순수 로직
// 2. Play Mode (초) - 통합/시각적 테스트

// 로직을 분리하여 Edit Mode 테스트 비율 증가
public class GameLogic // Edit Mode 테스트 가능
{
    public int CalculateDamage(int attack, int defense)
        => Mathf.Max(1, attack - defense);

    public bool CanUseSkill(int currentMana, int skillCost)
        => currentMana >= skillCost;

    public float CalculateComboMultiplier(int combo)
        => 1f + (combo * 0.1f);
}

// Play Mode는 통합 테스트용으로만
[UnityTest]
public IEnumerator FullGameFlow_StartsAndEnds()
{
    SceneManager.LoadScene("GameScene");
    yield return null;

    var gameManager = Object.FindObjectOfType<GameManager>();
    Assert.AreEqual(GameState.Playing, gameManager.State);

    gameManager.EndGame();
    yield return null;

    Assert.AreEqual(GameState.GameOver, gameManager.State);
}
```

---

## 빠른 트러블슈팅 표

| 증상 | 원인 | 해결 |
|------|------|------|
| 테스트가 항상 통과 | Assert 누락 | 먼저 실패하는 테스트 작성 (Red) |
| 테스트가 랜덤하게 실패 | 공유 상태 | SetUp/TearDown으로 초기화 |
| Edit Mode에서 NullReference | Unity API 사용 | 로직 분리 또는 Play Mode 사용 |
| Mock이 작동 안 함 | 인터페이스 미사용 | 인터페이스 추출 |
| 테스트 시간 너무 김 | Play Mode 테스트 과다 | 로직 분리, Edit Mode로 이동 |
| 싱글톤 테스트 불가 | 강한 결합 | 인터페이스 + 주입 |
