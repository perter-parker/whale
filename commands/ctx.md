---
description: 현재 대화 컨텍스트 사용량(토큰 %)을 측정하고 전환 시점 권고
allowed-tools: Bash
---
# /whale:ctx — 컨텍스트 사용량 체크

## 현재 세션 측정

!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/ctx-check.sh"`

## 출력 해석 및 권고

위 측정 결과를 기반으로 아래 기준에 따라 권고한다:

| 구간 | 상태 | 권고 액션 |
|------|------|----------|
| 0–50% | ✅ GREEN | 그대로 진행 |
| 50–75% | ⚠️ YELLOW | `/compact` 로 대화 압축 후 계속 |
| 75–90% | 🔴 RED | 현재 작업 저장 → 새 대화에서 `state.md` 참조해 재개 |
| 90%+ | 🆘 CRITICAL | 즉시 새 대화 시작. 핵심 컨텍스트만 복사 |

**새 대화 재개 방법:**
- `.claude/whale/state.md` 에 진행 상태가 기록되어 있으므로 `/whale:status` 로 복원 가능
- 새 대화 첫 메시지: "이어서 작업합니다. `.claude/whale/state.md` 를 확인하세요."

**규칙:** 측정값만 보고한다 — 에이전트를 dispatch 하거나 파일을 수정하지 않는다.
