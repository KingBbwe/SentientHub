// Builds a static documentation site from the repo's Markdown into site/dist/.
// The Motoko canister itself cannot run on Render (it needs the Internet Computer or a local dfx replica);
// this site publishes the specification, status and playtest transcript so they can be read in a browser.
const fs = require('fs'), path = require('path'), { marked } = require('marked');
const root = path.join(__dirname, '..'), out = path.join(__dirname, 'dist');
const pages = [
  { file: 'README.md', slug: 'index', title: 'SentientHub' },
  { file: 'docs/VERTICAL_SLICE.md', slug: 'vertical-slice', title: 'Vertical slice' },
  { file: 'docs/COMPILE_REPAIR_STATUS.md', slug: 'status', title: 'Build status and open rulings' },
  { file: 'docs/GTM.md', slug: 'gtm', title: 'Go to market' },
  { file: 'nomenclature.md', slug: 'nomenclature', title: 'Nomenclature' },
];
const esc = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;');
const nav = cur => pages.map(p => `<a href="${p.slug === 'index' ? './' : p.slug + '.html'}"${p.slug === cur ? ' aria-current="page"' : ''}>${esc(p.title)}</a>`).join('');
const shell = (p, body) => `<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${esc(p.title)} - SentientHub</title>
<style>body{font:16px/1.6 system-ui,sans-serif;margin:0;color:#1d1d1f;background:#faf8f3}nav{background:#2b2d42;padding:.6rem 1rem;display:flex;flex-wrap:wrap;gap:1rem}nav a{color:#edf2f4;text-decoration:none}nav a[aria-current]{border-bottom:2px solid #ef233c}main{max-width:52rem;margin:0 auto;padding:1rem 1.2rem 4rem}pre,code{background:#eee;border-radius:4px}pre{padding:.8rem;overflow:auto}code{padding:.1rem .3rem}table{border-collapse:collapse;display:block;overflow:auto}td,th{border:1px solid #ccc;padding:.3rem .6rem}.note{background:#fff3cd;border:1px solid #e0c36a;padding:.6rem .9rem;border-radius:6px}</style></head><body><nav>${nav(p.slug)}</nav><main>${p.slug === 'index' ? '<p class="note">This is the documentation site. The SentientHub canister runs on the Internet Computer (or a local <code>dfx</code> replica), not on Render. Money-handling is custodian-settled and no code signs, mints or burns FUDDY.</p>' : ''}${body}</main></body></html>`;
fs.rmSync(out, { recursive: true, force: true }); fs.mkdirSync(out, { recursive: true });
for (const p of pages) {
  const f = path.join(root, p.file);
  if (!fs.existsSync(f)) { console.warn('skip (missing): ' + p.file); continue; }
  let html = marked.parse(fs.readFileSync(f, 'utf8'));
  html = html.replace(/href="(?:\.\/)?(?:docs\/)?([A-Za-z_]+)\.md"/g, (m, n) => { const q = pages.find(x => x.file.endsWith('/' + n + '.md') || x.file === n + '.md'); return q ? `href="${q.slug}.html"` : m; });
  fs.writeFileSync(path.join(out, p.slug + '.html'), shell(p, html));
  console.log('built ' + p.slug + '.html');
}
