# <프로젝트명> — 개발 규약 (CLAUDE.md)

> whale 워크플로 에이전트(researcher·planner·dba·be·fe·reviewer·qa·security·summarizer)가 **작업 전 필독**하는 프로젝트 단일 규약.
> 방법론(컨텍스트 격리·피드백 루프·계약 우선 등)은 플러그인에 내장. 이 파일은 **이 프로젝트 고유의 값**(스택·경로·동결 대상·계약 위치·아키텍처)을 담는다.
> whale 은 특정 아키텍처·표준을 강제하지 않는다. 도메인 특화(예: 공공기관 행안부 표준)는 `config.profile` 로 켤 때만 적용된다.
> `/whale:init` 이 부재 시 이 템플릿을 복사한다. 값을 채워라.

## 0. 기본 개발 방식 (whale 라우팅)

이 프로젝트의 개발은 **기본적으로 whale 에이전트 생애주기로 진행**한다. 슬래시 커맨드를 명시하지 않아도 아래를 따른다:

- **새 기능·비자명한 개발 요청** → whale 생애주기: **researcher → planner → ⛔승인 게이트(사람이 `APPROVED` 명시) → dba/be/fe(TDD) → reviewer → qa(+조건부 e2e·security) → summarizer.** 계획 후 승인 게이트에서 반드시 멈춘다(임의 통과 금지).
- **단일 성격 작업** → 해당 전문가로 바로: DB=dba · 백엔드=be · 프론트=fe · 리뷰=reviewer · 보안=security-reviewer · 테스트=qa/e2e-tester · 리팩터=refactor.
- **버그·이슈** → Mode B(피어). **여러 기능/도메인을 병렬로 진행** → git worktree 물리 격리를 먼저 제안·세팅(`/whale:worktree create` 또는 `whale-worktree.sh`). 폴더·의존성 설치 부작용이 있으니 사용자 확인 후 실행.
- **사소한 작업**(오타·1줄·질문)은 생애주기 없이 바로.
- **plan 모드**에서는 계획을 whale 7섹션(P1~P7) 구조로 산출하고 각 파트의 실행 전문가를 명시한다.

> 상태 추적(run-id·게이트)이 필요하면 `/whale:start`로 시작한다. 커맨드를 안 써도 순서·승인 게이트는 동일하게 지킨다.

## 1. 기술 스택
- 백엔드: <예: Spring Boot 3 / NestJS>
- 프론트엔드: <예: Next.js / React + TanStack Query>
- DB / 마이그레이션: <예: PostgreSQL / Flyway V{N}__*.sql>
- 패키지 매니저: <pnpm | npm | gradle | poetry>  ← hooks 게이트 명령의 기준(`/whale:hooks-init`)
- 테스트 / 커버리지: <프레임워크 / 최소 커버리지 기준 %>

## 2. 아키텍처 (이 프로젝트가 결정 — whale 은 강제하지 않음)
- **채택 아키텍처:** <예: 레이어드(Controller→Service→Repository) | 피처 슬라이스(`features/<name>/`) | 헥사고날 | …>
- **전술 DDD**(Aggregate/VO/Domain Event) 적용 모듈: <없음 | 모듈명> — 그 외 모듈엔 무단 도입 금지.
- **도메인 프로필:** `config.profile.domain` = <general(기본) | public-sector-kr(행안부 DB 표준·PII 암호화 등)>, `multitenant` = <false | true(site_id 격리)>.
- 모듈 간 참조 원칙: <예: 직접 import | ID 참조 + Application Service | 이벤트>.

## 3. 계약 단일 진실원 (Contract SSOT) — 부분수정 방지의 핵심
레이어 경계마다 "진실은 여기 하나"를 못박는다. 파생물은 여기서 생성(codegen)하거나 이 표를 따라 손수 동기화한다.

| 경계 | SSOT (원본) | 파생물 (따라가는 것) | 생성/동기화 방법 |
|------|-------------|----------------------|------------------|
| API 계약 | <OpenAPI yaml 경로 / BE DTO> | FE 타입·API 클라이언트 | <openapi-typescript 등 codegen \| 수동> |
| DB 스키마 | <마이그레이션 DDL 경로> | 엔티티·타입 | migration-first |
| 도메인 타입 | <BE 스키마 / zod / proto> | FE 모델 | <codegen> |
| IaC | <terraform 경로> | 환경설정 | plan-first |

> 규칙: SSOT 를 바꾸면 **같은 커밋에서** 파생물을 갱신한다. 파생물만 손대는 것은 드리프트 = 금지.
> 이 표는 `.claude/whale/config.json` 의 `contracts.ssot` 와 정합해야 한다.

## 4. 완료 게이트 (Definition of Done)
작업은 아래를 **전부** 통과해야 "완료"다. hooks(`/whale:hooks-init`)가 일부를 자동 강제한다.
- [ ] 테스트 GREEN (커버리지 기준 유지)
- [ ] 린트 0 error (arbitrary value·raw 복붙 금지)
- [ ] 복잡도/중복 임계 이내 (<도구·임계>)
- [ ] 보안: 시크릿 하드코딩 없음·입력검증·RBAC·민감정보 평문 노출 없음 (민감 변경은 security-reviewer + 사람 승인. 공공기관 프로필이면 PII 저장 암호화 추가)
- [ ] 계약 SSOT 와 파생물 정합 (드리프트 0)
- [ ] 동결 대상 무변경 / 회귀 없음

## 5. 동결(수정 금지) 대상
- 스키마 / 모듈: <없음 | 목록>
- 마이그레이션: V{N} 이하 무수정(append-only)
- 변경이 필요하면 [변경-게이트]로 리더 승인 후.

## 6. 교차-run 메모리 파일 (누적 학습)
경로는 `.claude/whale/config.json.paths` 기준. `/whale:init` 이 스캐폴드.
- **PROGRESS.md** — 진행 로그.
- **DECISIONS.md** — 결정 + 이유(ADR-lite). planner/be/fe 가 append.
- **LessonsLearned.md** — 반복 실패 패턴. reviewer 가 append, summarizer 가 정리.

## 7. 모듈 문서 관례 (FEATURE.md)
각 핵심 모듈 루트에 `FEATURE.md` 를 둔다(템플릿: 플러그인 `templates/FEATURE.md`).
owns / does-not-own / 진입점 / 발행 이벤트 / 외부 의존성을 명시.
researcher 가 **최우선**으로 읽고, planner 가 영향 범위 판정에 참조한다(부분수정 방지).

## 8. 커밋 / 브랜치
- <Git Flow / 커밋 컨벤션>. 하나의 커밋 = 하나의 목적.
- 외부 라이브러리 추가는 **사용자 확인 필수**(공급망·라이선스).
