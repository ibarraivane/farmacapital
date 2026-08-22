'use strict';

const {
  getSupabaseAdminConfig,
  validateAdminSession,
  validateEmployeeSession,
} = require('./supabaseAdmin');

function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === 'object') return req.body;
    return JSON.parse(req.body || '{}');
  } catch {
    return {};
  }
}

function roundMoney(n) {
  return Math.round(Number(n) * 100) / 100;
}

function restHeaders(serviceKey) {
  return {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
    Accept: 'application/json',
    'Content-Type': 'application/json',
    Prefer: 'return=representation',
  };
}

function patchError(data) {
  if (!data) return 'no_se_pudo_guardar';
  if (typeof data === 'string') return data.slice(0, 180);
  return data.message || data.error || data.code || 'no_se_pudo_guardar';
}

async function pagoServicioAdminHandler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ ok: false, error: 'supabase_not_configured' });
  }

  const body = safeJson(req);
  const sessionToken = String(body.session_token || req.headers['x-session-token'] || '').trim();
  if (!sessionToken) {
    return res.status(401).json({ ok: false, error: 'missing_session' });
  }

  const action = String(body.action || 'editar').trim();
  const headers = restHeaders(serviceKey);

  try {
    if (action === 'listar') {
      const isEmp = await validateEmployeeSession(supabaseUrl, serviceKey, sessionToken);
      if (!isEmp) return res.status(403).json({ ok: false, error: 'requiere_empleado' });
      const qs = new URLSearchParams();
      qs.set('select', 'id,folio,proveedor,categoria,referencia,monto_servicio,comision,compensacion_mp,costo_liquidacion,fuente_liquidacion,referencia_externa,total_cobrado,metodo_pago,liquidado_point,notas,created_at,atendido_por');
      qs.set('order', 'created_at.desc');
      qs.set('limit', '300');
      if (body.desde) qs.append('created_at', `gte.${body.desde}`);
      if (body.hasta) qs.append('created_at', `lte.${body.hasta}`);
      const resp = await fetch(`${supabaseUrl}/rest/v1/pagos_servicio?${qs.toString()}`, { headers });
      const rows = await resp.json().catch(() => []);
      if (!resp.ok || !Array.isArray(rows)) {
        return res.status(502).json({ ok: false, error: 'no_se_pudo_listar' });
      }
      const usersResp = await fetch(`${supabaseUrl}/rest/v1/usuarios?select=id,nombre`, { headers });
      const users = await usersResp.json().catch(() => []);
      const byId = Object.fromEntries((Array.isArray(users) ? users : []).map((u) => [String(u.id), u.nombre]));
      return res.status(200).json({
        ok: true,
        rows: rows.map((r) => ({
          ...r,
          atendido_por_nombre: r.atendido_por != null ? (byId[String(r.atendido_por)] || '') : '',
        })),
      });
    }

    const isAdmin = await validateAdminSession(supabaseUrl, serviceKey, sessionToken);
    if (!isAdmin) {
      return res.status(403).json({ ok: false, error: 'requiere_admin' });
    }

    const id = Number(body.id);
    if (!Number.isFinite(id) || id <= 0) {
      return res.status(400).json({ ok: false, error: 'id_invalido' });
    }

    if (action === 'eliminar') {
      const resp = await fetch(`${supabaseUrl}/rest/v1/pagos_servicio?id=eq.${id}`, {
        method: 'DELETE',
        headers,
      });
      const data = await resp.json().catch(() => []);
      if (!resp.ok) {
        return res.status(502).json({ ok: false, error: 'no_se_pudo_eliminar' });
      }
      return res.status(200).json({ ok: true, deleted: Array.isArray(data) ? data.length : 1 });
    }

    const patch = {};
    if (body.metodo_pago === 'efectivo' || body.metodo_pago === 'tarjeta') {
      patch.metodo_pago = body.metodo_pago;
    }
    if (body.notas !== undefined) {
      const n = String(body.notas || '').trim();
      patch.notas = n || null;
    }
    if (body.referencia !== undefined) {
      const r = String(body.referencia || '').trim();
      patch.referencia = r || null;
    }
    if (body.monto_servicio != null && body.monto_servicio !== '') {
      const m = roundMoney(body.monto_servicio);
      if (!(m > 0)) return res.status(400).json({ ok: false, error: 'monto_invalido' });
      patch.monto_servicio = m;
    }
    if (body.comision != null && body.comision !== '') {
      const c = roundMoney(body.comision);
      if (c < 0 || !Number.isFinite(c)) return res.status(400).json({ ok: false, error: 'comision_invalida' });
      patch.comision = c;
    }
    if (body.atendido_por != null && body.atendido_por !== '') {
      const aid = Number(body.atendido_por);
      if (!Number.isFinite(aid) || aid <= 0) {
        return res.status(400).json({ ok: false, error: 'atendido_por_invalido' });
      }
      patch.atendido_por = aid;
    }

    if (patch.monto_servicio != null || patch.comision != null) {
      const curResp = await fetch(
        `${supabaseUrl}/rest/v1/pagos_servicio?id=eq.${id}&select=monto_servicio,comision`,
        { headers }
      );
      const cur = await curResp.json().catch(() => []);
      const row = Array.isArray(cur) ? cur[0] : null;
      if (!row) return res.status(404).json({ ok: false, error: 'no_encontrado' });
      const monto = patch.monto_servicio != null ? patch.monto_servicio : Number(row.monto_servicio);
      const com = patch.comision != null ? patch.comision : Number(row.comision);
      patch.total_cobrado = roundMoney(monto + com);
      if (patch.monto_servicio != null) {
        patch.compensacion_mp = roundMoney(monto * 0.01);
        patch.costo_liquidacion = monto;
        if (!patch.fuente_liquidacion) patch.fuente_liquidacion = 'saldo_mp';
      }
    }

    if (!Object.keys(patch).length) {
      return res.status(400).json({ ok: false, error: 'nada_que_guardar' });
    }

    const resp = await fetch(`${supabaseUrl}/rest/v1/pagos_servicio?id=eq.${id}`, {
      method: 'PATCH',
      headers,
      body: JSON.stringify(patch),
    });
    const data = await resp.json().catch(() => []);
    if (!resp.ok) {
      return res.status(502).json({ ok: false, error: patchError(data) });
    }
    return res.status(200).json({ ok: true, row: Array.isArray(data) ? data[0] : data });
  } catch (e) {
    return res.status(500).json({ ok: false, error: e?.message || 'error' });
  }
}

module.exports = { pagoServicioAdminHandler };
