---
description: 프로젝트에 whale 강제 게이트(Hooks) 스캐폴드 — lint/test 게이트 + 위험명령 차단
argument-hint: (인자 없음)
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(mkdir:*), Bash(cp:*), Read, Write
---
# /whale:hooks-init — 강제 게이트(Hooks) 스캐폴드

whale 의 리뷰·QA·보안은 에이전트 "판단"이다. Hooks 는 "무조건 실행"이다 — lint·test·위험명령 차단을 **결정적으로 강제**해 권고를 강제로 바꾼다(야간 무인에 특히 중요).

이 커맨드는 프로젝트 **`.claude/settings.json`**(whale 상태 파일 `.claude/whale/` 과 다른 위치)에 훅을 스캐폴드한다.

## 절차

1. **스택 감지:**
   !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect-stack.sh" . 2>/dev/null`
   - 출력의 `LINT`/`TEST`/`TYPECHECK`/`BUILD` 를 `config.hooks.gate.commands` 에 채울 값으로 삼는다.
   - 전부 비어있으면(감지 실패) "스택 미감지 — `config.hooks.gate.commands` 를 수동 입력" 안내.

2. **config 확인:** `.claude/whale/config.json` 의 `hooks` 블록을 읽는다(없으면 `/whale:init` 먼저). `hooks.gate.commands` 에 이미 값이 있으면 그것을 우선(감지값으로 덮어쓰지 않음).

3. **settings.json 스캐폴드/병합 (덮어쓰기 금지):**
   - 현재 상태:
     !`cat .claude/settings.json 2>/dev/null || echo '(.claude/settings.json 없음 — 신규 생성 대상)'`
   - **없으면:** `mkdir -p .claude` 후 `${CLAUDE_PLUGIN_ROOT}/templates/hooks/settings.json` 을 `.claude/settings.json` 으로 복사한다.
   - **있으면:** 절대 덮어쓰지 않는다. 기존 `hooks.PreToolUse`/`hooks.PostToolUse` 배열에 whale 항목(guard·run-gate)을 **append 하는 병합안(JSON diff)** 을 화면에 제시하고, 사용자가 직접 반영하도록 안내한다. 동일 matcher 가 이미 있으면 중복 경고.

4. **게이트 모드 안내:** 기본은 `WHALE_GATE_MODE=lint-only`(PostToolUse 에서 lint+typecheck 만, 전체 test 는 QA phase 위임 — 무인 안전·빠름). 전체 강제가 필요하면 `full`, 끄려면 `off`. `config.hooks.gate.mode` 로도 관리.

5. **가드 안내:** PreToolUse(Bash) 는 `guard-dangerous-cmd.sh` 로 위험명령(`rm -rf /~.`·보호브랜치 강제푸시·prod 마이그레이션·`DROP/TRUNCATE`·`curl|sh`·`terraform destroy` 등)을 **exit 2 로 차단**한다. 공공기관 보수적 기본이 필요하면 `config.hooks.guard.failClosed=true`(가드 오류 시에도 차단).

6. **완료 보고:** 감지 스택·주입 명령·차단 위험명령 목록 + "이제 Edit/Write 시 lint 게이트가, Bash 시 위험명령 차단이 자동 실행된다" 안내.

**규칙:** `.claude/settings.json` 은 사람이 승인해 병합한다(무인 안전 — 덮어쓰기 금지). 명령은 스택 감지로 결정한다(하드코딩 금지). 의존성(린터·테스트 러너) 설치는 사용자가 직접.
