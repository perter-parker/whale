# Whale — 활성 흐름 상태

> `/whale:start`·`/whale:next`·`/whale:approve`·`/whale:status` 가 읽고 쓰는 단일 상태 파일.
> 작업 한 건(run-id)의 생애주기 phase 진행·승인·피드백 루프를 추적한다.
> 마일스톤/요구사항 상태는 프로젝트의 `.planning/` 이 담당한다.

## 활성 흐름

_없음_ — `/whale:start <task>` 로 시작한다.

<!--
활성 흐름이 있을 때의 형식 (start 가 채우고, next/approve 가 갱신):

## 활성 흐름

- **run-id:** `20260716-oauth-login-01`
- **Task:** OAuth 소셜 로그인 추가
- **Mode:** A (생애주기)
- **시작:** 2026-07-16
- **마일스톤 범위:** <config.scopeDir 에서 확인한 현재 범위>
- **현재 phase:** implement
- **승인 상태:** APPROVED (2026-07-16, "APPROVED: 20260716-oauth-login-01")
- **재시도:** 0 / 1 (maxRetries)

### 생애주기 진행

| # | phase | role | 상태 | 게이트 | 산출물/판정 |
|---|-------|------|------|--------|-------------|
| 1 | research  | researcher | ✅ 완료 | artifact | runs/<id>/research.md |
| 2 | plan      | planner    | ✅ 완료 | artifact | runs/<id>/plan.md (7섹션) |
| 3 | approve   | —          | ✅ 승인 | approval | APPROVED 2026-07-16 |
| 4 | implement | (도메인)   | ▶ 진행중 | artifact | 하위 dispatch 표 참조 |
| 5 | review    | reviewer   | ⬜ 대기 | verdict  | 재구현 필요: — |
| 6 | qa        | qa         | ⬜ 대기 | verdict  | 재구현 필요: — (E2E 수행 시 e2e.md 동반) |
| 7 | summarize | summarizer | ⬜ 대기 | artifact | PR 디스크립션 |

상태 표기: ✅ 완료 / ▶ 진행중 / ⬜ 대기 / 🔁 재구현중 / ⛔ 블로커

#### implement 하위 dispatch (계획 P3 구현단계·P4 전문가배정 기준)

| 순서 | 전문가 | 상태 | TDD/산출물 |
|------|--------|------|-----------|
| 1 | dba | ✅ 완료 | 스키마+마이그레이션 계획 |
| 2 | be  | ▶ 진행중 | API TDD (Red-Green-Refactor) |
| 3 | fe  | ⬜ 대기 | (계획에 있으면) |

> 계획에 등장하지 않는 전문가는 이 표에 넣지 않는다(예: BE-only 면 dba·fe 행 없음).

### 피드백 루프 이력

| 회차 | 트리거 | 지적 범위 | 처리 phase | 결과 |
|------|--------|-----------|-----------|------|
| _아직 없음_ | | | | |

<!-- 예: 1 | review CRITICAL | be Service 트랜잭션 경계 | implement(be) | 수정 완료 -->

### 블로커
- _없음_
-->

## 완료된 흐름 (히스토리)

_아직 없음_

<!--
- `20260716-oauth-login-01` — OAuth 로그인 | 완료 2026-07-16 | 재시도 0회 | summary: runs/<id>/summary.md
-->
