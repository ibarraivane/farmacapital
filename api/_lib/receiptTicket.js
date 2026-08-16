'use strict';

const crypto = require('crypto');
const { FARMACIA_FISCAL } = require('./farmaciaFiscal');

const PASS_CSS = `
* { box-sizing: border-box; }
html, body { margin: 0; padding: 0; background: #f1f5f9; font-family: system-ui, -apple-system, 'Segoe UI', sans-serif; color: #0f172a; }
.pass { max-width: 420px; margin: 0 auto; min-height: 100vh; padding: 20px 16px 32px; }
.card { background: #fff; border-radius: 16px; padding: 20px; box-shadow: 0 8px 30px rgba(15,23,42,.08); }
.badge { display: inline-block; padding: 6px 12px; border-radius: 999px; font-size: 12px; font-weight: 800; letter-spacing: .02em; }
.badge-ready { background: #dcfce7; color: #166534; }
.badge-prep { background: #fef3c7; color: #92400e; }
.badge-envio { background: #dbeafe; color: #1e40af; }
.folio { font-size: 28px; font-weight: 900; letter-spacing: .5px; margin: 12px 0 4px; }
.sub { color: #64748b; font-size: 14px; line-height: 1.5; }
.qr { display: block; margin: 16px auto; border-radius: 12px; }
.btn { display: block; margin-top: 14px; padding: 12px 16px; background: #0D1B2A; color: #fff; text-align: center; text-decoration: none; border-radius: 10px; font-weight: 700; font-size: 14px; }
.meta { margin-top: 16px; font-size: 13px; line-height: 1.6; color: #475569; }
`;

const TICKET_CSS = `
* { box-sizing: border-box; }
html, body { margin: 0; padding: 0; background: #fff; font-family: 'Courier New', Courier, monospace; }
.ticket { width: 100%; max-width: 360px; margin: 0 auto; font-size: 13px; line-height: 1.45; color: #000; padding: 16px 12px 24px; }
.center { text-align: center; }
.separator { border: none; border-top: 1px dashed #000; margin: 8px 0; }
.footer { text-align: center; margin-top: 12px; font-size: 11px; color: #444; }
.ticket-link { display: block; margin-top: 12px; padding: 10px; background: #0D1B2A; color: #fff; text-align: center; text-decoration: none; border-radius: 8px; font-weight: 700; }
`;

function getPublicSiteBase() {
  return String(process.env.PUBLIC_SITE_URL || 'https://www.farmacapital.mx').replace(/\/+$/, '');
}

function formatFolioPOS(pedidoId) {
  if (pedidoId == null) return null;
  return `VTA-${String(pedidoId).padStart(8, '0')}`;
}

function formatFolioOnline(pedidoId) {
  if (pedidoId == null) return null;
  return `#FC-${String(pedidoId).padStart(4, '0')}`;
}

function pedidoEstaListo(pedido) {
  const estado = String(pedido?.estado || '').toLowerCase();
  return estado === 'listo' || estado === 'completado';
}

function formatMoneyMx(value) {
  const n = Number(value || 0);
  return Number.isFinite(n) ? n.toFixed(2) : '0.00';
}

function buildReciboPublicUrl(token) {
  const t = String(token || '').trim();
  if (!t) return null;
  return `${getPublicSiteBase()}/r/${encodeURIComponent(t)}`;
}

function supabaseHeaders(serviceKey, extra = {}) {
  return {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
    'Content-Type': 'application/json',
    ...extra,
  };
}

async function fetchPedidoReciboRow(supabaseUrl, serviceKey, pedidoId) {
  const select = [
    'id',
    'total',
    'tipo',
    'tipo_entrega',
    'estado',
    'created_at',
    'metodo_pago',
    'recibo_token',
    'cliente_id',
    'clientes(nombre,telefono)',
    'pedido_items(cantidad,precio_unitario,productos(nombre))',
  ].join(',');
  const resp = await fetch(
    `${supabaseUrl}/rest/v1/pedidos?id=eq.${pedidoId}&select=${encodeURIComponent(select)}&limit=1`,
    { headers: supabaseHeaders(serviceKey) }
  );
  const rows = await resp.json().catch(() => []);
  if (!resp.ok || !Array.isArray(rows)) return null;
  return rows[0] || null;
}

