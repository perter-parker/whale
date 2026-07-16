---
description: 화면설계서(명세↔구현 허브) 작성 — 역할별 섹션 dispatch
argument-hint: <화면ID> [섹션 또는 역할: domain|dba|design|api|fe | 생략 시 현재 체인 단계]
allowed-tools: Read, Bash, Grep, Glob, Agent
---
@.claude/whale/config.json

화면설계서는 **한 파일을 5개 역할이 섹션별로 나눠 작성**하는 명세↔구현 교차 허브다.
승인된 화면정의서(`config.json.paths.screenSpecs`/`{화면ID}_*_화면정의서.md`)를 설계로 **번역**한다 (발명 금지).

대상: **$ARGUMENTS**

## 절차 (경로는 모두 `config.json.paths` 에서 읽는다)

1. 템플릿 `config.json.paths.screenDesignTemplate` 를 SSOT로 사용.
2. 대상 화면설계서 파일이 없으면 `config.json.paths.screenDesigns`/`{화면ID}_{화면명}_화면설계서.md` 로 템플릿 복사 생성(머리말 표 + §1·§8·§9 골격).
3. 작성할 섹션의 **소유 역할만** agentType 으로 Agent 툴 dispatch (다른 섹션은 건드리지 않는다):

   | 인자 | 섹션 | 역할(config.json.roles) |
   |------|------|------------------------|
   | `domain` | §2 도메인 | domain-expert |
   | `dba` | §3 데이터 | dba |
   | `design` | §4 화면·디자인 | designer |
   | `api` | §5 API | be-developer |
   | `fe` | §6 프론트 구조 | fe-developer |

   인자 생략 시 `state.md` 의 현재 진행 단계 역할을 사용.
4. 각 역할은 **기준문서 3원칙**으로 작성: 있으면 실명 [참조] · 없으면 [추가] · 변경은 [변경-게이트]→§9. 동결(프로젝트 CLAUDE.md 에 명시된 수정 금지 스키마·모듈) 직접 변경 금지.
5. 예외 분류: 명세에 없던 기술 선택 [설계결정]→§7, 명세 공백 [확인필요]→§9.2.
6. 작성한 역할은 §8 추적표의 자기 열을 채운다.

## 완료 보고

- 작성한 섹션 · 파일 경로
- §7 설계결정 N건 / §9 변경-게이트 N건 / 확인필요 N건
- §8 추적표 매핑 상태(누락·발명 행 유무)
- 다음 섹션 소유 역할 안내. 체인 진행은 `/whale:next`(설계 게이트 통과 시 핸드오프).
