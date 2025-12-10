# Common Mistakes and Anti-patterns

## 1. 과도한 추상화

### ❌ 안티패턴: 인터페이스 과부하
```csharp
// 단일 구현체를 위한 인터페이스
public interface IPlayerMovement { void Move(Vector3 dir); }
public interface IPlayerJump { void Jump(); }
public interface IPlayerHealth { void TakeDamage(int amount); }
public interface IPlayerAnimation { void PlayAnimation(string name); }
public interface IPlayerSound { void PlaySound(string name); }
public interface IPlayerInventory { /* ... */ }

public class Player : MonoBehaviour,
    IPlayerMovement, IPlayerJump, IPlayerHealth,
    IPlayerAnimation, IPlayerSound, IPlayerInventory
{
    // 복잡성만 증가, 실제 유연성 없음
}
```

### ✅ 올바른 접근
```csharp
// 확장 가능성 있는 것만 추상화
public interface IStatModifier { } // 버프, 장비, 펫 등 여러 구현
public interface ISkill { }        // 다양한 스킬 구현

public class Player : MonoBehaviour
{
    private List<IStatModifier> modifiers; // OCP 적용
    private List<ISkill> skills;           // OCP 적용

    // 단일 구현은 직접 작성
    public void Move(Vector3 dir) { }
    public void Jump() { }
}
```

**규칙:**
- 2개 이상 구현체가 예상될 때만 인터페이스 생성
- "나중에 필요할지도"는 충분한 이유가 아님
- YAGNI 원칙 따르기

---

## 2. 테스트를 위한 테스트

### ❌ 안티패턴: 무의미한 테스트
```csharp
// 프로퍼티 getter만 테스트
[Test]
public void Player_Name_ReturnsName()
{
    var player = new Player { Name = "Test" };
    Assert.AreEqual("Test", player.Name);
}

// 생성자만 테스트
[Test]
public void Player_Constructor_CreatesInstance()
{
    var player = new Player();
    Assert.IsNotNull(player);
}

// Unity 함수 래퍼 테스트
[Test]
public void MathHelper_Clamp_ClampsValue()
{
    Assert.AreEqual(5, MathHelper.Clamp(10, 0, 5));
    // Mathf.Clamp만 감싸는 메서드
}
```

### ✅ 의미 있는 테스트
```csharp
// 비즈니스 로직 테스트
[Test]
public void Player_TakeDamage_AppliesArmorReduction()
{
    var player = new Player(health: 100, armor: 50);
    player.TakeDamage(100);
    Assert.AreEqual(50, player.CurrentHealth);
}

// 경계 조건 테스트
[Test]
public void Player_TakeDamage_NeverGoesBelowZero()
{
    var player = new Player(health: 10);
    player.TakeDamage(100);
    Assert.AreEqual(0, player.CurrentHealth);
    Assert.IsTrue(player.IsDead);
}

// 상태 전환 테스트
[Test]
public void Player_Die_TriggersDeathEvent()
{
    var player = new Player(health: 10);
    bool eventFired = false;
    player.OnDeath += () => eventFired = true;

    player.TakeDamage(100);

    Assert.IsTrue(eventFired);
}
```

---

## 3. 테스트를 위한 private → public 변경

### ❌ 안티패턴: 캡슐화 깨짐
```csharp
public class ScoreSystem
{
    // 테스트 위해 public으로 변경
    public int comboCounter;
    public float multiplier;
    public List<int> recentScores;

    public void AddScore(int score) { /* ... */ }
}

// 내부 구현에 의존하는 테스트
[Test]
public void AddScore_UpdatesComboCounter()
{
    var system = new ScoreSystem();
    system.AddScore(100);
    Assert.AreEqual(1, system.comboCounter); // 구현 의존
}
```

### ✅ 행동 테스트
```csharp
public class ScoreSystem
{
    private int comboCounter;
    private float multiplier;

    public int TotalScore { get; private set; }
    public int CurrentCombo => comboCounter; // 필요시 읽기 전용 노출

    public void AddScore(int score) { /* ... */ }
}

// 행동(결과) 테스트
[Test]
public void AddScore_WithConsecutiveHits_AppliesComboBonus()
{
    var system = new ScoreSystem();

    system.AddScore(100);
    system.AddScore(100);
    system.AddScore(100);

    // 결과 검증, 내부 구현 X
    Assert.Greater(system.TotalScore, 300);
}
```

---

## 4. God ScriptableObject

### ❌ 안티패턴: 모든 설정을 하나에
```csharp
[CreateAssetMenu]
public class GameSettings : ScriptableObject
{
    [Header("Player")]
    public int playerMaxHealth;
    public float playerSpeed;
    public float playerJumpForce;

    [Header("Enemy")]
    public int enemyMaxHealth;
    public float enemySpeed;
    public int enemyDamage;

    [Header("Audio")]
    public float masterVolume;
    public float bgmVolume;
    public float sfxVolume;

    [Header("UI")]
    public Color primaryColor;
    public Color secondaryColor;

    [Header("Economy")]
    public int startingGold;
    public float goldMultiplier;

    // 100+ 필드...
}
```

