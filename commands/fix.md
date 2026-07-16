---
description: Mode B(피어) — 고정 순서 없이 이슈 성격에 맞는 에이전트(들)를 투입
argument-hint: <버그/이슈 설명>
allowed-tools: Read, Bash(ls:*), Bash(cat:*), Bash(git:*), Grep, Glob, Agent
---
# /whale:fix — Mode B 이슈 해결

이슈: **$ARGUMENTS**

## Whale 설정
@.claude/whale/config.json

## 절차

1. **분류:** 이슈가 어느 영역인지 판단한다 (BE/FE/도메인규칙/DB/테스트/디자인). 필요하면 코드를 빠르게 살펴 근본 원인을 파악.
2. **spec 영향 판단:** 이 변경이 다른 BC/에이전트에 영향을 주거나 기존 문서로 예측 불가능하면, **먼저 `/whale:spec-check`** 로 spec-first 절차를 거친다(프로젝트 CLAUDE.md "요구사항 변경 시 필수 절차").
3. **피어 투입:** Mode B 는 고정 순서가 없다. `config.json.roles` 에서 적합한 역할(들)을 골라 agentType 으로 Agent 툴 dispatch 한다. 예: API 불일치 → be-developer↔fe-developer, 테스트 실패 → qa→해당 개발자, 도메인 규칙 의문 → `/whale:domain`(온디맨드 검증/리뷰어), 기획·화면 의문 → `/whale:plan`·`/whale:design`(온디맨드). domain·planner·designer 는 자동 체인엔 없지만 Mode B 에선 필요 시 호출한다.
4. **재검증 판단:** 수정 영향 범위가 크면 qa 재검증이 필요한지 결정.

**규칙:** Mode B 는 state.md 의 Mode A 체인을 진행시키지 않는다(별개). 버그픽스·리팩토링은 spec 갱신 불필요할 수 있으나, 기능 변경이면 2번을 반드시 거친다.
