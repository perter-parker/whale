---
description: 현재 흐름이 체인 어디에 있는지, 완료/대기/블로커를 표시
allowed-tools: Bash(ls:*), Bash(cat:*), Read
---
# /whale:status — 워크플로 상태

## Whale 설정
@.claude/whale/config.json

## 현재 흐름 상태
@.claude/whale/state.md

## 현재 마일스톤
!`SCOPE=$(grep -o '"scopeDir"[^,]*' .claude/whale/config.json 2>/dev/null | cut -d'"' -f4); SCOPE=${SCOPE:-.planning/milestone}; cat .planning/STATE.md 2>/dev/null | head -30; echo '---'; ls "$SCOPE" 2>/dev/null`

## 출력 형식

위 정보를 종합해 간결히 보고한다:
- **활성 흐름:** feature 이름, Mode, 시작일 (없으면 "없음")
- **체인 진행:** 어느 단계까지 ✅, 현재 ▶ 단계, 남은 ⬜ 단계 (Mode A 인 경우)
- **블로커:** state.md 에 기록된 블로커 또는 검증 미충족 항목
- **다음 액션:** `/whale:next` 진행 가능 여부, 또는 무엇을 먼저 해결해야 하는지
- **마일스톤 컨텍스트:** 현재 진행 중 마일스톤/Phase 1줄 요약

상태만 보고한다 — 에이전트를 dispatch 하거나 파일을 수정하지 않는다.
