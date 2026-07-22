<!-- WHALE-ROUTING:START — whale 워크플로 전역 라우팅 (제거하려면 이 블록을 지우세요) -->
## whale 워크플로 (기본 개발 방식)

whale 플러그인이 설치된 프로젝트에서는, 슬래시 커맨드를 명시하지 않아도 개발을 **whale 에이전트 생애주기로 기본 진행**한다:

- **새 기능·비자명한 개발** → researcher → planner → **⛔승인 게이트(사람이 `APPROVED` 명시)** → dba/be/fe(TDD) → reviewer → qa(+조건부 e2e·security) → summarizer. 계획 후 승인 게이트에서 반드시 멈춘다. **(이 풀체인 = full 티어.)**
- **강도 티어로 경량화(config.modes)**: 작은 신규(단일 파일·기존 패턴·계약/보안 무관) → **fast**(implement+hooks 만). 신규 API/DB 컬럼/화면·단일 BC → **normal**(plan→approve→implement→review→qa 경량). 아키텍처·인증·다중BC·breaking → **full**. 인증·암호화·입력검증·결제 변경이면 fast 여도 **최소 normal 자동 승격 + security 강제**.
- **단일 성격 작업** → 해당 whale 전문가로 바로(dba/be/fe/reviewer/security-reviewer/qa/e2e-tester/refactor/designer/domain-expert).
- **버그·이슈** → Mode B(피어, `/whale:fix`). 작은 **신규** 는 Fast 티어(`/whale:start`). **병렬 작업** → git worktree.
- **사소한 작업**(오타·1줄·질문)은 생애주기 없이 바로.
- 프로젝트 `CLAUDE.md`의 계약 SSOT·동결 대상·완료 게이트를 존중한다.

> 이 블록은 whale 플러그인의 `templates/user-CLAUDE-snippet.md` 에서 왔다. whale 미설치 프로젝트에서는 무시된다.
<!-- WHALE-ROUTING:END -->
