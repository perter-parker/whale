#!/usr/bin/env bash
# whale ctx-check — 현재 세션 컨텍스트 사용량 측정
# Usage: ctx-check.sh [ctx_limit]
# Requires: CLAUDE_CODE_SESSION_ID env var (Claude Code 자동 주입)

set -euo pipefail

CTX_LIMIT="${1:-200000}"
SESSION_ID="${CLAUDE_CODE_SESSION_ID:-}"

if [[ -z "$SESSION_ID" ]]; then
  echo "ERROR: CLAUDE_CODE_SESSION_ID not set (Claude Code 세션 외부에서 실행됨)" >&2
  exit 1
fi

# /a/b/c → -a-b-c (Claude 프로젝트 경로 인코딩)
PROJECT_KEY=$(echo "$PWD" | tr '/' '-')
JSONL="$HOME/.claude/projects/${PROJECT_KEY}/${SESSION_ID}.jsonl"

if [[ ! -f "$JSONL" ]]; then
  echo "ERROR: 세션 JSONL 파일 없음: $JSONL" >&2
  exit 1
fi

export _CTX_JSONL="$JSONL"
export _CTX_LIMIT="$CTX_LIMIT"
export _CTX_SESSION="${SESSION_ID:0:8}"

python3 - << 'PYEOF'
import json, os

jsonl     = os.environ['_CTX_JSONL']
ctx_limit = int(os.environ['_CTX_LIMIT'])
session   = os.environ['_CTX_SESSION']

last_ctx = last_inp = last_cc = last_cr = last_out = 0
total_inp = total_out = total_cc = total_cr = 0
turns = 0
cost  = 0.0

for line in open(jsonl):
    d = json.loads(line)
    if d.get('type') == 'assistant':
        u = d.get('message', {}).get('usage', {})
        if u:
            inp = u.get('input_tokens', 0)
            cc  = u.get('cache_creation_input_tokens', 0)
            cr  = u.get('cache_read_input_tokens', 0)
            out = u.get('output_tokens', 0)
            last_inp, last_cc, last_cr, last_out = inp, cc, cr, out
            last_ctx = inp + cc + cr
            total_inp += inp
            total_out += out
            total_cc  += cc
            total_cr  += cr
            turns += 1
    cost += d.get('costUSD', 0)

pct    = last_ctx / ctx_limit * 100
filled = min(int(pct / 5), 20)
bar    = '█' * filled + '░' * (20 - filled)

if   pct < 50: status = '✅ GREEN   — 여유 있음';   advice = '계속 진행 가능'
elif pct < 75: status = '⚠️  YELLOW  — 절반 초과'; advice = '/compact 로 압축 후 계속'
elif pct < 90: status = '🔴 RED     — 위험';       advice = '새 대화 전환 강력 권장'
else:          status = '🆘 CRITICAL — 임박';      advice = '지금 즉시 새 대화 시작'

print(f'세션    : {session}...')
print(f'턴 수   : {turns}')
print()
print(f'  [{bar}] {pct:.1f}%')
print(f'  현재 입력  : {last_ctx:>9,} / {ctx_limit:,} tokens')
print(f'  ├ 신규     : {last_inp:>9,}')
print(f'  ├ 캐시 생성: {last_cc:>9,}')
print(f'  └ 캐시 읽기: {last_cr:>9,}')
print(f'  누적 출력  : {total_out:>9,} tokens')
if cost > 0:
    print(f'  비용(USD)  : ${cost:.4f}')
print()
print(f'상태 : {status}')
print(f'권장 : {advice}')
PYEOF
