'use strict';

const fs = require('fs');
const path = require('path');
const { buscarImagenesPorEan } = require('./imageSources');

const FUENTE_TIPOS = new Set(['instructivo', 'fabricante', 'cofepris', 'openfacts', 'otra']);
const TIPOS = new Set(['medicamento', 'dermocosmetico', 'suplemento', 'cuidado_personal', 'material', 'equipo_medico']);
const VIAS = new Set(['oral', 'topica', 'oftalmica', 'otica', 'nasal', 'vaginal', 'inyectable', 'inhalada']);
const CAMPOS = ['resumen', 'para_que_sirve', 'como_se_usa', 'no_usar_si', 'consulta_si', 'interacciones', 'efectos', 'alarma', 'conservacion'];

function noVacio(v) {
  if (Array.isArray(v)) return v.some((x) => String(x || '').trim());
  return String(v || '').trim().length > 0;
}

function validarResultadoEnriquecimiento(resultado) {
  const errores = [];
  if (!resultado || typeof resultado !== 'object') {
    return { ok: false, errores: ['resultado vacío'] };
  }
  if (!TIPOS.has(resultado.tipo_ficha)) errores.push('tipo_ficha inválido');
  const fuentes = Array.isArray(resultado.fuentes) ? resultado.fuentes : [];
  const camposConFuente = new Set();
  fuentes.forEach((f, i) => {
    if (!f || !String(f.url || '').trim()) errores.push(`fuentes[${i}].url vacía`);
    if (f && f.tipo && !FUENTE_TIPOS.has(f.tipo)) errores.push(`fuentes[${i}].tipo inválido`);
    for (const c of (f && f.campos) || []) camposConFuente.add(c);
  });
  const faltantes = Array.isArray(resultado.faltantes) ? resultado.faltantes : [];
  if (resultado.monografia) {
    if (resultado.monografia.via && !VIAS.has(resultado.monografia.via)) {
      errores.push('monografia.via inválida');
    }
    const c = resultado.monografia.contenido || {};
    for (const campo of CAMPOS) {
      if (noVacio(c[campo]) && !camposConFuente.has(campo) && !faltantes.includes(campo)) {
        errores.push(`sección ${campo} sin fuente`);
      }
    }
  }
  if (resultado.producto && noVacio(resultado.producto.resumen)
    && !camposConFuente.has('resumen') && !faltantes.includes('resumen')) {
    errores.push('sección resumen sin fuente');
  }
  return { ok: errores.length === 0, errores };
}

function payloadSeguroParaAgente(producto) {
  return {
    producto_id: producto.id,
    nombre: producto.nombre || '',
    marca: producto.marca || '',
    codigo_barras: producto.codigo_barras || '',
    principio_activo: producto.principio_activo || '',
    concentracion: producto.concentracion || '',
    forma_farmaceutica: producto.forma_farmaceutica || '',
    presentacion: producto.presentacion || '',
    requiere_receta: Boolean(producto.requiere_receta),
    tipo_ficha: producto.tipo_ficha || '',
    monografia_existente: producto.monografia_existente || null,
  };
}

function restHeaders(serviceKey) {
  return {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
    'Content-Type': 'application/json',
    Prefer: 'return=representation',
  };
}

async function rest(supabaseUrl, serviceKey, pathname, { method = 'GET', body, query } = {}) {
  const url = new URL(`${supabaseUrl}/rest/v1/${pathname}`);
  if (query) {
    for (const [k, v] of Object.entries(query)) url.searchParams.set(k, v);
  }
  const resp = await fetch(url.toString(), {
    method,
    headers: restHeaders(serviceKey),
    body: body == null ? undefined : JSON.stringify(body),
  });
  const data = await resp.json().catch(() => null);
  if (!resp.ok) {
    const detail = typeof data === 'object' ? JSON.stringify(data) : String(data || '');
    throw new Error(`rest_${pathname}:${resp.status}:${detail.slice(0, 220)}`);
  }
  return data;
}

function loadPrompt() {
  const p = path.join(__dirname, '../../../docs/catalogo-fichas/prompt_investigacion.md');
  try {
    return fs.readFileSync(p, 'utf8');
  } catch {
    return 'Eres un asistente de catálogo. Devuelve solo JSON válido. No inventes.';
  }
}

function foldClave(s) {
  return String(s || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/\s*(?:\+|\/|&| y )\s*/gi, ' + ')
    .replace(/[^a-z0-9+ ]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

async function buscarMonografiaPublicada(supabaseUrl, serviceKey, clave, via) {
  if (!clave) return null;
  const rows = await rest(supabaseUrl, serviceKey, 'monografias', {
    query: {
      clave: `eq.${clave}`,
      via: `eq.${via || 'oral'}`,
      estado: 'eq.publicado',
      select: 'id,clave,via,contenido',
      limit: '1',
    },
  });
  return Array.isArray(rows) && rows[0] ? rows[0] : null;
}

async function investigarConClaude({ payload, apiKey, fetchFn = fetch }) {
  if (!apiKey) {
    throw new Error('Falta ANTHROPIC_API_KEY en el servidor. El job no puede investigar texto.');
  }
  const system = loadPrompt();
  const resp = await fetchFn('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify({
      model: process.env.ANTHROPIC_ENRICH_MODEL || 'claude-sonnet-4-20250514',
      max_tokens: 4096,
      system,
      tools: [{ type: 'web_search_20250305', name: 'web_search' }],
      messages: [{ role: 'user', content: JSON.stringify(payload) }],
    }),
  });
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok) {
    throw new Error(`anthropic_${resp.status}:${JSON.stringify(data).slice(0, 180)}`);
  }
  const text = (data.content || [])
    .filter((b) => b.type === 'text')
    .map((b) => b.text)
    .join('\n')
    .trim();
  const jsonMatch = text.match(/\{[\s\S]*\}/);
  if (!jsonMatch) throw new Error('El agente no devolvió JSON.');
  const parsed = JSON.parse(jsonMatch[0]);
  const usage = data.usage || {};
  return {
    parsed,
    tokens: Number(usage.input_tokens || 0) + Number(usage.output_tokens || 0),
  };
}

