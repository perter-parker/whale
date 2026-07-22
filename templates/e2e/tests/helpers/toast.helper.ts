import { type Page, expect } from '@playwright/test';

/**
 * ToastHelper — Toast/Notification 추상화.
 * 에러/성공 메시지는 개별 locator 로 검증(다중매칭 정규식 금지).
 * 디자인 시스템 토스트의 role/data-slot 에 맞춰 조정하라(status/alert 관습).
 */
export class ToastHelper {
  constructor(private readonly page: Page) {}

  async expectSuccess(message?: string): Promise<void> {
    const toast = this.page.getByRole('status');
    await expect(toast).toBeVisible();
    if (message) await expect(toast).toContainText(message);
  }

  async expectError(message?: string): Promise<void> {
    const toast = this.page.getByRole('alert');
    await expect(toast).toBeVisible();
    if (message) await expect(toast).toContainText(message);
  }
}
