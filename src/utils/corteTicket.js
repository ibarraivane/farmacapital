/** Ticket de corte: resumen de caja + detalle de cada producto del turno. */

import { jsPDF } from "jspdf";
import { openThermalPrintWindow } from "./printTicket";

export const CORTES_BUCKET = "cortes";

const money = (n) => `$${parseFloat(n || 0).toFixed(2)}`;

const DENOM_ORDEN = [1000, 500, 200, 100, 50, 20, 10, 5, 2, 1, 0.5];

function esc(s) {
  return String(s ?? "").replace(/[&<>"']/g, (c) => (
    { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]
  ));
}

function horaLocal(iso) {
  if (!iso) return "—";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "—";
  return d.toLocaleTimeString("es-MX", { hour: "2-digit", minute: "2-digit" });
}

function etiquetaMetodo(m) {
  const x = String(m || "").toLowerCase();
  if (x === "efectivo") return "efectivo";
  if (x === "tarjeta" || x === "bbva_terminal") return "tarjeta";
  if (x === "mercadopago" || x === "mercadopago_point") return "MercadoPago";
  if (x === "spei") return "SPEI";
  return m || "—";
}

function parseJsonArray(data) {
  if (Array.isArray(data)) return data;
  if (typeof data === "string") {
    try {
      const v = JSON.parse(data);
      return Array.isArray(v) ? v : [];
    } catch {
      return [];
    }
  }
  return [];
}

function mapItem(i) {
  const prod = i.productos || {};
  const lote = i.lotes || {};
  const qty = parseFloat(i.cantidad || 0);
  const pu = parseFloat(i.precio_unitario || 0);
  return {
    producto_id: i.producto_id ?? prod.id ?? null,
    nombre: prod.nombre || i.producto_nombre || "Producto",
    sku: prod.sku || "",
    cantidad: qty,
    precio_unitario: pu,
    subtotal: qty * pu,
    lote: lote.numero_lote || "",
    caducidad: lote.fecha_caducidad || "",
  };
}

function mapVenta(t) {
  const items = Array.isArray(t.items) ? t.items.map(mapItem) : [];
  return {
    id: t.id,
    created_at: t.created_at,
    metodo_pago: etiquetaMetodo(t.metodo_pago),
    total: parseFloat(t.total || 0),
    estado: t.estado || "",
    notas: t.notas || "",
    cajero_venta: t.usuarios?.nombre || t.cajero_venta || "",
    items,
  };
}

export async function enrichPedidosConItems(supabase, sessionToken, pedidos) {
  const list = Array.isArray(pedidos) ? pedidos : [];
  const tok = String(sessionToken || "").trim();
  if (!tok || !list.length) return list.map(mapVenta);
  const out = [];
  for (const t of list) {
    try {
      const { data } = await supabase.rpc("empleado_listar_pedido_items_detalle_transacciones", {
        p_session_token: tok,
        p_pedido_id: t.id,
      });
      out.push(mapVenta({ ...t, items: parseJsonArray(data) }));
    } catch {
      out.push(mapVenta(t));
    }
  }
  return out;
}

export async function cargarVentasDetalleTurno(supabase, sessionToken, desdeIso, hastaIso) {
  const tok = String(sessionToken || "").trim();
  const { data } = tok
    ? await supabase.rpc("empleado_listar_pedidos_transacciones", {
        p_session_token: tok,
        p_created_desde: desdeIso,
        p_created_hasta: hastaIso,
        p_limite: 400,
      })
    : { data: [] };
  return enrichPedidosConItems(supabase, tok, parseJsonArray(data));
}

function filasDenoms(denoms) {
  if (!denoms || typeof denoms !== "object") return [];
  return DENOM_ORDEN
    .map((d) => {
      const n = parseInt(denoms[d] ?? denoms[String(d)] ?? 0, 10) || 0;
      return n > 0 ? { denom: d, n, sub: d * n } : null;
    })
    .filter(Boolean);
}

