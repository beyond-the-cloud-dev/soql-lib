// Wraps docusaurus-plugin-llms. Once it has written the markdown twin of each doc page (/page.md),
// every built page that has a twin gets a <link rel="alternate" type="text/markdown"> to it, and the
// home page one to llms.txt. Wrapping keeps the order: Docusaurus runs postBuild hooks in parallel.
const fs = require('fs/promises');
const path = require('path');
const llms = require('docusaurus-plugin-llms').default;

const exists = (file) =>
  fs.access(file).then(
    () => true,
    () => false,
  );

async function htmlFiles(dir) {
  const entries = await fs.readdir(dir, { withFileTypes: true });
  const files = await Promise.all(
    entries.map((entry) => {
      const file = path.join(dir, entry.name);
      if (entry.isDirectory()) return htmlFiles(file);
      return entry.name.endsWith('.html') ? [file] : [];
    }),
  );
  return files.flat();
}

async function linkMarkdownTwins(outDir, siteUrl) {
  for (const file of await htmlFiles(outDir)) {
    const route = path
      .relative(outDir, file)
      .split(path.sep)
      .join('/')
      .replace(/(^|\/)index\.html$/, '')
      .replace(/\.html$/, '');
    if (route === '404') continue;
    const twin = route ? `${route}.md` : 'llms.txt';
    if (!(await exists(path.join(outDir, twin)))) continue;
    const html = await fs.readFile(file, 'utf8');
    const link = `<link rel="alternate" type="text/markdown" href="${siteUrl}/${twin}">`;
    await fs.writeFile(file, html.replace('</head>', `${link}</head>`));
  }
}

module.exports = function llmsMarkdown(context, options) {
  const plugin = llms(context, options);
  return {
    ...plugin,
    async postBuild(props) {
      await plugin.postBuild(props);
      await linkMarkdownTwins(
        props.outDir,
        context.siteConfig.url.replace(/\/$/, ''),
      );
    },
  };
};
