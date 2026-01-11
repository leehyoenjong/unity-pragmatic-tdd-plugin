# 코드 리뷰: 안티패턴 + SOLID + Beta 안전성 검토

## 지시사항

1. **SOLID 원칙 검토** (reviewer 에이전트 호출):
   - SRP: 클래스당 하나의 책임
   - OCP: 확장에 열림, 수정에 닫힘
   - LSP: 하위 타입 대체 가능
   - ISP: 인터페이스 분리
   - DIP: 추상화에 의존

2. **안티패턴 체크리스트**:

| 항목 | 확인 |
|------|------|
| 과도한 추상화 (단일 구현 인터페이스) | □ |
| 테스트를 위한 테스트 (getter/생성자만 테스트) | □ |
| private → public 변경 (캡슐화 깨짐) | □ |
| God ScriptableObject (100+ 필드) | □ |
| 싱글톤 남용 (테스트 불가 결합) | □ |
| Update에서 모든 것 처리 | □ |
| 매직 넘버 | □ |

3. 발견된 문제별 개선 방안 제시:
   - 구체적인 코드 예시와 함께 설명
   - Unity 특화 패턴 권장 (Event, ScriptableObject 등)

4. 성능 고려사항:
   - Hot Path (Update, FixedUpdate)에서 SOLID 적용 주의
   - 값 캐싱, 오브젝트 풀링 권장
   - GC 할당 최소화

5. **Beta 안전성 검토** (Beta 단계일 경우):

| 질문 | 확인 |
|------|------|
| 기존 시스템 구조 사용? | □ |
| 수정 파일 10개 미만? | □ |
| 데이터 구조 유지? | □ |
| 롤백 용이? | □ |

- 모두 Yes → `SAFE ✅`
- 하나라도 No → `HIGH RISK ⚠️` 대안 제시

6. 상세 가이드 참조:
   - `.claude/docs/anti-patterns.md`
   - `.claude/docs/performance-solid.md`
