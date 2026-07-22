---
description: refactor 에이전트를 dispatch (온디맨드·주기 기술부채 상환, 동작 불변)
argument-hint: <대상 모듈/디렉토리 (없으면 전역 스캔)>
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["refactor"]` 에 매핑된 agentType(기본 **refactor**)을 **Agent 툴로 dispatch** 한다.

대상: **$ARGUMENTS** (비어있으면 프로젝트 전역에서 부채 상위 스캔)

에이전트는 자기 정의(부채 상위 식별·반복 실패 통합점 공통화·800줄+ 모듈 분해 제안·FEATURE.md 생성·동작 불변 강제)를 따른다.

**규칙:** refactor 는 **생애주기(Mode A) 및 run-id 와 독립**이다 — state.md 활성 phase 를 진행시키지 않고 run-id 를 발급하지 않는다. 산출물은 `config.refactor.debtReportPath` 에 쌓인다. **기능 추가·동작 변경 금지**(리팩터 전후 동일 테스트 통과가 증빙). 기능 변경이 필요하면 `/whale:start` 또는 `/whale:fix` 로 보낸다. 위험이 큰 분해는 실행하지 않고 제안으로 남겨 리더 승인을 받는다.

진행 시 요약(부채 상위 n·실행 리팩터 n(동작 불변)·제안 n·생성 FEATURE.md n)과 핸드오프(리더 검토)를 안내한다.
