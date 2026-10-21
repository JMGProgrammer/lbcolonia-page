import type { APIRoute } from 'astro';

export const prerender = false;

export const POST: APIRoute = async ({ request }) => {
  try {
    let body: any = {};
    try {
      body = await request.json();
    } catch {
      // cuerpo opcional
    }

    return new Response(
      JSON.stringify({
        ok: true,
        mensaje: 'Revalidación procesada con éxito',
        partido_id: body?.partido_id ?? null,
        timestamp: new Date().toISOString(),
      }),
      {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'private, no-store, no-cache, must-revalidate',
        },
      }
    );
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
};
