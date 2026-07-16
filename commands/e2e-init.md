---
description: 프로젝트에 E2E 하네스(Playwright 설정·Helper 스켈레톤·fixture·AI 가이드)를 스캐폴드
argument-hint: (인자 없음)
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(mkdir:*), Bash(cp:*), Read, Write
---
# /whale:e2e-init — E2E 하네스 스캐폴드

whale 플러그인은 엔진(e2e-tester 에이전트)만 제공한다. **프로젝트별 E2E 하네스**(Playwright 설정·디자인시스템 매핑 Helper·fixture·AI 가이드)는 프로젝트 로컬에 둔다. 이 커맨드가 그 스켈레톤을 스캐폴드한다.

## 절차

1. **스택 감지:**
   !`cat package.json 2>/dev/null | grep -E '"(packageManager|name)"'; echo '---'; ls pnpm-lock.yaml package-lock.json yarn.lock 2>/dev/null`
   - lockfile 로 pnpm/npm/yarn 판별 → `runCommand`·`installCommand` 를 `pnpm|npx|yarn` 에 맞춰 결정(하드코딩 금지).
   - 프로젝트 **`CLAUDE.md`** 에서 디자인 시스템(shadcn/커스텀 DS 등)을 확인 → Helper 의 셀렉터 전략(role 우세 vs data-slot 매핑)을 그 DS 에 맞게 조정 안내.

2. **기존 확인:** `config.json.e2e.testDir`(기본 `tests/e2e/`) 또는 `playwright.config.*` 가 이미 있으면 **덮어쓰지 않는다.** 존재를 보고하고 사용자 조정 안내 후 멈춘다.

3. **스캐폴드 (플러그인 `templates/e2e/` → 프로젝트):** 기존 파일은 건너뛰고, 없는 것만 복사한다.
   - `${CLAUDE_PLUGIN_ROOT}/templates/e2e/playwright.config.ts` → `playwright.config.ts`
   - `${CLAUDE_PLUGIN_ROOT}/templates/e2e/tests/helpers/*.helper.ts` → `tests/helpers/`
   - `${CLAUDE_PLUGIN_ROOT}/templates/e2e/tests/fixtures/index.ts` → `tests/fixtures/index.ts`
   - `${CLAUDE_PLUGIN_ROOT}/templates/e2e/tests/e2e/example.spec.ts` → `tests/e2e/example.spec.ts`
   - `${CLAUDE_PLUGIN_ROOT}/templates/e2e/tests/README.e2e.md` → `tests/README.e2e.md` (**= AI 가이드**, e2e-tester 필독)
   - `${CLAUDE_PLUGIN_ROOT}/templates/e2e/github-workflow.yml` → `.github/workflows/e2e.yml` (CI 라벨 기반 실행)
   - 필요 디렉토리는 `mkdir -p` 로 먼저 생성.

4. **config.json 갱신 안내:** `.claude/whale/config.json` 에 `e2e` 블록과 `roles.e2e` 가 없으면 **추가하도록 안내**(플러그인 `templates/config.json` 의 `e2e` 스키마를 제시). init 과 달리 config 를 직접 덮어쓰지 않고, 없는 키만 추가 제안한다. 감지한 `runCommand`·`installCommand`·디자인시스템에 맞춰 값을 조정.

5. **의존성 설치 안내(실행하지 않음):** "`config.e2e.installCommand`(예: `pnpm add -D @playwright/test && npx playwright install`)를 실행하라"고 **안내만** 한다. 외부 의존성 설치는 **사용자 확인 필수**.

6. **완료 보고:** 생성 파일 경로 + "critical path 를 `config.e2e.criticalPaths` 또는 `plan.md` P5 에 적고 `/whale:e2e` 로 실행" + "Helper 셀렉터 전략을 디자인 시스템에 맞게 검토" 안내.

**규칙:** 기존 하네스 파일을 절대 덮어쓰지 않는다(사용자 데이터 보호). 스택(pnpm/npm/yarn)·디자인 시스템에 맞춰 runCommand·셀렉터 전략을 조정한다(하드코딩 금지). 의존성은 사용자 확인 후 설치한다.
