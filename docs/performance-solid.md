# Performance Considerations for SOLID

## 핵심 원칙
> "SOLID는 설계 원칙이지, 모든 코드에 적용할 규칙이 아니다"

게임 개발에서는 **성능이 우선**입니다. 매 프레임 실행되는 코드(Update, FixedUpdate)에 SOLID 적용 시 주의하세요.

---

## GC 할당 문제

### ❌ 문제: 인터페이스와 제네릭 컬렉션
```csharp
public class StatSystem
{
    private List<IStatModifier> modifiers; // 힙 할당

    // ❌ 매 프레임 호출 시 GC 압박
    public int GetAttack()
    {
        int value = baseAttack;
        foreach (var mod in modifiers) // 잠재적 박싱
        {
            value += mod.GetModifier(StatType.Attack);
        }
        return value;
    }
}
```

### ✅ 해결 1: 값 캐싱
```csharp
public class StatSystem
{
    private List<IStatModifier> modifiers;

    // 캐시된 값
    private Dictionary<StatType, int> cachedStats = new();
    private bool isDirty = true;

    public int GetStat(StatType type)
    {
        if (isDirty)
        {
            RecalculateAllStats(); // 변경 시에만 계산
            isDirty = false;
        }
        return cachedStats[type];
    }

    public void AddModifier(IStatModifier modifier)
    {
        modifiers.Add(modifier);
        isDirty = true; // 다음 조회 시 재계산
    }

    public void RemoveModifier(IStatModifier modifier)
    {
        modifiers.Remove(modifier);
        isDirty = true;
    }

    private void RecalculateAllStats()
    {
        foreach (StatType type in Enum.GetValues(typeof(StatType)))
        {
            int value = GetBaseStat(type);
            foreach (var mod in modifiers)
            {
                value += mod.GetModifier(type);
            }
            cachedStats[type] = value;
        }
    }
}
```

### ✅ 해결 2: struct와 제네릭 (박싱 방지)
```csharp
// 인터페이스 대신 struct 사용
public readonly struct StatModifier
{
    public readonly StatType Type;
    public readonly int FlatBonus;
    public readonly float PercentBonus;

    public StatModifier(StatType type, int flat, float percent)
    {
        Type = type;
        FlatBonus = flat;
        PercentBonus = percent;
    }
}

public class StatSystem
{
    // struct 배열 - 힙 할당 최소화
    private StatModifier[] modifiers;
    private int modifierCount;

    public void AddModifier(in StatModifier modifier) // 'in'으로 복사 방지
    {
        if (modifierCount >= modifiers.Length)
        {
            // 배열 확장 (드물게 발생)
            Array.Resize(ref modifiers, modifiers.Length * 2);
        }
        modifiers[modifierCount++] = modifier;
        isDirty = true;
    }
}
```

---

## Hot Path 최적화

**Hot Path**: 매 프레임 또는 매우 자주 실행되는 코드

### ❌ Hot Path에서 피해야 할 패턴
```csharp
void Update()
{
    // ❌ 매 프레임 인터페이스 순회
    foreach (var modifier in statModifiers)
    {
        currentAttack += modifier.GetModifier();
    }

    // ❌ 매 프레임 LINQ 사용
    var activeBuffs = buffs.Where(b => b.IsActive).ToList();

    // ❌ 매 프레임 문자열 연결
    debugText = "HP: " + currentHp + "/" + maxHp;

    // ❌ 매 프레임 GetComponent
    var rb = GetComponent<Rigidbody>();
}
```

### ✅ Hot Path 최적화 패턴
```csharp
public class OptimizedPlayer : MonoBehaviour
{
    // 컴포넌트 캐싱
    private Rigidbody rb;
    private StatSystem stats;

    // 값 캐싱
    private int cachedAttack;
    private StringBuilder debugBuilder = new();

    void Awake()
    {
        rb = GetComponent<Rigidbody>();
        stats = new StatSystem();
        stats.OnStatsChanged += OnStatsChanged; // 이벤트 구독
    }

    void OnStatsChanged()
    {
        // 스탯 변경 시에만 캐시 업데이트
        cachedAttack = stats.GetStat(StatType.Attack);
    }

    void Update()
    {
        // ✅ 캐시된 값 사용
        PerformAttack(cachedAttack);

        // ✅ StringBuilder 재사용
        debugBuilder.Clear();
        debugBuilder.Append("HP: ");
        debugBuilder.Append(currentHp);
        debugBuilder.Append("/");
        debugBuilder.Append(maxHp);
    }
}
```

---

## SOLID와 함께 오브젝트 풀링

