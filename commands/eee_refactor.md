# /eee_refactor - 지능형 리팩토링

LSP, AST-grep, 아키텍처 분석을 활용한 안전한 리팩토링 명령어입니다.

## 사용법

```
/eee_refactor <대상>
/eee_refactor <대상> --scope=<file|module|project>
/eee_refactor <대상> --strategy=<safe|aggressive>
```

## 예시

```
/eee_refactor PlayerController
/eee_refactor InventorySystem --scope=module
/eee_refactor "모든 Manager 클래스" --strategy=aggressive
```

---

## 리팩토링 단계

```
1. 분석 단계
   ↓ 대상 코드 읽기 및 구조 파악
2. 영향 분석
   ↓ 의존성, 참조, 테스트 영향도 확인
3. 계획 수립
   ↓ 📍 체크포인트 - 사용자 확인
4. 안전 장치 설정
   ↓ 테스트 실행, 백업 포인트
5. 리팩토링 실행
   ↓ 단계별 변경
6. 검증
   ↓ 테스트, 컴파일 체크
7. 완료 보고
```

---

## 전략 옵션

### safe (기본값)
- 작은 변경만 수행
- 매 변경 후 검증
- 실패 시 즉시 롤백

### aggressive
- 대규모 변경 허용
- 배치 변경 후 검증
- 사용자 확인 필수

---

## 실행 지시사항

### Step 1: 대상 분석

```
1. 대상 파일/클래스 식별
2. 현재 구조 분석
   - 클래스 계층
   - 메서드 목록
   - 의존성 그래프

3. 문제점 식별
   - SOLID 위반
   - 코드 냄새
   - 복잡도 이슈
```

### Step 2: 영향 분석

```
1. 참조 검색 (Grep/Glob 사용)
   - 이 클래스를 사용하는 파일들
   - 상속/구현 관계

2. 테스트 영향
   - 관련 테스트 파일
   - 테스트 커버리지

3. 위험도 평가
   - Low: 단일 파일, 내부 변경
   - Medium: 다중 파일, 인터페이스 변경
   - High: 공용 API 변경, 대규모 수정
```

### Step 3: 리팩토링 계획

```markdown
## 리팩토링 계획: [대상]

### 현재 상태
- [문제점 요약]

### 목표 상태
- [개선 후 구조]

### 변경 사항
1. [변경 1]
2. [변경 2]
3. [변경 3]

### 영향받는 파일
- [파일 목록]

### 위험도: [Low/Medium/High]

### 예상 테스트 영향
- [테스트 변경 필요 여부]
```

📍 **체크포인트: 계획 승인**
- ✅ 진행
- 🔍 더 꼼꼼히 검토
- ✏️ 수정 요청

### Step 4: 안전 장치

```
1. 현재 상태 기록
   - git status 확인
   - 변경 전 스냅샷

2. 테스트 실행 (가능한 경우)
   - 현재 테스트 상태 확인
   - 기준선 설정

3. 롤백 계획 준비
```

### Step 5: 리팩토링 실행

**Unity C# 특화 패턴:**

```csharp
// 1. 인터페이스 추출
public interface IPlayerController {
    void Move(Vector3 direction);
}

// 2. 의존성 주입 적용
public class PlayerController : MonoBehaviour, IPlayerController {
    private readonly IInputHandler _inputHandler;

    public void Initialize(IInputHandler inputHandler) {
        _inputHandler = inputHandler;
    }
}

// 3. Pure C# 분리
public class PlayerLogic {
    // 테스트 가능한 순수 로직
}
```

**변경 순서:**
1. 인터페이스 추출 (OCP 준비)
2. 의존성 분리
3. Pure C# 로직 추출
4. MonoBehaviour 최소화
5. 테스트 추가

### Step 6: 검증

```
1. 컴파일 체크
   - 모든 파일 빌드 확인

2. 테스트 실행
   - 기존 테스트 통과 확인
   - 새 테스트 추가 (필요시)

3. 코드 품질 확인
   - SOLID 준수 여부
   - 복잡도 개선 여부
```

### Step 7: 완료 보고

```markdown
## 리팩토링 완료: [대상]

### 변경 요약
- 변경된 파일: N개
- 추가된 파일: N개
- 삭제된 파일: N개

### 개선 사항
- [개선 1]
- [개선 2]

### 테스트 결과
- 통과: N개
- 실패: N개 (사유)

### 다음 단계 권장
- [ ] 통합 테스트 확인
- [ ] 코드 리뷰 요청
- [ ] 문서 업데이트
```

---

## 리팩토링 패턴 (Unity 특화)

### 1. MonoBehaviour → Pure C# 분리

**Before:**
```csharp
public class GameManager : MonoBehaviour {
    public void CalculateScore() { /* 복잡한 로직 */ }
}
```

**After:**
```csharp
// Pure C# - 테스트 가능
public class ScoreCalculator {
    public int Calculate() { /* 로직 */ }
}

// MonoBehaviour - 최소화
public class GameManager : MonoBehaviour {
    private ScoreCalculator _calculator = new();
    public int Score => _calculator.Calculate();
}
```

### 2. God Class 분할

**신호:**
- 500줄 이상
- 5개 이상 책임
- 10개 이상 의존성

**접근:**
1. 책임 식별
2. 인터페이스 추출
3. 클래스 분리
4. 조합 패턴 적용

### 3. 조건문 → 다형성

**Before:**
```csharp
switch (type) {
    case "A": DoA(); break;
    case "B": DoB(); break;
}
```

**After:**
```csharp
public interface IHandler { void Handle(); }
public class HandlerA : IHandler { public void Handle() { } }
public class HandlerB : IHandler { public void Handle() { } }
```

---

## 주의사항

### Beta/Live 단계에서
- ⚠️ 경고 표시 필수
- 영향 분석 철저히
- 롤백 계획 준비
- Oracle 상담 권장

### 절대 하지 않을 것
- 동작하는 테스트 삭제
- 공용 API 무단 변경
- 검증 없이 대규모 수정

---

## 연관 명령어

| 명령어 | 용도 |
|-------|------|
| `/eee_review` | 리팩토링 전 코드 리뷰 |
| `/eee_tdd` | 리팩토링 후 테스트 보강 |
| `/eee_commit` | 리팩토링 커밋 |
