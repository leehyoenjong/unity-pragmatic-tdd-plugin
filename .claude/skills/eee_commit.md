# Git Commit (Conventional Commits)

Conventional Commits 규칙에 따라 커밋을 생성합니다.

## 지시사항

1. 현재 변경사항 확인:
   ```bash
   git status
   git diff
   git log --oneline -3
   ```

2. 변경사항 분석 후 커밋 타입 결정:

   | 타입 | 설명 | 예시 |
   |------|------|------|
   | `feat` | 새 기능 | feat: 인벤토리 시스템 추가 |
   | `fix` | 버그 수정 | fix: 점수 계산 오류 수정 |
   | `docs` | 문서 변경 | docs: README 업데이트 |
   | `refactor` | 리팩토링 | refactor: ScoreController 구조 개선 |
   | `test` | 테스트 추가/수정 | test: 콤보 시스템 테스트 추가 |
   | `chore` | 기타 변경 | chore: 패키지 업데이트 |

3. Unity 특화 태그 (선택):
   - `[TESTED]` - 테스트된 코드
   - `[VISUAL]` - 시각적 요소 (UI, 애니메이션)
   - `[WIP]` - 작업 중

4. 커밋 메시지 형식:
   ```
   <type>: <description>

   [optional body]

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
   ```

5. 커밋 실행:
   ```bash
   git add <files>
   git commit -m "$(cat <<'EOF'
   <커밋 메시지>
   EOF
   )"
   ```

## 주의사항

- 민감한 파일 (.env, credentials 등) 커밋 금지
- 커밋 전 변경사항 반드시 확인
- 한 커밋에 하나의 논리적 변경만 포함