async function procesarUnJob({
  job,
  supabaseUrl,
  serviceKey,
  apiKey = process.env.ANTHROPIC_API_KEY,
  fetchFn = fetch,
  imageSearch = buscarImagenesPorEan,
  research = investigarConClaude,
}) {
  const productos = await rest(supabaseUrl, serviceKey, 'productos', {
    query: {
      id: `eq.${job.producto_id}`,
      select: 'id,nombre,marca,codigo_barras,principio_activo,concentracion,forma_farmaceutica,presentacion,requiere_receta,categoria,subcategoria',
      limit: '1',
    },
  });
  const producto = Array.isArray(productos) ? productos[0] : null;
  if (!producto) throw new Error(`Producto ${job.producto_id} no existe`);

  const clave = foldClave(producto.principio_activo);
  const via = /crema|gel|unguent|topica/i.test(producto.forma_farmaceutica || '') ? 'topica'
    : /colirio|oftal/i.test(producto.forma_farmaceutica || '') ? 'oftalmica'
    : /inhal|aerosol/i.test(producto.forma_farmaceutica || '') ? 'inhalada'
    : 'oral';
  const mono = await buscarMonografiaPublicada(supabaseUrl, serviceKey, clave, via);
  const imagenes = await imageSearch(producto.codigo_barras, fetchFn);
  const payload = payloadSeguroParaAgente({
    ...producto,
    tipo_ficha: clave ? 'medicamento' : 'cuidado_personal',
    monografia_existente: mono,
  });

  const r = await research({ payload, apiKey, fetchFn });
  const investigacion = {
    ...r.parsed,
    monografia: mono ? null : r.parsed.monografia,
    imagenes: [...(r.parsed.imagenes || []), ...imagenes],
  };
  if (mono) {
    investigacion.alertas = [
      ...(investigacion.alertas || []),
      'Monografía publicada reutilizada; no se investigó de nuevo la sustancia.',
    ];
  }

  const valid = validarResultadoEnriquecimiento(investigacion);
  if (!valid.ok) {
    throw new Error(`JSON inválido: ${valid.errores.join('; ')}`);
  }

  return {
    resultado: investigacion,
    tokens: r.tokens || 0,
    busquedas: imagenes.length,
    monografia_id: mono ? mono.id : null,
  };
}

async function runCatalogEnrichJob({
  supabaseUrl,
  serviceKey,
  limit = 3,
  dailyMax = Number(process.env.ENRICH_DAILY_MAX || 80),
  procesar = procesarUnJob,
}) {
  const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  const hoy = await rest(supabaseUrl, serviceKey, 'enriquecimiento_jobs', {
    query: {
      updated_at: `gte.${since}`,
      select: 'id,tokens',
      limit: '500',
    },
  });
  const usados = (hoy || []).filter((r) => Number(r.tokens) > 0).length;
  if (usados >= dailyMax) {
    return { ok: true, skipped: true, reason: 'daily_max', usados, dailyMax };
  }

  const jobs = await rest(supabaseUrl, serviceKey, 'enriquecimiento_jobs', {
    query: {
      estado: 'eq.pendiente',
      select: '*',
      order: 'created_at.asc',
      limit: String(limit),
    },
  });
  const processed = [];
  for (const job of jobs || []) {
    if (job.intentos >= 3) {
      await rest(supabaseUrl, serviceKey, 'enriquecimiento_jobs', {
        method: 'PATCH',
        query: { id: `eq.${job.id}` },
        body: { estado: 'error', error: 'Se agotaron los 3 intentos.', updated_at: new Date().toISOString() },
      });
      processed.push({ id: job.id, estado: 'error' });
      continue;
    }
    await rest(supabaseUrl, serviceKey, 'enriquecimiento_jobs', {
      method: 'PATCH',
      query: { id: `eq.${job.id}` },
      body: {
        estado: 'procesando',
        intentos: Number(job.intentos || 0) + 1,
        updated_at: new Date().toISOString(),
      },
    });
    try {
      const out = await procesar({ job, supabaseUrl, serviceKey });
      await rest(supabaseUrl, serviceKey, 'enriquecimiento_jobs', {
        method: 'PATCH',
        query: { id: `eq.${job.id}` },
        body: {
          estado: 'listo_para_revision',
          resultado: out.resultado,
          tokens: out.tokens,
          busquedas: out.busquedas,
          error: null,
          updated_at: new Date().toISOString(),
        },
      });
      processed.push({ id: job.id, estado: 'listo_para_revision' });
    } catch (err) {
      const wait = Number(job.intentos || 0) + 1 >= 3;
      await rest(supabaseUrl, serviceKey, 'enriquecimiento_jobs', {
        method: 'PATCH',
        query: { id: `eq.${job.id}` },
        body: {
          estado: wait ? 'error' : 'pendiente',
          error: String(err.message || err).slice(0, 400),
          updated_at: new Date().toISOString(),
        },
      });
      processed.push({
        id: job.id,
        estado: wait ? 'error' : 'pendiente',
        error: String(err.message || err).slice(0, 120),
      });
    }
  }
  return { ok: true, processed: processed.length, jobs: processed };
}

module.exports = {
  runCatalogEnrichJob,
  procesarUnJob,
  payloadSeguroParaAgente,
  validarResultadoEnriquecimiento,
  foldClave,
};
