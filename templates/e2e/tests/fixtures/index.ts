import { test as base } from '@playwright/test';
import { FormHelper } from '../helpers/form.helper';
import { DialogHelper } from '../helpers/dialog.helper';
import { SelectHelper } from '../helpers/select.helper';
import { TableHelper } from '../helpers/table.helper';
import { NavigationHelper } from '../helpers/navigation.helper';
import { ToastHelper } from '../helpers/toast.helper';

/**
 * whale E2E fixtures — 6종 Helper 를 테스트에 자동 주입.
 * 사용: test('...', async ({ form, dialog, toast }) => { ... })
 */
type Helpers = {
  form: FormHelper;
  dialog: DialogHelper;
  select: SelectHelper;
  table: TableHelper;
  nav: NavigationHelper;
  toast: ToastHelper;
};

export const test = base.extend<Helpers>({
  form: async ({ page }, use) => { await use(new FormHelper(page)); },
  dialog: async ({ page }, use) => { await use(new DialogHelper(page)); },
  select: async ({ page }, use) => { await use(new SelectHelper(page)); },
  table: async ({ page }, use) => { await use(new TableHelper(page)); },
  nav: async ({ page }, use) => { await use(new NavigationHelper(page)); },
  toast: async ({ page }, use) => { await use(new ToastHelper(page)); },
});

export { expect } from '@playwright/test';
