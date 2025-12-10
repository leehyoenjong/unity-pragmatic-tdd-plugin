# CI/CD Integration Guide

## 개요

CI(Continuous Integration)는 코드 품질을 자동으로 검증합니다. Unity 프로젝트에서 CI는 다음을 자동화합니다:
- 테스트 실행
- 빌드 검증
- 코드 분석

---

## GitHub Actions 설정

### 기본 워크플로우 (.github/workflows/unity-ci.yml)
```yaml
name: Unity CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

env:
  UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
  UNITY_EMAIL: ${{ secrets.UNITY_EMAIL }}
  UNITY_PASSWORD: ${{ secrets.UNITY_PASSWORD }}

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          lfs: true

      - name: Cache Library
        uses: actions/cache@v3
        with:
          path: Library
          key: Library-${{ hashFiles('Assets/**', 'Packages/**', 'ProjectSettings/**') }}
          restore-keys: |
            Library-

      - name: Run Edit Mode Tests
        uses: game-ci/unity-test-runner@v4
        id: editmode
        with:
          githubToken: ${{ secrets.GITHUB_TOKEN }}
          testMode: EditMode
          checkName: Edit Mode Tests

      - name: Run Play Mode Tests
        uses: game-ci/unity-test-runner@v4
        id: playmode
        with:
          githubToken: ${{ secrets.GITHUB_TOKEN }}
          testMode: PlayMode
          checkName: Play Mode Tests

      - name: Upload Test Results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: Test Results
          path: artifacts

  build:
    name: Build
    needs: test
    runs-on: ubuntu-latest
    strategy:
      matrix:
        targetPlatform:
          - StandaloneWindows64
          - Android
          - iOS

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          lfs: true

      - name: Cache Library
        uses: actions/cache@v3
        with:
          path: Library
          key: Library-${{ matrix.targetPlatform }}-${{ hashFiles('Assets/**', 'Packages/**', 'ProjectSettings/**') }}
          restore-keys: |
            Library-${{ matrix.targetPlatform }}-
            Library-

      - name: Build
        uses: game-ci/unity-builder@v4
        with:
          targetPlatform: ${{ matrix.targetPlatform }}
          buildName: MyGame

      - name: Upload Build
        uses: actions/upload-artifact@v3
        with:
          name: Build-${{ matrix.targetPlatform }}
          path: build/${{ matrix.targetPlatform }}
```

---

## Unity 라이선스 설정

### 1. 라이선스 파일 획득
```bash
# 로컬에서 Unity 실행하여 라이선스 파일 생성
# Windows: C:\ProgramData\Unity\Unity_lic.ulf
# Mac: /Library/Application Support/Unity/Unity_lic.ulf
# Linux: ~/.local/share/unity3d/Unity/Unity_lic.ulf
```

### 2. GitHub Secrets 설정
- `UNITY_LICENSE`: Unity_lic.ulf 파일 전체 내용
- `UNITY_EMAIL`: Unity 계정 이메일
- `UNITY_PASSWORD`: Unity 계정 비밀번호

---

## 단계별 CI 구성

### PR용 빠른 체크
```yaml
# .github/workflows/pr-check.yml
name: PR Check

on:
  pull_request:
    branches: [main, develop]

jobs:
  quick-test:
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - uses: actions/checkout@v4

      - name: Edit Mode Tests Only
        uses: game-ci/unity-test-runner@v4
        with:
          testMode: EditMode
          # Play Mode 건너뛰어 시간 절약
```

### 머지 후 전체 테스트
```yaml
# .github/workflows/full-test.yml
name: Full Test Suite

on:
  push:
    branches: [main, develop]

jobs:
  full-test:
    runs-on: ubuntu-latest
    timeout-minutes: 60

    steps:
      - uses: actions/checkout@v4

      - name: All Tests
        uses: game-ci/unity-test-runner@v4
        with:
          testMode: All
          coverageOptions: 'generateAdditionalMetrics;generateHtmlReport'

      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: CodeCoverage/Report/Summary.xml
```

---

## 로컬 테스트 스크립트

