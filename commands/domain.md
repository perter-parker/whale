---
description: domain-expert 에이전트를 단독 dispatch (DDD 전략 설계·검증)
argument-hint: <작업 설명>
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["domain"]` 에 매핑된 agentType(기본 **domain-expert**)을 **Agent 툴로 dispatch** 한다.

작업: **$ARGUMENTS**

에이전트는 자기 정의의 선행조건(프로토타입·기획 문서)을 따른다. domain-expert 는 경계를 *창작*하지 않고 *검증*하는 온디맨드 최종 리뷰어다. 진행 시 결과 요약과 핸드오프 대상(dba)을 안내한다.
