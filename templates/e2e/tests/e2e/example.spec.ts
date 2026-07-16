import { test, expect } from '../fixtures';

/**
 * 예시 스펙 — critical path(로그인) 스텁.
 * 프로젝트 화면에 맞춰 복제·확장하라. Helper fixture 자동 주입 사용법을 보여준다.
 *
 * 셀렉터 규칙: getByRole > getByLabel > data-slot (tests/README.e2e.md 참조).
 */
test.describe('로그인 (critical path)', () => {
  test('정상 로그인 → 대시보드 진입', async ({ page, form, toast, nav }) => {
    await nav.goto('/login');

    await form.fillFields({
      '아이디': 'testuser',
      '비밀번호': 'test-password',
    });
    await form.submit('로그인');

    // 성공 신호: 토스트 또는 URL 전이 — 프로젝트 동작에 맞게 택1/조정
    await toast.expectSuccess();
    await nav.expectUrl(/\/dashboard/);
    await expect(page.getByRole('heading', { name: '대시보드' })).toBeVisible();
  });

  test('잘못된 비밀번호 → 에러 표시', async ({ form, toast, nav }) => {
    await nav.goto('/login');
    await form.fillFields({ '아이디': 'testuser', '비밀번호': 'wrong' });
    await form.submit('로그인');
    await toast.expectError();
  });
});