### ✅ 책임별 분리
```csharp
[CreateAssetMenu(menuName = "Config/Player")]
public class PlayerConfig : ScriptableObject
{
    public int maxHealth = 100;
    public float moveSpeed = 5f;
    public float jumpForce = 10f;
}

[CreateAssetMenu(menuName = "Config/Audio")]
public class AudioConfig : ScriptableObject
{
    [Range(0, 1)] public float masterVolume = 1f;
    [Range(0, 1)] public float bgmVolume = 0.8f;
    [Range(0, 1)] public float sfxVolume = 1f;
}

[CreateAssetMenu(menuName = "Config/Economy")]
public class EconomyConfig : ScriptableObject
{
    public int startingGold = 100;
    public float goldMultiplier = 1f;
}

// 필요한 config만 참조
public class Player : MonoBehaviour
{
    [SerializeField] private PlayerConfig config;
    // AudioConfig나 EconomyConfig 필요 없음
}
```

---

## 5. 싱글톤 남용

### ❌ 안티패턴: 모든 것이 싱글톤
```csharp
public class GameManager : MonoBehaviour
{
    public static GameManager Instance;
    void Awake() => Instance = this;
}

public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance;
}

public class UIManager : MonoBehaviour
{
    public static UIManager Instance;
}

// 사용 - 강한 결합, 테스트 불가
public class Player : MonoBehaviour
{
    void OnDeath()
    {
        GameManager.Instance.GameOver();
        AudioManager.Instance.PlaySound("death");
        UIManager.Instance.ShowGameOverScreen();
    }
}
```

### ✅ 이벤트/DI 사용
```csharp
// 이벤트 기반
public class Player : MonoBehaviour
{
    public event Action OnDeath;

    void Die()
    {
        OnDeath?.Invoke(); // 누가 구독하는지 모름
    }
}

// 다른 시스템이 구독
public class GameManager : MonoBehaviour
{
    [SerializeField] private Player player;

    void Start()
    {
        player.OnDeath += HandlePlayerDeath;
    }

    void HandlePlayerDeath()
    {
        // 게임 오버 처리
    }
}

// 테스트 가능
[Test]
public void Player_OnDeath_FiresEvent()
{
    var player = new PlayerLogic();
    bool eventFired = false;
    player.OnDeath += () => eventFired = true;

    player.TakeDamage(1000);

    Assert.IsTrue(eventFired);
}
```

---

## 6. Update에서 모든 것 처리

### ❌ 안티패턴
```csharp
void Update()
{
    // 입력 체크
    if (Input.GetKeyDown(KeyCode.Space)) Jump();

    // 물리 이동 (FixedUpdate에서 해야 함)
    rb.velocity = new Vector2(moveInput * speed, rb.velocity.y);

    // 매 프레임 UI 업데이트 (불필요)
    healthText.text = $"HP: {currentHealth}/{maxHealth}";

    // 매 프레임 거리 계산 (불필요)
    float distToTarget = Vector3.Distance(transform.position, target.position);
    if (distToTarget < 5f) Attack();

    // 매 프레임 애니메이션 파라미터 (불필요)
    animator.SetBool("isRunning", moveInput != 0);
}
```

### ✅ 적절한 분리
```csharp
void Update()
{
    HandleInput(); // 입력만
}

void FixedUpdate()
{
    HandleMovement(); // 물리
}

// 값 변경 시만 UI 업데이트
void OnHealthChanged(int newHealth)
{
    healthText.text = $"HP: {newHealth}/{maxHealth}";
}

// 이벤트 기반 공격
void OnTriggerEnter(Collider other)
{
    if (other.CompareTag("Enemy"))
    {
        Attack();
    }
}

// 값 변경 시만 애니메이션
void SetMoveInput(float input)
{
    if (moveInput != input)
    {
        moveInput = input;
        animator.SetBool("isRunning", input != 0);
    }
}
```

---

## 7. 매직 넘버

### ❌ 안티패턴
```csharp
public void Attack()
{
    if (comboCount >= 5)
    {
        damage *= 1.5f;
    }

    if (currentHealth < 30)
    {
        damage *= 2f; // 분노 모드?
    }

    cooldownTimer = 0.5f;
}
```

### ✅ 명명된 상수
```csharp
private const int ComboThreshold = 5;
private const float ComboMultiplier = 1.5f;
private const int LowHealthThreshold = 30;
private const float RageMultiplier = 2f;
private const float AttackCooldown = 0.5f;

public void Attack()
{
    if (comboCount >= ComboThreshold)
    {
        damage *= ComboMultiplier;
    }

    if (currentHealth < LowHealthThreshold)
    {
        damage *= RageMultiplier;
    }

    cooldownTimer = AttackCooldown;
}
```

---

## 안티패턴 체크리스트

| 항목 | 확인 |
|------|------|
| 인터페이스가 2개 이상 구현체를 가지는가? | □ |
| 테스트가 행동을 검증하는가? | □ |
| private 메서드를 테스트하려고 하지 않았는가? | □ |
| ScriptableObject가 단일 책임을 가지는가? | □ |
| 싱글톤 대신 이벤트/DI를 사용하는가? | □ |
| Update에 최소한의 로직만 있는가? | □ |
| 매직 넘버가 없는가? | □ |
