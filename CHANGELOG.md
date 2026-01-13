# Changelog

모든 주요 변경사항을 기록합니다.

형식은 [Keep a Changelog](https://keepachangelog.com/ko/1.0.0/)를 따르며,
버전 관리는 [Semantic Versioning](https://semver.org/lang/ko/)을 따릅니다.

---

## [1.2.0] - 2026-01-13

### Added
- **병렬 구현 시스템**: 개발 에이전트 구조 전면 개편
  - `lead-architect`: 설계 총괄 + 작업 분배 + 코드 검토 + 최종 통합
  - `implementer-1`, `implementer-2`, `implementer-3`: 병렬 구현자 (동시 실행)

- **`/feature` 슬래시 명령어**: 시스템 생성 전용 명령어
  ```bash
  /feature Inventory
  /feature Combat "데미지 계산, 크리티컬, 버프/디버프"
  ```

- **리드-구현자 워크플로우**:
  ```
           ┌─ implementer-1 (클래스A + 테스트) ─┐
  lead ────┼─ implementer-2 (클래스B + 테스트) ─┼──→ lead (검토) ──→ 통합
           └─ implementer-3 (클래스C + 테스트) ─┘
                병렬 실행 (속도 3배)
  ```

- **코드 검토 + 재작업 루프**: lead-architect가 검토 후 문제 발견 시 해당 implementer에게 재작업 요청

### Changed
- **개발 에이전트 구조 변경**:
  - `architect` → `lead-architect` (역할 확장: 설계 + 검토 + 통합)
  - `implementer` → `implementer-1`, `implementer-2`, `implementer-3` (병렬화)

- **new-system.md 파이프라인**: 순차 실행 → 병렬 실행으로 개선
  - 컨텍스트 효율: 기존 대비 ~85% 절약
  - 구현 속도: 순차 대비 3배 향상

### Removed
- `.claude/agents/architect.md` - `lead-architect.md`로 대체
- `.claude/agents/implementer.md` - `implementer-1~3.md`로 대체

---

## [1.1.0] - 2025-01-11

### Added
- **QA 에이전트 시스템**: 게임 QA 특강 자료 기반으로 5개 전문 에이전트 추가
  - `qa-tc`: TC 작성, 테스트 피라미드 설계 (GQA)
  - `qa-tech`: 코드 분석, 기술적 버그 탐지 (TQA)
  - `qa-balance`: 밸런스, 경제 시스템, 데이터 분석 (FQA+DQA)
  - `qa-security`: 어뷰징 방지, 보안 취약점 (CQA)
  - `qa-release`: 런칭 체크리스트, 패치 검증 (PQA+SQA)

- **QA 파이프라인**: 전체 QA 검증 자동화 (`qa-pipeline.md`)
  ```
  qa-tech → qa-security → qa-balance → qa-tc → 종합 리포트
  ```

- **새 슬래시 명령어**:
  - `/eee_qa-full`: 전체 QA 파이프라인 실행
  - `/eee_bug-check`: 기술적 버그 분석
  - `/eee_security`: 보안/어뷰징 분석
  - `/eee_precommit`: 커밋 전 빠른 검증
  - `/eee_sync`: Git 커밋 + 푸시 통합

### Changed
- **슬래시 명령어 간소화**: 16개 → 10개
  - `/eee_review`에 SOLID + 안티패턴 + Beta 안전성 통합
  - `/eee_sync`로 commit + push 통합

### Removed
- `/eee_solid`: `/eee_review`에 통합
- `/eee_safety-check`: `/eee_review`에 통합
- `/eee_push`: `/eee_sync`로 대체
- `/eee_tc`, `/eee_balance`, `/eee_release`, `/eee_playnote`: `/eee_qa-full`로 통합

---

## [1.0.0] - 2025-01-10

### Added
- **서브에이전트 파이프라인**: 시스템 생성 자동화
  - `architect`: 시스템 설계, 인터페이스, OCP 확장점
  - `implementer`: Pure C# 구현, TDD 테스트 작성
  - `reviewer`: SOLID 검토, 안전성 평가

- **프로젝트 단계별 TDD 가이드**:
  - Prototype: ~10% TDD, 빠른 프로토타이핑
  - Alpha: 40-60% TDD, SOLID 적용
  - Beta: 60-80% TDD, 버그 수정 중심
  - Live: 80-100% TDD, 최소 변경

- **슬래시 명령어**:
  - `/eee_init`: 초기 설정
  - `/eee_tdd`: TDD 워크플로우
  - `/eee_transition`: 단계 전환
  - `/eee_commit`: Conventional Commits

- **폴더 명명 규칙**: `XX_FolderName` 자동 적용

- **알림 시스템 (Hooks)**: 작업 완료 시 OS 알림

- **추가 도구 연동 안내**:
  - Unity-MCP: Unity 에디터 직접 제어
  - claude-mem: 세션 간 컨텍스트 기억

---

## 로드맵

### 예정된 기능
- [x] `/feature`: 개발 파이프라인 명시적 호출 (v1.2.0에서 구현)
- [ ] 테스트 커버리지 리포트 연동
- [ ] GitHub Issues 자동 생성 연동

### 고려 중
- [ ] 다국어 지원 (영어 문서)
- [ ] VS Code 확장 연동
- [ ] Unity Test Runner 결과 파싱

---

## 기여 방법

버그 리포트나 기능 제안은 [GitHub Issues](https://github.com/leehyoenjong/unity-pragmatic-tdd-plugin/issues)에 등록해주세요.