export function snapshotFromCorte({ resultado, turno, zTransac, cajero, denominaciones }) {
  const sistema = parseFloat(resultado?.efectivo_sistema ?? 0);
  const fondo = parseFloat(resultado?.fondo_inicial ?? 0);
  const esperado = parseFloat(resultado?.esperado ?? fondo + sistema);
  const dif = parseFloat(resultado?.diferencia ?? 0);
  const declarado = parseFloat(resultado?.efectivo_declarado ?? esperado + dif);
  const ventas = (zTransac || []).map((t) => {
    if (Array.isArray(t.items) && (t.items.length === 0 || t.items[0]?.nombre != null)) {
      return {
        ...t,
        total: parseFloat(t.total || 0),
        metodo_pago: etiquetaMetodo(t.metodo_pago),
      };
    }
    return mapVenta(t);
  });
  const sumZ = ventas.reduce((a, t) => a + parseFloat(t.total || 0), 0);
  const porMetodo = {};
  ventas.forEach((t) => {
    const k = t.metodo_pago || "—";
    porMetodo[k] = (porMetodo[k] || 0) + parseFloat(t.total || 0);
  });
  return {
    corte_id: resultado?.corte_id ?? resultado?.id ?? null,
    turno: turno || resultado?.turno || "",
    cajero: cajero || "",
    generado_at: new Date().toISOString(),
    fondo,
    sistema,
    esperado,
    declarado,
    diferencia: dif,
    tarjeta: parseFloat(resultado?.tarjeta ?? resultado?.total_tarjeta ?? 0),
    mercadopago: parseFloat(resultado?.mercadopago ?? resultado?.total_mercadopago ?? 0),
    spei: parseFloat(resultado?.spei ?? resultado?.total_spei ?? 0),
    total_general: parseFloat(resultado?.total_general ?? 0),
    notas: resultado?.notas || "",
    denominaciones: filasDenoms(denominaciones || resultado?.denominaciones),
    devoluciones_efectivo: parseFloat(resultado?.detalle_metodos?.efectivo_devoluciones ?? 0),
    credito_otorgado: parseFloat(resultado?.detalle_metodos?.credito_otorgado ?? 0),
    ventas,
    suma_tickets: sumZ,
    por_metodo: porMetodo,
  };
}

export function snapshotFromHistorialRow(c) {
  return snapshotFromCorte({
    resultado: {
      id: c.id,
      corte_id: c.id,
      turno: c.turno,
      fondo_inicial: c.fondo_inicial,
      efectivo_sistema: c.efectivo_sistema,
      esperado: c.esperado,
      efectivo_declarado: c.efectivo_declarado,
      diferencia: c.diferencia,
      tarjeta: c.tarjeta,
      total_tarjeta: c.tarjeta,
      mercadopago: c.mercadopago,
      total_mercadopago: c.mercadopago,
      total_general: c.total_general,
      notas: c.notas,
      denominaciones: c.denominaciones,
    },
    turno: c.turno,
    zTransac: c.ventas || [],
    cajero: c.cajero,
    denominaciones: c.denominaciones,
  });
}

function htmlVentas(snap) {
  const ventas = snap.ventas || [];
  if (!ventas.length) {
    return '<p class="muted">Sin ventas en el turno</p>';
  }
  return ventas.map((t) => {
    const items = t.items || [];
    const filas = items.length
      ? items.map((i) => `
        <tr>
          <td>${esc(i.sku || "—")}</td>
          <td>${esc(i.nombre)}</td>
          <td class="r">${i.cantidad}</td>
          <td class="r">${money(i.precio_unitario)}</td>
          <td class="r">${money(i.subtotal)}</td>
          <td>${esc(i.lote || "—")}${i.caducidad ? ` · cad ${esc(i.caducidad)}` : ""}</td>
        </tr>`).join("")
      : `<tr><td colspan="6" class="muted">Sin partidas</td></tr>`;
    return `
      <div class="venta">
        <div class="venta-h">
          <strong>#${t.id}</strong>
          <span>${horaLocal(t.created_at)}</span>
          <span>${esc(t.metodo_pago)}</span>
          ${t.cajero_venta ? `<span>${esc(t.cajero_venta)}</span>` : ""}
          <span class="r"><strong>${money(t.total)}</strong></span>
        </div>
        ${t.notas ? `<div class="muted" style="padding:2px 0 6px">Nota: ${esc(t.notas)}</div>` : ""}
        <table>
          <thead><tr><th>SKU</th><th>Producto</th><th class="r">Qty</th><th class="r">P. unit</th><th class="r">Importe</th><th>Lote</th></tr></thead>
          <tbody>${filas}</tbody>
        </table>
      </div>`;
  }).join("");
}