/** Crea o reutiliza token público opaco para ver el ticket en /r/{token}. */
async function ensurePedidoReciboToken(supabaseUrl, serviceKey, pedidoId) {
  const row = await fetchPedidoReciboRow(supabaseUrl, serviceKey, pedidoId);
  if (!row) return null;
  if (row.recibo_token) return String(row.recibo_token);

  const token = crypto.randomUUID();
  const patchResp = await fetch(`${supabaseUrl}/rest/v1/pedidos?id=eq.${pedidoId}`, {
    method: 'PATCH',
    headers: supabaseHeaders(serviceKey, { Prefer: 'return=representation' }),
    body: JSON.stringify({
      recibo_token: token,
      recibo_generado_at: new Date().toISOString(),
    }),
  });
  const patched = await patchResp.json().catch(() => []);
  if (patchResp.ok && Array.isArray(patched) && patched[0]?.recibo_token) {
    return String(patched[0].recibo_token);
  }
  return token;
}

async function fetchPedidoByReciboToken(supabaseUrl, serviceKey, token) {
  const t = String(token || '').trim();
  if (!t) return null;
  const select = [
    'id',
    'total',
    'tipo',
    'tipo_entrega',
    'estado',
    'created_at',
    'metodo_pago',
    'recibo_token',
    'clientes(nombre,telefono)',
    'pedido_items(cantidad,precio_unitario,productos(nombre))',
  ].join(',');
  const resp = await fetch(
    `${supabaseUrl}/rest/v1/pedidos?recibo_token=eq.${encodeURIComponent(t)}&select=${encodeURIComponent(select)}&limit=1`,
    { headers: supabaseHeaders(serviceKey) }
  );
  const rows = await resp.json().catch(() => []);
  if (!resp.ok || !Array.isArray(rows)) return null;
  return rows[0] || null;
}

function mapItems(pedido) {
  return (pedido?.pedido_items || []).map((i) => ({
    nombre: i?.productos?.nombre || 'Producto',
    qty: Number(i?.cantidad ?? 1),
    precio: Number(i?.precio_unitario ?? 0),
  }));
}

