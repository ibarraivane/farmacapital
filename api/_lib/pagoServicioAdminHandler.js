'use strict';

const {
  getSupabaseAdminConfig,
  validateAdminSession,
  validateEmployeeSession,
  rpc,
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

function recargoCategoriaValido(comision, categoria) {
  const n = roundMoney(comision);
  if (String(categoria || '').toLowerCase() === 'recarga') return n === 0;
  return n > 0;
}

const RECIBO_IDS = ['cfe', 'telmex', 'totalplay', 'izzi', 'sky', 'agua', 'gas', 'otro'];
const RECARGO_RECIBO_MAX = 200;
const RECARGO_DEFAULT = { cfe: 8, telmex: 8, totalplay: 8, izzi: 10, sky: 10, agua: 8, gas: 8, otro: 10 };

function recargoIdDeProveedor(proveedor) {
  const k = String(proveedor || '').trim().toLowerCase();
  if (!k) return null;
  if (RECIBO_IDS.includes(k)) return k;
  if (k.includes('izzi')) return 'izzi';
  if (k.includes('cfe')) return 'cfe';
  if (k.includes('telmex')) return 'telmex';
  if (k.includes('totalplay')) return 'totalplay';
  if (k.includes('sky')) return 'sky';
  if (k.includes('agua')) return 'agua';
  if (k.includes('gas')) return 'gas';
  if (k.includes('otro')) return 'otro';
  return null;
}

async function recargosGuardados(supabaseUrl, headers) {
  try {
    const resp = await fetch(
      `${supabaseUrl}/rest/v1/configuracion?clave=eq.servicios_recargos&select=valor`,
      { headers }
    );
    const rows = await resp.json().catch(() => []);
    const raw = Array.isArray(rows) ? rows[0]?.valor : rows?.valor;
    if (!raw) return {};
    const obj = typeof raw === 'string' ? JSON.parse(raw) : raw;
    if (!obj || typeof obj !== 'object') return {};
    const out = {};
    for (const id of RECIBO_IDS) {
      const n = roundMoney(obj[id]);
      if (n > 0) out[id] = n;
    }
    return out;
  } catch {
    return {};
  }
}

function recargoVigente(proveedor, categoria, comisionCliente, cfg) {
  if (String(categoria || '').toLowerCase() === 'recarga') return 0;
  const id = recargoIdDeProveedor(proveedor);
  if (id) {
    const n = roundMoney(cfg?.[id] ?? RECARGO_DEFAULT[id]);
    if (n > 0) return n;
  }
  return roundMoney(comisionCliente);
}

function recargosReciboValidos(raw) {
  const src = raw && typeof raw === 'object' && !Array.isArray(raw) ? raw : {};
  const recargos = {};
  for (const id of RECIBO_IDS) {
    const n = roundMoney(src[id]);
    if (!(n > 0) || n > RECARGO_RECIBO_MAX) return null;
    recargos[id] = n;
  }
  return recargos;
}

function folioServicioMexico(id) {
  const ymd = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'America/Mexico_City',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(new Date()).replace(/-/g, '');
  return `SRV-${ymd}-${String(id).padStart(6, '0')}`;
}

async function employeeIdFromToken(supabaseUrl, serviceKey, sessionToken) {
  if (!sessionToken) return null;
  try {
    const data = await rpc(serviceKey, supabaseUrl, 'fn_validar_token_empleado', {
      p_token: sessionToken,
    });
    const id = Number(data);
    return Number.isFinite(id) && id > 0 ? id : null;
  } catch {
    return null;
  }
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
    if (action === 'registrar') {
      const actorId = await employeeIdFromToken(supabaseUrl, serviceKey, sessionToken);
      if (!actorId) return res.status(403).json({ ok: false, error: 'requiere_empleado' });

      const proveedor = String(body.proveedor || '').trim();
      const categoria = String(body.categoria || '').trim().toLowerCase();
      const metodo = String(body.metodo_pago || '').trim().toLowerCase();
      const monto = roundMoney(body.monto_servicio);
      const cfgRecargos = await recargosGuardados(supabaseUrl, headers);
      const comision = recargoVigente(proveedor, categoria, body.comision, cfgRecargos);
      if (!proveedor) return res.status(400).json({ ok: false, error: 'Proveedor requerido' });
      if (!categoria) return res.status(400).json({ ok: false, error: 'Categoría requerida' });
      if (!(monto > 0)) return res.status(400).json({ ok: false, error: 'Monto del servicio debe ser mayor a 0' });
      if (!recargoCategoriaValido(comision, categoria)) {
        return res.status(400).json({
          ok: false,
          error: categoria === 'recarga'
            ? 'Las recargas no llevan recargo de farmacia. Solo el monto de tiempo aire.'
            : 'El recargo de farmacia es obligatorio en recibos. No se guarda en cero.',
        });
      }
      if (metodo !== 'efectivo' && metodo !== 'tarjeta') {
        return res.status(400).json({ ok: false, error: 'metodo_pago inválido (efectivo o tarjeta)' });
      }

      const row = {
        folio: 'PENDING',
        categoria,
        proveedor,
        referencia: String(body.referencia || '').trim() || null,
        monto_servicio: monto,
        comision: categoria === 'recarga' ? 0 : comision,
        total_cobrado: roundMoney(monto + (categoria === 'recarga' ? 0 : comision)),
        metodo_pago: metodo,
        liquidado_point: !!body.liquidado_point,
        notas: String(body.notas || '').trim() || null,
        cliente_id: body.cliente_id != null && body.cliente_id !== '' ? Number(body.cliente_id) : null,
        atendido_por: actorId,
        compensacion_mp: roundMoney(monto * 0.01),
        costo_liquidacion: monto,
        fuente_liquidacion: 'saldo_mp',
      };
      if (row.cliente_id != null && (!Number.isFinite(row.cliente_id) || row.cliente_id <= 0)) {
        return res.status(400).json({ ok: false, error: 'cliente_invalido' });
      }

      const ins = await fetch(`${supabaseUrl}/rest/v1/pagos_servicio`, {
        method: 'POST',
        headers,
        body: JSON.stringify(row),
      });
      const created = await ins.json().catch(() => null);
      const inserted = Array.isArray(created) ? created[0] : created;
      if (!ins.ok || !inserted?.id) {
        return res.status(502).json({ ok: false, error: patchError(created) });
      }

      const folio = folioServicioMexico(inserted.id);
      const upd = await fetch(`${supabaseUrl}/rest/v1/pagos_servicio?id=eq.${inserted.id}`, {
        method: 'PATCH',
        headers,
        body: JSON.stringify({ folio }),
      });
      const updated = await upd.json().catch(() => []);
      const saved = Array.isArray(updated) ? updated[0] : updated;
      if (!upd.ok) {
        return res.status(502).json({ ok: false, error: patchError(updated) });
      }
      return res.status(200).json({ ok: true, row: saved || { ...inserted, folio } });
    }

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

    if (action === 'set_recargos') {
      const recargos = recargosReciboValidos(body.recargos);
      if (!recargos) {
        return res.status(400).json({ ok: false, error: 'El recargo de cada recibo tiene que ser mayor a 0.' });
      }
      const upsert = await fetch(`${supabaseUrl}/rest/v1/configuracion?on_conflict=clave`, {
        method: 'POST',
        headers: { ...headers, Prefer: 'resolution=merge-duplicates,return=representation' },
        body: JSON.stringify({ clave: 'servicios_recargos', valor: JSON.stringify(recargos) }),
      });
      const saved = await upsert.json().catch(() => null);
      if (!upsert.ok) {
        return res.status(502).json({ ok: false, error: patchError(saved) });
      }
      return res.status(200).json({ ok: true, recargos });
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
        `${supabaseUrl}/rest/v1/pagos_servicio?id=eq.${id}&select=monto_servicio,comision,categoria`,
        { headers }
      );
      const cur = await curResp.json().catch(() => []);
      const row = Array.isArray(cur) ? cur[0] : null;
      if (!row) return res.status(404).json({ ok: false, error: 'no_encontrado' });
      const monto = patch.monto_servicio != null ? patch.monto_servicio : Number(row.monto_servicio);
      const com = patch.comision != null ? patch.comision : Number(row.comision);
      const cat = String(row.categoria || '').toLowerCase();
      if (!recargoCategoriaValido(com, cat)) {
        return res.status(400).json({
          ok: false,
          error: cat === 'recarga'
            ? 'Las recargas no llevan recargo de farmacia.'
            : 'El recargo de farmacia es obligatorio en recibos.',
        });
      }
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
