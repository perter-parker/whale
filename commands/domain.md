---
description: domain-expert 에이전트를 단독 dispatch (DDD 전략 설계·검증)
argument-hint: <작업 설명>
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["domain"]` 에 매핑된 agentType(기본 **domain-expert**)을 **Agent 툴로 dispatch** 한다.

작업: **$ARGUMENTS**

에이전트는 자기 정의를 따른다. domain-expert 는 경계를 *창작*하지 않고 *검증*하는 온디맨드 Reviewer 렌즈다(전술 DDD 승인 모듈의 경계·규칙·용어 드리프트 검증). 진행 시 결과 요약과 함께, Reviewer 연동이면 그 판정에 반영하도록 안내한다.
