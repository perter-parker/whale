---
description: designer 에이전트를 단독 dispatch (UX/UI 설계)
argument-hint: <작업 설명>
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["design"]` 에 매핑된 agentType(기본 **designer**)을 **Agent 툴로 dispatch** 한다.

작업: **$ARGUMENTS**

에이전트는 자기 정의의 선행조건(프로토타입 자료)·산출물(와이어프레임·디자인 시스템)을 따른다. 진행 시 결과 요약과 핸드오프 대상(domain-expert·fe-developer)을 안내한다.
