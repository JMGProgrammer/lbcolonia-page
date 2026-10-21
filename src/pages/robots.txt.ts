// robots.txt: indexa todo lo público; el panel y la API viven en otro orígen.
import type { APIRoute } from 'astro';

export const GET: APIRoute = async ({ request }) => {
  const base = new URL(request.url).origin;
  const txt = `User-agent: *\nAllow: /\n\nSitemap: ${base}/sitemap.xml\n`;
  return new Response(txt, { headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
};
