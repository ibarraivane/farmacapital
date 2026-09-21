'use strict';
/**
 * Plantillas de correo transaccional · FarmaCapital · v2 (21-sep-2026).
 *
 * Cambios frente a v1: sin "Farmacia mexicana"; bloque principal con la acción arriba;
 * rastreador de pedido con barra de progreso y paso actual destacado; tabla de productos
 * con columna de cantidad y miniatura; modo oscuro completo (cada texto y fondo tiene clase
 * con su versión oscura, en lugar de invertir solo algunos).
 *
 * Técnica: tablas + estilos en línea, 600 px, VML para Outlook, preheader, texto plano.
 * Cada builder devuelve { subject, preheader, html, text }.
 */

const C = {
  ink: '#001534', blue: '#054ABC', jade: '#02A158', jadeTxt: '#017A43', jadeDim: '#E4F5EC',
  body: '#3A4B63', muted: '#5B6B80', line: '#DCE2EA', mist: '#F3F5F8', red: '#B42318', redDim: '#FDF3F2',
  hero2: '#0A2547', heroTxt: '#C9D6EA', mint: '#7FD3A8',
};
const SANS = "'Archivo','Helvetica Neue',Helvetica,Arial,sans-serif";
const SERIF = "'Fraunces',Georgia,'Times New Roman',serif";

const { FARMACIA_FISCAL } = require('./farmaciaFiscal');

/** Datos de marca y legales. Razón social, RFC y domicilio salen de farmaciaFiscal.js. */
const DEFAULTS = {
  baseUrl: 'https://www.farmacapital.mx',
  logoUrl: 'https://www.farmacapital.mx/brand/farmacapital-logo-full-light@1x.png',
  whatsapp: FARMACIA_FISCAL.telefono,
  whatsappDisplay: FARMACIA_FISCAL.telefono_display,
  email: 'contacto@farmacapital.mx',
  razonSocial: FARMACIA_FISCAL.razon_social,
  rfc: FARMACIA_FISCAL.rfc,
  domicilio: FARMACIA_FISCAL.direccion_comercial,
  mapsUrl: FARMACIA_FISCAL.maps_url,
};

