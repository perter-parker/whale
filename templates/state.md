# Whale — 활성 흐름 상태

> 이 파일은 `/whale:start`·`/whale:next`·`/whale:status` 가 읽고 쓰는 단일 상태 파일이다.
> Whale 워크플로(에이전트 체인 진행)만 추적한다. 마일스톤/요구사항 상태는 프로젝트의 `.planning/` 이 담당한다.

## 활성 흐름

_없음_ — `/whale:start <feature>` 로 시작한다.

<!--
활성 흐름이 있을 때의 형식 예시 (start 가 이 블록을 채운다):

## 활성 흐름

- **Feature:** <feature 이름>
- **Mode:** A (순차) | B (피어)
- **시작:** <YYYY-MM-DD>
- **마일스톤 범위:** <config.json.scopeDir 에서 확인한 현재 범위>

### 체인 진행 (Mode A)

| 단계 | 역할(agent) | 상태 | 산출물/비고 |
|------|------------|------|-----------|
| 1 | dba | ✅ 완료 \| ▶ 진행중 \| ⬜ 대기 | DB 스키마 + ERD + 마이그레이션 계획 |
| 2 | be-developer | ⬜ 대기 | 레이어드 구현 + OpenAPI + ADR |
| 3 | fe-developer | ⬜ 대기 | FE 구현 (API 스펙 기준) |
| 4 | qa | ⬜ 대기 | 테스트 + 요구사항 완성도 + 장애보고 |

> 기획·디자인·도메인 검토는 자동 체인에 없다. 필요 시 `/whale:plan|design|domain` 온디맨드. domain-expert 는 구현 후 최종 도메인 리뷰(/whale:domain).

### 블로커
- _없음_
-->

## 완료된 흐름 (히스토리)

_아직 없음_
