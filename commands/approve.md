---
description: 계획 승인 게이트 — run-id 를 명시해 implement 진입을 승인(또는 --reject 로 반려)
argument-hint: <run-id> [--reject]
allowed-tools: Read, Edit
---
# /whale:approve — 승인 게이트

## Whale 설정
@.claude/whale/config.json

## 현재 흐름 상태
@.claude/whale/state.md

인자: **$ARGUMENTS** (형식: `<run-id>` 또는 `<run-id> --reject`)

## 절차

1. **run-id 일치 확인:** 인자의 run-id 가 state.md 활성 흐름의 run-id 와 일치하는지 확인한다. 불일치(오타·잘못된 run)면 **거부**하고 활성 run-id 를 알려준다. (`config.approvalGate` 는 정확한 run-id 명시를 요구한다 — 무엇을 승인하는지 오인 방지.)
2. **승인 단계 확인:** state.md 현재 phase 가 `approve` 게이트인지 확인한다. 아직 plan 이 미완(현재 phase 가 approve 이전)이면 "아직 승인 단계가 아님 — plan 완료 후 `/whale:next` 로 approve 게이트에 도달해야 함" 을 보고하고 멈춘다.
3. **처리:**
   - 기본(승인): state.md 승인 상태를 `APPROVED (오늘, "APPROVED: <run-id>")` 로 Edit 하고, approve 행을 ✅ 승인으로 표시. "이제 `/whale:next` 로 implement 진입" 안내.
   - `--reject`: 승인 상태를 `REJECTED` 로 기록하고 현재 phase 를 `plan` 으로 되돌려(plan ▶, approve ⬜) 재계획을 유도. 반려 사유를 리더가 남기도록 안내.

**규칙:** 이 커맨드는 승인 상태만 기록한다 — 에이전트를 dispatch 하지 않는다(다음 진행은 `/whale:next`). 'ok'·'진행해' 같은 느슨한 표현은 승인이 아니다(`config.approvalGate.acceptLoose=false`).
