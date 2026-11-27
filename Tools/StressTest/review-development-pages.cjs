const fs = require('node:fs');
const { performance } = require('node:perf_hooks');
const { chromium } = require(process.env.EG_PLAYWRIGHT_MODULE ?? 'C:/Desarrollo/Desarrollo/FullStack/GE.UNI360/tmp/validacion-nf013-nf018-playwright/node_modules/playwright');
const session = JSON.parse(fs.readFileSync('tmp/capacity-dev/session.json', 'utf8'));
const inventory = JSON.parse(fs.readFileSync('tmp/capacity-dev/pages-audit.json', 'utf8'));
const origin = 'http://localhost:5242';
const excluded = /\/(login|logout|register|resetpassword|forgotpassword|access-denied)(\/|$)/i;
const cases = inventory.pages.filter(p => p.routes.length).flatMap(p => (process.env.EG_PAGE_ALIASES ? p.routes : [p.routes[0]]).map(route => ({ file: p.file, route })))
  .filter(p => !excluded.test(p.route)).map(p => ({ ...p, route: p.route.replace(/\{[^}]+\?\}/g, '').replace(/\{[^}]+\}/g, '1') }));
const result = { startedUtc: new Date().toISOString(), origin, viewport: { width: 1440, height: 1080 }, authentication: 'real-development-session', mode: 'read-only-full-navigation', pages: [] };
const part = Number(process.env.EG_PAGE_PART ?? 0);
const parts = Number(process.env.EG_PAGE_PARTS ?? 1);
const output = process.env.EG_PAGE_OUTPUT ?? (parts === 1 ? 'tmp/capacity-dev/pages-runtime.json' : `tmp/capacity-dev/pages-runtime-${part}.json`);
const completed = parts > 1 && fs.existsSync('tmp/capacity-dev/pages-runtime.json')
 ? new Set(JSON.parse(fs.readFileSync('tmp/capacity-dev/pages-runtime.json', 'utf8')).pages.map(p => p.route)) : new Set();
async function main() {
 const browser = await chromium.launch({ channel: 'msedge', headless: true });
 try {
  const context = await browser.newContext({ viewport: result.viewport });
  await context.addInitScript(storage => { for (const [key, value] of Object.entries(storage)) localStorage.setItem(key, value); }, session.storage);
  const page = await context.newPage();
  let current = null;
  const calls = new Map();
  page.on('request', request => {
   if (!current || !request.url().includes('/api/')) return;
   const call = { endpoint: new URL(request.url()).pathname, method: request.method(), start: performance.now(), owner: current };
   calls.set(request, call);
   current.inflight++;
   current.lastActivity = performance.now();
  });
  page.on('requestfailed', request => {
   const call = calls.get(request);
   if (call) { call.owner.inflight--; call.owner.lastActivity = performance.now(); call.owner.failures.push({ endpoint: call.endpoint, status: 0 }); calls.delete(request); }
  });
  page.on('response', async response => {
   const call = calls.get(response.request());
   if (!call) return;
   try {
    const data = await response.json().catch(() => null);
    call.owner.requests.push({ endpoint: call.endpoint, method: call.method, status: response.status(), ms: Math.round(performance.now() - call.start), businessFailure: data?.success === false || data?.Success === false });
   } finally { call.owner.inflight--; call.owner.lastActivity = performance.now(); calls.delete(response.request()); }
  });
  page.on('pageerror', error => { if (current) current.errors.push(error.name); });
  await page.route('**/api/**', async route => {
   const request = route.request(), path = new URL(request.url()).pathname.toLowerCase();
   if (!['GET', 'OPTIONS'].includes(request.method()) && !/\/(getallpaginado|buscar|resumen|resumen-lote|estado)$/.test(path) && path !== '/api/bitacora/filtros') {
    current?.blockedWrites.push(path);
    await route.fulfill({ status: 400, contentType: 'application/json', body: '{"success":false,"message":"Sólo lectura durante revisión"}' });
   } else await route.continue();
  });
  for (const [index, entry] of cases.entries()) {
   if (index % parts !== part || completed.has(entry.route)) continue;
   if (process.env.EG_PAGE_FILTER && !process.env.EG_PAGE_FILTER.split(',').some(filter => entry.route.toLowerCase().includes(filter.toLowerCase()))) continue;
   current = { ...entry, requests: [], failures: [], errors: [], blockedWrites: [], inflight: 0, lastActivity: performance.now() };
   const start = performance.now();
   try {
    await page.goto(origin + entry.route, { waitUntil: 'domcontentloaded', timeout: 30000 });
    await page.locator('.layout-root').waitFor({ state: 'visible', timeout: 20000 });
    await page.waitForFunction(() => !document.querySelector('.app-boot-shell'), null, { timeout: 20000 });
    const rendered = performance.now();
    while ((current.inflight > 0 || performance.now() - current.lastActivity < 1000 || performance.now() - rendered < 1500) && performance.now() - start < 20000) await page.waitForTimeout(100);
    current.elapsedMs = Math.round(performance.now() - start);
    current.timedOut = current.inflight > 0;
    current.redirected = new URL(page.url()).pathname !== new URL(origin + entry.route).pathname;
    current.visibleError = await page.locator('#blazor-error-ui').evaluateAll(nodes => nodes.some(n => getComputedStyle(n).display !== 'none')) || await page.getByText('No fue posible mostrar esta pagina', { exact: true }).isVisible();
    current.horizontalOverflow = await page.evaluate(() => document.documentElement.scrollWidth > innerWidth);
    current.gridCount = await page.locator('.eg-generic-data-grid').count();
   } catch (error) { current.errors.push(error.name); current.elapsedMs = Math.round(performance.now() - start); }
   const { inflight, lastActivity, ...record } = current;
   result.pages.push(record);
   fs.writeFileSync(output, JSON.stringify(result, null, 2));
   console.log(JSON.stringify({ route: record.route, ms: record.elapsedMs, requests: record.requests.length, failed: record.requests.filter(r => r.status >= 400 || r.businessFailure).length, errors: record.errors.length, visibleError: record.visibleError, redirected: record.redirected }));
  }
 } finally { await browser.close(); }
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });
