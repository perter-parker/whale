---
description: 현재 phase 게이트를 검증하고 생애주기 루프의 다음 단계로 핸드오프 (승인 게이트·피드백 루프 포함)
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(grep:*), Read, Write, Edit, Agent
---
# /whale:next — 다음 phase 로 핸드오프

## Whale 설정
@.claude/whale/config.json

## 현재 흐름 상태
@.claude/whale/state.md

## 절차

1. **현재 phase·티어 식별:** state.md 활성 흐름에서 ▶ 진행중 phase 와 그 phase 의 `role`·`gate`(config.lifecycle.phases)를 읽는다. run-id 와 **`Tier`(fast|normal|full)** 도 읽는다. 활성 흐름이 없으면 "활성 흐름 없음 — `/whale:start <task>` 로 시작" 안내 후 멈춘다.
   > **티어가 phase 순서를 정한다:** "다음 phase" 는 `config.lifecycle.phases` 전체가 아니라 **`config.modes.tiers[Tier].phases` 배열의 다음 항목**이다. 그 배열에 없는 phase(예: normal 의 research·summarize, fast 의 review·qa)는 애초에 진행표에 없으므로 건너뛴다. `config.modes` 가 없는 구 config 는 티어 무시하고 lifecycle.phases 전체(=full)로 동작(하위호환).
   > **fast 티어:** 진행표가 implement 한 phase뿐이다. implement 완료(hooks 게이트 통과) → review/qa/summarize 없이 곧장 흐름 종료(아래 7). `/whale:next` 는 사실상 종료 확인만 한다.
   > **qaProfile:** qa phase 를 dispatch 할 때 `config.modes.tiers[Tier].qaProfile`(normal→light, full→full)을 컨텍스트로 전달한다.

2. **게이트 검증 (gate 타입별 분기):** 산출물은 `config.paths.runArtifacts/<run-id>/` 하위에서 확인한다.

   - **`gate == "artifact"`** — 해당 phase 의 `produces` 파일이 존재하고 실제 내용으로 채워졌는지 Read/ls 로 확인.
     - **research**: `research.md` 존재 + 비어있지 않음(R1~R7).
     - **plan**: `plan.md` 존재 + **7섹션 전부** 채워짐. `grep -nE '^## P[1-7]\.' <plan.md>` 로 P1~P7 헤더 7개 존재 확인. placeholder(`{...}`)면 미충족.
     - **implement**: 3의 하위 dispatch 가 모두 완결됐는지 확인(아래 3 참조).
     - **summarize**: `summary.md` 존재 → 흐름 종료(아래 6).
   - **`gate == "approval"`** (approve phase) — state.md 승인 상태가 `APPROVED` 인지 확인.
     - `PENDING` 이면 **미충족**: "승인 대기 — `/whale:approve <run-id>` 또는 대화에 정확히 `APPROVED: <run-id>` 입력 필요" 를 보고하고 멈춘다. `config.approvalGate.acceptLoose=false` 이므로 'ok'·'진행해' 는 승인으로 인정하지 않는다. (단, 사용자가 이번 대화에 정확한 `APPROVED: <run-id>` 문구를 남겼다면 승인으로 인정하고 state 를 APPROVED 로 Edit 한 뒤 통과.)
     - `REJECTED` 이면 phase 를 plan 으로 되돌리고 재계획을 안내.
   - **`gate == "verdict"`** (review·qa phase) — 해당 산출물(`review.md`/`qa.md`)에서 `재구현 필요: YES/NO`(VERDICT 블록)를 읽는다. 판정이 없으면 **미충족**(에이전트 미완). → 판정 처리는 아래 4.
     > **E2E 는 독립 phase 가 아니다**(`config.e2e.runOn.mode=qa-conditional`). qa 는 critical path 가 있으면 내부에서 e2e-tester(`config.roles.e2e`)를 dispatch 하고, `e2e.md` 의 APP_BUG 를 자신의 `qa.md` VERDICT 에 흡수한다. 따라서 게이트는 여전히 `qa.md` 의 재구현 필요 YES/NO 하나이며, phase 표를 늘리지 않는다.
     > **Security 도 독립 phase 가 아니다**(`config.security.runOn.mode=qa-conditional`). qa 는 보안 민감 변경이면 security-reviewer(`config.roles.security`)를 dispatch 하고 `security.md` 의 Critical/High 를 `qa.md` VERDICT 에 흡수한다(게이트는 여전히 `qa.md` 하나). 단 `security.md` 가 **HOLD**(사람 필수 게이트 저촉)면 qa 는 summarize 로 진행하지 않고 **리더 보안 승인 대기**로 멈춘다(무인 자동 통과 방지). **Refactor 는 생애주기와 무관**하므로 이 커맨드가 다루지 않는다(/whale:refactor 독립 실행).

