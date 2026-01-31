# Notepads - 임시 메모 및 누적 지식

이 디렉토리는 작업 중 임시 메모와 누적 지식을 저장합니다.

## 구조

```
notepads/
├── README.md           # 이 파일
├── active-modes.txt    # 현재 활성화된 모드
├── context-monitor.log # 컨텍스트 모니터링 로그
└── {plan-name}/        # 작업별 누적 지식 (자동 생성)
    ├── learnings.md    # 발견한 패턴, 해결책
    ├── decisions.md    # 내린 결정과 이유
    ├── issues.md       # 발생한 문제와 해결
    └── progress.md     # 진행 상황 추적
```

## 용도

### 임시 메모
- `{agent}_scratch.md` - 에이전트별 임시 계산
- `active-modes.txt` - 현재 활성 모드 상태

### 누적 지식 ({plan-name}/)
- 작업 시작 시 자동 생성
- 세션 간 지식 유지
- 세션 재개 시 컨텍스트 복원

## 자동 생성 규칙

1. `/eee_feature {name}` 실행 시 → `notepads/{name}/` 생성
2. 시스템 구현 시작 시 → 해당 폴더 생성
3. 세션 시작 시 기존 폴더 확인

## 정리 규칙

- 완료된 작업: `notes/`로 이동
- 오래된 임시 파일: 7일 후 정리 권장
- `.gitkeep` 유지 필수
