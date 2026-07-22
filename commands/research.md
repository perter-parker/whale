---
description: researcher 에이전트를 단독 dispatch (코드베이스·요구사항·수정후보 조사)
argument-hint: <task 설명>
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["researcher"]` 에 매핑된 agentType(기본 **researcher**)을 **Agent 툴로 dispatch** 한다.

작업: **$ARGUMENTS**

에이전트는 자기 정의(읽기 전용 조사, 리서치 브리프 R1~R7 산출)를 따른다. 활성 run 이 있으면 산출물을 `config.paths.runArtifacts/<run-id>/research.md` 에 쓰고, run 이 없으면 단독 조사 모드로 응답 본문에 브리프를 낸다. 진행 시 결과 요약과 핸드오프 대상(planner)을 안내한다.
