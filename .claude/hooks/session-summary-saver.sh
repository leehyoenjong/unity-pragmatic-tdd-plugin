#!/bin/bash
# session-summary-saver.sh
# Stop 이벤트 시 세션 요약을 자동 저장

INPUT=$(cat)
NOTES_DIR=".claude/notes"
TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")
SESSION_FILE="${NOTES_DIR}/session_${TIMESTAMP}.md"

# notes 디렉토리 확인
mkdir -p "$NOTES_DIR"

# 세션 요약 파일 생성 (간단한 템플릿)
# 실제 요약은 LLM이 작성해야 하므로 여기서는 마커만 생성
MARKER_FILE="${NOTES_DIR}/.last_session"
echo "$TIMESTAMP" > "$MARKER_FILE"

exit 0
