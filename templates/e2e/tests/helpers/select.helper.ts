import { type Page } from '@playwright/test';

/**
 * SelectHelper — Select/Combobox 컴포넌트 추상화.
 * 디자인 시스템이 커스텀 콤보박스면 role='combobox'/'option' 매핑을 조정하라.
 */
export class SelectHelper {
  constructor(private readonly page: Page) {}

  /** 라벨로 콤보박스를 열고 옵션을 선택. */
  async choose(label: string, option: string): Promise<void> {
    await this.page.getByRole('combobox', { name: label }).click();
    await this.page.getByRole('option', { name: option }).click();
  }

  /** 첫 옵션 선택(빠른 스모크용). */
  async selectFirstOption(label: string): Promise<void> {
    await this.page.getByRole('combobox', { name: label }).click();
    await this.page.getByRole('option').first().click();
  }
}
