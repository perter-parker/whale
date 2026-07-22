#!/usr/bin/env bash
# whale-worktree — 작업별 git worktree(폴더·브랜치 물리 격리)로 병렬 작업을 세팅한다.
# 터미널 여러 개가 하나의 워킹 디렉토리를 공유해 소스가 섞이는 문제를 해결한다.
#
# Usage:
#   whale-worktree.sh create <base-branch> <name...> [--no-install] [--branch-prefix <p>]
#   whale-worktree.sh list
#   whale-worktree.sh remove <name> [--force]
#   whale-worktree.sh help
#
# 설계: 결정적 오케스트레이션(폴더/브랜치 세팅)만 담당. 파괴적 명령(rm -rf) 대신
#       git worktree 서브커맨드만 사용한다(기존 whale guard 훅과 충돌 없음).
set -uo pipefail

BRANCH_PREFIX="feature/"
BASE_PORT="${WHALE_BASE_PORT:-3000}"

here="$(cd "$(dirname "$0")" && pwd)"
DETECT="$here/detect-stack.sh"

die(){ echo "❌ $*" >&2; exit 1; }
info(){ echo "· $*"; }

require_git_repo(){
  git rev-parse --show-toplevel >/dev/null 2>&1 || die "git 저장소가 아닙니다. 저장소 루트에서 실행하세요."
}

repo_root(){ git rev-parse --show-toplevel; }
repo_name(){ basename "$(repo_root)"; }
parent_dir(){ dirname "$(repo_root)"; }

# 스택 감지로 의존성 설치 명령을 결정(하드코딩 금지 — detect-stack 재사용)
install_cmd(){
  local dir="$1" pm=""
  if [ -x "$DETECT" ]; then
    pm="$(bash "$DETECT" "$dir" 2>/dev/null | sed -n 's/^PM=//p')"
  fi
  case "$pm" in
    pnpm)  echo "pnpm install" ;;
    yarn)  echo "yarn install" ;;
    npm)   echo "npm install" ;;
    python)
      if [ -f "$dir/poetry.lock" ] || [ -f "$dir/pyproject.toml" ]; then echo "poetry install";
      elif [ -f "$dir/requirements.txt" ]; then echo "pip install -r requirements.txt"; fi ;;
    gradle) [ -x "$dir/gradlew" ] && echo "./gradlew dependencies" || echo "gradle dependencies" ;;
    maven)  echo "mvn -q dependency:resolve" ;;
    *) echo "" ;;
  esac
}

# ── create ──────────────────────────────────────────────
cmd_create(){
  require_git_repo
  local no_install=0
  local args=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --no-install) no_install=1; shift ;;
      --branch-prefix) BRANCH_PREFIX="$2"; shift 2 ;;
      *) args+=("$1"); shift ;;
    esac
  done
  [ "${#args[@]}" -ge 2 ] || die "사용법: create <base-branch> <name...>  (예: create main login payment)"

  local base="${args[0]}"
  local names=("${args[@]:1}")
  local repo parent root
  repo="$(repo_name)"; parent="$(parent_dir)"; root="$(repo_root)"

  # base 브랜치 존재 확인(로컬 또는 원격)
  if ! git show-ref --verify --quiet "refs/heads/$base" \
     && ! git show-ref --verify --quiet "refs/remotes/origin/$base"; then
    die "base 브랜치 '$base' 를 찾을 수 없습니다. (git branch -a 로 확인)"
  fi

  echo "🐳 worktree 생성 — repo=$repo · base=$base · ${#names[@]}개"
  local i=0 made=0
  for name in "${names[@]}"; do
    i=$((i+1))
    local branch="${BRANCH_PREFIX}${name}"
    local dir="$parent/$repo-$name"
    local port=$((BASE_PORT + i))

    echo
    echo "▶ $name → $dir  (branch: $branch, PORT: $port)"

    if [ -e "$dir" ]; then
      echo "  ⚠️  폴더가 이미 존재 — 건너뜀"
      continue
    fi

    # 브랜치가 있으면 재사용, 없으면 base 에서 새로 생성
    if git show-ref --verify --quiet "refs/heads/$branch"; then
      if ! git worktree add "$dir" "$branch" 2>/tmp/wt_err; then
        echo "  ⚠️  실패(브랜치가 다른 worktree에 체크아웃됐을 수 있음): $(cat /tmp/wt_err)"; continue
      fi
    else
      if ! git worktree add "$dir" -b "$branch" "$base" 2>/tmp/wt_err; then
        echo "  ⚠️  실패: $(cat /tmp/wt_err)"; continue
      fi
    fi
    made=$((made+1))

    # .env.worktree (기존 .env 는 건드리지 않음)
    cat > "$dir/.env.worktree" <<EOF
