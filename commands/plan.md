---
description: planner 에이전트를 단독 dispatch (요구사항 문서화·산출물 관리)
argument-hint: <작업 설명>
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["plan"]` 에 매핑된 agentType(기본 **planner**)을 **Agent 툴로 dispatch** 한다.

작업: **$ARGUMENTS**

에이전트는 플러그인이 제공하는 자기 정의의 역할·산출물(요구사항 문서, 미결사항, ubiquitous language 검수)을 따른다. 진행 시 결과 요약과 핸드오프 대상(designer)을 안내한다.
