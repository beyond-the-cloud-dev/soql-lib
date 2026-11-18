import { next, rewrite } from '@vercel/functions';

// Vercel Routing Middleware (this directory is the project root): serves the markdown twin of a docs page
// (/page.md, built by plugins/llms-markdown.js) to AI agents that send `Accept: text/markdown`. The home
// page has no twin, so it answers with llms.txt.
export const config = {
  // Pages (with or without .html) and .md twins only; skips assets and any other file
  matcher: '/((?!assets/)(?!.*\\.(?!(?:md|html)$)[^/.]+$).*)',
};

// Suffix of page URLs on this site: '' with cleanUrls, '.html' without
const PAGE_SUFFIX = '';

const quality = (accept, type) => {
  for (const part of accept.split(',')) {
    const [media, ...params] = part
      .split(';')
      .map((value) => value.trim().toLowerCase());
    if (media !== type) continue;
    const q = params.find((param) => param.startsWith('q='));
    return q ? Number(q.slice(2)) || 0 : 1;
  }
  return 0;
};

const prefersMarkdown = (accept) => {
  const markdown = quality(accept, 'text/markdown');
  return markdown > 0 && markdown >= quality(accept, 'text/html');
};

export default async function middleware(request) {
  const url = new URL(request.url);

  if (url.pathname.endsWith('.md')) {
    return next({
      headers: {
        Link: `<${url.origin}${url.pathname.slice(0, -3)}${PAGE_SUFFIX}>; rel="canonical"`,
        Vary: 'Accept',
      },
    });
  }
  if (!prefersMarkdown(request.headers.get('accept') || '')) {
    return next({ headers: { Vary: 'Accept' } });
  }

  const page = url.pathname.replace(/(\/index)?(\.html)?\/?$/, '');
  const markdown = new URL(page ? `${page}.md` : '/llms.txt', url.origin);
  // Not every page has a twin (archived versions, for one). Credentials are forwarded and redirects
  // not followed, so a protected preview's login redirect does not pass for an existing file.
  const headers = {};
  for (const name of ['cookie', 'x-vercel-protection-bypass']) {
    if (request.headers.has(name)) headers[name] = request.headers.get(name);
  }
  const twin = await fetch(markdown, {
    method: 'HEAD',
    headers,
    redirect: 'manual',
  }).catch(() => null);
  if (!twin?.ok) {
    return next({ headers: { Vary: 'Accept' } });
  }
  return rewrite(markdown, { headers: { Vary: 'Accept' } });
}