# whale worktree 환경 (dev 서버 포트 충돌 방지용 — 프로젝트 방식으로 로드하세요)
PORT=$port
WHALE_WORKTREE=$name
WHALE_BRANCH=$branch
EOF
    # whale 마커를 로컬 exclude 에 등록(git status 오염·remove 차단 방지)
    local excl; excl="$(git -C "$dir" rev-parse --git-path info/exclude 2>/dev/null || true)"
    if [ -n "$excl" ] && ! grep -qxF '.env.worktree' "$excl" 2>/dev/null; then
      echo '.env.worktree' >> "$excl"
    fi
    echo "  ✓ .env.worktree (PORT=$port)"

    # 의존성 설치 (best-effort)
    if [ "$no_install" -eq 0 ]; then
      local ic; ic="$(install_cmd "$dir")"
      if [ -n "$ic" ]; then
        echo "  · 의존성 설치: $ic"
        ( cd "$dir" && sh -c "$ic" ) >/dev/null 2>&1 \
          && echo "  ✓ 설치 완료" \
          || echo "  ⚠️  설치 실패(수동으로 '$ic' 실행) — 계속 진행"
      else
        echo "  · 스택 미감지 — 의존성 설치 생략(수동 설치)"
      fi
    fi

    # whale 상태 감지(자동 시드 안 함 — 안내만)
    if [ -f "$dir/.claude/whale/config.json" ]; then
      echo "  ✓ whale 준비됨(.claude/whale/config.json)"
    else
      echo "  · whale 미초기화 — 이 폴더에서 '/whale:init' 실행 권장"
    fi
  done

  echo
  echo "✅ 완료: $made/$((${#names[@]})) worktree 생성"
  echo "다음: 각 폴더에서 터미널을 하나씩 여세요"
  for name in "${names[@]}"; do
    echo "   cd \"$parent/$repo-$name\" && claude    # ${BRANCH_PREFIX}${name}"
  done
}

# ── list ────────────────────────────────────────────────
cmd_list(){
  require_git_repo
  echo "🐳 worktree 목록"
  git worktree list | while IFS= read -r line; do
    local path; path="$(echo "$line" | awk '{print $1}')"
    local port=""
    [ -f "$path/.env.worktree" ] && port="$(sed -n 's/^PORT=//p' "$path/.env.worktree")"
    if [ -n "$port" ]; then echo "  $line   (PORT=$port)"; else echo "  $line"; fi
  done
}

# ── remove ──────────────────────────────────────────────
cmd_remove(){
  require_git_repo
  local force=0 name=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --force|-f) force=1; shift ;;
      *) name="$1"; shift ;;
    esac
  done
  [ -n "$name" ] || die "사용법: remove <name> [--force]"

  local repo parent dir branch
  repo="$(repo_name)"; parent="$(parent_dir)"
  dir="$parent/$repo-$name"; branch="${BRANCH_PREFIX}${name}"

  [ -d "$dir" ] || die "worktree 폴더가 없습니다: $dir  (list 로 확인)"

  # whale 이 만든 마커는 우리가 정리(사용자 작업물이 아님)
  rm -f "$dir/.env.worktree"

  if [ "$force" -eq 1 ]; then
    git worktree remove --force "$dir" || die "제거 실패: $dir"
  else
    if ! git worktree remove "$dir" 2>/tmp/wt_err; then
      echo "⚠️  제거 실패(커밋 안 된 변경이 있을 수 있음): $(cat /tmp/wt_err)" >&2
      echo "   강제로 지우려면: whale-worktree.sh remove $name --force" >&2
      exit 1
    fi
  fi
  git worktree prune
  echo "✅ worktree 제거: $dir"
  echo "   브랜치 '$branch' 는 남아있습니다(머지 후 삭제: git branch -d $branch)"
}

usage(){
  cat <<'EOF'
🐳 whale-worktree — 작업별 git worktree 병렬 오케스트레이션

  create <base-branch> <name...> [--no-install] [--branch-prefix <p>]
      ../<repo>-<name> 폴더를 feature/<name> 브랜치로 생성하고 의존성 설치.
      예) create main login payment search notice

  list
      현재 worktree 목록(+ .env.worktree PORT).

  remove <name> [--force]
      작업 끝난 worktree 정리(브랜치는 유지).

주의: worktree는 폴더·브랜치만 격리한다. 의존성/빌드는 폴더마다 따로,
      dev 서버 포트는 .env.worktree(PORT=3001,3002…)를 참고해 다르게 띄우고,
      머지 차단(테스트·보안)은 CI에서 강제하라.
EOF
}

sub="${1:-help}"; shift || true
case "$sub" in
  create) cmd_create "$@" ;;
  list)   cmd_list "$@" ;;
  remove) cmd_remove "$@" ;;
  help|-h|--help|"") usage ;;
  *) echo "알 수 없는 서브커맨드: $sub" >&2; usage; exit 1 ;;
esac