3. **implement phase 특수 처리 (컨테이너 순차 dispatch):**
   현재 phase 가 `implement` 이면:
   - `runs/<run-id>/plan.md` 의 **P3(구현 단계)·P4(전문가 배정)** 를 읽어, `config.domainExperts.order`(dba→be→fe) 중 **계획에서 담당='예' 인 전문가만** 필터링한다. state.md "implement 하위 dispatch" 표에 그 전문가들만(순서대로) 넣는다. 계획에 없는 전문가는 표에 넣지 않는다(예: BE-only 면 be 만).
   - 표에서 다음 ⬜ 전문가 **하나**를 `config.domainExperts.roles` 매핑으로 Agent dispatch(각자 TDD). 직전 전문가 산출물·plan.md·research.md 를 컨텍스트로 전달. 완료되면 그 전문가를 ✅, "다음 전문가는 다시 `/whale:next`" 안내(한 번에 하나씩).
   - **티어 승격 감지(implement 중):** 전문가 dispatch 결과나 변경 diff 가 `config.modes.autoEscalate` 에 저촉하면(보안 민감 영역=humanGateAreas → 최소 normal / 아키텍처·다중BC·breaking → full) **state.md 의 `Tier` 를 승격**하고 사유를 피드백/이력 근처에 1줄 기록한다. 승격으로 새로 필요해진 phase(예: fast→normal 승격 시 review·qa)를 **진행표에 삽입**한 뒤 계속 진행한다(누락 검증 없이 종료 금지). 특히 **fast 티어에서 보안 영역 변경이 확인되면 곧장 종료하지 않고 review·qa(+security-reviewer)를 삽입**한다.
   - 모든 필요한 전문가가 ✅ 면 implement phase 를 ✅ 완료로 표시하고 **티어 배열의 다음 phase** 로 진행(fast 면 없음→종료 / normal·full 이면 review). (아래 5)

4. **verdict 처리 + 피드백 루프 판정 (review·qa):**
   - 판정이 **NO**(`재구현 필요: NO`): 현재 phase 를 ✅ 완료로, 다음 phase 를 ▶ 진행중으로 하고 다음 role 을 dispatch(아래 5).
   - 판정이 **YES**(= `config.feedbackLoop.triggerVerdict`): **피드백 루프 발동.**
     - state.md 재시도 카운트를 읽는다. `retryCount < config.feedbackLoop.maxRetries`(기본 1)이면:
       - retryCount++, 피드백 루프 이력 표에 행 추가(회차·트리거·지적범위·처리 phase).
       - 현재 phase 를 `config.feedbackLoop.returnTo`(implement)로 되돌린다. `scope=targeted` 이므로 **VERDICT 수정지침이 지목한 전문가만** implement 하위 표에서 ▶(🔁 재구현중)로 재활성화(전체 재구현 금지). 그 전문가를 재 dispatch 하며 수정지침(CRITICAL/MAJOR)을 컨텍스트로 전달.
       - 재구현 후 다시 review 로 올라온다.
     - `retryCount >= maxRetries` 이면: **자동 진행 중단.** "재시도 상한(maxRetries={n}) 초과 — 1회 재구현 후에도 {review|qa} 재구현 필요: YES. 리더 개입 필요(직접 수정 후 재판정 / plan 으로 되돌려 재계획 / run 보관·중단)" 를 보고하고 멈춘다. state 는 그대로 둔다(무한 루프 방지).