export function corteTicketHtml(snap) {
  const fecha = snap.generado_at
    ? new Date(snap.generado_at).toLocaleString("es-MX")
    : new Date().toLocaleString("es-MX");
  const den = (snap.denominaciones || [])
    .map((d) => `<div><span>${d.n} × ${money(d.denom)}</span><span>${money(d.sub)}</span></div>`)
    .join("");
  const met = Object.entries(snap.por_metodo || {})
    .map(([k, v]) => `<div><span>Tickets ${esc(k)}</span><span>${money(v)}</span></div>`)
    .join("");
  const nLineas = (snap.ventas || []).reduce((a, t) => a + (t.items || []).length, 0);
  return `<!doctype html><html><head><meta charset="utf-8">
    <title>Corte ${esc(snap.turno)} #${snap.corte_id ?? ""} — ${esc(fecha)}</title>
    <style>
      body{font-family:-apple-system,system-ui,sans-serif;font-size:12px;margin:18px;color:#111;max-width:720px}
      h1{font-size:16px;margin:0 0 2px} h2{font-size:13px;margin:16px 0 8px}
      .sub{color:#666;margin-bottom:14px}
      table{width:100%;border-collapse:collapse;margin:0}
      th,td{text-align:left;padding:3px 5px;border-bottom:1px solid #ddd;vertical-align:top}
      th{font-size:9px;text-transform:uppercase;color:#666}
      .r{text-align:right} .muted{color:#666;font-size:11px}
      .box{border:1px solid #ccc;padding:10px 12px;margin-bottom:12px}
      .box div{display:flex;justify-content:space-between;padding:2px 0;gap:12px}
      .dif{font-weight:700;border-top:1px solid #ccc;margin-top:4px;padding-top:6px}
      .venta{margin:0 0 14px;page-break-inside:avoid}
      .venta-h{display:flex;gap:10px;flex-wrap:wrap;font-size:12px;margin-bottom:4px;align-items:baseline}
      .venta-h .r{margin-left:auto}
      @media print { body{margin:8px} }
    </style></head><body>
    <h1>FarmaCapital — Corte de caja</h1>
    <div class="sub">Turno ${esc(snap.turno)} · corte #${snap.corte_id ?? "—"} · ${esc(fecha)}${snap.cajero ? ` · ${esc(snap.cajero)}` : ""}</div>
    <div class="box">
      <div><span>Fondo inicial</span><span>${money(snap.fondo)}</span></div>
      <div><span>Ventas en efectivo (sistema)</span><span>${money(snap.sistema)}</span></div>
      <div><span>Esperado en cajón</span><span>${money(snap.esperado)}</span></div>
      <div><span>Contado</span><span>${money(snap.declarado)}</span></div>
      <div class="dif"><span>Diferencia</span><span>${money(snap.diferencia)}</span></div>
      ${parseFloat(snap.devoluciones_efectivo || 0) > 0 ? `<div><span>Devoluciones en efectivo (ya restadas)</span><span>${money(snap.devoluciones_efectivo)}</span></div>` : ""}
      ${parseFloat(snap.credito_otorgado || 0) > 0 ? `<div><span>Crédito otorgado (no sale de caja)</span><span>${money(snap.credito_otorgado)}</span></div>` : ""}
    </div>
    <div class="box">
      <div><span>Tarjeta (BBVA + Point)</span><span>${money(snap.tarjeta)}</span></div>
      <div><span>MercadoPago (tienda web)</span><span>${money(snap.mercadopago)}</span></div>
      ${parseFloat(snap.spei || 0) > 0 ? `<div><span>SPEI</span><span>${money(snap.spei)}</span></div>` : ""}
      ${met}
      <div class="dif"><span>Suma de tickets</span><span>${money(snap.suma_tickets)}</span></div>
      <div><span>Total turno (contado − fondo + electrónicos)</span><span>${money(snap.total_general)}</span></div>
    </div>
    ${den ? `<h2>Billetes contados</h2><div class="box">${den}</div>` : ""}
    ${snap.notas ? `<p class="muted">Notas: ${esc(snap.notas)}</p>` : ""}
    <h2>Ventas del turno · ${(snap.ventas || []).length} ticket(s) · ${nLineas} producto(s)</h2>
    ${htmlVentas(snap)}
    <p style="margin-top:28px">Contó: ____________________ &nbsp;&nbsp; Recibió: ____________________</p>
    </body></html>`;
}

