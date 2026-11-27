// Development-only, read-only load test. No credentials are written to results.
const fs = require('node:fs');
const { performance } = require('node:perf_hooks');
const args = Object.fromEntries(process.argv.slice(2).reduce((pairs, value, i, all) => {
  if (value.startsWith('--')) pairs.push([value.slice(2), all[i + 1]]);
  return pairs;
}, []));
const origin = args.origin ?? 'http://localhost:5198';
const base = new URL(origin);
if (!['localhost', '127.0.0.1', '[::1]'].includes(base.hostname)) throw Error('Only loopback development hosts are allowed.');
const levels = (args.levels ?? '1,5,10,20,40,80').split(',').map(Number);
const seconds = Number(args.seconds ?? 20), think = Number(args.think ?? 1000);
if (levels.some(n => !Number.isInteger(n) || n < 1 || n > 200) || seconds < 5 || seconds > 120 || think < 0) throw Error('Invalid bounded load settings.');
const session = args.session ? JSON.parse(fs.readFileSync(args.session, 'utf8')) : {};
let token = session.token ?? '';
if (token.startsWith('"')) token = JSON.parse(token);
token = token.replace(/^Bearer /i, '');
const scenarios = args.scenarios ? JSON.parse(fs.readFileSync(args.scenarios, 'utf8')) : [{ name: 'health-only', path: '/api/Navigate/ping', method: 'GET', health: true }];
for (const scenario of scenarios) {
  if (!scenario.path.startsWith('/api/') || scenario.path.includes('://') || !['GET', 'POST'].includes(scenario.method)) throw Error('Invalid scenario.');
  if (scenario.method === 'POST' && !/\/GetAllPaginado$/i.test(scenario.path)) throw Error('Only paginated read POSTs allowed.');
}
if (scenarios.some(s => !s.health) && !token) throw Error('An authenticated local session is required.');
const headers = { Accept: 'application/json', 'Content-Type': 'application/json' };
if (token) headers.Authorization = 'Bearer ' + token;
if (session.empresa && Number(session.empresa) > 0) headers['X-Empresa-Id'] = session.empresa;
if (session.anio) headers['X-Anio-Presupuestal-Id'] = String(JSON.parse(session.anio).Id);
const pause = ms => new Promise(resolve => setTimeout(resolve, ms));
const percentile = (sorted, p) => sorted[Math.max(0, Math.ceil(sorted.length * p) - 1)] ?? 0;
const results = { startedUtc: new Date().toISOString(), origin, mode: scenarios.every(s => s.health) ? 'health-only-not-user-capacity' : 'authenticated-read-workload', secondsPerLevel: seconds, thinkMilliseconds: think, scenarios: scenarios.map(s => ({ name: s.name, path: s.path, method: s.method })), stages: [] };
async function request(scenario) {
  const start = performance.now();
  try {
    const response = await fetch(new URL(scenario.path, base), { method: scenario.method, headers, body: scenario.method === 'POST' ? JSON.stringify(scenario.body) : undefined, signal: AbortSignal.timeout(15000), redirect: 'error' });
    const body = await response.text();
    let valid = false, code = String(response.status);
    try { const data = JSON.parse(body); valid = response.ok && (scenario.health || Array.isArray(data) || data.Success === true || data.success === true); code = data.Code ?? data.code ?? code; } catch { valid = false; }
    return { ms: performance.now() - start, ok: valid, status: response.status, code, scenario: scenario.name };
  } catch (error) { return { ms: performance.now() - start, ok: false, status: 0, code: error.name, scenario: scenario.name }; }
}
async function main() {
  // Preflight rejects authentication/license/business errors before applying load.
  for (const scenario of scenarios) { const response = await request(scenario); if (!response.ok) throw Error('Preflight failed: ' + JSON.stringify(response)); }
  for (const users of levels) {
    const samples = [], start = performance.now(), until = start + seconds * 1000;
    await Promise.all(Array.from({ length: users }, async (_, worker) => {
      await pause(worker * Math.min(20, 1000 / users));
      let index = worker;
      while (performance.now() < until) {
        samples.push(await request(scenarios[index++ % scenarios.length]));
        if (think) await pause(think);
      }
    }));
    const duration = (performance.now() - start) / 1000;
    const summarize = group => {
      const sorted = group.map(s => s.ms).sort((a, b) => a - b);
      return { requests: group.length, failed: group.filter(s => !s.ok).length, p50Ms: Math.round(percentile(sorted, .5)), p95Ms: Math.round(percentile(sorted, .95)), p99Ms: Math.round(percentile(sorted, .99)), maxMs: Math.round(sorted.at(-1) ?? 0) };
    };
    const summary = summarize(samples);
    const stage = { users, ...summary, requestsPerSecond: +(samples.length / duration).toFixed(2), passed: summary.failed / samples.length < .01 && summary.p95Ms < 1000 && summary.p99Ms < 2500, endpoints: Object.fromEntries(scenarios.map(s => [s.name, summarize(samples.filter(row => row.scenario === s.name))])), failures: samples.filter(s => !s.ok).slice(0, 10) };
    stage.passed = stage.passed && Object.values(stage.endpoints).every(endpoint =>
      endpoint.requests > 0 && endpoint.failed / endpoint.requests < .01 && endpoint.p95Ms < 1000 && endpoint.p99Ms < 2500);
    results.stages.push(stage);
    fs.writeFileSync(args.output ?? 'tmp/capacity-dev/result.json', JSON.stringify(results, null, 2));
    console.log(JSON.stringify(stage));
    if (summary.failed / samples.length >= .05 || summary.p95Ms >= 5000) { console.log('Stopped at safety/error threshold.'); break; }
    await pause(2000);
  }
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });
