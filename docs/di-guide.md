# Dependency Injection (DI) Guide

## DI가 필요한 이유

```csharp
// ❌ 강한 결합 - 테스트 불가
public class Player : MonoBehaviour
{
    void Start()
    {
        var saveSystem = SaveSystem.Instance; // 싱글톤 의존
        var stats = GetComponent<StatSystem>(); // Unity 의존
    }
}

// ✅ 약한 결합 - 테스트 가능
public class Player : MonoBehaviour
{
    private ISaveSystem saveSystem;
    private IStatProvider stats;

    public void Initialize(ISaveSystem save, IStatProvider stats)
    {
        this.saveSystem = save;
        this.stats = stats;
    }
}
```

---

## 옵션 1: 수동 DI (소규모 프로젝트)

**장점:** 외부 의존 없음, 단순
**단점:** 보일러플레이트 코드, 대규모 프로젝트에서 복잡

### Composition Root 패턴
```csharp
public class GameInstaller : MonoBehaviour
{
    [SerializeField] private Player playerPrefab;
    [SerializeField] private Enemy enemyPrefab;

    void Awake()
    {
        // 서비스 생성
        var saveSystem = new JsonSaveSystem();
        var statSystem = new StatSystem();
        var combatSystem = new CombatSystem(statSystem);

        // Service Locator에 등록 (선택)
        ServiceLocator.Register<ISaveSystem>(saveSystem);

        // Player 생성 및 주입
        var player = Instantiate(playerPrefab);
        player.Initialize(saveSystem, statSystem, combatSystem);

        // Enemy 생성 및 주입
        var enemy = Instantiate(enemyPrefab);
        enemy.Initialize(statSystem, combatSystem);
    }
}
```

### 간단한 Service Locator
```csharp
public static class ServiceLocator
{
    private static readonly Dictionary<Type, object> services = new();

    public static void Register<T>(T service) where T : class
    {
        services[typeof(T)] = service;
    }

    public static T Get<T>() where T : class
    {
        if (services.TryGetValue(typeof(T), out var service))
        {
            return service as T;
        }
        throw new InvalidOperationException($"Service {typeof(T)} not registered");
    }

    public static void Clear()
    {
        services.Clear();
    }
}
```

---

## 옵션 2: VContainer (권장)

**장점:** 경량, 빠른 성능, Unity 친화적, 소스 생성기 사용
**단점:** 학습 곡선, 외부 패키지 의존

### 설치
```json
// Packages/manifest.json
{
  "dependencies": {
    "jp.hadashikick.vcontainer": "1.15.4"
  }
}
```

### 기본 사용법
```csharp
using VContainer;
using VContainer.Unity;

// 1. 인터페이스 정의
public interface IScoreService
{
    int CurrentScore { get; }
    void AddScore(int amount);
}

public class ScoreService : IScoreService
{
    public int CurrentScore { get; private set; }
    public void AddScore(int amount) => CurrentScore += amount;
}

// 2. LifetimeScope에 등록
public class GameLifetimeScope : LifetimeScope
{
    protected override void Configure(IContainerBuilder builder)
    {
        // 싱글톤 등록
        builder.Register<IScoreService, ScoreService>(Lifetime.Singleton);
        builder.Register<ISaveSystem, JsonSaveSystem>(Lifetime.Singleton);

        // Transient 등록 (매번 새 인스턴스)
        builder.Register<IDamageCalculator, DamageCalculator>(Lifetime.Transient);

        // MonoBehaviour 등록
        builder.RegisterComponentInHierarchy<Player>();
        builder.RegisterComponentInHierarchy<UIManager>();
    }
}

// 3. 주입 (MonoBehaviour)
public class Player : MonoBehaviour
{
    private IScoreService scoreService;
    private ISaveSystem saveSystem;

    [Inject]
    public void Construct(IScoreService score, ISaveSystem save)
    {
        this.scoreService = score;
        this.saveSystem = save;
    }

    void OnEnemyKilled()
    {
        scoreService.AddScore(100);
    }
}

// 4. 주입 (순수 C# 클래스)
public class GameStateController
{
    private readonly IScoreService scoreService;
    private readonly ISaveSystem saveSystem;

    // 생성자 주입 (자동)
    public GameStateController(IScoreService score, ISaveSystem save)
    {
        this.scoreService = score;
        this.saveSystem = save;
    }
}
```

