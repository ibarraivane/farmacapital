// FARMACAPITAL — Utilidad de impresión de tickets

import { mergeFarmaciaConfig } from "../constants/farmaciaFiscal";
import { isCoarsePointer } from "./touchKeyboard";

const PRINT_IFRAME_ID = "fc-epson-print-frame";

export function isStandalonePwa() {
  if (typeof window === "undefined") return false;
  const standalone = typeof window.matchMedia === "function"
    && window.matchMedia("(display-mode: standalone)").matches;
  return Boolean(standalone || window.navigator.standalone);
}

/**
 * iPad / Galaxy / PWA: no cerrar la ventana a los 3 s.
 * Al elegir la Epson el preview se rehace; si el documento ya no está, sale blanco o se cancela.
 */
export function shouldKeepPrintWindowOpen() {
  return isCoarsePointer() || isStandalonePwa();
}

export const TICKET_CSS = `
* { box-sizing: border-box; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
html, body { margin: 0; padding: 0; width: 80mm; max-width: 80mm; background: #fff; }
@page { size: 80mm auto; margin: 0; }
@media print {
  html, body { width: 80mm !important; max-width: 80mm !important; }
  #farmacapital-ticket { width: 80mm !important; max-width: 80mm !important; padding: 3mm 2mm 13mm 2mm !important; }
}

#farmacapital-ticket {
  font-family: 'Courier New', Courier, monospace;
  font-size: 11px;
  line-height: 1.45;
  width: 80mm;
  max-width: 80mm;
  background: #ffffff;
  color: #000000;
  padding: 10px 8px calc(10px + 10mm);
  margin: 0;
  box-sizing: border-box;
}
#farmacapital-ticket * {
  font-family: 'Courier New', Courier, monospace;
  -webkit-print-color-adjust: exact !important;
  print-color-adjust: exact !important;
}
.ticket { width: 80mm; max-width: 80mm; font-family: 'Courier New', Courier, monospace; font-size: 11px; line-height: 1.4; background: #fff; color: #000; padding: 8px 6px calc(8px + 10mm); }
.center { text-align: center; }
.left   { text-align: left; }
.right  { text-align: right; }
.separator { border: none; border-top: 1px dashed #000; margin: 5px 0; display: block; }
.separator-solid { border: none; border-top: 2px solid #000; margin: 5px 0; display: block; }
.product-row { display: flex; justify-content: space-between; font-size: 10px; padding: 2px 0; }
.product-name  { width: 60%; word-break: break-word; }
.product-total { width: 40%; text-align: right; font-weight: bold; }
.total-line { display: flex; justify-content: space-between; font-weight: bold; font-size: 11px; padding: 2px 0; }
.qr-section { text-align: center; margin-top: 10px; margin-bottom: 4mm; page-break-inside: avoid; }
.footer { text-align: center; margin-top: 8px; margin-bottom: 2mm; font-size: 9px; color: #333; page-break-inside: avoid; }
.ticket-puntos { background: #000 !important; color: #fff !important; text-align: center; padding: 5px 4px; font-size: 10px; font-weight: 900; margin: 6px 0; letter-spacing: 1px; }
.ticket-logo-wrap { text-align: center; margin-bottom: 4px; }
.ticket-logo-icon {
  height: 32px;
  width: 32px;
  max-width: 32px;
  max-height: 32px;
  display: block;
  margin: 0 auto 4px;
  object-fit: contain;
}
.ticket-logo-img {
  height: 26px;
  width: auto;
  max-width: 200px;
  max-height: 26px;
  display: block;
  margin: 0 auto 4px;
  object-fit: contain;
}
.ticket-brand-name {
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 2px;
  text-transform: uppercase;
  line-height: 1.2;
}
.ticket-brand-slogan {
  font-size: 9px;
  margin-top: 2px;
  color: #333;
}
`;

function escTitle(title) {
  return String(title || "Ticket FarmaCapital").replace(/[&<>"']/g, (c) => (
    { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]
  ));
}

