import { type Page, expect } from '@playwright/test';

/**
 * FormHelper — Form/Input 컴포넌트 추상화.
 * 셀렉터 우선순위: getByLabel(2순위 ARIA) 기반. 디자인 시스템에 맞게 조정하라.
 */
export class FormHelper {
  constructor(private readonly page: Page) {}

  /** { 라벨: 값 } 맵으로 여러 필드를 한 번에 채운다. */
  async fillFields(fields: Record<string, string>): Promise<void> {
    for (const [label, value] of Object.entries(fields)) {
      await this.page.getByLabel(label).fill(value);
    }
  }

  /** 제출 버튼 클릭(1순위 role). */
  async submit(buttonName = '저장'): Promise<void> {
    await this.page.getByRole('button', { name: buttonName }).click();
  }

  /** 필드별 에러 메시지를 개별 locator 로 각각 검증(다중매칭 금지). */
  async expectErrors(messages: string[]): Promise<void> {
    for (const msg of messages) {
      await expect(this.page.getByText(msg, { exact: true })).toBeVisible();
    }
  }
}