export function printCorteTicket(snap) {
  return openThermalPrintWindow(corteTicketTermicoInner(snap), `Corte ${snap.turno || ""} #${snap.corte_id ?? ""}`);
}

/** Hoja A4: el mismo detalle del PDF, por si alguna vez se imprime en laser. */
export function printCorteHojaA4(snap) {
  const w = window.open("", "_blank", "width=780,height=900");
  if (!w) return false;
  w.document.write(corteTicketHtml(snap));
  w.document.close();
  w.focus();
  w.print();
  return true;
}

function row80(left, right, bold) {
  return `<div class="total-line" style="${bold ? "font-weight:900" : "font-weight:400"}">
    <span>${esc(left)}</span><span>${esc(right)}</span>
  </div>`;
}

export function corteTicketTermicoInner(snap) {
  const when = snap.generado_at
    ? new Date(snap.generado_at).toLocaleString("es-MX")
    : new Date().toLocaleString("es-MX");
  const ventas = snap.ventas || [];
  const bloques = ventas.map((t) => {
    const items = t.items || [];
    const lineas = items.length
      ? items.map((i) => `
        <div style="margin:2px 0 4px">
          <div class="product-name">${esc((i.nombre || "Producto").slice(0, 36))}</div>
          <div class="product-row">
            <span>${esc(i.cantidad)} x ${money(i.precio_unitario)}${i.sku ? ` · ${esc(i.sku)}` : ""}</span>
            <span class="product-total">${money(i.subtotal)}</span>
          </div>
          ${i.lote ? `<div style="font-size:9px;color:#333">lote ${esc(i.lote)}${i.caducidad ? ` cad ${esc(i.caducidad)}` : ""}</div>` : ""}
        </div>`).join("")
      : `<div style="font-size:9px;color:#333">Sin partidas</div>`;
    return `
      <hr class="separator">
      <div class="total-line">
        <span>#${t.id} ${horaLocal(t.created_at)} ${esc(t.metodo_pago)}</span>
        <span>${money(t.total)}</span>
      </div>
      ${lineas}`;
  }).join("");
  const den = (snap.denominaciones || [])
    .map((d) => row80(`${d.n} x ${money(d.denom)}`, money(d.sub)))
    .join("");
  return `<div id="farmacapital-ticket" class="ticket">
    <div class="center ticket-brand-name">FarmaCapital</div>
    <div class="center" style="font-size:11px;font-weight:900;margin-top:4px">CORTE ${(snap.turno || "").toUpperCase()}</div>
    <div class="center" style="font-size:9px;margin-top:3px">#${snap.corte_id ?? "—"} · ${esc(when)}</div>
    ${snap.cajero ? `<div class="center" style="font-size:9px">${esc(snap.cajero)}</div>` : ""}
    <hr class="separator-solid">
    ${row80("Fondo inicial", money(snap.fondo))}
    ${row80("Ef. sistema", money(snap.sistema))}
    ${row80("Esperado", money(snap.esperado))}
    ${row80("Contado", money(snap.declarado))}
    ${row80("DIFERENCIA", money(snap.diferencia), true)}
    ${parseFloat(snap.devoluciones_efectivo || 0) > 0 ? row80("Dev. efectivo", money(snap.devoluciones_efectivo)) : ""}
    ${parseFloat(snap.credito_otorgado || 0) > 0 ? row80("Credito otorgado", money(snap.credito_otorgado)) : ""}
    <hr class="separator">
    ${row80("Tarjeta", money(snap.tarjeta))}
    ${row80("MercadoPago", money(snap.mercadopago))}
    ${parseFloat(snap.spei || 0) > 0 ? row80("SPEI", money(snap.spei)) : ""}
    ${row80("Suma tickets", money(snap.suma_tickets))}
    ${row80("Total turno", money(snap.total_general), true)}
    ${den ? `<hr class="separator"><div style="font-size:9px;font-weight:900;margin:4px 0">BILLETES</div>${den}` : ""}
    ${snap.notas ? `<hr class="separator"><div style="font-size:9px">Notas: ${esc(snap.notas)}</div>` : ""}
    <hr class="separator-solid">
    <div class="center" style="font-size:9px;font-weight:900;margin:6px 0">VENTAS ${ventas.length}</div>
    ${bloques || `<div class="center" style="font-size:9px">Sin ventas</div>`}
    <hr class="separator-solid">
    <div style="font-size:9px;margin-top:10px;line-height:1.8">
      <div>Conto: ________________</div>
      <div>Recibio: ________________</div>
    </div>
  </div>`;
}

