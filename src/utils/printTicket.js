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
 * iPad / Galaxy / PWA: captura a imagen + iframe oculto.
 * Chrome en Android abre un tab a pantalla completa si usamos window.open.
 */
export function shouldKeepPrintWindowOpen() {
  return isCoarsePointer() || isStandalonePwa();
}

export const TICKET_CSS = `
* { box-sizing: border-box; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
html, body { margin: 0; padding: 0; width: 80mm; max-width: 80mm; background: #fff; }
@page { size: 80mm auto; margin: 0; }
@media print {
  html, body { width: 80mm !important; max-width: 80mm !important; margin: 0 !important; padding: 0 !important; }
  #farmacapital-ticket { width: 80mm !important; max-width: 80mm !important; padding: 3mm 2mm 13mm 2mm !important; }
}
/* Android/iPad: Chrome ignora @page 80mm y manda una hoja carta.
   TM Print Assistant encoge toda la hoja → ticket minúsculo.
   zoom 2.7 ≈ 216mm/80mm para que el ticket ocupe el ancho y al encoger quede a 80 mm. */
@media print {
  html.fc-thermal-fill { zoom: 2.7; }
  #farmacapital-ticket, #farmacapital-ticket *:not(svg):not(svg *) {
    color: #000 !important;
    -webkit-text-stroke: 0.4px #000;
    font-weight: 700 !important;
  }
  #farmacapital-ticket .ticket-puntos,
  #farmacapital-ticket .ticket-puntos *,
  #farmacapital-ticket [style*="background:#000"],
  #farmacapital-ticket [style*="background: #000"] {
    color: #fff !important;
    background: #000 !important;
    -webkit-text-stroke: 0 !important;
  }
  #farmacapital-ticket img.ticket-logo-icon,
  #farmacapital-ticket img.ticket-logo-img {
    filter: grayscale(1) contrast(8) brightness(0.15);
  }
}

#farmacapital-ticket {
  font-family: Arial, Helvetica, sans-serif;
  font-size: 12px;
  font-weight: 700;
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
  font-family: Arial, Helvetica, sans-serif;
  -webkit-print-color-adjust: exact !important;
  print-color-adjust: exact !important;
}
.ticket { width: 80mm; max-width: 80mm; font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: 700; line-height: 1.4; background: #fff; color: #000; padding: 8px 6px calc(8px + 10mm); }
.center { text-align: center; }
.left   { text-align: left; }
.right  { text-align: right; }
.separator { border: none; border-top: 1px dashed #000; margin: 5px 0; display: block; }
.separator-solid { border: none; border-top: 2px solid #000; margin: 5px 0; display: block; }
.product-row { display: flex; justify-content: space-between; font-size: 12px; font-weight: 700; padding: 2px 0; }
.product-name  { width: 60%; word-break: break-word; }
.product-total { width: 40%; text-align: right; font-weight: 800; }
.total-line { display: flex; justify-content: space-between; font-weight: 700; font-size: 12px; padding: 2px 0; }
.qr-section { text-align: center; margin-top: 10px; margin-bottom: 4mm; page-break-inside: avoid; }
.footer { text-align: center; margin-top: 8px; margin-bottom: 2mm; font-size: 12px; font-weight: 700; color: #000; page-break-inside: avoid; }
.ticket-puntos { background: #000 !important; color: #fff !important; text-align: center; padding: 6px 4px; font-size: 12px; font-weight: 900; margin: 6px 0; letter-spacing: 0.5px; }
.ticket-block { font-size: 12px; font-weight: 700; line-height: 1.45; color: #000; }
.ticket-product-name { font-size: 13px; font-weight: 800; }
.ticket-total-final { font-size: 17px; font-weight: 900; border-top: 2px solid #000; padding-top: 3px; margin-top: 2px; }
.ticket-qr-caption { font-size: 11px; font-weight: 700; color: #000; margin-top: 4px; }
.ticket-gracias { font-weight: 900; font-size: 13px; }
.ticket-web { margin-top: 3px; font-size: 12px; font-weight: 700; color: #000; }
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
  font-size: 16px;
  font-weight: 900;
  letter-spacing: 1px;
  text-transform: uppercase;
  line-height: 1.2;
}
.ticket-brand-slogan {
  font-size: 12px;
  font-weight: 700;
  margin-top: 2px;
  color: #000;
}
`;

