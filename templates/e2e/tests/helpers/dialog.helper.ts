import { type Page, expect } from '@playwright/test';

/**
 * DialogHelper — Dialog/Modal 컴포넌트 추상화.
 * 셀렉터 우선순위: getByRole('dialog') 스코프 후 내부 요소 조작.
 */
export class DialogHelper {
  constructor(private readonly page: Page) {}

  private get dialog() {
    return this.page.getByRole('dialog');
  }

  async waitForOpen(): Promise<void> {
    await expect(this.dialog).toBeVisible();
  }

  async clickConfirm(name = '확인'): Promise<void> {
    await this.dialog.getByRole('button', { name }).click();
  }

  async clickCancel(name = '취소'): Promise<void> {
    await this.dialog.getByRole('button', { name }).click();
  }

  async close(): Promise<void> {
    await this.dialog.getByRole('button', { name: /닫기|close/i }).click();
  }
}