export function corteTicketPdfBlob(snap) {
  const doc = new jsPDF({ unit: "mm", format: "a4" });
  const W = 210;
  const M = 14;
  const maxY = 282;
  let y = 16;

  const newPage = () => {
    doc.addPage();
    y = 16;
  };
  const need = (h) => {
    if (y + h > maxY) newPage();
  };
  const line = (label, value, bold) => {
    need(6);
    doc.setFont("helvetica", bold ? "bold" : "normal");
    doc.setFontSize(9);
    doc.text(String(label), M, y);
    doc.text(String(value), W - M, y, { align: "right" });
    y += 5;
  };
  const wrap = (text, size, x, width) => {
    doc.setFontSize(size);
    const lines = doc.splitTextToSize(String(text || ""), width);
    lines.forEach((ln) => {
      need(5);
      doc.text(ln, x, y);
      y += 4.2;
    });
  };

  doc.setFont("helvetica", "bold");
  doc.setFontSize(14);
  doc.text("FarmaCapital — Corte de caja", M, y);
  y += 6;
  doc.setFont("helvetica", "normal");
  doc.setFontSize(9);
  const when = snap.generado_at
    ? new Date(snap.generado_at).toLocaleString("es-MX")
    : new Date().toLocaleString("es-MX");
  doc.text(`Turno ${snap.turno || ""} · corte #${snap.corte_id ?? "—"} · ${when}`, M, y);
  y += 5;
  if (snap.cajero) {
    doc.text(String(snap.cajero), M, y);
    y += 5;
  }
  y += 2;
  doc.setDrawColor(40);
  doc.line(M, y, W - M, y);
  y += 7;

  line("Fondo inicial", money(snap.fondo));
  line("Ventas en efectivo (sistema)", money(snap.sistema));
  line("Esperado en cajón", money(snap.esperado));
  line("Contado", money(snap.declarado));
  line("Diferencia", money(snap.diferencia), true);
  if (parseFloat(snap.devoluciones_efectivo || 0) > 0) {
    line("Devoluciones en efectivo (ya restadas)", money(snap.devoluciones_efectivo));
  }
  if (parseFloat(snap.credito_otorgado || 0) > 0) {
    line("Crédito otorgado (no sale de caja)", money(snap.credito_otorgado));
  }
  y += 2;
  doc.line(M, y, W - M, y);
  y += 6;
  line("Tarjeta (BBVA + Point)", money(snap.tarjeta));
  line("MercadoPago (tienda web)", money(snap.mercadopago));
  if (parseFloat(snap.spei || 0) > 0) line("SPEI", money(snap.spei));
  Object.entries(snap.por_metodo || {}).forEach(([k, v]) => line(`Tickets ${k}`, money(v)));
  line("Suma de tickets", money(snap.suma_tickets), true);
  line("Total turno (contado − fondo + electrónicos)", money(snap.total_general));

  if ((snap.denominaciones || []).length) {
    y += 3;
    doc.line(M, y, W - M, y);
    y += 6;
    doc.setFont("helvetica", "bold");
    doc.setFontSize(10);
    doc.text("Billetes contados", M, y);
    y += 6;
    snap.denominaciones.forEach((d) => {
      line(`${d.n} × ${money(d.denom)}`, money(d.sub));
    });
  }

  if (snap.notas) {
    y += 3;
    doc.setFont("helvetica", "italic");
    wrap(`Notas: ${snap.notas}`, 8, M, W - 2 * M);
  }

  y += 4;
  doc.line(M, y, W - M, y);
  y += 7;
  const nLineas = (snap.ventas || []).reduce((a, t) => a + (t.items || []).length, 0);
  doc.setFont("helvetica", "bold");
  doc.setFontSize(11);
  need(8);
  doc.text(`Ventas · ${(snap.ventas || []).length} ticket(s) · ${nLineas} producto(s)`, M, y);
  y += 7;

  const ventas = snap.ventas || [];
  if (!ventas.length) {
    doc.setFont("helvetica", "normal");
    doc.setFontSize(9);
    doc.text("Sin ventas en el turno", M, y);
    y += 6;
  } else {
    ventas.forEach((t) => {
      need(16);
      doc.setFont("helvetica", "bold");
      doc.setFontSize(9);
      doc.text(`#${t.id}  ${horaLocal(t.created_at)}  ${t.metodo_pago || ""}`, M, y);
      doc.text(money(t.total), W - M, y, { align: "right" });
      y += 4.5;
      if (t.cajero_venta) {
        doc.setFont("helvetica", "normal");
        doc.setFontSize(8);
        doc.text(String(t.cajero_venta), M, y);
        y += 4;
      }
      if (t.notas) {
        doc.setFont("helvetica", "italic");
        wrap(t.notas, 8, M, W - 2 * M);
      }
      const items = t.items || [];
      if (!items.length) {
        doc.setFont("helvetica", "normal");
        doc.setFontSize(8);
        doc.text("Sin partidas", M + 2, y);
        y += 5;
      } else {
        items.forEach((i) => {
          need(12);
          doc.setFont("helvetica", "normal");
          doc.setFontSize(8);
          const left = `${i.cantidad} × ${i.nombre}${i.sku ? `  (${i.sku})` : ""}`;
          const wrapped = doc.splitTextToSize(left, 140);
          wrapped.forEach((ln, idx) => {
            need(5);
            doc.text(ln, M + 2, y);
            if (idx === 0) doc.text(money(i.subtotal), W - M, y, { align: "right" });
            y += 4;
          });
          const meta = [
            i.precio_unitario ? `a ${money(i.precio_unitario)}` : "",
            i.lote ? `lote ${i.lote}` : "",
            i.caducidad ? `cad ${i.caducidad}` : "",
          ].filter(Boolean).join(" · ");
          if (meta) {
            doc.setFontSize(7);
            doc.setTextColor(90);
            wrap(meta, 7, M + 2, 160);
            doc.setTextColor(0);
          }
        });
      }
      y += 3;
    });
  }

  y += 8;
  need(16);
  doc.setFont("helvetica", "normal");
  doc.setFontSize(9);
  doc.text("Contó: ____________________     Recibió: ____________________", M, y);
  return doc.output("blob");
}

