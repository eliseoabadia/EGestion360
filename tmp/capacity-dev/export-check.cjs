const fs = require('node:fs');
const { chromium } = require('C:/Desarrollo/Desarrollo/FullStack/GE.UNI360/tmp/validacion-nf013-nf018-playwright/node_modules/playwright');

const session = JSON.parse(fs.readFileSync('tmp/capacity-dev/session.json', 'utf8'));
const route = 'http://localhost:5242/Patrimonio/Bienes';
const apiPath = '/api/Bien/GetAllPaginado';
const filter = 'MESA';
const expectedCount = 1032;

(async () => {
  const browser = await chromium.launch({ channel: 'msedge', headless: true });
  try {
    const context = await browser.newContext({ acceptDownloads: false });
    await context.addInitScript(storage => {
      for (const [key, value] of Object.entries(storage)) localStorage.setItem(key, value);
    }, session.storage);
    const page = await context.newPage();
    await page.goto(route, { waitUntil: 'domcontentloaded' });
    await page.locator('.layout-root').waitFor({ state: 'visible', timeout: 20000 });
    await page.getByRole('button', { name: 'Exportar registros a Excel', exact: true }).waitFor();

    const searchResponsePromise = page.waitForResponse(response => {
      const request = response.request();
      if (!new URL(response.url()).pathname.endsWith(apiPath) || request.method() !== 'POST') return false;
      try { return JSON.parse(request.postData() ?? '{}').searchString === filter; }
      catch { return false; }
    }, { timeout: 20000 });
    await page.getByPlaceholder('Buscar por clave, descripcion, tipo, serie, factura o area...', { exact: true }).fill(filter);
    const searchResponse = await searchResponsePromise;
    const searchBody = await searchResponse.json();
    const searchTotal = searchBody.totalCount ?? searchBody.TotalCount;
    if (searchResponse.status() !== 200 || (searchBody.success ?? searchBody.Success) !== true || searchTotal !== expectedCount)
      throw Error(`Search precondition failed: HTTP ${searchResponse.status()}, total=${searchTotal}`);

    await page.evaluate(() => {
      window.downloadFile = (base64, fileName, contentType) => {
        window.__exportCheck = { base64Characters: base64.length, fileName, contentType };
      };
    });

    let exporting = false;
    let expectedTotal = null;
    let received = 0;
    let pageCount = 0;
    const ids = new Set();
    const responseTasks = [];
    const handlerErrors = [];
    page.on('response', response => {
      if (!exporting || !new URL(response.url()).pathname.endsWith(apiPath)) return;
      const task = response.json().then(data => {
        if (response.status() !== 200 || (data.success ?? data.Success) !== true)
          throw Error(`Export page returned HTTP ${response.status()}`);
        const items = data.items ?? data.Items ?? [];
        expectedTotal ??= data.totalCount ?? data.TotalCount;
        if ((data.totalCount ?? data.TotalCount) !== expectedTotal) throw Error('TotalCount changed during export');
        pageCount++;
        received += items.length;
        for (const row of items) {
          const entry = Object.entries(row).find(([key]) => /pkidbien$/i.test(key));
          if (!entry) throw Error('Bien key was not present in the export response');
          ids.add(entry[1]);
        }
      }).catch(error => { handlerErrors.push(error.message); });
      responseTasks.push(task);
    });

    exporting = true;
    await page.getByRole('button', { name: 'Exportar registros a Excel', exact: true }).click();
    await page.waitForFunction(() => Boolean(window.__exportCheck), null, { timeout: 60000 });
    await Promise.all(responseTasks);
    if (handlerErrors.length) throw Error(handlerErrors.join('; '));
    if (expectedTotal !== expectedCount || received !== expectedTotal || ids.size !== expectedTotal)
      throw Error(`Incomplete export: pages=${pageCount}, records=${received}, unique=${ids.size}, total=${expectedTotal}`);

    const result = {
      filter,
      pages: pageCount,
      pageSize: 250,
      records: received,
      uniqueRecords: ids.size,
      total: expectedTotal,
      downloadIntercepted: true,
      physicalDataFileCreated: false
    };
    fs.writeFileSync('tmp/capacity-dev/export-check.json', JSON.stringify(result, null, 2));
    console.log(JSON.stringify(result));
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error.message); process.exitCode = 1; });
