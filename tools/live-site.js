#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

function usage() {
  console.error('Usage:');
  console.error('  node tools/live-site.js screenshot <url> [outputPath]');
  console.error('  node tools/live-site.js actions <url> <jsonActions> [outputPath]');
  process.exit(1);
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function slugifyUrl(url) {
  return url
    .replace(/^https?:\/\//, '')
    .replace(/[^a-zA-Z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .toLowerCase();
}

function defaultOutputPath(mode, url) {
  const stamp = new Date().toISOString().replace(/[:.]/g, '-');
  const host = slugifyUrl(url).slice(0, 80) || 'site';
  return path.join('artifacts', 'live-site', `${mode}-${host}-${stamp}.png`);
}

async function runScreenshot(url, outputPath) {
  const browser = await chromium.launch({
    headless: process.env.HEADLESS !== 'false',
  });

  try {
    const context = await browser.newContext({
      viewport: { width: 1600, height: 1000 },
    });
    const page = await context.newPage();
    await page.goto(url, { waitUntil: 'networkidle', timeout: 60000 });
    await page.screenshot({ path: outputPath, fullPage: true });
    console.log(outputPath);
  } finally {
    await browser.close();
  }
}

async function runActions(url, jsonActions, outputPath) {
  let actions;
  try {
    actions = JSON.parse(jsonActions);
  } catch (error) {
    console.error('Invalid JSON actions payload.');
    throw error;
  }

  if (!Array.isArray(actions)) {
    throw new Error('Actions payload must be a JSON array.');
  }

  const browser = await chromium.launch({
    headless: process.env.HEADLESS !== 'false',
  });

  try {
    const context = await browser.newContext({
      viewport: { width: 1600, height: 1000 },
    });
    const page = await context.newPage();
    await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60000 });

    for (const action of actions) {
      if (!action || typeof action !== 'object') {
        throw new Error('Each action must be an object.');
      }

      const type = action.type;
      switch (type) {
        case 'goto': {
          if (!action.url) throw new Error('goto action requires url');
          await page.goto(action.url, {
            waitUntil: action.waitUntil || 'networkidle',
            timeout: action.timeout || 60000,
          });
          break;
        }
        case 'click': {
          if (!action.selector) throw new Error('click action requires selector');
          await page.click(action.selector, { timeout: action.timeout || 30000 });
          break;
        }
        case 'fill': {
          if (!action.selector) throw new Error('fill action requires selector');
          await page.fill(action.selector, String(action.value ?? ''), {
            timeout: action.timeout || 30000,
          });
          break;
        }
        case 'type': {
          if (!action.selector) throw new Error('type action requires selector');
          await page.type(action.selector, String(action.value ?? ''), {
            delay: action.delay || 0,
            timeout: action.timeout || 30000,
          });
          break;
        }
        case 'press': {
          if (!action.selector || !action.key) {
            throw new Error('press action requires selector and key');
          }
          await page.press(action.selector, action.key, {
            timeout: action.timeout || 30000,
          });
          break;
        }
        case 'waitForSelector': {
          if (!action.selector) {
            throw new Error('waitForSelector action requires selector');
          }
          await page.waitForSelector(action.selector, {
            state: action.state || 'visible',
            timeout: action.timeout || 30000,
          });
          break;
        }
        case 'waitForTimeout': {
          await page.waitForTimeout(Number(action.ms || 500));
          break;
        }
        case 'selectOption': {
          if (!action.selector) {
            throw new Error('selectOption action requires selector');
          }
          await page.selectOption(action.selector, action.value);
          break;
        }
        case 'screenshot': {
          const stepPath = action.path || outputPath;
          ensureDir(path.dirname(stepPath));
          await page.screenshot({ path: stepPath, fullPage: action.fullPage !== false });
          break;
        }
        default:
          throw new Error(`Unsupported action type: ${type}`);
      }
    }

    await page.screenshot({ path: outputPath, fullPage: true });
    console.log(outputPath);
  } finally {
    await browser.close();
  }
}

(async function main() {
  const mode = process.argv[2];
  const url = process.argv[3];

  if (!mode || !url) {
    usage();
  }

  if (mode !== 'screenshot' && mode !== 'actions') {
    usage();
  }

  const outputPath = path.resolve(
    process.argv[mode === 'actions' ? 5 : 4] || defaultOutputPath(mode, url)
  );
  ensureDir(path.dirname(outputPath));

  if (mode === 'screenshot') {
    await runScreenshot(url, outputPath);
    return;
  }

  const jsonActions = process.argv[4];
  if (!jsonActions) {
    usage();
  }
  await runActions(url, jsonActions, outputPath);
})().catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});
