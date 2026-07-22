# E2E AI 가이드 (whale)

> 이 문서는 **e2e-tester 에이전트가 작업 전 반드시 읽는** 하네스 규칙서다(`config.e2e.selectorRulesDoc`).
> `/whale:e2e-init` 이 프로젝트에 복사한다. 프로젝트 디자인 시스템·스택에 맞게 조정하라.

## 1. 셀렉터 우선순위 규칙

테스트 대상을 잡을 때 **항상 아래 우선순위**를 따른다:

1. **1순위 — ARIA role**: `getByRole('button', { name: '저장' })`, `getByRole('dialog')`, `getByRole('row', { name: /홍길동/ })`
2. **2순위 — ARIA 속성**: `getByLabel('이름')`, `getByPlaceholder('검색어를 입력하세요')`, `getByText('성공', { exact: true })`
3. **3순위 — data-slot**: `[data-slot="dialog-title"]` (디자인 시스템 컴포넌트의 구조적 요소, role 로 안 잡힐 때만)

**영역 스코프 필수** — 같은 페이지의 유사 요소 오인을 막는다:
```ts
const area = page.getByTestId('datasource-content');
await area.getByRole('button', { name: '폴더 생성' }).click();
```

### 금지 패턴
- ❌ `getByText(/생성|수정|삭제/)` — 다중 매칭 정규식(strict mode 위반). 에러 메시지는 **개별 locator 로 각각** 검증.
- ❌ CSS/XPath 절대경로: `.btn-primary > span:nth-child(2)` — UI 변경에 취약.
- ❌ 저수준 API 를 스펙에 직접 남발 — Helper 로 추상화(아래).

## 2. Component Helper 목록

저수준 Playwright API 대신 **고수준 Helper** 를 쓴다. fixture 로 자동 주입된다.

| Helper | fixture | 주요 메서드 |
|--------|---------|-----------|
| FormHelper | `form` | `fillFields({ 라벨: 값 })`, `submit('저장')`, `expectErrors([...])` |
| DialogHelper | `dialog` | `waitForOpen()`, `clickConfirm('생성')`, `clickCancel()`, `close()` |
| SelectHelper | `select` | `choose('라벨', '옵션')`, `selectFirstOption('라벨')` |
| TableHelper | `table` | `getRowByText('텍스트')`, `clickRowAction('텍스트', '삭제')` |
| NavigationHelper | `nav` | `goto('/path')`, `clickTab('탭명')`, `expectUrl(/regex/)` |
| ToastHelper | `toast` | `expectSuccess('메시지?')`, `expectError('메시지?')` |

사용 예:
```ts
test('에이전트 생성', async ({ page, form, dialog, toast }) => {
  await page.goto('/ai-agent/create');
  await form.fillFields({ '에이전트 이름': '테스트', '설명': '설명입니다' });
  await form.submit('저장');
  await dialog.clickConfirm('생성');
  await toast.expectSuccess();
});
```

필요한 조작에 Helper 가 없으면 **저수준 코드를 스펙에 흩뿌리지 말고 Helper 를 확장**한다.

## 3. Self-healing 실패 4분류

실패를 아래로 분류한다. **자가수정 대상과 리포트 대상이 다르다.**

| 분류 | 정의 | e2e-tester 행동 |
|------|------|----------------|
| **UI_CHANGE** | 화면은 정상인데 셀렉터만 어긋남 | 셀렉터/Helper **자가수정**(우선순위 규칙 준수) |
| **TEST_BUG** | 스코프·대기 부족·strict mode 위반 | 테스트 코드 **자가수정** |
| **APP_BUG** | 앱 실제 결함(잘못된 동작·응답·상태) | **고치지 말고 리포트** → qa Blocker → 재구현 |
| **ENV_ISSUE** | 서버 미기동·네트워크·시드 부재 | **고치지 말고 리포트** → 환경 조치 요청 |

자가수정은 UI_CHANGE/TEST_BUG 만, **최대 `config.e2e.maxHealRetries`회**. APP_BUG/ENV_ISSUE 는 회차를 소모하지 않는다.

## 4. Critical path 작성법

- critical(로그인·핵심 CRUD·권한·결제)을 **가장 먼저·강하게** 검증한다.
- `config.e2e.criticalPaths` 또는 `plan.md` P5 에 목록을 둔다.
- 비메인·부수 시나리오는 무인 시간 예산 안에서 **스킵 판정 가능**(사유 명시).

## 5. 무인 실행 규율

- 앱 코드/마이그레이션/서버를 **변경하지 않는다**(E2E 스펙·Helper·리포트만).
- **파괴적/비가역 시나리오(실데이터 삭제·결제 실호출·메일 발송)는 실행 금지** — 테스트 격리 환경·시드·모의가 보장된 경우만.
- 결과는 `runs/<run-id>/e2e.md` 트리아지 리포트로 남긴다(APP_BUG 를 크리티컬리티순 최상단).
