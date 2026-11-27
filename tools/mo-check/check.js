const mo = require('motoko'), fs = require('fs'), path = require('path');
const dir = (process.env.MO_BASE || __dirname + '/base') + ''; const files = {};
fs.readdirSync(dir).forEach(f => files['base/' + f] = { content: fs.readFileSync(path.join(dir, f), 'utf8') });
mo.clearPackages();
const pkg = { name: 'base', version: 'local', files: {} }; fs.readdirSync(dir).forEach(f => pkg.files[f] = { content: fs.readFileSync(path.join(dir, f), 'utf8') });
try { mo.loadPackage(pkg); } catch (e) { console.log('loadPackage', String(e).slice(0, 200)); }
// every .mo under the backend's src/ is written to the virtual file system at its relative path, so imports resolve
const root = path.resolve(__dirname, '../../sentient-economic-backend');
const srcDir = path.join(root, 'src');
if (fs.existsSync(srcDir)) fs.readdirSync(srcDir).filter(f => f.endsWith('.mo')).forEach(f => mo.write('src/' + f, fs.readFileSync(path.join(srcDir, f), 'utf8')));
const target = process.argv[2];
const vname = target.indexOf('/src/') !== -1 ? 'src/' + path.basename(target) : 'Main.mo';
mo.write(vname, fs.readFileSync(target, 'utf8'));
let d; try { d = mo.check(vname); } catch (e) { console.log('THROW', String(e && e.message || e).slice(0, 300)); process.exit(1); }
const ds = Array.isArray(d) ? d : ((d && d.diagnostics) || []);
console.log('diagnostics', ds.length, 'errors', ds.filter(x => x.severity === 1).length);
ds.slice(0, +process.argv[3] || 25).forEach(x => console.log((x.range ? x.range.start.line + 1 : '?') + ' ' + (x.code || '') + ' ' + String(x.message).split('\n')[0].slice(0, 170)));
