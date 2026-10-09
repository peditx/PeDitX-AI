// Check the chat markdown renderer extracted from web/index.html.
const fs = require('fs');
const html = fs.readFileSync(__dirname + '/../web/index.html', 'utf8');
const script = html.slice(html.indexOf('<script>') + 8, html.lastIndexOf('</script>'));
new Function(script); // syntax check of the whole inline script

const start = html.indexOf('function esc(');
const end = html.indexOf('function add(');
if (start < 0 || end < 0) throw new Error('renderer not found in web/index.html');
const mdRender = new Function(html.slice(start, end) + '; return mdRender;')();

const cases = [
  ['heading', '# Title\nbody', m => m.includes('<h3>Title</h3>')],
  ['bold', 'a **b** c', m => m.includes('<strong>b</strong>')],
  ['italic guard', '5 * 3 * 2', m => !m.includes('<em>')],
  ['fence', 'x\n```python\nprint("**not bold**")\n```', m => m.includes('<pre class="code">') && m.includes('print("**not bold**")') && !m.includes('```')],
  ['inline code kept', 'use `a*b*c` ok', m => m.includes('<code>a*b*c</code>')],
  ['inline code not double escaped', 'run `<a>` now', m => m.includes('<code>&lt;a&gt;</code>')],
  ['list grouped', '- one\n- two', m => m.match(/<ul>/g).length === 1 && m.includes('<li>two</li>')],
  ['xss escaped', '<script>alert(1)</script>', m => !m.includes('<script>') && m.includes('&lt;script&gt;')],
  ['js link not turned into href', '[x](javascript:alert(1))', m => !m.includes('href="javascript')],
  ['http link kept', '[docs](https://example.com/a)', m => m.includes('href="https://example.com/a"')],
  ['newline preserved', 'a\nb', m => m.includes('a\nb')],
];

let bad = 0;
for (const [name, input, ok] of cases) {
  const out = mdRender(input);
  const pass = ok(out);
  if (!pass) { bad++; console.log('FAIL ' + name + ' -> ' + out); }
}
console.log(bad ? bad + ' failed' : 'all ' + cases.length + ' checks passed');
process.exit(bad ? 1 : 0);
