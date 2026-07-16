#!/usr/bin/env bash
# whale guard — PreToolUse(Bash) 위험명령 차단 훅.
# Claude Code 는 PreToolUse hook 에 도구 입력을 JSON 으로 stdin 전달한다.
#   { "tool_input": { "command": "..." }, ... }
# exit code 규약:
#   0 = 통과(안전)
#   2 = 차단 → stderr 사유가 Claude 에게 전달되고 도구 실행 취소 (whale 무인 안전 핵심)
#   1 = 가드 자체 오류 → 기본은 통과(작업을 막지 않음). WHALE_GUARD_FAIL_CLOSED=1 이면 차단.
set -uo pipefail

fail_closed="${WHALE_GUARD_FAIL_CLOSED:-0}"

# --- stdin payload 에서 command 추출 (jq 있으면 사용, 없으면 grep 폴백) ---
payload="$(cat 2>/dev/null || true)"
cmd=""
if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // .command // empty' 2>/dev/null || true)"
fi
if [ -z "$cmd" ]; then
  # 폴백: "command":"..." 첫 매치 (완벽하진 않지만 jq 부재 환경 방어)
  cmd="$(printf '%s' "$payload" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p' | head -1)"
fi

# command 를 못 뽑으면 판단 불가 → 정책에 따름
if [ -z "$cmd" ]; then
  if [ "$fail_closed" = "1" ]; then
    echo "whale-guard: command 파싱 실패(fail-closed) — 차단" >&2
    exit 2
  fi
  exit 0
fi

block() {
  echo "🛑 whale-guard 차단: $1" >&2
  echo "   명령: $cmd" >&2
  echo "   의도한 작업이면 사람이 직접 실행하세요(훅 우회 금지)." >&2
  exit 2
}

# --- 위험 패턴 (대소문자 무시) ---
lc="$(printf '%s' "$cmd" | tr '[:upper:]' '[:lower:]')"

# 파괴적 삭제: rm -rf 로 루트/홈/현재/와일드카드 삭제
if printf '%s' "$lc" | grep -Eq 'rm[[:space:]]+(-[a-z]*f[a-z]*[[:space:]]+)+(-[a-z]*[[:space:]]+)*(/|~|\$home|\.|\*)([[:space:]]|$)'; then
  block "재귀 강제 삭제(rm -rf) 대상이 루트/홈/현재/와일드카드"
fi
printf '%s' "$lc" | grep -Eq 'rm[[:space:]]+-[a-z]*r[a-z]*f|rm[[:space:]]+-[a-z]*f[a-z]*r' && \
  printf '%s' "$lc" | grep -Eq '(/|~|\*)([[:space:]]|$)' && block "위험한 재귀 강제 삭제"

# 보호 브랜치 강제 푸시
if printf '%s' "$lc" | grep -Eq 'git[[:space:]]+push.*(--force|[[:space:]]-f([[:space:]]|$))'; then
  printf '%s' "$lc" | grep -Eq '--force-with-lease' || block "git push --force (보호 브랜치 이력 파괴 위험). --force-with-lease 를 사용하거나 사람이 직접."
fi

# 히스토리 파괴
printf '%s' "$lc" | grep -Eq 'git[[:space:]]+filter-branch' && block "git filter-branch (히스토리 재작성)"
printf '%s' "$lc" | grep -Eq 'git[[:space:]]+clean[[:space:]]+-[a-z]*f[a-z]*d|git[[:space:]]+clean[[:space:]]+-[a-z]*d[a-z]*f' && block "git clean -fdx (미추적 파일 대량 삭제)"

# 프로덕션 마이그레이션 / DB 파괴
printf '%s' "$lc" | grep -Eq '(migrate[[:space:]]+deploy|flyway[[:space:]]+migrate|alembic[[:space:]]+upgrade)' && \
  printf '%s' "$lc" | grep -Eq 'prod|production' && block "프로덕션 마이그레이션 (비가역)"
printf '%s' "$lc" | grep -Eq 'drop[[:space:]]+(database|table|schema)' && block "DROP DATABASE/TABLE/SCHEMA"
printf '%s' "$lc" | grep -Eq 'truncate[[:space:]]+table' && block "TRUNCATE TABLE"
# WHERE 없는 DELETE
printf '%s' "$lc" | grep -Eq 'delete[[:space:]]+from[[:space:]]+[a-z0-9_."]+[[:space:]]*(;|$)' && block "WHERE 없는 DELETE FROM (전체 삭제)"

# 원격 스크립트 실행
printf '%s' "$lc" | grep -Eq '(curl|wget)[[:space:]].*\|[[:space:]]*(sudo[[:space:]]+)?(sh|bash|zsh)' && block "원격 스크립트 파이프 실행(curl|sh) — 공급망 위험"

# 인프라 파괴
printf '%s' "$lc" | grep -Eq 'terraform[[:space:]]+destroy' && block "terraform destroy (인프라 파괴)"
printf '%s' "$lc" | grep -Eq 'kubectl[[:space:]]+delete[[:space:]]+(namespace|ns)[[:space:]]' && block "kubectl delete namespace"
printf '%s' "$lc" | grep -Eq 'docker[[:space:]]+system[[:space:]]+prune[[:space:]]+-[a-z]*a[a-z]*f|docker[[:space:]]+system[[:space:]]+prune[[:space:]]+-[a-z]*f[a-z]*a' && block "docker system prune -af"

exit 0
