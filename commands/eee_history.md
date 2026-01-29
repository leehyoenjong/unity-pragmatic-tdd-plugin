# /eee_history - 세션 히스토리

세션 노트를 검색하고 관리합니다.

## 사용법

```
/eee_history                    # 최근 세션 목록
/eee_history search <키워드>    # 키워드로 검색
/eee_history show <날짜>        # 특정 날짜 세션 보기
/eee_history save               # 현재 세션 요약 저장
```

## 실행 절차

### 1. 인자 파싱
```
args = "$ARGUMENTS"
command = args의 첫 단어 (없으면 "list")
```

### 2. 명령별 처리

#### list (기본)
```bash
ls -la .claude/notes/session_*.md | tail -10
```
최근 10개 세션 표시

#### search <keyword>
```bash
grep -r "<keyword>" .claude/notes/ --include="*.md"
```
노트에서 키워드 검색

#### show <date>
```bash
cat .claude/notes/session_<date>*.md
```
해당 날짜 세션 노트 표시

#### save
현재 세션 요약을 수동으로 저장:

```markdown
# Session Summary - {YYYY-MM-DD HH:MM}

## 수행한 작업
- [작업 1]
- [작업 2]

## 변경된 파일
- [파일 목록]

## 중요 결정
- [결정 사항]

## 미완료/다음 작업
- [ ] [남은 작업]

## 키워드
#tag1 #tag2
```

### 3. 출력 형식

```markdown
---
📜 **세션 히스토리**

### 최근 세션
| 날짜 | 주요 작업 | 태그 |
|-----|----------|-----|
| 2026-01-29 | Inventory 시스템 | #feature |
| 2026-01-28 | 버그 수정 | #bugfix |

[상세 내용...]
---
```

## 자동 저장 트리거

다음 상황에서 세션 요약 저장을 권장:

1. **대규모 작업 완료 시**
   - 새 시스템 구현 완료
   - 중요 버그 수정

2. **중요 결정 시**
   - 아키텍처 결정
   - 기술 선택

3. **세션 종료 전**
   - 컨텍스트 한계 임박
   - 사용자 요청

## 검색 팁

```
/eee_history search Inventory     # Inventory 관련 모든 기록
/eee_history search #bugfix       # 버그 수정 태그
/eee_history search 2026-01       # 2026년 1월 기록
```
