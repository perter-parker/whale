---
description: planner를 dispatch해 화면 정의서(개발 기준 정본) 작성 (템플릿 기반)
argument-hint: <화면ID 또는 화면명> [추가 맥락]
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["plan"]` 에 매핑된 agentType(**planner**)을 **Agent 툴로 dispatch** 해 화면 정의서(개발 기준 정본)를 작성한다.

흐름: `프로토타입 + PRD → 화면정의서(기획) → 화면설계서(개발 5역할) → 구현`. 본 명령어는 그 첫 단계.

대상 화면: **$ARGUMENTS**

## 절차 (경로는 모두 `config.json.paths` 에서 읽는다)

1. planner 정의의 "화면 정의서 작성" 절(작성 원칙·12섹션·절차)을 확인한다.
2. 템플릿 `config.json.paths.screenSpecTemplate` 를 SSOT로 사용한다.
3. 대상 화면의 프로토타입(`config.json.paths.prototype` 하위)과 상위 PRD(`config.json.paths.prd`)·요구사항 문서를 근거로 12섹션을 **번역**한다 (발명 금지).
4. 산출물은 `config.json.paths.screenSpecs`/`{화면ID}_{화면명}_화면정의서.md` 에 쓴다.
5. 답 없는 항목은 §12 미결 사항에 `[확인필요]` + **기한**으로 누적 — 임의 결정 금지. 규칙·상태 값은 PRD § 링크(재정의 금지).

## 완료 보고

- 작성한 파일 경로
- §12 미결 사항 개수 ([확인필요] N건) — 0이면 상태 `승인됨`(개발 착수 가능), 남으면 `검토중`
- 핸드오프 대상: **designer**(화면설계서 §4) 또는 리더(사용자) 검수
