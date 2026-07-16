---
description: Mode A(순차) 워크플로 시작 — 마일스톤 범위 확인 후 에이전트 체인 첫 단계를 dispatch
argument-hint: <feature 이름/설명>
allowed-tools: Bash(ls:*), Bash(cat:*), Read, Write, Edit, Agent
---
# /whale:start — Mode A 순차 워크플로 시작

대상 feature: **$ARGUMENTS**

## Whale 설정
@.claude/whale/config.json

## 현재 흐름 상태
@.claude/whale/state.md

## 현재 마일스톤 범위 (기본 .planning/milestone — config.json.scopeDir 이 다르면 그 경로 기준으로 판단)
!`ls .planning/milestone/ 2>/dev/null; echo '---'; cat .planning/milestone/*.md 2>/dev/null | head -80`

## 절차

> **선행:** `.claude/whale/config.json` 이 없으면 먼저 `/whale:init` 을 안내하고 멈춘다.

1. **범위 확인:** 위 마일스톤 범위에 "$ARGUMENTS" 가 포함되는가? 범위 밖이면 **즉시 멈추고** 사용자에게 확인을 요청한다. (프로젝트 CLAUDE.md 에 범위 규칙이 있으면 그것을 우선한다.)
2. **활성 흐름 충돌 확인:** state.md 에 이미 진행 중인 흐름이 있으면, 그것을 마치거나 보관할지 사용자에게 확인.
3. **state 기록:** `.claude/whale/state.md` 의 "활성 흐름" 블록을 Edit 으로 채운다 — Feature=$ARGUMENTS, Mode=A, 시작일=오늘, `config.json.modeA_chain` 의 모든 단계를 표로(1단계는 ▶ 진행중, 나머지 ⬜ 대기).
4. **첫 단계 dispatch:** `config.json.modeA_chain[0]` 역할(기본 **dba**)에 매핑된 agentType(`config.json.roles`)을 **Agent 툴로 dispatch** 한다. 에이전트는 플러그인이 제공하는 자기 정의의 선행조건·산출물 목록을 따른다. dba 의 입력은 **승인된 화면정의서/PRD + 기존 코드·스키마**.
5. 에이전트 완료 후, 산출물 요약과 함께 "다음 단계 진행은 `/whale:next`" 를 안내한다.

**규칙:** 체인 순서·역할명은 반드시 `config.json` 에서 읽는다(하드코딩 금지). 자동 체인은 구현·검증 4역할(dba→be→fe→qa)뿐이며, 기획·디자인·도메인 검토가 필요하면 `/whale:plan|design|domain` 으로 온디맨드 호출한다. 각 단계는 선행 단계 산출물 완료가 전제다.