### OCP 유지하면서 풀링 적용
```csharp
// 풀링 가능한 객체 인터페이스
public interface IPoolable
{
    void OnSpawn();
    void OnDespawn();
}

// 제네릭 오브젝트 풀
public class ObjectPool<T> where T : class, IPoolable, new()
{
    private readonly Stack<T> pool = new();
    private readonly int maxSize;

    public ObjectPool(int initialSize, int maxSize = 100)
    {
        this.maxSize = maxSize;
        for (int i = 0; i < initialSize; i++)
        {
            pool.Push(new T());
        }
    }

    public T Get()
    {
        T item = pool.Count > 0 ? pool.Pop() : new T();
        item.OnSpawn();
        return item;
    }

    public void Return(T item)
    {
        item.OnDespawn();
        if (pool.Count < maxSize)
        {
            pool.Push(item);
        }
    }
}

// 사용 예시
public class Bullet : IPoolable
{
    public Vector3 Position;
    public Vector3 Velocity;
    public bool IsActive;

    public void OnSpawn()
    {
        IsActive = true;
    }

    public void OnDespawn()
    {
        IsActive = false;
        Position = Vector3.zero;
        Velocity = Vector3.zero;
    }
}

public class BulletManager
{
    private ObjectPool<Bullet> bulletPool = new(50, 200);

    public Bullet SpawnBullet(Vector3 pos, Vector3 velocity)
    {
        var bullet = bulletPool.Get();
        bullet.Position = pos;
        bullet.Velocity = velocity;
        return bullet;
    }

    public void DespawnBullet(Bullet bullet)
    {
        bulletPool.Return(bullet);
    }
}
```

---

## 성능 측정 도구

### 간단한 성능 프로파일러
```csharp
public static class PerformanceProfiler
{
    private static Dictionary<string, System.Diagnostics.Stopwatch> watches = new();

    [System.Diagnostics.Conditional("UNITY_EDITOR")]
    public static void BeginSample(string name)
    {
        if (!watches.ContainsKey(name))
        {
            watches[name] = new System.Diagnostics.Stopwatch();
        }
        watches[name].Restart();
    }

    [System.Diagnostics.Conditional("UNITY_EDITOR")]
    public static void EndSample(string name)
    {
        if (watches.TryGetValue(name, out var watch))
        {
            watch.Stop();
            if (watch.ElapsedMilliseconds > 1) // 1ms 초과 시 경고
            {
                Debug.LogWarning($"[Perf] {name}: {watch.ElapsedMilliseconds}ms");
            }
        }
    }
}

// 사용
void Update()
{
    PerformanceProfiler.BeginSample("StatCalculation");
    RecalculateStats();
    PerformanceProfiler.EndSample("StatCalculation");
}
```

### Unity Profiler 마커
```csharp
using Unity.Profiling;

public class StatSystem
{
    private static readonly ProfilerMarker s_GetStatMarker =
        new ProfilerMarker("StatSystem.GetStat");

    public int GetStat(StatType type)
    {
        using (s_GetStatMarker.Auto())
        {
            return CalculateStat(type);
        }
    }
}
```

---

## SOLID vs 성능 결정 매트릭스

| 상황 | SOLID 적용 | 성능 최적화 | 권장 |
|------|-----------|-------------|------|
| 매 프레임 (Update) | ⚠️ 신중하게 | ✅ 우선 | 캐싱 + 단순화 |
| 이벤트 기반 (OnClick) | ✅ 적극적 | ❌ 불필요 | SOLID 우선 |
| 초기화 (Awake/Start) | ✅ 적극적 | ❌ 불필요 | SOLID 우선 |
| 게임 로직 (점수, 스탯) | ✅ 적극적 | ⚠️ 캐싱 고려 | SOLID + 캐싱 |
| 물리 계산 | ⚠️ 최소화 | ✅ 우선 | 단순화 우선 |
| AI 로직 | ✅ OCP 중요 | ⚠️ 주기적 실행 | Job System 고려 |

---

## 권장 패턴 요약

```csharp
// ✅ 권장: 계층 분리 + 캐싱
public class Player : MonoBehaviour
{
    // 순수 로직 (SOLID 적용)
    private StatSystem stats;

    // 캐시 (성능 최적화)
    private int cachedDamage;
    private float cachedSpeed;

    void Awake()
    {
        stats = new StatSystem();
        stats.OnChanged += RefreshCache;
    }

    void RefreshCache()
    {
        cachedDamage = stats.GetStat(StatType.Attack);
        cachedSpeed = stats.GetStat(StatType.Speed) / 100f;
    }

    void Update()
    {
        // Hot path에서는 캐시된 값만 사용
        transform.Translate(Vector3.right * cachedSpeed * Time.deltaTime);
    }

    void OnAttack()
    {
        // 이벤트에서는 시스템 직접 호출 OK
        int finalDamage = stats.CalculateDamageWithModifiers(cachedDamage);
        DealDamage(finalDamage);
    }
}
```
