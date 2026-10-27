'use strict';

/**
 * Genera miniaturas WebP de 480 px para el bucket `productos`.
 *
 * Reemplaza /storage/v1/render/image (Image Transformations), que Supabase
 * cobra por cada imagen distinta vista en el ciclo. La tienda pide
 * productos/_miniaturas/480/<nombre>.webp como objeto público normal.
 *
 * Idempotente: solo procesa lo que devuelve fn_miniaturas_pendientes (sin
 * miniatura o con miniatura más vieja que la foto). Nunca toca la original.
 *
 * Lo corre el cron diario (/api/miniaturas/job) y, para la carga inicial,
 * scripts/generar-miniaturas.js en bucle.
 */

const { rpc } = require('./supabaseAdmin');

const BUCKET = 'productos';
const PREFIJO = '_miniaturas/480/';
const ANCHO = 480;
const CALIDAD_WEBP = 80;
const CACHE_SEGUNDOS = 604800; // 7 días; la URL lleva ?v= de la original

function rutaMiniatura(nombre) {
  return `${PREFIJO}${nombre}.webp`;
}

function codificarRuta(nombre) {
  return String(nombre)
    .split('/')
    .map((s) => encodeURIComponent(s))
    .join('/');
}

async function generarMiniatura(buffer, sharpLib) {
  return sharpLib(buffer, { failOn: 'none' })
    .rotate()
    .resize({ width: ANCHO, withoutEnlargement: true })
    .webp({ quality: CALIDAD_WEBP })
    .toBuffer();
}

async function procesarUno({ supabaseUrl, serviceKey, nombre, sharpLib, fetchImpl }) {
  const auth = { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` };

  const resp = await fetchImpl(`${supabaseUrl}/storage/v1/object/${BUCKET}/${codificarRuta(nombre)}`, {
    headers: auth,
  });
  if (!resp.ok) throw new Error(`descarga_${resp.status}`);
  const original = Buffer.from(await resp.arrayBuffer());

  const miniatura = await generarMiniatura(original, sharpLib);

  const up = await fetchImpl(
    `${supabaseUrl}/storage/v1/object/${BUCKET}/${codificarRuta(rutaMiniatura(nombre))}`,
    {
      method: 'POST',
      headers: {
        ...auth,
        'Content-Type': 'image/webp',
        'Cache-Control': `max-age=${CACHE_SEGUNDOS}`,
        'x-upsert': 'true',
      },
      body: miniatura,
    }
  );
  if (!up.ok) {
    const detalle = await up.text().catch(() => '');
    throw new Error(`subida_${up.status}:${detalle.slice(0, 120)}`);
  }
  return { bytesOriginal: original.length, bytesMiniatura: miniatura.length };
}

/**
 * @param {object} p
 * @param {string} p.supabaseUrl
 * @param {string} p.serviceKey
 * @param {number} [p.limite=150]       máximo de fotos por corrida
 * @param {number} [p.presupuestoMs=45000] corta antes del timeout de Vercel
 * @param {number} [p.concurrencia=4]
 */
async function runMiniaturasJob({
  supabaseUrl,
  serviceKey,
  limite = 150,
  presupuestoMs = 45000,
  concurrencia = 4,
  sharpLib,
  fetchImpl = fetch,
  rpcImpl = rpc,
} = {}) {
  const inicio = Date.now();
  const sharpUsado = sharpLib || require('sharp');

  const pendientes = await rpcImpl(serviceKey, supabaseUrl, 'fn_miniaturas_pendientes', {
    p_limite: limite,
  });
  const lista = Array.isArray(pendientes) ? pendientes.map((r) => r && r.name).filter(Boolean) : [];

  let hechas = 0;
  let bytesAntes = 0;
  let bytesDespues = 0;
  const errores = [];
  let i = 0;

  async function trabajador() {
    while (i < lista.length && Date.now() - inicio < presupuestoMs) {
      const nombre = lista[i++];
      try {
        const r = await procesarUno({ supabaseUrl, serviceKey, nombre, sharpLib: sharpUsado, fetchImpl });
        hechas += 1;
        bytesAntes += r.bytesOriginal;
        bytesDespues += r.bytesMiniatura;
      } catch (err) {
        errores.push({ nombre, error: String((err && err.message) || err).slice(0, 160) });
      }
    }
  }

  await Promise.all(Array.from({ length: Math.max(1, concurrencia) }, trabajador));

  return {
    ok: true,
    job: 'miniaturas',
    pendientes_en_lote: lista.length,
    hechas,
    con_error: errores.length,
    errores: errores.slice(0, 20),
    // Si el lote vino lleno o se acabó el tiempo, hay más por hacer.
    quedan_mas: lista.length >= limite || hechas + errores.length < lista.length,
    kb_originales: Math.round(bytesAntes / 1024),
    kb_miniaturas: Math.round(bytesDespues / 1024),
  };
}

module.exports = { runMiniaturasJob, rutaMiniatura, codificarRuta, generarMiniatura };
