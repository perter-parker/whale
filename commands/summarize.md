---
description: summarizer 에이전트를 단독 dispatch (작업 결과지·PR 디스크립션)
argument-hint: <요약 대상 설명>
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["summarizer"]` 에 매핑된 agentType(기본 **summarizer**)을 **Agent 툴로 dispatch** 한다.

작업: **$ARGUMENTS**

에이전트는 자기 정의(변경파일·TDD사이클·리뷰이슈·QA결과·완료체크리스트를 PR 디스크립션 형식으로 종합, 기록만·코드 미수정)를 따른다. 활성 run 이 있으면 `runs/<run-id>/summary.md` 에 쓴다. 진행 시 결과지 요약과 함께 `config.json.reviewer`(리더) 최종 병합 검수를 안내한다.
