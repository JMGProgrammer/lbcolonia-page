// Cache del público en el CDN: las páginas de contenido expiran en 60 s con SWR
// (el público refresca a ~1 min, Docs/04 §4). Feeds/canon con TTL mayor.
// Los assets estáticos (_astro, fuentes, imágenes) no se tocan: cache propia.
import { defineMiddleware } from 'astro:middleware';

const ttlPorRuta = (pathname: string): string => {
  if (pathname.startsWith('/admin') || pathname.startsWith('/api/')) {
    return 'private, no-store, no-cache, must-revalidate';
  }
  if (pathname.startsWith('/sitemap.xml') || pathname.startsWith('/robots.txt') || pathname.startsWith('/rss.xml')) {
    return 'public, max-age=0, s-maxage=3600, stale-while-revalidate=86400';
  }
  return 'public, s-maxage=60, stale-while-revalidate=300';
};

const esAsset = (pathname: string): boolean =>
  pathname.startsWith('/_astro/') ||
  pathname.startsWith('/fonts/') ||
  /\.(png|svg|ico|webp|jpe?g|woff2?)$/.test(pathname);

export const onRequest = defineMiddleware(async (contexto, next) => {
  const respuesta = await next();
  if (!esAsset(contexto.url.pathname)) {
    respuesta.headers.set('Cache-Control', ttlPorRuta(contexto.url.pathname));
    respuesta.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
    respuesta.headers.set('X-Content-Type-Options', 'nosniff');

    if (contexto.url.pathname.startsWith('/admin')) {
      const scriptSrc = import.meta.env.DEV
        ? "script-src 'self' 'unsafe-inline'"
        : "script-src 'self'";

      respuesta.headers.set(
        'Content-Security-Policy',
        [
          "default-src 'self'",
          scriptSrc,
          "style-src 'self' 'unsafe-inline'",
          "connect-src 'self' https://*.supabase.co wss://*.supabase.co",
          "img-src 'self' data: blob: https://*.supabase.co",
          "font-src 'self'",
          "object-src 'none'",
          "base-uri 'self'",
          "form-action 'self'",
          "frame-ancestors 'none'",
        ].join('; ')
      );
    }
  }
  return respuesta;
});
