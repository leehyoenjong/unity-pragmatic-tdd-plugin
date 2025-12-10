# PROJECT_CONTEXT.md Template

PROJECT_CONTEXT.md 생성 시 이 템플릿을 사용하세요:

```markdown
# PROJECT_CONTEXT.md

## Project Information
- Project Name: [이름]
- Created: [날짜]
- Current Stage: [Prototype/Alpha/Beta/Live]
- Stage Start Date: [날짜]

## Current Stage Details

### [현재 단계] Stage (Started: [날짜])

**Stage Transition History:**
- Prototype: [날짜] ~ [날짜]
- Alpha: [날짜] ~ [날짜] (Current)
- Beta: [예정일]
- Live: [예정일]

**Refactoring Status:**
- [ ] Initial prototype cleanup (Alpha entry)
- [ ] SOLID applied to core systems
- [ ] Test coverage >40%

## TDD Application by Feature Type

### Confirmed Core Features (TDD 80-100%)
- Score/Combo calculation system
- Save/Load system
- [추가 확정 기능]

### Experimental Features (TDD 20-40%)
- Gameplay balancing
- [추가 실험적 기능]

### Visual Elements (TDD 0-10%)
- UI Layout
- Animations
- Effects

## SOLID Design Implementation

### Systems with OCP Applied:
- [x] StatSystem (has IStatModifier extension point)
- [x] SkillSystem (has ISkill interface)
- [ ] ItemSystem (planned)

### Extension Points Available:
```csharp
// StatSystem
public void AddModifier(IStatModifier modifier)

// SkillSystem
public void AddSkill(ISkill skill)
```

### Systems Needing SOLID:
- [ ] CombatSystem (needs strategy pattern)
- [ ] ItemSystem (needs OCP)

## Feature Addition Safety Check

### Beta Stage Safety Criteria:
When a new feature is requested in Beta, check ALL of these:

1. ✅ Uses existing system structure?
2. ✅ Modifies <10 files?
3. ✅ No data structure changes?
4. ✅ Can complete in 1 week?
5. ✅ Easy to rollback?

**All ✅**: Safe to add
**Any ❌**: Recommend deferring

### Examples of Safe Features:
- New stages/levels
- New items (using existing ItemSystem)
- New skills (using existing SkillSystem)
- Visual variations

### Examples of Risky Features:
- Multiplayer mode
- Character class system
- Complete economy redesign

## Code Organization
```
Scripts/
├── Core/              # Pure C# - Full TDD
│   ├── StatSystem.cs (OCP applied)
│   ├── SkillSystem.cs (OCP applied)
│   └── SaveSystem.cs
├── GamePlay/          # MonoBehaviour - Selective
│   ├── PlayerController.cs
│   └── EnemyAI.cs
└── Tests/
    └── Core/          # Tests for Core only
```

## Scheduled Refactoring

### Alpha Stage:
- Sprint end: 1-2 days refactoring
- Mid-Alpha review: [Date] - 3 days
- Beta entry: [Date] - 1 week cleanup

### Beta Stage:
- Only for critical bugs
- No structural changes

## Update History
- [Date]: Initial file creation
- [Date]: Transitioned to Alpha stage
- [Date]: Applied OCP to StatSystem

---
Update this file when:
- Stage transitions
- New extension points added
- Major refactoring completed
- Feature safety assessments change

Use command: "Update PROJECT_CONTEXT" when needed.
```
