import { execFileSync, spawn } from 'node:child_process';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, '..', '..');
const port = Number(process.env.DEMO_PORT ?? 4110);
const url = `http://localhost:${port}/`;
const viewport = { width: 1100, height: 660 };

const cursorScript = `
  window.addEventListener('DOMContentLoaded', () => {
    const dot = document.createElement('div');
    dot.style.cssText = 'position:fixed;left:-40px;top:-40px;width:26px;height:26px;margin:-13px 0 0 -13px;border-radius:50%;border:2px solid rgba(255,255,255,0.9);box-sizing:border-box;background:rgba(255,255,255,0.12);box-shadow:0 0 0 2px rgba(0,0,0,0.4);pointer-events:none;z-index:99999;transition:transform 120ms';
    document.body.appendChild(dot);
    window.addEventListener('mousemove', (e) => { dot.style.left = e.clientX + 'px'; dot.style.top = e.clientY + 'px'; });
    window.addEventListener('mousedown', () => { dot.style.transform = 'scale(0.7)'; });
    window.addEventListener('mouseup', () => { dot.style.transform = 'scale(1)'; });
  });
`;

const pause = (page, ms) => page.waitForTimeout(ms);

async function clickOn(page, locator) {
  const box = await locator.boundingBox();
  await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2, { steps: 25 });
  await pause(page, 300);
  await locator.click();
}

async function typeSlowly(page, text) {
  await page.keyboard.type(text, { delay: 150 });
}

const scenes = {
  async main(page) {
    await pause(page, 1500);
    await clickOn(page, page.getByRole('button').first());
    await pause(page, 1800);
    await typeSlowly(page, 'helo');
    await pause(page, 800);
    await page.keyboard.press('Backspace');
    await typeSlowly(page, 'lo');
    await pause(page, 2000);
  },
};

function toGif(video, offsetSeconds, out) {
  execFileSync('ffmpeg', [
    '-y', '-loglevel', 'error',
    '-ss', offsetSeconds.toFixed(2),
    '-i', video,
    '-vf', 'fps=10,scale=900:-1:flags=lanczos,split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle',
    out,
  ]);
}

async function launch() {
  const channel = process.env.DEMO_CHANNEL;
  if (channel) return chromium.launch({ channel });
  try {
    return await chromium.launch();
  } catch {
    return chromium.launch({ channel: 'chrome' });
  }
}

async function waitFor(target, tries = 50) {
  for (let i = 0; i < tries; i++) {
    try {
      if ((await fetch(target)).ok) return;
    } catch {}
    await new Promise((r) => setTimeout(r, 200));
  }
  throw new Error(`server not ready at ${target}`);
}

const server = spawn('npx', ['vite', 'preview', '--port', String(port), '--strictPort'], { cwd: root, stdio: 'ignore' });
const videoDir = mkdtempSync(join(tmpdir(), 'demo-'));
const only = process.argv.slice(2);
let browser;

try {
  await waitFor(url);
  browser = await launch();
  for (const [name, scene] of Object.entries(scenes)) {
    if (only.length > 0 && !only.includes(name)) continue;
    const context = await browser.newContext({ viewport, recordVideo: { dir: videoDir, size: viewport } });
    await context.route(/google-analytics|googletagmanager/, (route) => route.abort());
    await context.addInitScript(cursorScript);
    const started = Date.now();
    const page = await context.newPage();
    await page.goto(url);
    await page.waitForLoadState('networkidle');
    const offset = (Date.now() - started) / 1000;
    await scene(page);
    await context.close();
    toGif(await page.video().path(), offset, join(here, `${name}.gif`));
    console.log(`recorded docs/demo/${name}.gif`);
  }
} finally {
  await browser?.close();
  server.kill();
  rmSync(videoDir, { recursive: true, force: true });
}
