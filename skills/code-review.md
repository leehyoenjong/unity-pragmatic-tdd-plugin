# Code Review Skill

이 skill은 코드 리뷰 시 안티패턴을 검토하고 개선점을 제안합니다.

---

## 안티패턴 체크리스트

### 1. 과도한 추상화
```csharp
// ❌ 단일 구현체를 위한 인터페이스
public interface IPlayerMovement { void Move(Vector3 dir); }
public interface IPlayerJump { void Jump(); }
public interface IPlayerHealth { void TakeDamage(int amount); }
// 6개 인터페이스를 구현하는 Player...

// ✅ 확장 가능성 있는 것만 추상화
public class Player : MonoBehaviour
{
    private List<IStatModifier> modifiers; // 버프, 장비, 펫 등 여러 구현
    private List<ISkill> skills;           // 다양한 스킬 구현

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

### 2. 테스트를 위한 테스트
```csharp
// ❌ 무의미한 테스트
[Test]
public void Player_Name_ReturnsName()
{
    var player = new Player { Name = "Test" };
    Assert.AreEqual("Test", player.Name); // getter만 테스트
}

[Test]
public void Player_Constructor_CreatesInstance()
{
    var player = new Player();
    Assert.IsNotNull(player); // 생성자만 테스트
}

// ✅ 의미 있는 테스트
[Test]
public void Player_TakeDamage_AppliesArmorReduction()
{
    var player = new Player(health: 100, armor: 50);
    player.TakeDamage(100);
    Assert.AreEqual(50, player.CurrentHealth); // 비즈니스 로직 테스트
}
```

---

### 3. 테스트를 위한 private → public 변경
```csharp
// ❌ 캡슐화 깨짐
public class ScoreSystem
{
    public int comboCounter;  // 테스트 위해 public으로 변경
    public float multiplier;
}

// ✅ 행동을 테스트
public class ScoreSystem
{
    private int comboCounter;
    public int TotalScore { get; private set; }

    public void AddScore(int score) { }
}

[Test]
public void AddScore_WithConsecutiveHits_AppliesComboBonus()
{
    var system = new ScoreSystem();
    system.AddScore(100);
    system.AddScore(100);
    system.AddScore(100);
    Assert.Greater(system.TotalScore, 300); // 결과 검증, 내부 구현 X
}
```

---

### 4. God ScriptableObject
```csharp
// ❌ 모든 설정을 하나에
[CreateAssetMenu]
public class GameSettings : ScriptableObject
{
    [Header("Player")]
    public int playerMaxHealth;
    public float playerSpeed;

    [Header("Enemy")]
    public int enemyMaxHealth;

    [Header("Audio")]
    public float masterVolume;

    // 100+ 필드...
}

// ✅ 책임별 분리
[CreateAssetMenu(menuName = "Config/Player")]
public class PlayerConfig : ScriptableObject
{
    public int maxHealth = 100;
    public float moveSpeed = 5f;
}

[CreateAssetMenu(menuName = "Config/Audio")]
public class AudioConfig : ScriptableObject
{
    [Range(0, 1)] public float masterVolume = 1f;
}
```

---

### 5. 싱글톤 남용
```csharp
// ❌ 모든 것이 싱글톤
public class GameManager : MonoBehaviour
{
    public static GameManager Instance;
}
public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance;
}

// 사용 - 강한 결합, 테스트 불가
public class Player : MonoBehaviour
{
    void OnDeath()
    {
        GameManager.Instance.GameOver();
        AudioManager.Instance.PlaySound("death");
    }
}

// ✅ 이벤트/DI 사용
public class Player : MonoBehaviour
{
    public event Action OnDeath;

    void Die()
    {
        OnDeath?.Invoke(); // 누가 구독하는지 모름
    }
}

public class GameManager : MonoBehaviour
{
    [SerializeField] private Player player;

    void Start()
    {
        player.OnDeath += HandlePlayerDeath;
    }
}
```

---

### 6. Update에서 모든 것 처리
```csharp
// ❌ 안티패턴
void Update()
{
    if (Input.GetKeyDown(KeyCode.Space)) Jump();

    // 물리 이동 (FixedUpdate에서 해야 함)
    rb.velocity = new Vector2(moveInput * speed, rb.velocity.y);

    // 매 프레임 UI 업데이트 (불필요)
    healthText.text = $"HP: {currentHealth}/{maxHealth}";

    // 매 프레임 거리 계산 (불필요)
    float dist = Vector3.Distance(transform.position, target.position);
}

// ✅ 적절한 분리
void Update()
{
    HandleInput(); // 입력만
}

void FixedUpdate()
{
    HandleMovement(); // 물리
}

void OnHealthChanged(int newHealth)
{
    healthText.text = $"HP: {newHealth}/{maxHealth}"; // 변경 시만
}
```

---

### 7. 매직 넘버
```csharp
// ❌ 매직 넘버
public void Attack()
{
    if (comboCount >= 5)
        damage *= 1.5f;

    if (currentHealth < 30)
        damage *= 2f;

    cooldownTimer = 0.5f;
}

// ✅ 명명된 상수
private const int ComboThreshold = 5;
private const float ComboMultiplier = 1.5f;
private const int LowHealthThreshold = 30;
private const float RageMultiplier = 2f;
private const float AttackCooldown = 0.5f;

public void Attack()
{
    if (comboCount >= ComboThreshold)
        damage *= ComboMultiplier;

    if (currentHealth < LowHealthThreshold)
        damage *= RageMultiplier;

    cooldownTimer = AttackCooldown;
}
```

---

## 리뷰 체크리스트

| 항목 | 확인 |
|------|------|
| 인터페이스가 2개 이상 구현체를 가지는가? | □ |
| 테스트가 행동을 검증하는가? | □ |
| private 메서드를 테스트하려고 하지 않았는가? | □ |
| ScriptableObject가 단일 책임을 가지는가? | □ |
| 싱글톤 대신 이벤트/DI를 사용하는가? | □ |
| Update에 최소한의 로직만 있는가? | □ |
| 매직 넘버가 없는가? | □ |

---

## 커밋 규칙

### 커밋 시점
1. **테스트된 코드**: 모든 테스트 통과 AND 경고 없음
2. **시각적 기능**: 기능 작동 AND Play Mode에서 테스트
3. **프로토타입**: 핵심 메카닉 시연 가능

### 커밋 메시지
- `feat(logic): Add combo calculation [TESTED]`
- `feat(visual): Add jump animation [VISUAL]`
- `refactor: Extract game state logic for testability`
- `refactor: Apply OCP to stat system`
- `test: Add tests for existing save system`
- `fix: Correct pet stat calculation [TESTED]`
