# Git 커밋과 푸시를 한 번에 수행합니다.

## 지시사항

1. **변경사항 확인**:
   - `git status`로 변경된 파일 확인
   - `git diff`로 변경 내용 확인

2. **커밋 메시지 작성** (Conventional Commits):
   ```
   <type>(<scope>): <description>

   [optional body]

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

   | Type | 용도 |
   |------|------|
   | feat | 새 기능 |
   | fix | 버그 수정 |
   | refactor | 리팩토링 |
   | test | 테스트 추가 |
   | docs | 문서 수정 |
   | chore | 기타 작업 |

3. **커밋 + 푸시 실행**:
   ```bash
   git add .
   git commit -m "메시지"
   git push
   ```

4. **주의사항**:
   - 민감한 파일 (.env 등) 커밋 금지
   - 큰 변경은 여러 커밋으로 분리 권장
   - 충돌 발생 시 사용자에게 알림