### 테스트 실행 스크립트 (scripts/run-tests.sh)
```bash
#!/bin/bash

UNITY_PATH="/Applications/Unity/Hub/Editor/2022.3.0f1/Unity.app/Contents/MacOS/Unity"
PROJECT_PATH="$(pwd)"
RESULTS_PATH="$PROJECT_PATH/TestResults"

mkdir -p "$RESULTS_PATH"

echo "Running Edit Mode Tests..."
"$UNITY_PATH" \
  -batchmode \
  -nographics \
  -projectPath "$PROJECT_PATH" \
  -runTests \
  -testPlatform EditMode \
  -testResults "$RESULTS_PATH/editmode-results.xml" \
  -logFile "$RESULTS_PATH/editmode.log"

EDIT_MODE_RESULT=$?

echo "Running Play Mode Tests..."
"$UNITY_PATH" \
  -batchmode \
  -nographics \
  -projectPath "$PROJECT_PATH" \
  -runTests \
  -testPlatform PlayMode \
  -testResults "$RESULTS_PATH/playmode-results.xml" \
  -logFile "$RESULTS_PATH/playmode.log"

PLAY_MODE_RESULT=$?

if [ $EDIT_MODE_RESULT -ne 0 ] || [ $PLAY_MODE_RESULT -ne 0 ]; then
  echo "Tests failed!"
  exit 1
fi

echo "All tests passed!"
```

---

## Git Hooks

### Pre-commit Hook (.git/hooks/pre-commit)
```bash
#!/bin/bash

echo "Running pre-commit tests..."

UNITY_PATH="/Applications/Unity/Hub/Editor/2022.3.0f1/Unity.app/Contents/MacOS/Unity"

"$UNITY_PATH" \
  -batchmode \
  -nographics \
  -projectPath "$(pwd)" \
  -runTests \
  -testPlatform EditMode \
  -testResults /tmp/test-results.xml \
  -logFile /tmp/unity-test.log

if [ $? -ne 0 ]; then
  echo "❌ Tests failed! Commit aborted."
  exit 1
fi

echo "✅ All tests passed!"
```

### Pre-push Hook (.git/hooks/pre-push)
```bash
#!/bin/bash

echo "Running pre-push tests..."

./scripts/run-tests.sh

if [ $? -ne 0 ]; then
  echo "❌ Tests failed! Push aborted."
  exit 1
fi

echo "✅ All tests passed! Pushing..."
```

---

## 테스트 리포트

### NUnit 결과 파싱
```yaml
- name: Publish Test Results
  uses: EnricoMi/publish-unit-test-result-action@v2
  if: always()
  with:
    files: |
      artifacts/**/*.xml
```

### Slack 알림
```yaml
- name: Notify Slack on Failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: "Unity tests failed! Check the workflow run for details."
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 권장 CI/CD 파이프라인

```
PR 생성
    │
    ▼
┌─────────────────┐
│   Edit Mode     │  (5분)
│   Tests Only    │
└────────┬────────┘
         │ Pass
         ▼
┌─────────────────┐
│  코드 리뷰      │
└────────┬────────┘
         │ Approved
         ▼
Main/Develop 머지
         │
         ▼
┌─────────────────┐
│  Full Test      │  (15분)
│  Suite          │
└────────┬────────┘
         │ Pass
         ▼
┌─────────────────┐
│  Build All      │  (30분)
│  Platforms      │
└────────┬────────┘
         │ Success
         ▼
┌─────────────────┐
│  Deploy to      │
│  TestFlight/    │
│  PlayStore Beta │
└─────────────────┘
```

---

## 트러블슈팅

| 문제 | 해결 |
|------|------|
| 라이선스 오류 | Secrets 확인, 라이선스 재활성화 |
| 메모리 부족 | `-quit` 플래그 추가, runner 스펙 업그레이드 |
| 캐시 미스 | 캐시 키 패턴 확인 |
| 타임아웃 | `timeout-minutes` 증가 |
| LFS 파일 누락 | `lfs: true` 옵션 확인 |
