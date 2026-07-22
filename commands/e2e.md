---
description: e2e-tester 에이전트를 단독 dispatch (Playwright E2E 무인 실행·트리아지)
argument-hint: <대상 시나리오/critical path 설명>
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["e2e"]` 에 매핑된 agentType(기본 **e2e-tester**)을 **Agent 툴로 dispatch** 한다.

작업: **$ARGUMENTS**

에이전트는 자기 정의(셀렉터 우선순위·Helper 추상화·self-healing 4분류·무인 규율·크리티컬리티 우선순위)를 따른다.

**선행:** `config.e2e` 와 E2E AI 가이드(`config.e2e.selectorRulesDoc`)·Helper 층이 있어야 한다 — 없으면 **`/whale:e2e-init` 을 안내하고 멈춘다**. 활성 run 이 있으면 산출물을 `config.paths.runArtifacts/<run-id>/e2e.md` 에 쓴다(없으면 단독 실행 모드로 응답 본문에 트리아지 리포트).

진행 시 VERDICT 요약(critical x/y, APP_BUG n(Blocker n), healed n, 스킵 n)과 핸드오프(qa 로 반환 — qa 가 종합 판정에 흡수, APP_BUG Blocker → 기존 피드백 루프로 해당 전문가 재구현)를 안내한다.
