---
description: (온디맨드·선택) planner를 dispatch해 화면 정의서 작성 — 생애주기 루프의 선택적 입력 문서
argument-hint: <화면ID 또는 화면명> [추가 맥락]
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

> **위치:** 화면정의서는 생애주기 자동 루프(research→plan→…)의 **강제 게이트가 아니라 선택적 입력 문서**다. spec-first 문서를 유지하는 프로젝트에서 Researcher/Planner 의 근거로 쓰고 싶을 때 온디맨드로 작성한다.

`config.json.roles["planner"]` 에 매핑된 agentType(**planner**)을 **Agent 툴로 dispatch** 해 화면 정의서를 작성한다.

대상 화면: **$ARGUMENTS**

## 절차 (경로는 모두 `config.json.paths` 에서 읽는다)

1. 대상 화면의 프로토타입(`config.json.paths.prototype` 하위)과 상위 PRD(`config.json.paths.prd`)·요구사항 문서를 근거로 화면정의서를 **번역**한다(발명 금지).
2. 프로젝트에 화면정의서 템플릿이 있으면 그것을 SSOT로 사용한다(없으면 프로젝트 관례의 섹션 구성을 따른다).
3. 산출물은 `config.json.paths.screenSpecs`/`{화면ID}_{화면명}_화면정의서.md` 에 쓴다.
4. 답 없는 항목은 미결 사항에 `[확인필요]` + **기한**으로 누적 — 임의 결정 금지. 규칙·상태 값은 PRD § 링크(재정의 금지).

## 완료 보고

- 작성한 파일 경로
- 미결 사항 개수([확인필요] N건) — 0이면 `승인됨`, 남으면 `검토중`
- 이 문서는 이후 `/whale:start` → Researcher/Planner 가 선택적 입력으로 참조한다.
