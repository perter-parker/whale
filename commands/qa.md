---
description: qa 에이전트를 단독 dispatch (테스트 전략·품질 검증)
argument-hint: <작업 설명>
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["qa"]` 에 매핑된 agentType(기본 **qa**)을 **Agent 툴로 dispatch** 한다.

작업: **$ARGUMENTS**

에이전트는 자기 정의의 선행조건(fe-developer 완료 알림·요구사항 ID 매핑)을 따른다. 진행 시 결과 요약과 최종 검수 대상(`config.json.reviewer`)을 안내한다.
