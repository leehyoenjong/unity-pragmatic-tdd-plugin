# 전체 QA 파이프라인을 실행합니다.

## 지시사항

1. **qa-pipeline 파이프라인을 실행**합니다.
   - 위치: `.claude/pipelines/qa-pipeline.md`

2. 실행 순서:
   ```
   qa-tech → qa-security → (qa-balance) → qa-tc → 종합 리포트
   ```

3. 옵션:
   - `--quick`: 기술+보안만 (빠른 검증)
   - `--balance`: 밸런스 분석 포함
   - `--tc-only`: TC 생성만

4. 사용 예시:
   ```
   /eee_qa-full 인벤토리 시스템
   /eee_qa-full --quick 결제 로직
   /eee_qa-full --balance 전투 시스템
   ```

5. 출력: QA 종합 리포트 (마크다운)

6. 상세 가이드: `.claude/pipelines/qa-pipeline.md`
