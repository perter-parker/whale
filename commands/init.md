---
description: 현재 프로젝트에 whale 상태·설정 파일(.claude/whale/)을 스캐폴드
argument-hint: (인자 없음)
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(mkdir:*), Bash(cp:*), Read, Write
---
# /whale:init — 프로젝트에 whale 초기화

whale 플러그인은 **엔진(명령어·에이전트)**만 제공한다. 역할 매핑·체인 순서·문서 경로 같은 **프로젝트별 값**과 **흐름 상태**는 프로젝트 로컬에 둔다. 이 명령어가 그 두 파일을 스캐폴드한다.

## 절차

1. **현재 상태 확인:**
   !`ls -la .claude/whale/ 2>/dev/null || echo '(.claude/whale/ 없음 — 신규 생성)'`

2. **이미 존재하면:** `.claude/whale/config.json` 이 이미 있으면 **덮어쓰지 않는다.** 존재를 보고하고, 필요 시 사용자가 직접 수정하도록 안내하고 멈춘다.

3. **없으면 스캐폴드:**
   - `mkdir -p .claude/whale`
   - 플러그인 템플릿을 프로젝트로 복사:
     - `${CLAUDE_PLUGIN_ROOT}/templates/config.json` → `.claude/whale/config.json`
     - `${CLAUDE_PLUGIN_ROOT}/templates/state.md` → `.claude/whale/state.md`
   - (복사 후) `config.json` 을 Read 로 확인.

4. **프로젝트에 맞게 조정 안내:** 복사한 `config.json` 을 열어 다음을 이 프로젝트에 맞게 확인/수정하도록 안내한다:
   - `modeA_chain` / `roles` — 이 프로젝트의 자동 체인 순서와 역할↔agentType 매핑. (플러그인 에이전트가 `whale:dba` 처럼 네임스페이스로 노출되면 그 값으로 교체.)
   - `scopeDir` — 마일스톤 범위 문서 디렉토리.
   - `paths.*` — 화면정의서/설계서·PRD·프로토타입 경로.
   - `reviewer` — 최종 검수자.

5. **완료 보고:** 생성한 파일 경로 + "이제 `/whale:start <feature>` 로 Mode A 를 시작할 수 있다" 안내.

**규칙:** 기존 `config.json`·`state.md` 를 절대 덮어쓰지 않는다(사용자 데이터 보호). 없을 때만 생성한다.
