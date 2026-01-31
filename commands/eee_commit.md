# Git Commit (Git Master Style)

oh-my-opencode의 git-master 로직을 적용한 지능형 커밋 명령어입니다.

## 핵심 원칙

### 원자적 커밋 (Atomic Commits)

**파일 수에 따른 커밋 분리:**
```
3+ 파일 → 최소 2개 커밋
5+ 파일 → 최소 3개 커밋
10+ 파일 → 최소 5개 커밋
```

### 의존성 순서

커밋 순서는 의존성 방향을 따릅니다:
1. 인터페이스/추상 클래스 먼저
2. 구현 클래스
3. 테스트 코드
4. 설정/문서

---

## 지시사항

### Step 1: 변경사항 분석

```bash
# 현재 상태 확인
git status

# 변경 내용 확인
git diff

# 최근 커밋 스타일 분석 (30개)
git log --oneline -30
```

### Step 2: 커밋 스타일 감지

**자동 스타일 감지:**
```
1. 언어 감지: 한국어 vs English
2. 포맷 감지:
   - Conventional Commits (feat:, fix:, ...)
   - Plain (변경사항 설명)
   - Short (한 줄 요약)
3. 이모지 사용 여부
```

### Step 3: 커밋 분리 계획

**변경 파일 분류:**
```
카테고리별 그룹화:
- Core/Interfaces: 인터페이스, 추상 클래스
- Implementation: 구현 클래스
- Tests: 테스트 코드
- Config: 설정 파일
- Docs: 문서
```

**커밋 순서 결정:**
```
1. Core → 2. Implementation → 3. Tests → 4. Config → 5. Docs
```

### Step 4: 커밋 실행

**각 커밋에 대해:**
```bash
# 관련 파일만 스테이징
git add <specific-files>

# 커밋 (HEREDOC 사용)
git commit -m "$(cat <<'EOF'
<type>: <description>

[optional body]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

---

## 커밋 타입

| 타입 | 설명 | 예시 |
|------|------|------|
| `feat` | 새 기능 | feat: 인벤토리 시스템 추가 |
| `fix` | 버그 수정 | fix: 점수 계산 오류 수정 |
| `refactor` | 리팩토링 | refactor: ScoreController 구조 개선 |
| `test` | 테스트 추가/수정 | test: 콤보 시스템 테스트 추가 |
| `docs` | 문서 변경 | docs: README 업데이트 |
| `chore` | 기타 변경 | chore: 패키지 업데이트 |
| `style` | 코드 스타일 | style: 포맷팅 수정 |
| `perf` | 성능 개선 | perf: 렌더링 최적화 |

## Unity 특화 태그 (선택)

- `[TESTED]` - 테스트된 코드
- `[VISUAL]` - 시각적 요소 (UI, 애니메이션)
- `[WIP]` - 작업 중
- `[BREAKING]` - 호환성 깨는 변경

---

## 예시: 원자적 커밋

### 상황: 8개 파일 변경

```
변경된 파일:
1. IInventoryService.cs (인터페이스)
2. InventoryService.cs (구현)
3. InventoryController.cs (컨트롤러)
4. InventoryValidator.cs (검증)
5. InventoryServiceTests.cs (테스트)
6. InventoryControllerTests.cs (테스트)
7. inventory-config.json (설정)
8. CHANGELOG.md (문서)
```

### 커밋 분리 (최소 4개)

```bash
# 커밋 1: 인터페이스
git add IInventoryService.cs
git commit -m "feat(inventory): add IInventoryService interface"

# 커밋 2: 구현
git add InventoryService.cs InventoryController.cs InventoryValidator.cs
git commit -m "feat(inventory): implement inventory service and controller"

# 커밋 3: 테스트
git add *Tests.cs
git commit -m "test(inventory): add unit tests for inventory system"

# 커밋 4: 설정 및 문서
git add inventory-config.json CHANGELOG.md
git commit -m "chore(inventory): add config and update changelog"
```

---

## 스타일 감지 예시

### 한국어 + Conventional
```
git log 분석 결과:
- feat: 인벤토리 시스템 추가
- fix: 점수 계산 버그 수정
- refactor: 코드 구조 개선

→ 감지된 스타일: 한국어, Conventional Commits
→ 새 커밋도 동일 스타일 적용
```

### 영어 + Plain
```
git log 분석 결과:
- Add inventory system
- Fix score calculation bug
- Improve code structure

→ 감지된 스타일: English, Plain
→ 새 커밋도 동일 스타일 적용
```

---

## 금지 사항

- ❌ 3개 이상 파일을 단일 커밋에 포함 (특수 상황 제외)
- ❌ 테스트와 구현을 같은 커밋에 포함
- ❌ 민감한 파일 (.env, credentials) 커밋
- ❌ 커밋 전 변경사항 미확인
- ❌ force push (특수 상황 제외)

## 허용 예외

다음 경우 단일 커밋 허용:
- 긴밀하게 연결된 2-3개 파일
- 오타 수정 등 사소한 변경
- 사용자 명시적 요청

---

## 자동 분리 기준

### 분리하는 경우
```
1. 파일 유형이 다름 (인터페이스 vs 구현 vs 테스트)
2. 기능 영역이 다름 (서로 다른 시스템)
3. 변경 성격이 다름 (기능 추가 vs 버그 수정 vs 리팩토링)
```

### 합치는 경우
```
1. 동일 기능의 긴밀한 변경
2. 분리 시 빌드 실패
3. 의미 단위로 묶여야 하는 경우
```

---

## 출력 형식

### 분석 결과
```markdown
## 커밋 분석

### 변경 파일 (8개)
- Core: 1개
- Implementation: 3개
- Tests: 2개
- Config: 1개
- Docs: 1개

### 스타일 감지
- 언어: 한국어
- 포맷: Conventional Commits

### 커밋 계획 (4개)
1. `feat(inventory): add IInventoryService interface` (1 file)
2. `feat(inventory): implement inventory service` (3 files)
3. `test(inventory): add unit tests` (2 files)
4. `chore(inventory): update config and docs` (2 files)

진행할까요? [Y/n]
```

---

## 연관 명령어

| 명령어 | 용도 |
|-------|------|
| `/eee_precommit` | 커밋 전 검증 |
| `/eee_sync` | 원격 동기화 |
| `/eee_review` | 코드 리뷰 |
