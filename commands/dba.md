---
description: dba 에이전트를 단독 dispatch (DB 스키마 설계·ERD)
argument-hint: <작업 설명>
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["dba"]` 에 매핑된 agentType(기본 **dba**)을 **Agent 툴로 dispatch** 한다.

작업: **$ARGUMENTS**

에이전트는 자기 정의의 선행조건(승인된 계획서 plan.md + research.md, 있으면 화면정의서)을 따른다. 선행 산출물이 없으면 무엇이 필요한지 보고하고 멈춘다. 진행 시 결과 요약과 핸드오프 대상(계획에 be 있으면 be-developer, 없으면 Reviewer)을 안내한다.
