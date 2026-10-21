// sitemap.xml dinámico: rutas fijas + datos de la base (clubes, noticias, páginas).
import type { APIRoute } from 'astro';
import { listarClubes, listarNoticias, listarPaginas } from '../lib/data';

export const GET: APIRoute = async ({ request }) => {
  const base = new URL(request.url).origin;
  const fijas = [
    '',
    '/fixture',
    '/tabla',
    '/clubes',
    '/sanciones',
    '/noticias',
    '/contacto',
    '/reglamento',
    '/privacidad',
    '/terminos',
    '/creditos',
  ];
  const [clubes, noticias, paginas] = await Promise.all([listarClubes(), listarNoticias(50), listarPaginas()]);

  const urls = new Set<string>(fijas.map((p) => `${base}${p}`));
  for (const c of clubes) urls.add(`${base}/clubes/${c.slug}`);
  for (const n of noticias) urls.add(`${base}/noticias/${n.slug}`);
  for (const p of paginas) urls.add(`${base}/${p.slug}`);

  const xml = `<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${[...urls].map((u) => `<url><loc>${u}</loc></url>`).join('\n')}
</urlset>`;
  return new Response(xml, { headers: { 'Content-Type': 'application/xml; charset=utf-8' } });
};
