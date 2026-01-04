# Git Push

원격 저장소에 커밋을 푸시합니다.

## 지시사항

1. 푸시 전 상태 확인:
   ```bash
   git status
   git log --oneline origin/main..HEAD
   ```

2. 푸시할 커밋 목록 사용자에게 표시

3. 푸시 실행:
   ```bash
   git push
   ```

4. 결과 보고:
   - 성공: 푸시된 커밋 해시와 브랜치 표시
   - 실패: 오류 원인 설명 및 해결 방법 제시

## 주의사항

- `--force` 옵션 사용 금지 (사용자 명시 요청 시에만)
- main/master 브랜치 force push 경고
- 푸시 전 항상 변경사항 확인

## 문제 해결

### 충돌 발생 시
```bash
git fetch origin
git rebase origin/main
# 또는
git pull --rebase
```

### 권한 오류 시
- SSH 키 확인
- 저장소 접근 권한 확인
