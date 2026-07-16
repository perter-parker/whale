---
description: 작업별 git worktree(폴더·브랜치 물리 격리)로 병렬 작업 세팅 (create|list|remove)
argument-hint: create <base> <name...> | list | remove <name> [--force]
allowed-tools: Bash(bash:*), Bash(git:*)
---
# /whale:worktree — 병렬 worktree 오케스트레이션

터미널 여러 개로 병렬 작업할 때 **하나의 워킹 디렉토리를 공유하면 소스가 섞이는 문제**를,
작업별 git worktree(폴더·브랜치 물리 격리)로 해결한다. 각 worktree 폴더에서 터미널을 열면
그 안의 whale 에이전트 팀은 자기 폴더·자기 브랜치만 본다 — checkout 충돌도, 내용 섞임도 없다.

## 실행

다음을 **Bash 로 실행**하고 결과를 그대로 요약한다:

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/whale-worktree.sh" $ARGUMENTS
```

- **create `<base-branch> <name...>`** — `../<repo>-<name>` 폴더를 `feature/<name>` 브랜치로 생성하고,
  스택을 감지해 의존성을 설치하며, `.env.worktree`(PORT=3001, 3002…)를 만든다.
  예: `/whale:worktree create main login payment search notice`
- **list** — 현재 worktree 목록(+ PORT).
- **remove `<name>` [--force]** — 작업 끝난 worktree 정리(브랜치는 유지).

## 실행 후 안내

create 완료 시, 사용자에게 각 폴더에서 터미널을 하나씩 열라고 안내한다:

```
cd ../<repo>-login && claude      # feature/login
cd ../<repo>-payment && claude    # feature/payment
```

## 규칙 / 주의

- 이 명령은 **결정적 오케스트레이션**(폴더·브랜치 세팅)만 한다. 계약·리뷰·보안 같은 개발 지능은
  각 worktree 안의 taskforce 에이전트가 담당한다. 생애주기(Mode A)·run-id 와 **독립**이다.
- **whale 을 유저 레벨(`~/.claude/`)에 설치**하면 worktree 로 폴더가 갈라져도 모든 폴더의
  Claude Code 에서 whale 이 자동으로 붙는다(권장).
- worktree 가 **격리하지 못하는 것**: 의존성/빌드는 폴더마다 따로(전역 캐시 매니저면 부담↓),
  같은 브랜치를 두 worktree 에서 동시 체크아웃 불가(git 이 막음), 로컬 DB/포트는 공유되면 충돌
  (`.env.worktree` 의 PORT 를 참고해 dev 서버를 다르게 띄우기).
- **머지 차단 게이트(테스트·보안 스캔)** 는 이 명령이 아니라 CI(`.gitlab-ci.yml` 등)에서 강제하라.
  새 worktree 에 `.claude/whale/config.json` 이 없으면(=git 미커밋) 그 폴더에서 `/whale:init` 을 먼저 실행한다.
