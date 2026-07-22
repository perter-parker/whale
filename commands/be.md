---
description: be-developer 에이전트를 단독 dispatch (백엔드 구현·API·인프라)
argument-hint: <작업 설명>
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["be"]` 에 매핑된 agentType(기본 **be-developer**)을 **Agent 툴로 dispatch** 한다.

작업: **$ARGUMENTS**

에이전트는 자기 정의의 선행조건(승인된 계획서 plan.md + dba 산출물·API 요구)을 따른다. 선행 산출물이 없으면 무엇이 필요한지 보고하고 멈춘다. 진행 시 결과 요약과 핸드오프 대상(계획에 fe 있으면 fe-developer, 없으면 Reviewer)을 안내한다.
