---
description: 현재 흐름이 체인 어디에 있는지, 완료/대기/블로커를 표시
allowed-tools: Bash(ls:*), Bash(cat:*), Read
---
# /whale:status — 워크플로 상태

## Whale 설정
@.claude/whale/config.json

## 현재 흐름 상태
@.claude/whale/state.md

## 현재 마일스톤 (기본 .planning — config.json.scopeDir 이 다르면 그 경로 기준으로 판단)
!`cat .planning/STATE.md 2>/dev/null | head -30; echo '---'; ls .planning/milestone/ 2>/dev/null`

## 출력 형식

위 정보를 종합해 간결히 보고한다:
- **활성 흐름:** run-id, Task, Mode, 시작일 (없으면 "없음")
- **생애주기 진행:** 7 phase(research→plan→approve→implement→review→qa→summarize) 중 어디까지 ✅, 현재 ▶, 남은 ⬜
- **승인 상태:** PENDING / APPROVED / REJECTED (approve 게이트)
- **재시도:** N / max, 피드백 루프 발동 이력 요약
- **implement 하위 진행:** (implement phase 일 때) 도메인 전문가(dba/be/fe)별 상태
- **블로커:** state.md 에 기록된 블로커 또는 게이트 미충족 항목
- **다음 액션:** `/whale:next` 진행 가능 여부. approve 대기면 "`/whale:approve <run-id>` 필요" 를 명시. 루프 상한 초과면 리더 개입 안내.
- **마일스톤 컨텍스트:** 현재 진행 중 마일스톤/Phase 1줄 요약

상태만 보고한다 — 에이전트를 dispatch 하거나 파일을 수정하지 않는다.