function wrapTicketHtml(innerHtml, title = "Ticket FarmaCapital") {
  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>${escTitle(title)}</title>
  <style>${TICKET_CSS}</style>
</head>
<body>
${innerHtml}
</body>
</html>`;
}

function popupBlockedMessage() {
  return (
    "No se pudo abrir la ventana de impresión.\n\n" +
    "En la tablet: permite ventanas emergentes para farmacapital.mx.\n" +
    "Si usas el icono de la app (PWA), abre FarmaCapital en Chrome o Safari e inténtalo de nuevo.\n" +
    "En iPad: Ajustes → Safari → Bloquear ventanas emergentes → desactivar."
  );
}

function waitForPrintAssets(doc) {
  return new Promise((resolve) => {
    const imgs = Array.from(doc?.images || []);
    const pending = imgs.filter((img) => !img.complete);
    if (!pending.length) {
      resolve();
      return;
    }
    let left = pending.length;
    const tick = () => {
      left -= 1;
      if (left <= 0) resolve();
    };
    pending.forEach((img) => {
      img.addEventListener("load", tick, { once: true });
      img.addEventListener("error", tick, { once: true });
    });
    setTimeout(resolve, 2000);
  });
}

function launchPrintOnWindow(win, { closeAfter }) {
  let started = false;
  const run = async () => {
    if (started || !win || win.closed) return;
    started = true;
    await waitForPrintAssets(win.document);
    if (win.closed) return;
    try {
      win.focus();
      win.print();
    } catch (e) {
      console.error("[FarmaCapital] Error al imprimir:", e);
      return;
    }
    if (!closeAfter) return;
    const close = () => {
      try { if (!win.closed) win.close(); } catch { /* noop */ }
    };
    win.addEventListener("afterprint", close);
    setTimeout(close, 60_000);
  };
  try {
    win.addEventListener("load", () => { setTimeout(run, 200); });
  } catch { /* about:blank en algunos WebViews */ }
  setTimeout(run, 900);
}

function writeHtml(win, html) {
  win.document.open();
  win.document.write(html);
  win.document.close();
}

function printViaIframe(html) {
  if (typeof document === "undefined") return false;
  const prev = document.getElementById(PRINT_IFRAME_ID);
  if (prev) prev.remove();
  const iframe = document.createElement("iframe");
  iframe.id = PRINT_IFRAME_ID;
  iframe.title = "Imprimir ticket";
  iframe.setAttribute("aria-hidden", "true");
  // iOS imprime en blanco si el iframe es display:none o 0×0
  iframe.style.cssText = "position:fixed;left:-10000px;top:0;width:80mm;min-height:200px;border:0;opacity:0;pointer-events:none;";
  document.body.appendChild(iframe);
  const win = iframe.contentWindow;
  if (!win?.document) return false;
  writeHtml(win, html);
  launchPrintOnWindow(win, { closeAfter: false });
  return true;
}

function printViaPopup(html) {
  let win = null;
  try {
    win = window.open("", "_blank", "width=320,height=700,toolbar=0,menubar=0,scrollbars=1,resizable=1");
  } catch {
    win = null;
  }
  if (!win || win.closed) return false;
  writeHtml(win, html);
  launchPrintOnWindow(win, { closeAfter: !shouldKeepPrintWindowOpen() });
  return true;
}

/** Popup (gesto del toque) o iframe si la tablet/PWA bloquea ventanas. */
export function printPreparedHtml(html) {
  if (typeof window === "undefined") return false;
  if (printViaPopup(html)) return true;
  if (printViaIframe(html)) return true;
  alert(popupBlockedMessage());
  return false;
}

/**
 * Abre el diálogo de impresión del ticket ya montado en pantalla.
 * Compatible con Epson TM-T20III/IV (80 mm) desde PC, Galaxy o iPad.
 * @param {string} ticketId - ID del elemento DOM del ticket
 */
export function printTicket(ticketId = "farmacapital-ticket") {
  const ticket = document.getElementById(ticketId);
  if (!ticket) {
    console.error("[FarmaCapital] Ticket no encontrado:", ticketId);
    return false;
  }

  const clone = ticket.cloneNode(true);
  const srcSvgs = ticket.querySelectorAll("svg");
  const dstSvgs = clone.querySelectorAll("svg");
  srcSvgs.forEach((src, i) => {
    if (dstSvgs[i]) dstSvgs[i].replaceWith(src.cloneNode(true));
  });

  return printPreparedHtml(wrapTicketHtml(clone.outerHTML));
}

/**
 * Misma ventana 80 mm que el ticket de venta (Epson TM-T20).
 * `innerHtml` debe incluir el nodo #farmacapital-ticket.
 */
export function openThermalPrintWindow(innerHtml, title = "Ticket FarmaCapital") {
  return printPreparedHtml(wrapTicketHtml(innerHtml, title));
}

/**
 * Genera HTML completo del ticket a partir de datos estructurados.
 * Útil para impresión sin componente React montado.
 */
export function generateTicketHTML(data) {
  const { venta, productos, cliente, metodoPago, config } = data;
  const fecha = new Date(venta.created_at || Date.now());
  const fechaStr = fecha.toLocaleDateString("es-MX", { day:"2-digit", month:"2-digit", year:"numeric" });
  const horaStr  = fecha.toLocaleTimeString("es-MX", { hour:"2-digit", minute:"2-digit" });
  const folio = venta.folio || `VTA-${String(venta.id || "0").padStart(8, "0")}`;
  const total = parseFloat(venta.total || 0);
  const fmt = n => `$${parseFloat(n || 0).toFixed(2)}`;

  const cfg = mergeFarmaciaConfig(config || {});

  const rows = (productos || []).map(p => `
    <div style="margin-bottom:3px">
      <div style="font-size:10px;font-weight:bold">${(p.nombre||"Producto").slice(0,22)}</div>
      <div style="display:flex;justify-content:space-between;font-size:10px">
        <span>${p.qty||p.cantidad||1} x ${fmt(p.precio||p.precio_unitario||0)}</span>
        <span style="font-weight:bold">${fmt((p.precio||p.precio_unitario||0)*(p.qty||p.cantidad||1))}</span>
      </div>
    </div>`).join("");

  const iconSrc = `${process.env.PUBLIC_URL || ""}/brand/farmacapital-icon.png?v=6`;

  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Ticket FarmaCapital</title>
  <style>${TICKET_CSS}</style>
</head>
<body>
<div id="farmacapital-ticket" class="ticket">
  <div class="center ticket-logo-wrap">
    <img src="${iconSrc}" alt="" class="ticket-logo-icon" aria-hidden="true"/>
    <div class="ticket-brand-name">FarmaCapital</div>
    <div class="ticket-brand-slogan">"Tu salud primero"</div>
  </div>
  <hr class="separator">
  <div style="font-size:9px;line-height:1.6">
    <div>Sucursal: ${cfg.nombre_farmacia}</div>
    <div>Dirección: ${cfg.direccion_farmacia}</div>
    <div>RFC: ${cfg.rfc}</div>
    ${cfg.telefono_farmacia?`<div>Tel: ${cfg.telefono_farmacia_display||cfg.telefono_farmacia}</div>`:""}
  </div>
  <hr class="separator">
  <div style="font-size:9px;line-height:1.7">
    <div>Fecha:  ${fechaStr}</div>
    <div>Hora:   ${horaStr}</div>
    <div>Folio:  #${folio}</div>
    ${cliente?`<div>Cliente: ${cliente.nombre||"—"}</div>`:""}
  </div>
  <hr class="separator">
  ${rows}
  <hr class="separator">
  <div style="display:flex;justify-content:space-between;font-size:10px;padding:1px 0">
    <span>Subtotal:</span><span>${fmt(total)}</span>
  </div>
  <hr class="separator">
  <div style="display:flex;justify-content:space-between;font-size:14px;font-weight:900;padding:3px 0">
    <span>TOTAL:</span><span>${fmt(total)}</span>
  </div>
  <hr class="separator">
  <div style="font-size:10px">Método: ${metodoPago||"Efectivo"}</div>
  <hr class="separator">
  <div class="footer">
    <div style="font-weight:bold;font-size:11px;letter-spacing:1px">Gracias por su compra</div>
    <div>¡Vuelva pronto!</div>
    <div style="margin-top:3px;font-size:8px;color:#555">farmacapital.mx</div>
  </div>
</div>
</body>
</html>`;
}

/** Abre ventana popup e imprime HTML generado programáticamente. */
export function printTicketWindow(data) {
  return printPreparedHtml(generateTicketHTML(data));
}
