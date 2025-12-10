# SOLID Review Skill

이 skill은 코드에 SOLID 원칙을 검토하고 적용할 때 사용합니다.

---

## OCP (Open-Closed Principle) - 가장 중요!

**"확장에는 열려있고, 수정에는 닫혀있어야 한다"**

Beta/Live 단계에서 안전하게 기능을 추가하는 핵심입니다.

```csharp
// ❌ OCP 위반 - Beta에서 펫 추가 불가
public class Player
{
    public void CalculateDamage()
    {
        damage = attack + weapon.bonus;
        // 펫 추가하려면 이 코드 수정 필요
    }
}

// ✅ OCP 준수 - Beta에서 펫 추가 가능
public class Player
{
    private List<IDamageModifier> modifiers; // 확장 포인트

    public void CalculateDamage()
    {
        damage = attack;
        foreach (var mod in modifiers)
        {
            damage += mod.GetBonus();
        }
    }
    // 펫 추가? modifiers.Add(pet)만 하면 됨
}
```

### OCP 필수 적용 시스템

1. **스탯/능력치 시스템**
```csharp
public class StatSystem
{
    private Dictionary<StatType, int> baseStats;
    private List<IStatModifier> modifiers; // 확장 포인트!

    public int GetStat(StatType type)
    {
        int value = baseStats[type];
        foreach (var modifier in modifiers)
        {
            value += modifier.GetModifier(type);
        }
        return value;
    }

    public void AddModifier(IStatModifier modifier)
    {
        modifiers.Add(modifier);
    }
}

// Beta에서 펫 추가 - StatSystem 수정 없음
public class Pet : IStatModifier
{
    public int GetModifier(StatType type)
    {
        if (type == StatType.Attack) return 5;
        return 0;
    }
}
```

2. **스킬/액션 시스템**
```csharp
public class SkillSystem
{
    private List<ISkill> skills; // 확장 포인트!

    public void UseSkill(int index)
    {
        if (index < skills.Count)
            skills[index].Execute();
    }

    public void AddSkill(ISkill skill)
    {
        skills.Add(skill);
    }
}
```

3. **아이템/장비 시스템**
```csharp
public interface IItem
{
    string Id { get; }
    void Use(Player player);
}

public class ItemDatabase
{
    private Dictionary<string, IItem> items; // 확장 포인트!

    public void RegisterItem(IItem item)
    {
        items[item.Id] = item;
    }
}
```

---

## SRP (Single Responsibility Principle)

**"한 클래스는 하나의 책임만 가져야 한다"**

```csharp
// ❌ SRP 위반 - Player가 모든 것을 함
public class Player : MonoBehaviour
{
    public int hp, attack, defense;
    public void Move() { }
    public void Attack() { }
    public void TakeDamage() { }
    public void SaveData() { }
    public void LoadData() { }
    public void UpdateUI() { }
}

// ✅ SRP 준수 - 책임 분리
public class Player : MonoBehaviour
{
    private StatSystem stats;        // 스탯만
    private CombatSystem combat;     // 전투만
    private MovementController movement; // 이동만
}

public class SaveSystem
{
    public void Save(GameData data) { }
    public GameData Load() { }
}
```

---

## DIP (Dependency Inversion Principle)

**"구체 클래스가 아닌 추상화에 의존하라"**

```csharp
// ❌ DIP 위반
public class Player
{
    private Sword sword; // 구체 클래스 의존

    public void Attack()
    {
        damage = sword.GetDamage();
    }
}

// ✅ DIP 준수
public class Player
{
    private IWeapon weapon; // 추상화 의존

    public void Attack()
    {
        damage = weapon.GetDamage();
    }
}

// Beta에서 펫을 무기로 추가 가능 - Player 수정 없음
public class Pet : IWeapon
{
    public int GetDamage() => 5;
}
```

---

## LSP (Liskov Substitution Principle)

**"자식 클래스는 부모 클래스를 대체할 수 있어야 한다"**

```csharp
// ❌ LSP 위반
public class Bird
{
    public virtual void Fly() { }
}

public class Penguin : Bird
{
    public override void Fly()
    {
        throw new NotSupportedException(); // 부모 대체 불가
    }
}

// ✅ LSP 준수
public interface IFlyable
{
    void Fly();
}

public class Bird { }
public class Sparrow : Bird, IFlyable { public void Fly() { } }
public class Penguin : Bird { } // 날지 않음
```

---

## ISP (Interface Segregation Principle)

**"클라이언트가 사용하지 않는 인터페이스에 의존하면 안 된다"**

```csharp
// ❌ ISP 위반
public interface ICharacter
{
    void Move();
    void Attack();
    void CastSpell();
    void Heal();
}

public class Warrior : ICharacter
{
    public void CastSpell() { } // 사용 안 함
    public void Heal() { } // 사용 안 함
}

// ✅ ISP 준수
public interface IMovable { void Move(); }
public interface IAttacker { void Attack(); }
public interface ISpellCaster { void CastSpell(); }

public class Warrior : IMovable, IAttacker { }
public class Mage : IMovable, ISpellCaster { }
```

---

## SOLID 적용 시점

### Alpha에서 SOLID 적용
- 확장 가능성 있는 시스템 (스탯, 스킬, 아이템)
- 핵심 게임 메카닉
- 재사용 시스템

### 단순하게 유지
- 거의 변경되지 않는 기본 메카닉 (기본 이동)
- 게임 플로우 제어
- 간단한 UI 요소

### 균형이 핵심
```csharp
// ❌ 과도한 추상화
public interface IJumpable { }
public interface IMoveable { }
public interface IDamageable { }
// 20개 인터페이스... 이 클래스가 뭘 하는지 알 수 없음

// ✅ 적절한 추상화
public class Player
{
    // 확장될 시스템 → 추상화
    private List<IStatModifier> statModifiers; // OCP
    private List<ISkill> skills; // OCP

    // 거의 변경 안 됨 → 단순하게
    private int level;
    private string name;
    private float moveSpeed;
}
```

---

## SOLID 체크리스트

| 항목 | 확인 |
|------|------|
| 인터페이스가 2개 이상 구현체를 가지는가? | □ |
| 확장 포인트가 적절히 마련되었는가? | □ |
| 각 클래스가 하나의 책임만 가지는가? | □ |
| 추상화에 의존하고 있는가? | □ |
| 인터페이스가 너무 크지 않은가? | □ |