/** Pase móvil para pedidos online (no clona ticket Epson). */
function generatePickupPassHTML({ pedido, ticketUrl, mode = 'pickup' }) {
  const cfg = FARMACIA_FISCAL;
  const folio = formatFolioOnline(pedido?.id) || `#FC-${pedido?.id || '?'}`;
  const total = formatMoneyMx(pedido?.total);
  const nombre = pedido?.clientes?.nombre ? String(pedido.clientes.nombre).trim() : '';
  const qrSrc = ticketUrl
    ? `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(ticketUrl)}`
    : null;

  let badgeClass = 'badge-ready';
  let badgeText = 'Listo para recoger';
  let headline = 'Muestra este pase en mostrador';
  let detail =
    'Tu pedido ya está surtido. Presenta esta pantalla o el folio al llegar a FarmaCapital.';

  if (mode === 'preparing') {
    badgeClass = 'badge-prep';
    badgeText = 'En preparación';
    headline = 'Estamos preparando tu pedido';
    detail =
      'Cuando esté listo te avisaremos por WhatsApp. Guarda este enlace para consultar el estado.';
  } else if (mode === 'envio') {
    badgeClass = 'badge-envio';
    badgeText = 'Listo para envío';
    headline = 'Tu pedido está listo para salir';
    detail =
      'Coordinaremos la entrega (Rappi / Uber). Te contactamos por WhatsApp para confirmar horario.';
  }

  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>${folio} — FarmaCapital</title>
  <style>${PASS_CSS}</style>
</head>
<body>
  <div class="pass">
    <div class="card">
      <span class="badge ${badgeClass}">${badgeText}</span>
      <div class="folio">${folio}</div>
      ${nombre ? `<div class="sub">${nombre}</div>` : ''}
      <h1 style="font-size:18px;margin:16px 0 8px;line-height:1.3">${headline}</h1>
      <p class="sub">${detail}</p>
      ${qrSrc && mode === 'pickup' ? `<img class="qr" src="${qrSrc}" width="200" height="200" alt="QR pase de recogida">` : ''}
      <div class="meta">
        <div><strong>Total pagado:</strong> $${total}</div>
        <div><strong>Farmacia:</strong> ${cfg.direccion_comercial}</div>
        <div><strong>Tel:</strong> ${cfg.telefono_display || cfg.telefono}</div>
      </div>
      <a class="btn" href="${cfg.maps_url}" target="_blank" rel="noopener">Cómo llegar (Google Maps)</a>
    </div>
    <p style="text-align:center;color:#94a3b8;font-size:12px;margin-top:16px">FarmaCapital · farmacapital.mx</p>
  </div>
</body>
</html>`;
}

/** Elige ticket Epson (POS) o pase móvil (online) según tipo y estado del pedido. */
function generateReciboHTML({ pedido, ticketUrl }) {
  const tipo = String(pedido?.tipo || '').toLowerCase();
  const entrega = String(pedido?.tipo_entrega || '').toLowerCase();
  const listo = pedidoEstaListo(pedido);
  const esOnline = tipo === 'online' || tipo === 'web' || tipo === 'tienda_online';

  if (esOnline) {
    if (listo && entrega === 'envio') {
      return generatePickupPassHTML({ pedido, ticketUrl, mode: 'envio' });
    }
    if (listo && entrega === 'recoger') {
      return generatePickupPassHTML({ pedido, ticketUrl, mode: 'pickup' });
    }
    if (!listo) {
      return generatePickupPassHTML({ pedido, ticketUrl, mode: 'preparing' });
    }
  }

  return generateTicketHTML({ pedido, ticketUrl });
}

function generateTicketHTML({ pedido, ticketUrl }) {
  const venta = {
    id: pedido.id,
    total: pedido.total,
    created_at: pedido.created_at,
    folio: formatFolioPOS(pedido.id),
  };
  const productos = mapItems(pedido);
  const cliente = pedido.clientes || null;
  const metodoPago = String(pedido.metodo_pago || 'Efectivo').replace(/_/g, ' ');
  const fecha = new Date(venta.created_at || Date.now());
  const fechaStr = fecha.toLocaleDateString('es-MX', { day: '2-digit', month: '2-digit', year: 'numeric' });
  const horaStr = fecha.toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' });
  const folio = venta.folio || `#${venta.id || '?'}`;
  const total = parseFloat(venta.total || 0);
  const fmt = (n) => `$${parseFloat(n || 0).toFixed(2)}`;
  const cfg = FARMACIA_FISCAL;
  const iconSrc = `${getPublicSiteBase()}/brand/farmacapital-icon.png`;

  const rows = productos
    .map(
      (p) => `
    <div style="margin-bottom:4px">
      <div style="font-weight:bold">${String(p.nombre || 'Producto').slice(0, 28)}</div>
      <div style="display:flex;justify-content:space-between;font-size:12px">
        <span>${p.qty} x ${fmt(p.precio)}</span>
        <span style="font-weight:bold">${fmt(p.precio * p.qty)}</span>
      </div>
    </div>`
    )
    .join('');

  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Ticket ${folio} — FarmaCapital</title>
  <style>${TICKET_CSS}</style>
</head>
<body>
  <div class="ticket">
    <div class="center">
      <img src="${iconSrc}" alt="" width="36" height="36" style="display:block;margin:0 auto 6px"/>
      <div style="font-size:16px;font-weight:900;letter-spacing:1px">FarmaCapital</div>
      <div style="font-size:11px;color:#555">Tu salud primero</div>
    </div>
    <hr class="separator">
    <div style="font-size:11px;line-height:1.6">
      <div>${cfg.nombre_comercial || 'FarmaCapital'}</div>
      <div>${cfg.direccion_comercial}</div>
      <div>RFC: ${cfg.rfc}</div>
      <div>Tel: ${cfg.telefono_display || cfg.telefono}</div>
    </div>
    <hr class="separator">
    <div style="font-size:11px;line-height:1.7">
      <div>Fecha: ${fechaStr}</div>
      <div>Hora: ${horaStr}</div>
      <div>Folio: ${folio}</div>
      ${cliente?.nombre ? `<div>Cliente: ${cliente.nombre}</div>` : ''}
    </div>
    <hr class="separator">
    ${rows || '<div>Sin detalle de productos</div>'}
    <hr class="separator">
    <div style="display:flex;justify-content:space-between;font-size:16px;font-weight:900">
      <span>TOTAL</span><span>${fmt(total)}</span>
    </div>
    <div style="margin-top:6px;font-size:12px">Método: ${metodoPago}</div>
    <hr class="separator">
    <div class="footer">
      <div style="font-weight:bold">Gracias por su compra</div>
      <div>farmacapital.mx</div>
    </div>
    ${ticketUrl ? `<a class="ticket-link" href="${ticketUrl}">Guardar este ticket</a>` : ''}
  </div>
</body>
</html>`;
}

module.exports = {
  getPublicSiteBase,
  buildReciboPublicUrl,
  ensurePedidoReciboToken,
  fetchPedidoByReciboToken,
  fetchPedidoReciboRow,
  generateReciboHTML,
  generatePickupPassHTML,
  generateTicketHTML,
  formatFolioPOS,
  formatFolioOnline,
  formatMoneyMx,
  mapItems,
  pedidoEstaListo,
};
