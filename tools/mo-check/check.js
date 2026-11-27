const mo = require('motoko'), fs = require('fs'), path = require('path');
const dir = (process.env.MO_BASE || __dirname + '/base') + ''; const files = {};
fs.readdirSync(dir).forEach(f => files['base/' + f] = { content: fs.readFileSync(path.join(dir, f), 'utf8') });
mo.clearPackages();
const pkg = { name: 'base', version: 'local', files: {} }; fs.readdirSync(dir).forEach(f => pkg.files[f] = { content: fs.readFileSync(path.join(dir, f), 'utf8') });
try { mo.loadPackage(pkg); } catch (e) { console.log('loadPackage', String(e).slice(0, 200)); }
mo.write('Main.mo', fs.readFileSync(process.argv[2], 'utf8'));
let d; try { d = mo.check('Main.mo'); } catch (e) { console.log('THROW', String(e && e.message || e).slice(0, 300)); process.exit(1); }
const ds = Array.isArray(d) ? d : ((d && d.diagnostics) || []);
console.log('diagnostics', ds.length, 'errors', ds.filter(x => x.severity === 1).length);
ds.slice(0, +process.argv[3] || 25).forEach(x => console.log((x.range ? x.range.start.line + 1 : '?') + ' ' + (x.code || '') + ' ' + String(x.message).split('\n')[0].slice(0, 170)));
