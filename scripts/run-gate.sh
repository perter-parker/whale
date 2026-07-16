#!/usr/bin/env bash
# whale run-gate — PostToolUse(Edit|Write) 게이트 훅.
# detect-stack 으로 lint/typecheck/test 명령을 얻어 실행하고, 실패 시 exit 2 로 차단한다.
# 모드(WHALE_GATE_MODE 또는 인자):
#   lint-only (기본, 무인 안전·빠름) : lint + typecheck 만. 전체 test 는 QA phase 위임.
#   full        : lint + typecheck + test
#   changed-only: lint + typecheck (test 는 변경 관련만 — 프로젝트가 지원할 때)
#   off         : 아무 것도 안 함(통과)
# exit: 0 통과 / 2 게이트 실패(차단, stderr 사유)
set -uo pipefail

mode="${WHALE_GATE_MODE:-${1:-lint-only}}"
[ "$mode" = "off" ] && exit 0

here="$(cd "$(dirname "$0")" && pwd)"
detect="$here/detect-stack.sh"
[ -x "$detect" ] || detect="bash $detect"

# detect-stack 출력 파싱
eval "$($detect . 2>/dev/null | sed 's/^/WHALE_/')" 2>/dev/null || true
lint="${WHALE_LINT:-}"; test_cmd="${WHALE_TEST:-}"; tc="${WHALE_TYPECHECK:-}"

# 스택 미감지면 조용히 통과(하드코딩 강요 금지 — hooks-init 이 config.hooks.gate.commands 로 채우도록)
[ -z "$lint$test_cmd$tc" ] && exit 0

fail() { echo "🛑 whale-gate 실패: $1" >&2; echo "   수정 후 다시 시도하세요." >&2; exit 2; }
run() { # $1=label $2=cmd
  [ -z "$2" ] && return 0
  echo "· whale-gate: $1 ($2)" >&2
  sh -c "$2" >/dev/null 2>&1 || fail "$1 — $2"
}

run "lint" "$lint"
run "typecheck" "$tc"
case "$mode" in
  full) run "test" "$test_cmd" ;;
  *)    : ;;  # lint-only / changed-only: 전체 test 미실행
esac

exit 0
