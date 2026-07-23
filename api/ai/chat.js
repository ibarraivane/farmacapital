'use strict';

const SYSTEM_PROMPT = `Eres el asistente de administración de FarmaCapital, farmacia independiente en Chinampac de Juárez, Iztapalapa, CDMX.
Ayudas al equipo con:
- Reportes y resúmenes de ventas, inventario y operación (usa los DATOS EN VIVO cuando estén disponibles; no inventes cifras).
- Alertas de reabasto, productos agotados y stock bajo.
- Redacción de correos y mensajes WhatsApp a proveedores mayoristas (Nadro, Marzam, Casa Saba, Fármacos Nacionales): tono profesional, español de México.
- COFEPRIS, bitácoras, márgenes y buenas prácticas de farmacia independiente.
Responde en español, conciso y accionable. Si faltan datos para un reporte, indica qué falta y ofrece un borrador con placeholders.`;

function normalizeUrl(url) {
  if (!url) return '';
  return String(url).trim().replace(/\/+$/g, '').replace(/\/rest\/v1$/i, '').replace(/\/+$/g, '');
}

async function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === 'object') return req.body;
    return JSON.parse(req.body || '{}');
  } catch {
    return {};
  }
}

async function rpc(supabaseUrl, serviceKey, fn, payload) {
  const resp = await fetch(`${supabaseUrl}/rest/v1/rpc/${fn}`, {
    method: 'POST',
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });
  if (!resp.ok) {
    const detail = await resp.text().catch(() => '');
    throw new Error(`rpc_${fn}_failed:${resp.status}:${detail.slice(0, 200)}`);
  }
  return resp.json();
}

async function validateSession(supabaseUrl, serviceKey, sessionToken) {
  if (!sessionToken) return false;
  try {
    const data = await rpc(supabaseUrl, serviceKey, 'fn_validar_session_token', {
      p_token: sessionToken,
    });
    return Boolean(data && data !== false && !data?.error);
  } catch {
    return false;
  }
}

function sumPedidos(arr) {
  if (!Array.isArray(arr)) return 0;
  return arr.reduce((s, r) => s + Number(r?.total || 0), 0);
}

async function buildFarmaciaContext(supabaseUrl, serviceKey, sessionToken) {
  const hoy = new Date();
  const pad = (n) => String(n).padStart(2, '0');
  const hoyLocal = `${hoy.getFullYear()}-${pad(hoy.getMonth() + 1)}-${pad(hoy.getDate())}`;
  const startDay = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate());
  const startWeek = new Date(startDay);
  startWeek.setDate(startWeek.getDate() - startWeek.getDay());
  const startMonth = new Date(hoy.getFullYear(), hoy.getMonth(), 1);

  const ctx = {
    p_session_token: sessionToken,
    p_ctx: {
      hoy_local: hoyLocal,
      ayer_local: hoyLocal,
      inicio_mes_local: `${hoy.getFullYear()}-${pad(hoy.getMonth() + 1)}-01`,
      today_start: startDay.toISOString(),
      today_end: new Date(startDay.getTime() + 86400000 - 1).toISOString(),
      week_start: startWeek.toISOString(),
      month_start: startMonth.toISOString(),
      yesterday_start: new Date(startDay.getTime() - 86400000).toISOString(),
      yesterday_end: new Date(startDay.getTime() - 1).toISOString(),
      week_prev_start: new Date(startWeek.getTime() - 7 * 86400000).toISOString(),
      week_prev_end: new Date(startWeek.getTime() - 1).toISOString(),
      month_prev_start: new Date(hoy.getFullYear(), hoy.getMonth() - 1, 1).toISOString(),
      month_prev_end: new Date(hoy.getFullYear(), hoy.getMonth(), 0, 23, 59, 59).toISOString(),
    },
  };

  const [alertas, dash] = await Promise.all([
    rpc(supabaseUrl, serviceKey, 'empleado_admin_alertas_snapshot', {
      p_session_token: sessionToken,
      p_hoy: hoyLocal,
    }).catch(() => null),
    rpc(supabaseUrl, serviceKey, 'empleado_dashboard_operacion_bundle', ctx).catch(() => null),
  ]);

  const lines = [`Fecha consulta: ${hoyLocal} (CDMX)`];

  if (alertas) {
    lines.push(`Productos con stock bajo mínimo: ${alertas.stock_bajo ?? 0}`);
    const pend = Array.isArray(alertas.pend_pedidos) ? alertas.pend_pedidos.length : 0;
    lines.push(`Pedidos online pendientes: ${pend}`);
    lines.push(`Citas web hoy: ${alertas.citas_web_hoy ?? 0}`);
  }

  if (dash) {
    const vHoy = sumPedidos(dash.ped_hoy);
    const vSem = sumPedidos(dash.ped_semana);
    const vMes = sumPedidos(dash.ped_mes);
    lines.push(`Ventas completadas hoy: $${vHoy.toFixed(2)} MXN`);
    lines.push(`Ventas semana (desde domingo): $${vSem.toFixed(2)} MXN`);
    lines.push(`Ventas mes: $${vMes.toFixed(2)} MXN`);

    const agotados = Array.isArray(dash.bajo_stock) ? dash.bajo_stock : [];
    if (agotados.length) {
      lines.push('Productos agotados (muestra):');
      agotados.slice(0, 12).forEach((p) => {
        lines.push(`  · ${p.nombre} — stock ${p.stock ?? 0} (mín ${p.stock_minimo ?? 0})`);
      });
    }

    const cad = Array.isArray(dash.por_caducar) ? dash.por_caducar.length : 0;
    if (cad) lines.push(`Lotes por caducar (30 días): ${cad} registros`);
  }

  return lines.join('\n');
}

