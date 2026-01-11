# 커밋 전 빠른 QA 검증을 수행합니다.

## 지시사항

1. **qa-tech과 qa-security 에이전트를 순차 호출**하여 빠른 검증을 수행합니다.

2. 검증 범위:
   - 변경된 파일만 대상
   - Critical/High 이슈만 보고
   - 5분 이내 완료 목표

3. 체크 항목:

### 기술 (qa-tech)
- [ ] Null 참조 가능성
- [ ] 경계값 처리
- [ ] 동시성 문제
- [ ] Unity 특화 이슈

### 보안 (qa-security)
- [ ] 클라이언트 신뢰 문제
- [ ] 재화/아이템 조작 가능성
- [ ] 입력 검증 누락

4. 출력 형식:

```markdown
## Pre-commit QA 결과

### 통과 ✅ / 실패 ❌

### Critical 이슈 (커밋 차단)
- 없음 / {{이슈 목록}}

### High 이슈 (권장 수정)
- 없음 / {{이슈 목록}}

### 권장사항
- {{개선 제안}}
```

5. 사용 예시:
   ```
   /eee_precommit
   /eee_precommit PlayerController.cs
   /eee_precommit 변경된 파일들
   ```

6. 통과 기준:
   - Critical: 0개 (필수)
   - High: 3개 이하 (권장)
