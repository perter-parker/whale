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
   - `mkdir -p .claude/whale/runs` (run-id 별 산출물 저장 루트 = `paths.runArtifacts`)
   - `mkdir -p .claude/whale/memory` (교차-run 메모리 = `paths.progress/decisions/lessonsLearned`)
   - 플러그인 템플릿을 프로젝트로 복사:
     - `${CLAUDE_PLUGIN_ROOT}/templates/config.json` → `.claude/whale/config.json`
     - `${CLAUDE_PLUGIN_ROOT}/templates/state.md` → `.claude/whale/state.md`
   - 교차-run 메모리 스켈레톤 생성(존재 시 스킵): `.claude/whale/memory/{PROGRESS,DECISIONS,LessonsLearned}.md` (각 파일에 제목 헤더 1줄).
   - 프로젝트 루트 `CLAUDE.md` **부재 시에만** `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md` 복사(존재 시 절대 덮어쓰지 않음 — 사용자 규약 보호).
   - (복사 후) `config.json` 을 Read 로 확인.

4. **프로젝트에 맞게 조정 안내:** 복사한 `config.json` 을 열어 다음을 이 프로젝트에 맞게 확인/수정하도록 안내한다:
   - `lifecycle.phases` / `domainExperts` / `roles` — 생애주기 phase 구성, implement 가 부르는 도메인 전문가, 역할↔agentType 매핑. (플러그인 에이전트가 `whale:dba` 처럼 네임스페이스로 노출되면 그 값으로 교체.)
   - `approvalGate` / `feedbackLoop` — 승인 문구 규칙, 재시도 상한(기본 1).
   - `runId` — run-id 형식(티켓번호 체계 등으로 커스터마이즈 가능).
   - `contracts.ssot` / `coverage` — 계약 단일 진실원(경계·원본·파생물·codegen), qa 여정 커버리지 지표. CLAUDE.md §3 과 정합.
   - `security` / `roles.security` — 보안 게이트(SAST/SCA·사람 필수 게이트·머지 차단). 안 쓰면 이 블록을 비우면 된다.
   - `refactor` / `roles.refactor` — 부채 상환 임계·리포트 경로(온디맨드/주기).
   - `scopeDir` — 마일스톤 범위 문서 디렉토리.
   - `paths.*` — `runArtifacts`·`decisions`·`lessonsLearned`·`claudeMd`·`featureDoc` + (선택) 화면정의서·PRD·프로토타입 경로.
   - `e2e` / `roles.e2e` — E2E 를 쓰면 `/whale:e2e-init` 로 Playwright 하네스와 `config.e2e` 블록을 별도 스캐폴드한다.
   - `reviewer` — 최종 검수자.

5. **완료 보고:** 생성한 파일 경로 + 다음 안내:
   - "**슬래시 없이 자동 진행**: whale Output Style(플러그인 내장, force-for-plugin)이 켜지면 개발 요청이 자동으로 whale 생애주기로 라우팅된다. 켜졌는지는 `/output-style` 로 확인·전환. 전역 적용은 `~/.claude/CLAUDE.md` 에 whale 라우팅 블록(플러그인 `templates/user-CLAUDE-snippet.md`)을 추가."
   - "**강제 게이트**를 쓰려면 `/whale:hooks-init` 실행(스택 감지→`.claude/settings.json` 병합)."
   - "**CLAUDE.md §3 계약 SSOT·§7 FEATURE.md**(각 핵심 모듈에 `templates/FEATURE.md` 참고 배치)를 채우라."
   - "이제 `/whale:start <task>` 로 생애주기 루프를 시작할 수 있다."

**규칙:** 기존 `config.json`·`state.md`·`CLAUDE.md`·메모리 파일을 절대 덮어쓰지 않는다(사용자 데이터 보호). 없을 때만 생성한다. FEATURE.md 는 위치가 프로젝트마다 달라 자동 생성하지 않고 안내만 한다.