function escTitle(title) {
  return String(title || "Ticket FarmaCapital").replace(/[&<>"']/g, (c) => (
    { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]
  ));
}

function wrapTicketHtml(innerHtml, title = "Ticket FarmaCapital") {
  const fillClass = shouldKeepPrintWindowOpen() ? " fc-thermal-fill" : "";
  return `<!DOCTYPE html>
<html lang="es" class="${fillClass.trim()}">
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

function launchPrintOnWindow(win, { closeAfter, onClose }) {
  let started = false;
  let closed = false;
  const close = () => {
    if (closed) return;
    closed = true;
    try { if (win && !win.closed) win.close(); } catch { /* noop */ }
    try { onClose?.(); } catch { /* noop */ }
  };
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
      close();
      return;
    }
    if (!closeAfter) return;
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
  if (!win?.document) {
    iframe.remove();
    return false;
  }
  writeHtml(win, html);
  launchPrintOnWindow(win, {
    closeAfter: true,
    onClose: () => { try { iframe.remove(); } catch { /* noop */ } },
  });
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
  launchPrintOnWindow(win, { closeAfter: true });
  return true;
}

function printRawHtml(html) {
  // Tablet/PWA: iframe oculto. El popup abre Chrome con el ticket a pantalla.
  if (shouldKeepPrintWindowOpen()) {
    if (printViaIframe(html)) return true;
    if (printViaPopup(html)) return true;
    alert(popupBlockedMessage());
    return false;
  }
  if (printViaPopup(html)) return true;
  if (printViaIframe(html)) return true;
  alert(popupBlockedMessage());
  return false;
}

/** Imagen a todo el ancho de la hoja. Chrome manda carta; al encoger a 80 mm el ticket llena el rollo. */
function printCanvasFullBleed(canvas) {
  const png = canvas.toDataURL("image/png");
  return printRawHtml(`<!DOCTYPE html>
<html lang="es"><head>
<meta charset="UTF-8">
<title>Ticket FarmaCapital</title>
<style>
html, body { margin: 0; padding: 0; background: #fff; }
img { display: block; width: 100%; height: auto; }
@media print {
  @page { margin: 0; }
  html, body { margin: 0; width: 100%; }
  img { width: 100% !important; height: auto !important; }
}
</style>
</head>
<body><img src="${png}" alt="ticket"/></body>
</html>`);
}

function isThermalBlackBg(el) {
  let node = el;
  while (node && node.nodeType === 1) {
    if (node.classList?.contains("ticket-puntos") || node.classList?.contains("ticket-rx")) return true;
    const bg = `${node.getAttribute?.("style") || ""}`.replace(/\s/g, "").toLowerCase();
    if (bg.includes("background:#000") || bg.includes("background-color:#000")) return true;
    node = node.parentElement;
  }
  return false;
}

function hardenTicketForThermal(root, view) {
  if (!root) return;
  root.style.fontFamily = "Arial, Helvetica, sans-serif";
  root.style.color = "#000";
  root.style.fontWeight = "700";
  root.querySelectorAll("*").forEach((node) => {
    if (node.closest("svg")) return;
    const onBlack = isThermalBlackBg(node);
    node.style.fontFamily = "Arial, Helvetica, sans-serif";
    if (onBlack) {
      node.style.color = "#fff";
      node.style.webkitTextStroke = "0";
    } else {
      node.style.color = "#000";
      node.style.webkitTextStroke = "0.45px #000";
    }
    const computed = view?.getComputedStyle?.(node);
    const weight = parseInt(node.style.fontWeight || computed?.fontWeight || "400", 10);
    if (!Number.isFinite(weight) || weight < 700) node.style.fontWeight = "700";
    const px = parseFloat(computed?.fontSize || node.style.fontSize || "12");
    if (Number.isFinite(px) && px < 12) node.style.fontSize = "12px";
  });
}

async function printElementAs80mmPdf(el) {
  const { default: html2canvas } = await import("html2canvas");
  const canvas = await html2canvas(el, {
    scale: 4,
    letterRendering: true,
    backgroundColor: "#ffffff",
    useCORS: true,
    logging: false,
    onclone(doc) {
      const t = doc.getElementById(el.id) || doc.body;
      t.style.width = "80mm";
      t.style.maxWidth = "80mm";
      t.style.color = "#000";
      t.style.background = "#fff";
      t.style.position = "static";
      hardenTicketForThermal(t, doc.defaultView);
      t.querySelectorAll("img").forEach((img) => {
        img.style.filter = "grayscale(1) contrast(8) brightness(0.15)";
      });
    },
  });
  return printCanvasFullBleed(canvas);
}

async function printHtmlAs80mmPdf(html) {
  const host = document.createElement("div");
  host.style.cssText = "position:fixed;left:-120vw;top:0;width:80mm;background:#fff;";
  if (/<html/i.test(html)) {
    const parsed = new DOMParser().parseFromString(html, "text/html");
    host.appendChild(parsed.body.firstElementChild || parsed.body);
  } else {
    host.innerHTML = html;
  }
  document.body.appendChild(host);
  await waitForPrintAssets(host);
  const target = host.querySelector("#farmacapital-ticket") || host.firstElementChild || host;
  try {
    await printElementAs80mmPdf(target);
  } finally {
    host.remove();
  }
  return true;
}

/** Tablet: iframe oculto. PC: popup que se cierra al terminar. */
export function printPreparedHtml(html) {
  if (typeof window === "undefined") return false;
  if (shouldKeepPrintWindowOpen()) {
    printHtmlAs80mmPdf(html).catch((e) => {
      console.error("[FarmaCapital] PDF térmico:", e);
      printRawHtml(html);
    });
    return true;
  }
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

  if (shouldKeepPrintWindowOpen()) {
    printElementAs80mmPdf(ticket).catch((e) => {
      console.error("[FarmaCapital] PDF térmico:", e);
      const clone = ticket.cloneNode(true);
      const srcSvgs = ticket.querySelectorAll("svg");
      const dstSvgs = clone.querySelectorAll("svg");
      srcSvgs.forEach((src, i) => {
        if (dstSvgs[i]) dstSvgs[i].replaceWith(src.cloneNode(true));
      });
      printPreparedHtml(wrapTicketHtml(clone.outerHTML));
    });
    return true;
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
    <div style="margin-bottom:4px">
      <div class="ticket-product-name">${(p.nombre||"Producto").slice(0,22)}</div>
      <div class="product-row">
        <span>${p.qty||p.cantidad||1} x ${fmt(p.precio||p.precio_unitario||0)}</span>
        <span class="product-total">${fmt((p.precio||p.precio_unitario||0)*(p.qty||p.cantidad||1))}</span>
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
  <div class="ticket-block">
    <div>Sucursal: ${cfg.nombre_farmacia}</div>
    <div>Dirección: ${cfg.direccion_farmacia}</div>
    <div>RFC: ${cfg.rfc}</div>
    ${cfg.telefono_farmacia?`<div>Tel: ${cfg.telefono_farmacia_display||cfg.telefono_farmacia}</div>`:""}
  </div>
  <hr class="separator">
  <div class="ticket-block">
    <div>Fecha:  ${fechaStr}</div>
    <div>Hora:   ${horaStr}</div>
    <div>Folio:  #${folio}</div>
    ${cliente?`<div>Cliente: ${cliente.nombre||"—"}</div>`:""}
  </div>
  <hr class="separator">
  ${rows}
  <hr class="separator">
  <div class="total-line">
    <span>Subtotal:</span><span>${fmt(total)}</span>
  </div>
  <hr class="separator">
  <div class="total-line ticket-total-final">
    <span>TOTAL:</span><span>${fmt(total)}</span>
  </div>
  <hr class="separator">
  <div class="ticket-block">Método: ${metodoPago||"Efectivo"}</div>
  <hr class="separator">
  <div class="footer">
    <div class="ticket-gracias">Gracias por su compra</div>
    <div>¡Vuelva pronto!</div>
    <div class="ticket-web">farmacapital.mx</div>
  </div>
</div>
</body>
</html>`;
}

/** Abre ventana popup e imprime HTML generado programáticamente. */
export function printTicketWindow(data) {
  return printPreparedHtml(generateTicketHTML(data));
}
