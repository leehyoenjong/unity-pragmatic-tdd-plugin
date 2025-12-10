# 현재 구현하려는 기능에 TDD를 적용합니다.

## 지시사항

1. PROJECT_CONTEXT.md를 확인하여 현재 프로젝트 단계를 파악하세요.
2. 구현하려는 기능이 TDD 적용 대상인지 판단하세요:
   - 게임 로직, 데이터 직렬화, 수학 계산 → TDD 적용
   - UI, 애니메이션, 시각적 요소 → TDD 생략

3. TDD 적용 시 다음 워크플로우를 따르세요:
   - **Red**: 실패하는 테스트 먼저 작성
   - **Green**: 테스트 통과하는 최소 코드 구현
   - **Refactor**: SOLID 원칙 적용하며 리팩토링

4. 테스트 파일 위치: `Assets/Tests/EditMode/` 또는 `Assets/Tests/PlayMode/`

5. 커밋 메시지 형식:
   - `feat(logic): [기능명] [TESTED]`
   - `test: Add tests for [기능명]`

자세한 가이드는 `.claude/docs/` 폴더의 문서를 참조하세요.
