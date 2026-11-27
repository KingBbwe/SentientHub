// Runs a Motoko test script (a non-actor program) in the interpreter: node run.js <file.mo>. Exit 1 on a trap or compile error.
const mo = require('motoko'), fs = require('fs'), path = require('path');
const dir = process.env.MO_BASE || path.join(__dirname, 'base'); const pkg = { name: 'base', version: 'local', files: {} };
fs.readdirSync(dir).forEach(f => pkg.files[f] = { content: fs.readFileSync(path.join(dir, f), 'utf8') });
mo.loadPackage(pkg);
const root = path.resolve(__dirname, '../../sentient-economic-backend');
['src', 'tests'].forEach(d => { const p = path.join(root, d); fs.existsSync(p) && fs.readdirSync(p).filter(f => f.endsWith('.mo')).forEach(f => mo.write(d + '/' + f, fs.readFileSync(path.join(p, f), 'utf8'))); });
const rel = path.relative(root, path.resolve(process.argv[2]));
const diags = mo.check(rel).filter(x => x.severity === 1);
if (diags.length) { diags.slice(0, 10).forEach(x => console.log('COMPILE', x.range.start.line + 1, x.code, String(x.message).split('\n')[0])); process.exit(1); }
try { const r = mo.run(rel); console.log(r.stdout || '', r.stderr || ''); process.exit(r && r.result && r.result.error ? 1 : 0); } catch (e) { console.log('FAILED', String(e && e.message || e).slice(0, 300)); process.exit(1); }
