---
description: security-reviewer 에이전트를 단독 dispatch (SAST/SCA 보안 검토·머지 차단 판정)
argument-hint: <검토 대상 변경/기능 설명>
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

`config.json.roles["security"]` 에 매핑된 agentType(기본 **security-reviewer**)을 **Agent 툴로 dispatch** 한다.

작업: **$ARGUMENTS**

에이전트는 자기 정의(SAST 8항목·SCA 실존확인/취약/라이선스·사람 필수 게이트·머지 차단 기준·무인 안전 규율)를 따른다.

**선행:** `config.security` 가 있어야 한다 — 없으면 프로젝트가 보안 게이트를 안 쓰는 것으로 보고 "커버리지 공백" 표기 후 멈춘다. 활성 run 이 있으면 산출물을 `config.paths.runArtifacts/<run-id>/security.md` 에 쓴다(없으면 단독 실행 모드로 응답 본문에 리포트).

진행 시 VERDICT 요약(Critical n / High n / SCA 이슈 n / 사람게이트 HOLD 여부)과 핸드오프(qa 로 반환 — qa 가 종합 판정에 흡수, Critical/High → Blocker 승격 → 피드백 루프로 해당 전문가 재구현, 사람게이트 저촉 → 리더 보안 승인 대기)를 안내한다.
