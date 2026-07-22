---
description: reviewer 에이전트를 단독 dispatch (아키텍처·보안·품질 코드리뷰)
argument-hint: <리뷰 대상 설명>
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["reviewer"]` 에 매핑된 agentType(기본 **reviewer**)을 **Agent 툴로 dispatch** 한다.

작업: **$ARGUMENTS**

에이전트는 자기 정의(컨텍스트 격리, 3축 렌즈 A아키텍처·B보안·C품질 + D도메인 온디맨드, CRITICAL/MAJOR/MINOR 분류, `재구현 필요: YES/NO` + 지적범위 수정지침 강제)를 따른다. 활성 run 이 있으면 `runs/<run-id>/review.md` 에 쓴다. 진행 시 VERDICT 요약과 핸드오프(YES→해당 전문가 재구현 / NO→qa)를 안내한다.