5. **충족 시 (핸드오프):**
   - state.md 에서 현재 phase 를 ✅ 완료로, **`config.modes.tiers[Tier].phases` 배열의 다음 phase**(lifecycle.phases 전체가 아님)를 ▶ 진행중으로 Edit. 티어 배열에 다음 phase 가 없으면 흐름 종료(아래 7).
   - 다음 phase 의 `role` 을 Agent 로 dispatch(직전 산출물 **경로 + HANDOFF 요약**만 컨텍스트로 — 전문 통째 전달 금지, Context 절약). 단 `role==null` 인 phase:
     - `approve`: dispatch 없이 "리더 승인 대기 — `/whale:approve <run-id>`" 안내만.
     - `implement`: 위 3 으로 처리(도메인 전문가 dispatch).
   - **qa phase dispatch 시:** `qaProfile`(티어에 따라 light/full)을 컨텍스트로 전달. full 이면 qa 가 e2e·security 를 **필요 시 병렬 dispatch** 함을 상기(qa 에이전트 내부 규칙).
   - **summarize phase:** `full` 티어에만 존재한다. summarizer 를 dispatch 하기 전, `git diff --stat`·산출물 파일 목록·완료 체크리스트 등 **결정론 부분은 이 커맨드가 Bash 로 조립**해 summarizer 에 넘긴다(summarizer 는 개요·판정 서술에 집중). `normal` 티어는 summarize phase 자체가 없으므로, qa 통과(NO) 시 곧장 흐름 종료(7)하며 필요하면 결과 요약을 Bash 조립으로 출력한다(별도 summarizer agent 미호출).

6. **미충족 시:** 무엇이 누락됐는지 구체적으로 보고하고 **멈춘다**(다음 phase 로 넘기지 않음). state 는 그대로 둔다. 사유 명시: (산출물 없음) 어떤 파일이 없는지 / (계획 미완) 7섹션 중 빠진 것 / (승인 대기) `/whale:approve` 필요 / (판정 없음) review·qa 미완 / (루프 상한 초과) 리더 개입.

7. **흐름 끝(티어별 종료 지점):** 티어 배열의 마지막 phase 를 통과하면 종료한다 — **full**=summarize 완료 후 / **normal**=qa 통과(NO) 후 / **fast**=implement+hooks 게이트 통과 후. `config.json.reviewer`(리더)에게 최종 병합 검수 요약을 출력하고, 활성 흐름을 "완료된 흐름(히스토리)" 로 이동(run-id·**Tier**·재시도 횟수·산출물 경로 기록). fast·normal 은 summary.md 대신 Bash 조립 요약으로 갈음할 수 있다.

**규칙:** phase 순서·역할·게이트·루프·**티어(modes)** 설정은 반드시 `config.json` 에서 읽는다(하드코딩 금지). 티어 배열에 있는 phase 만 진행하되, **승격 하드룰**(보안 영역→최소 normal, 아키텍처/breaking→full)은 우회 금지 — 승격 시 누락 phase 를 삽입하고 계속한다. 승인 없이 implement 로 넘기지 않는다. 동결 대상(프로젝트 CLAUDE.md 명시)은 직접 변경하지 않고 [변경-게이트]로 올린다. 하위호환: (1) `lifecycle` 없고 `modeA_chain` 만 있으면 구 4역할 체인 모드(존재 검증만). (2) `modes` 없으면 티어 무시하고 lifecycle.phases 전체(full)로 동작.
