import { defineConfig, devices } from '@playwright/test';

/**
 * whale E2E 하네스 — /whale:e2e-init 이 프로젝트로 복사.
 * baseURL·서버 기동은 프로젝트 환경에 위임한다(하드코딩 금지).
 *   - E2E_BASE_URL 환경변수로 대상 URL 지정 (기본 http://localhost:3000)
 *   - webServer 블록은 프로젝트 기동 명령에 맞춰 주석 해제·수정
 */
export default defineConfig({
  testDir: './tests/e2e',          // config.e2e.testDir 와 일치시킬 것
  fullyParallel: true,             // Playwright 병렬 실행(속도)
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: [['html'], ['list']],

  use: {
    baseURL: process.env.E2E_BASE_URL ?? 'http://localhost:3000',
    trace: 'on-first-retry',       // 실패 원인 분석용(트리아지 근거)
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],

  // 프로젝트 로컬 서버를 자동 기동하려면 주석 해제 후 명령을 채운다:
  // webServer: {
  //   command: 'pnpm dev',
  //   url: process.env.E2E_BASE_URL ?? 'http://localhost:3000',
  //   reuseExistingServer: !process.env.CI,
  //   timeout: 120_000,
  // },
});