export function corteTicketFileName(corteId) {
  return `corte-${Number(corteId)}.pdf`;
}

export async function uploadCorteTicketPdf(corteId, blob, sessionToken) {
  const tok = String(sessionToken || "").trim();
  if (!tok) throw new Error("Sesión expirada");
  const resp = await fetch("/api/admin/storage-upload", {
    method: "POST",
    headers: {
      "Content-Type": "application/pdf",
      "X-Session-Token": tok,
      "X-Bucket": CORTES_BUCKET,
      "X-File-Name": corteTicketFileName(corteId),
      "X-Upsert": "true",
    },
    body: blob,
  });
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok || !data?.ok) {
    throw new Error(data?.message || data?.error || `Error ${resp.status}`);
  }
  return data.publicUrl;
}

export function getSupabasePublicUrl() {
  return String(
    process.env.REACT_APP_SUPABASE_URL || process.env.VITE_SUPABASE_URL || ""
  ).replace(/\/+$/, "");
}

export function corteTicketPublicUrl(corteId, supabaseUrl = getSupabasePublicUrl()) {
  const base = String(supabaseUrl || "").replace(/\/+$/, "");
  return `${base}/storage/v1/object/public/${CORTES_BUCKET}/${corteTicketFileName(corteId)}`;
}

export async function abrirOCrearTicketCorte({ corte, sessionToken, fetchVentas }) {
  const id = corte?.id ?? corte?.corte_id;
  if (!id) throw new Error("Corte sin id");
  const ventas = fetchVentas ? await fetchVentas(corte) : corte.ventas || [];
  const snap = snapshotFromHistorialRow({ ...corte, ventas });
  const blob = corteTicketPdfBlob(snap);
  const publicUrl = await uploadCorteTicketPdf(id, blob, sessionToken);
  window.open(publicUrl, "_blank", "noopener,noreferrer");
  return publicUrl;
}
