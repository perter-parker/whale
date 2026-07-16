---
description: planner 에이전트를 단독 dispatch (7섹션 구현계획서 + 승인 게이트)
argument-hint: <task 설명>
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["planner"]` 에 매핑된 agentType(기본 **planner**)을 **Agent 툴로 dispatch** 한다.

작업: **$ARGUMENTS**

에이전트는 자기 정의(고정 7섹션 구현계획서 P1~P7 작성, 발명 금지·번역, 미결은 [확인필요], 말미 APPROVAL GATE 로 `APPROVED:<run-id>` 요청)를 따른다. 입력은 `runs/<run-id>/research.md`(필수) + 선택적으로 화면정의서/PRD. 활성 run 이 있으면 산출물을 `runs/<run-id>/plan.md` 에 쓴다. 진행 시 계획 요약과 함께 "리더 승인 → `/whale:approve <run-id>`" 를 안내한다.
