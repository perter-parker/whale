import { type Page, expect } from '@playwright/test';

/**
 * NavigationHelper — Tabs/Breadcrumb/라우팅 추상화.
 */
export class NavigationHelper {
  constructor(private readonly page: Page) {}

  async goto(path: string): Promise<void> {
    await this.page.goto(path);
  }

  async clickTab(name: string): Promise<void> {
    await this.page.getByRole('tab', { name }).click();
  }

  async expectUrl(pattern: RegExp): Promise<void> {
    await expect(this.page).toHaveURL(pattern);
  }
}
