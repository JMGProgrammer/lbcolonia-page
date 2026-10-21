// rss.xml: feed de noticias publicadas (RSS 2.0 mínimo; escHtml para escapar títulos).
import type { APIRoute } from 'astro';
import { listarNoticias } from '../lib/data';
import { escHtml } from '../lib/fmt';

export const GET: APIRoute = async ({ request }) => {
  const base = new URL(request.url).origin;
  const noticias = await listarNoticias(30);

  const items = noticias
    .map((n) => {
      const fecha = n.publicado_at ?? n.created_at;
      return `  <item>
    <title>${escHtml(n.titulo)}</title>
    <link>${base}/noticias/${n.slug}</link>
    <guid isPermaLink="true">${base}/noticias/${n.slug}</guid>
    <pubDate>${fecha ? new Date(fecha).toUTCString() : ''}</pubDate>
    <description>${escHtml(n.bajada ?? '')}</description>
  </item>`;
    })
    .join('\n');

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Noticias · Liga de Básquetbol de Colonia</title>
    <link>${base}</link>
    <description>Noticias del básquetbol de la LBC (Uruguay)</description>
    <language>es-uy</language>
${items}
  </channel>
</rss>`;
  return new Response(xml, { headers: { 'Content-Type': 'application/rss+xml; charset=utf-8' } });
};