const esc = (v) => String(v ?? '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const money = (n) => '$' + (Number.isFinite(Number(n)) ? Number(n) : 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const folio = (id) => '#FC-' + String(id ?? '').replace(/^#?FC-?/i, '').padStart(4, '0');
const row = (inner, pad = '0 36px 28px') => `<tr><td class="px" style="padding:${pad};">${inner}</td></tr>`;

/* ================= piezas ================= */

/** Botón a prueba de Outlook. variant: 'light' (en el bloque oscuro) | 'dark' (en blanco). */
function button(label, href, variant = 'dark', width = 260) {
  const bg = variant === 'light' ? '#FFFFFF' : C.ink;
  const fg = variant === 'light' ? C.ink : '#FFFFFF';
  const cls = variant === 'light' ? 'btn btn-l' : 'btn btn-d';
  return `<table role="presentation" cellpadding="0" cellspacing="0" border="0"><tr><td>
<!--[if mso]><v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="urn:schemas-microsoft-com:office:word" href="${esc(href)}" style="height:52px;v-text-anchor:middle;width:${width}px;" arcsize="18%" stroke="f" fillcolor="${bg}"><w:anchorlock/><center style="color:${fg};font-family:Arial,sans-serif;font-size:16px;font-weight:bold;">${esc(label)}</center></v:roundrect><![endif]-->
<!--[if !mso]><!-- --><a href="${esc(href)}" class="${cls}" style="display:inline-block;background:${bg};color:${fg};font-family:${SANS};font-size:16px;font-weight:700;line-height:52px;padding:0 30px;border-radius:10px;text-decoration:none;">${esc(label)}&nbsp;&nbsp;&rarr;</a><!--<![endif]-->
</td></tr></table>`;
}

/** Bloque principal oscuro: estado, título, monto y acción. */
function hero({ tag, title, accent, lead, amountLabel, amount, cta, ctaHref, note }) {
  return `<tr><td style="background:${C.ink};padding:0 36px 34px;" class="px hero">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
      <tr><td style="padding-top:8px;">
        <span style="display:inline-block;background:rgba(127,211,168,.16);color:${C.mint};font-family:${SANS};font-size:12px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;border-radius:999px;padding:6px 12px;">${esc(tag)}</span>
      </td></tr>
      <tr><td style="padding-top:16px;">
        <h1 class="h1" style="margin:0;font-family:${SANS};font-size:34px;line-height:1.06;font-weight:800;letter-spacing:-.015em;color:#FFFFFF;">${esc(title)}${accent ? `<br><span style="font-family:${SERIF};font-style:italic;font-weight:400;color:${C.mint};">${esc(accent)}</span>` : ''}</h1>
      </td></tr>
      ${lead ? `<tr><td style="padding-top:14px;font-family:${SANS};font-size:16px;line-height:1.55;color:${C.heroTxt};">${lead}</td></tr>` : ''}
      ${amount ? `<tr><td style="padding-top:24px;">
        <div style="font-family:${SANS};font-size:13px;color:${C.heroTxt};">${esc(amountLabel || 'Total')}</div>
        <div style="font-family:${SANS};font-size:44px;line-height:1.1;font-weight:800;letter-spacing:-.02em;color:#FFFFFF;">${esc(amount)}</div></td></tr>` : ''}
      ${cta ? `<tr><td style="padding-top:20px;">${button(cta, ctaHref, 'light')}</td></tr>` : ''}
      ${note ? `<tr><td style="padding-top:14px;font-family:${SANS};font-size:13px;line-height:1.5;color:${C.heroTxt};">${note}</td></tr>` : ''}
    </table></td></tr>`;
}

/** Rastreador: barra de progreso + nodos. El paso actual lleva halo y leyenda. */
function tracker(steps, current, caption) {
  const n = steps.length;
  const seg = (on, show) => show
    ? `<td valign="middle" style="padding:0;font-size:0;line-height:0;"><div class="${on ? 'bar-on' : 'bar-off'}" style="height:4px;line-height:4px;font-size:0;background:${on ? C.jade : C.line};">&nbsp;</div></td>`
    : '<td style="padding:0;font-size:0;line-height:0;">&nbsp;</td>';
  const cols = steps.map((s, i) => {
    const done = i < current, now = i === current;
    const dot = done
      ? `<span class="dot-done" style="display:inline-block;width:24px;height:24px;line-height:24px;border-radius:12px;background:${C.jade};color:#fff;font-family:${SANS};font-size:13px;font-weight:700;text-align:center;">&#10003;</span>`
      : now
        ? `<span class="dot-now" style="display:inline-block;width:16px;height:16px;border-radius:12px;background:${C.blue};border:5px solid #DCE7FA;"></span>`
        : `<span class="dot-off" style="display:inline-block;width:12px;height:12px;border-radius:8px;background:#FFFFFF;border:2px solid #B5C1D1;"></span>`;
    const lblCls = now ? 'c-ink' : done ? 'c-jade' : 'c-muted';
    const lblCol = now ? C.ink : done ? C.jadeTxt : C.muted;
    return `<td width="${(100 / n).toFixed(2)}%" valign="top" style="padding:0;">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0"><tr>
        ${seg(i <= current, i > 0)}
        <td width="28" height="28" align="center" valign="middle" style="width:28px;height:28px;padding:0;font-size:0;line-height:0;">${dot}</td>
        ${seg(i < current, i < n - 1)}
      </tr></table>
      <div class="${lblCls} trk-l" style="font-family:${SANS};font-size:12px;line-height:16px;font-weight:${now ? 800 : 600};color:${lblCol};text-align:center;padding-top:8px;">${esc(s)}</div></td>`;
  }).join('');
  return `
  <div class="c-muted" style="font-family:${SANS};font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:${C.muted};padding-bottom:12px;">Paso ${current + 1} de ${n} · <span class="c-ink" style="color:${C.ink};">${esc(steps[current])}</span></div>
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="table-layout:fixed;"><tr>${cols}</tr></table>
  ${caption ? `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-top:18px;"><tr><td class="bg-blue" style="background:#EAF0FB;border-left:4px solid ${C.blue};border-radius:10px;padding:12px 16px;font-family:${SANS};font-size:14px;line-height:1.5;color:${C.ink};" ><span class="c-ink">${caption}</span></td></tr></table>` : ''}`;
}

function sectionTitle(t) {
  return `<div class="c-ink" style="font-family:${SANS};font-size:18px;font-weight:800;color:${C.ink};padding-bottom:10px;">${esc(t)}</div>`;
}

/** Productos: miniatura · nombre/presentación · cantidad · importe. */
function items(list, sums) {
  const head = `<tr>
    <td class="c-muted b-line" style="padding:0 0 8px;border-bottom:1px solid ${C.line};font-family:${SANS};font-size:12px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:${C.muted};" colspan="2">Producto</td>
    <td align="center" width="48" class="c-muted b-line" style="padding:0 0 8px;border-bottom:1px solid ${C.line};font-family:${SANS};font-size:12px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:${C.muted};">Cant.</td>
    <td align="right" width="84" class="c-muted b-line" style="padding:0 0 8px;border-bottom:1px solid ${C.line};font-family:${SANS};font-size:12px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:${C.muted};">Importe</td></tr>`;
  const rows = (list || []).map((it) => `<tr>
    <td width="52" valign="middle" class="b-line thumb" style="padding:12px 0;border-bottom:1px solid ${C.line};">
      ${it.img ? `<img src="${esc(it.img)}" width="44" height="44" alt="" style="display:block;width:44px;height:44px;border-radius:8px;background:${C.mist};object-fit:contain;">`
               : `<span class="bg-mist" style="display:inline-block;width:44px;height:44px;border-radius:8px;background:${C.mist};"></span>`}</td>
    <td valign="middle" class="b-line" style="padding:12px 8px 12px 0;border-bottom:1px solid ${C.line};font-family:${SANS};">
      <div class="c-ink" style="font-size:15px;font-weight:650;color:${C.ink};">${esc(it.nombre)}</div>
      ${it.detalle ? `<div class="c-muted" style="font-size:13px;color:${C.muted};padding-top:2px;">${esc(it.detalle)}</div>` : ''}</td>
    <td align="center" valign="middle" class="c-ink b-line" style="padding:12px 0;border-bottom:1px solid ${C.line};font-family:${SANS};font-size:15px;color:${C.ink};">${esc(it.cantidad ?? 1)}</td>
    <td align="right" valign="middle" class="c-ink b-line" style="padding:12px 0;border-bottom:1px solid ${C.line};font-family:${SANS};font-size:15px;font-weight:650;color:${C.ink};white-space:nowrap;">${money(it.importe)}</td></tr>`).join('');
  const s = (sums || []).map((r) => r.total
    ? `<tr><td colspan="3" class="c-ink" style="padding:14px 0 0;font-family:${SANS};font-size:16px;font-weight:800;color:${C.ink};">${esc(r.label)}</td>
       <td align="right" class="c-ink" style="padding:14px 0 0;font-family:${SANS};font-size:22px;font-weight:800;color:${C.ink};white-space:nowrap;">${esc(r.value)}</td></tr>`
    : `<tr><td colspan="3" class="c-body" style="padding:8px 0 0;font-family:${SANS};font-size:14px;color:${C.body};">${esc(r.label)}</td>
       <td align="right" class="c-ink" style="padding:8px 0 0;font-family:${SANS};font-size:14px;color:${C.ink};white-space:nowrap;">${esc(r.value)}</td></tr>`).join('');
  return `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">${(list || []).length ? head + rows : ''}${s}</table>`;
}

/** Datos clave en rejilla 2×N (celdas con fondo niebla). */
function grid(cells) {
  const list = cells.filter((c) => c && c.value);
  let out = '';
  for (let i = 0; i < list.length; i += 2) {
    const cell = (c, side) => `<td width="50%" valign="top" style="padding:0 ${side === 'l' ? '5px' : '0'} 10px ${side === 'r' ? '5px' : '0'};">${c ? `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td class="bg-mist" style="background:${C.mist};border-radius:10px;padding:14px 16px;">
        <div class="c-muted" style="font-family:${SANS};font-size:12px;color:${C.muted};">${esc(c.label)}</div>
        <div class="${c.alert ? 'c-red' : 'c-ink'}" style="font-family:${SANS};font-size:15px;font-weight:700;line-height:1.35;color:${c.alert ? C.red : C.ink};padding-top:4px;">${esc(c.value)}</div></td></tr></table>` : ''}</td>`;
    out += `<tr>${cell(list[i], 'l')}${cell(list[i + 1], 'r')}</tr>`;
  }
  return `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">${out}</table>`;
}

function nextSteps(list) {
  const rows = list.map((s, i) => `<tr>
    <td width="34" valign="top" style="padding:0 0 14px;"><span class="num" style="display:inline-block;width:24px;height:24px;line-height:24px;border-radius:12px;background:${C.mist};color:${C.ink};font-family:${SANS};font-size:12px;font-weight:800;text-align:center;">${i + 1}</span></td>
    <td valign="top" style="padding:2px 0 14px;font-family:${SANS};font-size:15px;line-height:1.45;"><span class="c-ink" style="font-weight:700;color:${C.ink};">${esc(s[0])}</span> <span class="c-body" style="color:${C.body};">${esc(s[1] || '')}</span></td></tr>`).join('');
  return `${sectionTitle('Qué sigue')}<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">${rows}</table>`;
}

function alertBox(title, text) {
  return `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td class="bg-red" style="background:${C.redDim};border-radius:10px;padding:14px 16px;font-family:${SANS};font-size:14px;line-height:1.5;">
    <span class="c-red" style="font-weight:700;color:${C.red};">${esc(title)}</span> <span class="c-body" style="color:${C.body};">${esc(text)}</span></td></tr></table>`;
}

function help(cfg, title = '¿Dudas con tu pedido?') {
  const wa = `https://wa.me/52${cfg.whatsapp}`;
  return `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" class="b-line" style="border:1px solid ${C.line};border-radius:12px;"><tr>
    <td style="padding:16px 18px;font-family:${SANS};">
      <div class="c-ink" style="font-size:15px;font-weight:700;color:${C.ink};">${esc(title)}</div>
      <div class="c-body" style="font-size:14px;line-height:1.5;color:${C.body};padding-top:2px;">Te atendemos por WhatsApp o respondiendo este correo.</div></td>
    <td align="right" style="padding:16px 18px;white-space:nowrap;"><a href="${esc(wa)}" class="c-link" style="font-family:${SANS};font-size:15px;font-weight:700;color:${C.blue};text-decoration:none;">WhatsApp&nbsp;&rarr;</a></td></tr></table>`;
}

/* ================= estructura ================= */

function layout({ preheader, top, heroHtml, blocks, cfg, reason, title }) {
  const body = blocks.filter(Boolean).map((b) => row(b)).join('');
  return `<!doctype html>
<html lang="es" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="x-apple-disable-message-reformatting">
<meta name="color-scheme" content="light dark"><meta name="supported-color-schemes" content="light dark">
<title>${esc(title)}</title>
<!--[if !mso]><!--><link href="https://fonts.googleapis.com/css2?family=Archivo:wght@400;600;700;800&family=Fraunces:ital,wght@1,400&display=swap" rel="stylesheet"><!--<![endif]-->
<style>
  :root{color-scheme:light dark;supported-color-schemes:light dark;}
  body{margin:0;padding:0;width:100%!important;}
  @media (max-width:620px){ .px{padding-left:22px!important;padding-right:22px!important;} .h1{font-size:28px!important;} .trk-l{font-size:11px!important;letter-spacing:-.01em;} .thumb{width:44px!important;} .thumb img,.thumb span{width:36px!important;height:36px!important;} }
  @media (prefers-color-scheme:dark){
    .bg-page{background:#060B14!important;}
    .card{background:#0E1726!important;}
    .bg-mist,.num{background:#172236!important;}
    .bg-blue{background:#12264A!important;}
    .bg-red{background:#2A1416!important;}
    .b-line{border-color:#223149!important;}
    .bar-off{background:#223149!important;}
    .c-ink{color:#F2F5FA!important;}
    .c-body{color:#C3CEDD!important;}
    .c-muted{color:#93A3B8!important;}
    .c-jade{color:#5FD39A!important;}
    .c-red{color:#FF8A80!important;}
    .c-link{color:#8DB4FF!important;}
    .num{color:#F2F5FA!important;}
    .dot-off{background:#0E1726!important;border-color:#3A4B63!important;}
    .dot-now{border-color:#1E3A6E!important;}
    .btn-d{background:#FFFFFF!important;color:#001534!important;}
    .foot a{color:#93A3B8!important;}
  }
  [data-ogsc] .c-ink{color:#F2F5FA!important;} [data-ogsc] .c-body{color:#C3CEDD!important;} [data-ogsc] .c-muted{color:#93A3B8!important;}
</style>
<!--[if mso]><style>*{font-family:Arial,sans-serif!important;}</style><![endif]-->
</head>
<body class="bg-page" style="margin:0;padding:0;background:#EEF1F5;">
<div style="display:none;max-height:0;overflow:hidden;mso-hide:all;font-size:1px;line-height:1px;color:#EEF1F5;">${esc(preheader)}&#8199;&#65279;&#847;&#8199;&#65279;&#847;&#8199;&#65279;&#847;&#8199;&#65279;&#847;</div>
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" class="bg-page" style="background:#EEF1F5;"><tr><td align="center" style="padding:24px 12px;">
<table role="presentation" width="600" cellpadding="0" cellspacing="0" border="0" class="card" style="width:100%;max-width:600px;background:#FFFFFF;border-radius:16px;overflow:hidden;">
  <tr><td style="background:${C.ink};padding:22px 36px 18px;" class="px">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0"><tr>
      <td><a href="${esc(cfg.baseUrl)}" style="text-decoration:none;"><img src="${esc(cfg.logoUrl)}" width="140" alt="FarmaCapital" style="display:block;border:0;width:140px;height:auto;color:#ffffff;font-family:${SANS};font-size:20px;font-weight:700;"></a></td>
      <td align="right" style="font-family:${SANS};font-size:13px;font-weight:600;color:${C.heroTxt};">${esc(top || '')}</td>
    </tr></table></td></tr>
  ${heroHtml}
  <tr><td style="height:30px;line-height:30px;font-size:0;">&nbsp;</td></tr>
  ${body}
  <tr><td class="px foot b-line" style="padding:20px 36px 30px;border-top:1px solid ${C.line};">
    <p class="c-muted" style="margin:0 0 6px;font-family:${SANS};font-size:12px;line-height:1.6;color:${C.muted};">
      <a href="${esc(cfg.baseUrl)}/privacidad" style="color:${C.muted};">Aviso de privacidad</a> &nbsp;·&nbsp;
      <a href="${esc(cfg.baseUrl)}/terminos" style="color:${C.muted};">Términos</a> &nbsp;·&nbsp;
      <a href="mailto:${esc(cfg.email)}" style="color:${C.muted};">${esc(cfg.email)}</a></p>
    <p class="c-muted" style="margin:0;font-family:${SANS};font-size:11px;line-height:1.6;color:#8C9AAD;">${esc(cfg.razonSocial)} · RFC ${esc(cfg.rfc)} · ${esc(cfg.domicilio)}<br>${esc(reason || 'Recibes este correo porque hiciste un pedido en FarmaCapital.')}</p>
  </td></tr>
</table>
</td></tr></table>
</body></html>`;
}

/* ================= plantillas ================= */

const P_ENVIO = ['Pedido', 'Cotizado', 'Pagado', 'En camino', 'Entregado'];
const P_RECOGER = ['Pedido', 'Pagado', 'Preparando', 'Listo', 'Entregado'];
const lines = (a) => a.filter((x) => x !== null && x !== undefined && x !== false).join('\n');

/**
 * Desglose del cobro: Productos + Servicio + Envío = Total.
 * - `subtotal` por omisión es la suma de los importes de los productos.
 * - `servicio` es el cargo de plataforma ($5 en pedidos con envío; $0 al recoger).
 *   Leerlo de pedido.logistics_meta.cargo_plataforma_mxn, nunca restarlo "a ojo".
 * - Si las filas no suman el total, avisa en consola: el correo nunca debe mostrar
 *   un total que no cuadre con sus renglones.
 */
function desglose(d, totalLabel) {
  const r2 = (n) => Math.round(Number(n || 0) * 100) / 100;
  const sumItems = r2((d.items || []).reduce((s, i) => s + Number(i.importe || 0), 0));
  const subtotal = d.subtotal != null ? r2(d.subtotal) : sumItems;
  const servicio = r2(d.servicio);
  const envio = d.envio != null ? r2(d.envio) : null;
  const total = r2(d.total);
  const dif = r2(subtotal + servicio + (envio || 0) - total);
  const cuadra = dif === 0 && (!(d.items || []).length || sumItems === subtotal);
  if (!cuadra && typeof console !== 'undefined') {
    console.warn(`[emailTemplates] El desglose no cuadra (pedido ${d.pedidoId ?? d.folio ?? '?'}): productos ${subtotal} (renglones ${sumItems}) + servicio ${servicio} + envío ${envio || 0} ≠ total ${total}`);
  }
  const rows = [
    { label: 'Productos', value: money(subtotal) },
    servicio > 0 ? { label: 'Servicio', value: money(servicio) } : null,
    envio != null ? { label: 'Envío a domicilio', value: envio > 0 ? money(envio) : 'Gratis' } : null,
    { label: totalLabel, value: money(total), total: true },
  ].filter(Boolean);
  return { rows, text: rows.map((r) => `${r.label}: ${r.value}`), cuadra };
}

function envioCotizado(d, cfg = DEFAULTS) {
  const f = folio(d.pedidoId), total = money(d.total), pay = d.urlPagar || `${cfg.baseUrl}/carrito`;
  const des = desglose(d, 'Total a pagar');
  const html = layout({
    cfg, title: 'Tu envío ya tiene precio', top: `Pedido ${f}`,
    preheader: `Total ${total} con envío incluido${d.vigencia ? `. Precio válido hasta ${d.vigencia}` : ''}.`,
    heroHtml: hero({
      tag: 'Cotización lista', title: 'Tu envío ya tiene precio.', accent: 'Solo falta pagar.',
      lead: `Hola ${esc(d.nombre || '')}. Es un solo cargo: productos, ${Number(d.servicio) > 0 ? 'servicio y envío' : 'envío'} incluidos.`,
      amountLabel: 'Total a pagar', amount: total, cta: `Pagar ${total}`, ctaHref: pay,
      note: d.vigencia ? `Precio válido hasta <strong style="color:#FFFFFF;">${esc(d.vigencia)}</strong>. Si vence, te lo recotizamos sin costo.` : '',
    }),
    blocks: [
      tracker(P_ENVIO, 1, `<strong>Esperando tu pago.</strong> En cuanto pagues, preparamos tu pedido y sale a tu domicilio.`),
      sectionTitle('Entrega') + grid([
        { label: 'Entrega con', value: d.paqueteria },
        { label: 'Destino', value: d.destino },
        { label: 'Tiempo estimado', value: d.plazo },
        { label: 'Precio válido hasta', value: d.vigencia, alert: true },
      ]),
      sectionTitle('Tu pedido') + items(d.items, des.rows),
      `${button(`Pagar ${total}`, pay, 'dark')}
       <p class="c-muted" style="margin:12px 0 0;font-family:${SANS};font-size:13px;line-height:1.5;color:${C.muted};">Entra con el teléfono del pedido${d.telUltimos4 ? ` (termina en ${esc(d.telUltimos4)})` : ''}.</p>`,
      nextSteps([['Pagas en línea.', 'Tarjeta o Mercado Pago.'], ['Preparamos tu pedido.', 'Te llega el ticket a este correo.'], ['Sale a tu domicilio.', 'Te avisamos cuando vaya en camino.']]),
      help(cfg),
    ],
  });
  const text = lines([`Hola ${d.nombre || ''}.`, '', `Tu envío ya tiene precio. Pedido ${f}.`, '',
    ...(d.items || []).map((i) => `- ${i.nombre} x${i.cantidad ?? 1}: ${money(i.importe)}`),
    ...des.text, '',
    d.paqueteria && `Entrega con: ${d.paqueteria}`, d.destino && `Destino: ${d.destino}`, d.plazo && `Tiempo estimado: ${d.plazo}`,
    d.vigencia && `Precio válido hasta: ${d.vigencia}`, '', `Paga aquí: ${pay}`, `Dudas: WhatsApp ${cfg.whatsappDisplay}`]);
  return { subject: `Tu envío ya tiene precio · Pedido ${f}`, preheader: `Total ${total}`, html, text };
}

function pagoAprobado(d, cfg = DEFAULTS) {
  const f = folio(d.pedidoId), recoger = d.entrega === 'recoger';
  const des = desglose(recoger ? { ...d, envio: null } : d, 'Total pagado');
  const html = layout({
    cfg, title: 'Recibimos tu pago', top: `Pedido ${f}`,
    preheader: `Recibimos tu pago de ${money(d.total)}. Tu ticket va adjunto.`,
    heroHtml: hero({ tag: 'Pago confirmado', title: 'Recibimos tu pago.', accent: 'Gracias por tu compra.', lead: `Hola ${esc(d.nombre || '')}. Tu pedido ya está en preparación y tu ticket va adjunto.`, amountLabel: 'Total pagado', amount: money(d.total), cta: d.urlTicket ? 'Ver mi ticket' : null, ctaHref: d.urlTicket }),
    blocks: [
      tracker(recoger ? P_RECOGER : P_ENVIO, 2, recoger ? '<strong>Preparando tu pedido.</strong> Te avisamos cuando esté listo para recoger.' : '<strong>Pago recibido.</strong> Te avisamos cuando tu pedido vaya en camino.'),
      sectionTitle('Tu pedido') + items(d.items, des.rows),
      grid([{ label: 'Forma de pago', value: d.metodo }, { label: 'Entrega', value: recoger ? 'Recoger en sucursal' : 'Envío a domicilio' }]),
      `<p class="c-body" style="margin:0;font-family:${SANS};font-size:14px;line-height:1.5;color:${C.body};">¿Necesitas factura? Escríbenos a <a href="mailto:${esc(cfg.email)}?subject=${encodeURIComponent(`Factura ${f}`)}" class="c-link" style="color:${C.blue};font-weight:600;">${esc(cfg.email)}</a> con el folio ${esc(f)} dentro de las 24 horas siguientes.</p>`,
      help(cfg),
    ],
  });
  return { subject: `Pago confirmado · Pedido ${f}`, preheader: 'Tu ticket va adjunto', html, text: lines([`Hola ${d.nombre || ''}.`, '', `Recibimos tu pago. Pedido ${f}.`, '', ...(d.items || []).map((i) => `- ${i.nombre} x${i.cantidad ?? 1}: ${money(i.importe)}`), ...des.text, '', `Tu ticket va adjunto${d.urlTicket ? `: ${d.urlTicket}` : ''}.`, '', `Dudas: WhatsApp ${cfg.whatsappDisplay}`]) };
}

function listoParaRecoger(d, cfg = DEFAULTS) {
  const f = folio(d.pedidoId), maps = d.urlMapa || cfg.mapsUrl;
  const html = layout({
    cfg, title: 'Tu pedido está listo', top: `Pedido ${f}`,
    preheader: `Tu pedido ${f} está listo. Recógelo de 8:00 a 22:30.`,
    heroHtml: hero({ tag: 'Listo para recoger', title: 'Tu pedido está listo.', accent: 'Te esperamos.', lead: `Hola ${esc(d.nombre || '')}. Pasa por él cuando quieras, en horario de sucursal.`, amountLabel: d.aPagar ? 'Pagas al recoger' : null, amount: d.aPagar ? money(d.aPagar) : null, cta: 'Cómo llegar', ctaHref: maps }),
    blocks: [
      tracker(P_RECOGER, 3, `<strong>Listo en sucursal.</strong> Presenta tu folio ${esc(f)}${d.requiereReceta ? ' y tu receta vigente' : ''}.`),
      d.requiereReceta ? alertBox('Tu pedido incluye medicamentos con receta.', 'Trae la receta médica vigente para poder entregártelos.') : '',
      sectionTitle('Dónde recogerlo') + grid([
        { label: 'Sucursal', value: 'Ciudad de México' },
        { label: 'Horario', value: 'Todos los días 8:00–22:30' },
        { label: 'Dirección', value: 'Radiodifusora 100, Chinampac de Juárez' },
        { label: 'Presenta', value: `Folio ${f}` },
      ]),
      help(cfg),
    ],
  });
  return { subject: `Tu pedido está listo · ${f}`, preheader: 'Recógelo hoy', html, text: `Hola ${d.nombre || ''}.\n\nTu pedido ${f} está listo para recoger.\nRadiodifusora 100, Chinampac de Juárez. Todos los días 8:00–22:30.\n${d.requiereReceta ? 'Trae tu receta médica vigente.\n' : ''}Cómo llegar: ${maps}` };
}

function enCamino(d, cfg = DEFAULTS) {
  const f = folio(d.pedidoId);
  const html = layout({
    cfg, title: 'Tu pedido va en camino', top: `Pedido ${f}`,
    preheader: `Tu pedido ${f} va en camino${d.llegada ? `; llega aprox. ${d.llegada}` : ''}.`,
    heroHtml: hero({ tag: 'En camino', title: 'Tu pedido va en camino.', accent: 'Ya casi llega.', lead: `Hola ${esc(d.nombre || '')}. Salió de la sucursal hacia tu domicilio.`, amountLabel: d.llegada ? 'Llegada aproximada' : null, amount: d.llegada, cta: d.urlRastreo ? 'Seguir mi pedido' : null, ctaHref: d.urlRastreo }),
    blocks: [
      tracker(P_ENVIO, 3, '<strong>En camino.</strong> Ten a la mano tu identificación para recibirlo.'),
      sectionTitle('Entrega') + grid([{ label: 'Entrega con', value: d.paqueteria }, { label: 'Destino', value: d.destino }, { label: 'Guía', value: d.guia }]),
      help(cfg, '¿Algo no llegó bien?'),
    ],
  });
  return { subject: `Tu pedido va en camino · ${f}`, preheader: 'Ya casi llega', html, text: `Hola ${d.nombre || ''}.\n\nTu pedido ${f} va en camino${d.paqueteria ? ` con ${d.paqueteria}` : ''}.${d.llegada ? `\nLlegada aproximada: ${d.llegada}.` : ''}${d.urlRastreo ? `\nSíguelo: ${d.urlRastreo}` : ''}` };
}

function cotizacionEspecializado(d, cfg = DEFAULTS) {
  const f = d.folio || 'COT-0000', url = d.urlAceptar || `${cfg.baseUrl}/cuenta`;
  const html = layout({
    cfg, title: 'Tu cotización está lista', top: `Cotización ${f}`,
    reason: 'Recibes este correo porque solicitaste una cotización en FarmaCapital.',
    preheader: `Encontramos tu medicamento: ${money(d.precio)}. ${d.disponibilidad || ''}`,
    heroHtml: hero({ tag: 'Cotización lista', title: 'Encontramos tu medicamento.', accent: 'Esta es tu cotización.', lead: `Hola ${esc(d.nombre || '')}. No se cobra nada hasta que la aceptes.`, amountLabel: 'Precio total', amount: money(d.precio), cta: 'Aceptar cotización', ctaHref: url, note: d.vigencia ? `Precio válido hasta <strong style="color:#FFFFFF;">${esc(d.vigencia)}</strong>.` : '' }),
    blocks: [
      tracker(['Solicitud', 'Cotización', 'Aceptada', 'Entregado'], 1, '<strong>Esperando tu respuesta.</strong> ¿Otra presentación o marca? Responde este correo y te recotizamos.'),
      sectionTitle('Detalle') + grid([
        { label: 'Medicamento', value: d.medicamento }, { label: 'Presentación', value: d.presentacion },
        { label: 'Cantidad', value: d.cantidad }, { label: 'Disponibilidad', value: d.disponibilidad },
        { label: 'Entrega', value: d.entrega }, { label: 'Precio válido hasta', value: d.vigencia, alert: true },
      ]),
      d.requiereReceta ? alertBox('Requiere receta médica.', 'La solicitaremos al entregarlo.') : '',
      help(cfg, '¿Preguntas sobre este medicamento?'),
    ],
  });
  return { subject: `Tu cotización está lista · ${f}`, preheader: money(d.precio), html, text: `Hola ${d.nombre || ''}.\n\nCotización ${f}: ${d.medicamento} ${d.presentacion || ''} (${d.cantidad || 1}).\nPrecio: ${money(d.precio)}. ${d.disponibilidad || ''}\nVálido hasta: ${d.vigencia || ''}\n\nAcepta aquí: ${url}\nWhatsApp ${cfg.whatsappDisplay}` };
}

module.exports = { envioCotizado, pagoAprobado, listoParaRecoger, enCamino, cotizacionEspecializado, DEFAULTS, _internals: { desglose, layout, hero, tracker, items, grid, button, money, folio, esc } };
