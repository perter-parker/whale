import { type Page, type Locator } from '@playwright/test';

/**
 * TableHelper — DataTable 컴포넌트 추상화.
 * 영역 스코프: testId 로 특정 테이블을 좁혀 strict mode 위반을 예방.
 */
export class TableHelper {
  constructor(private readonly page: Page, private readonly testId?: string) {}

  private get root(): Locator {
    return this.testId ? this.page.getByTestId(this.testId) : this.page.getByRole('table');
  }

  /** 행 텍스트로 특정 행 locator 를 얻는다. */
  getRowByText(text: string): Locator {
    return this.root.getByRole('row', { name: new RegExp(text) });
  }

  /** 특정 행의 액션 버튼 클릭(예: 삭제/수정). */
  async clickRowAction(rowText: string, action: string): Promise<void> {
    await this.getRowByText(rowText).getByRole('button', { name: action }).click();
  }
}