async function callGemini(apiKey, systemText, messages) {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${encodeURIComponent(apiKey)}`;
  const resp = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      system_instruction: { parts: [{ text: systemText }] },
      contents: messages.map((m) => ({
        role: m.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: m.content }],
      })),
      generationConfig: { maxOutputTokens: 2048, temperature: 0.65 },
    }),
  });
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok || data?.error) {
    const err = data?.error || { message: `HTTP ${resp.status}` };
    const e = new Error(err.message || 'gemini_error');
    e.code = err.code || resp.status;
    throw e;
  }
  return data?.candidates?.[0]?.content?.parts?.[0]?.text || 'No pude obtener respuesta.';
}

module.exports = async function handler(req, res) {
  const apiKey = String(process.env.GEMINI_API_KEY || '').trim();

  if (req.method === 'GET') {
    const configured = Boolean(apiKey);
    const sessionToken = String(req.query?.session_token || '').trim();
    if (!configured) {
      return res.status(200).json({ ok: true, configured: false });
    }
    if (!sessionToken) {
      return res.status(200).json({ ok: true, configured: true, session: false });
    }
    const supabaseUrl = normalizeUrl(process.env.SUPABASE_URL || process.env.REACT_APP_SUPABASE_URL || '');
    const serviceKey = String(process.env.SUPABASE_SERVICE_ROLE_KEY || '').trim();
    if (!supabaseUrl || !serviceKey) {
      return res.status(200).json({ ok: true, configured: true, session: false });
    }
    const valid = await validateSession(supabaseUrl, serviceKey, sessionToken);
    return res.status(200).json({ ok: true, configured: true, session: valid });
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }

  if (!apiKey) {
    return res.status(503).json({ ok: false, error: 'gemini_not_configured' });
  }

  const supabaseUrl = normalizeUrl(process.env.SUPABASE_URL || process.env.REACT_APP_SUPABASE_URL || '');
  const serviceKey = String(process.env.SUPABASE_SERVICE_ROLE_KEY || '').trim();

  const body = await safeJson(req);
  const sessionToken = String(body?.session_token || '').trim();
  const messages = Array.isArray(body?.messages) ? body.messages : [];
  const includeContext = body?.include_context !== false;

  if (!sessionToken) {
    return res.status(401).json({ ok: false, error: 'missing_session' });
  }
  if (!messages.length) {
    return res.status(400).json({ ok: false, error: 'missing_messages' });
  }
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ ok: false, error: 'supabase_not_configured' });
  }

  const valid = await validateSession(supabaseUrl, serviceKey, sessionToken);
  if (!valid) {
    return res.status(401).json({ ok: false, error: 'invalid_session' });
  }

  let systemText = SYSTEM_PROMPT;
  if (includeContext) {
    try {
      const ctx = await buildFarmaciaContext(supabaseUrl, serviceKey, sessionToken);
      systemText += `\n\n--- DATOS EN VIVO DE LA FARMACIA ---\n${ctx}`;
    } catch (e) {
      console.warn('[ai/chat] context:', e?.message);
    }
  }

  try {
    const reply = await callGemini(apiKey, systemText, messages);
    return res.status(200).json({ ok: true, reply });
  } catch (e) {
    if (e.code === 429) {
      return res.status(429).json({ ok: false, error: 'rate_limit', message: 'Límite de uso alcanzado. Intenta en unos minutos.' });
    }
    if (e.code === 401 || e.code === 403) {
      return res.status(502).json({ ok: false, error: 'gemini_auth', message: 'Clave Gemini inválida en Vercel.' });
    }
    console.error('[ai/chat]', e);
    return res.status(502).json({ ok: false, error: 'gemini_error', message: e.message });
  }
};
