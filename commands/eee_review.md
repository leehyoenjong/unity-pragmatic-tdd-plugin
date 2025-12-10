# 코드의 안티패턴을 검토하고 개선점을 제안합니다.

## 지시사항

1. 다음 안티패턴 체크리스트를 확인하세요:

| 항목 | 확인 |
|------|------|
| 과도한 추상화 (단일 구현 인터페이스) | □ |
| 테스트를 위한 테스트 (getter/생성자만 테스트) | □ |
| private → public 변경 (캡슐화 깨짐) | □ |
| God ScriptableObject (100+ 필드) | □ |
| 싱글톤 남용 (테스트 불가 결합) | □ |
| Update에서 모든 것 처리 | □ |
| 매직 넘버 | □ |

2. 발견된 문제별 개선 방안 제시:
   - 구체적인 코드 예시와 함께 설명
   - Unity 특화 패턴 권장 (Event, ScriptableObject 등)

3. 커밋 규칙 확인:
   - 테스트된 코드: `[TESTED]` 태그
   - 시각적 기능: `[VISUAL]` 태그
   - 리팩토링: `refactor:` 접두사

4. 성능 고려사항:
   - Hot Path (Update, FixedUpdate)에서 SOLID 적용 주의
   - 값 캐싱, 오브젝트 풀링 권장
   - GC 할당 최소화

5. 상세 가이드 참조:
   - `.claude/docs/anti-patterns.md`
   - `.claude/docs/performance-solid.md`
