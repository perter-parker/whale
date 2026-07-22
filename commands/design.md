---
description: designer 에이전트를 단독 dispatch (UX/UI 설계)
argument-hint: <작업 설명>
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["design"]` 에 매핑된 agentType(기본 **designer**)을 **Agent 툴로 dispatch** 한다.

작업: **$ARGUMENTS**

에이전트는 자기 정의(온디맨드 렌즈 — Planner/Implementer 보조, 화면 구조·상호작용·디자인 토큰 준수)를 따른다. 진행 시 결과 요약과 핸드오프 대상(요청 맥락에 따라 Planner 또는 fe-developer)을 안내한다.