### 씬 간 서비스 유지
```csharp
// RootLifetimeScope.cs - DontDestroyOnLoad 씬에 배치
public class RootLifetimeScope : LifetimeScope
{
    protected override void Configure(IContainerBuilder builder)
    {
        // 전역 서비스
        builder.Register<ISaveSystem, JsonSaveSystem>(Lifetime.Singleton);
        builder.Register<IAudioService, AudioService>(Lifetime.Singleton);
    }
}

// GameSceneLifetimeScope.cs - 게임 씬에 배치
public class GameSceneLifetimeScope : LifetimeScope
{
    protected override void Configure(IContainerBuilder builder)
    {
        // 씬 전용 서비스
        builder.Register<IScoreService, ScoreService>(Lifetime.Scoped);
        builder.RegisterComponentInHierarchy<Player>();
    }
}
```

---

## 옵션 3: ScriptableObject 기반 DI

**장점:** Unity 네이티브, 에디터 친화적, Inspector에서 설정 가능
**단점:** 런타임 인스턴스 관리 복잡, 테스트 추가 설정 필요

### Service ScriptableObject
```csharp
// 서비스 인터페이스
public interface IGameConfig
{
    int MaxHealth { get; }
    float MoveSpeed { get; }
}

// ScriptableObject 구현
[CreateAssetMenu(fileName = "GameConfig", menuName = "Config/GameConfig")]
public class GameConfigSO : ScriptableObject, IGameConfig
{
    [SerializeField] private int maxHealth = 100;
    [SerializeField] private float moveSpeed = 5f;

    public int MaxHealth => maxHealth;
    public float MoveSpeed => moveSpeed;
}

// 사용
public class Player : MonoBehaviour
{
    [SerializeField] private GameConfigSO config; // Inspector에서 할당

    void Start()
    {
        currentHealth = config.MaxHealth;
        moveSpeed = config.MoveSpeed;
    }
}
```

### Event Channel 패턴
```csharp
[CreateAssetMenu(fileName = "GameEvent", menuName = "Events/GameEvent")]
public class GameEventSO : ScriptableObject
{
    private readonly List<IGameEventListener> listeners = new();

    public void Raise()
    {
        for (int i = listeners.Count - 1; i >= 0; i--)
        {
            listeners[i].OnEventRaised();
        }
    }

    public void Register(IGameEventListener listener) => listeners.Add(listener);
    public void Unregister(IGameEventListener listener) => listeners.Remove(listener);
}

public interface IGameEventListener
{
    void OnEventRaised();
}

public class GameEventListener : MonoBehaviour, IGameEventListener
{
    [SerializeField] private GameEventSO gameEvent;
    [SerializeField] private UnityEvent response;

    void OnEnable() => gameEvent.Register(this);
    void OnDisable() => gameEvent.Unregister(this);
    public void OnEventRaised() => response?.Invoke();
}
```

---

## DI 선택 가이드

| 프로젝트 규모 | 권장 | 이유 |
|--------------|------|------|
| 소규모 (1-2명, <3개월) | 수동 DI + Service Locator | 단순, 빠른 개발 |
| 중규모 (3-5명, 6개월) | VContainer | 체계적 관리, 쉬운 테스트 |
| 대규모 (5+, 1년+) | VContainer + ScriptableObject | 유연성, 에디터 친화적 |
| 프로토타입 | ScriptableObject만 | Inspector 설정, 빠른 반복 |

---

## 권장 구조

```
Scripts/
├── Core/
│   ├── Interfaces/          # 서비스 인터페이스
│   │   ├── IScoreService.cs
│   │   ├── ISaveSystem.cs
│   │   └── IAudioService.cs
│   └── Services/            # 구현체
│       ├── ScoreService.cs
│       ├── JsonSaveSystem.cs
│       └── AudioService.cs
├── DI/
│   ├── GameLifetimeScope.cs  # VContainer 설정
│   └── ServiceLocator.cs     # 간단한 서비스 로케이터
├── ScriptableObjects/
│   ├── Config/              # Config SO
│   └── Events/              # Event Channel SO
└── Tests/
    └── Fakes/               # 테스트용 Fake 구현체
        ├── FakeScoreService.cs
        └── InMemorySaveSystem.cs
```
