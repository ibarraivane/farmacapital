import { mergeFarmaciaConfig } from "../constants/farmaciaFiscal";
import { openThermalPrintWindow } from "./printTicket";

export function tituloTicketServicio(categoria, proveedor) {
  const prov = String(proveedor || "").trim() || "SERVICIO";
  const cat = String(categoria || "").toLowerCase();
  if (cat === "recarga") return `RECARGA ${prov}`.toUpperCase();
  return `PAGO ${prov}`.toUpperCase();
}

export function labelMetodoServicio(metodo) {
  const m = String(metodo || "").toLowerCase();
  if (m === "tarjeta") return "Tarjeta Point";
  if (m === "efectivo") return "Efectivo";
  return metodo || "Efectivo";
}

function esc(s) {
  return String(s ?? "").replace(/[&<>"']/g, (c) => (
    { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]
  ));
}

function money(n) {
  return `$${parseFloat(n || 0).toFixed(2)}`;
}

/** Acepta el payload del POS o la fila de pagos_servicio / Transacciones. */
export function normalizarServicioTicket(src = {}) {
  return {
    folio: src.folio || "",
    proveedor: src.proveedor || "Servicio",
    categoria: src.categoria || "",
    referencia: src.referencia || "",
    montoServicio: src.montoServicio ?? src.monto_servicio ?? 0,
    comision: src.comision ?? 0,
    total: src.total ?? src.total_cobrado ?? 0,
    metodoPago: src.metodoPago || src.metodo_pago || "efectivo",
    created_at: src.created_at || Date.now(),
  };
}

export function servicioTicketInner(raw, config) {
  const d = normalizarServicioTicket(raw);
  const cfg = mergeFarmaciaConfig(config || {});
  const fecha = new Date(d.created_at);
  const fechaStr = fecha.toLocaleDateString("es-MX", { day: "2-digit", month: "2-digit", year: "numeric" });
  const horaStr = fecha.toLocaleTimeString("es-MX", { hour: "2-digit", minute: "2-digit", second: "2-digit" });
  const titulo = tituloTicketServicio(d.categoria, d.proveedor);
  const iconSrc = `${process.env.PUBLIC_URL || ""}/brand/farmacapital-icon.png?v=6`;

  return `<div id="farmacapital-ticket" class="ticket">
  <div class="center ticket-logo-wrap">
    <img src="${iconSrc}" alt="" class="ticket-logo-icon" aria-hidden="true"/>
    <div class="ticket-brand-name">FarmaCapital</div>
    <div class="ticket-brand-slogan">"Tu salud primero"</div>
  </div>
  <div class="separator"></div>
  <div class="center ticket-gracias">${esc(titulo)}</div>
  <div class="separator"></div>
  <div class="ticket-block">
    <div>Sucursal: ${esc(cfg.nombre_farmacia)}</div>
    <div>Dirección: ${esc(cfg.direccion_farmacia)}</div>
    <div>RFC: ${esc(cfg.rfc)}</div>
    ${cfg.telefono_farmacia ? `<div>Tel: ${esc(cfg.telefono_farmacia_display || cfg.telefono_farmacia)}</div>` : ""}
  </div>
  <div class="separator"></div>
  <div class="ticket-block">
    <div>Fecha:  ${esc(fechaStr)}</div>
    <div>Hora:   ${esc(horaStr)}</div>
    <div>Folio:  #${esc(d.folio || "SRV")}</div>
    ${d.referencia ? `<div>Ref:    ${esc(d.referencia)}</div>` : ""}
  </div>
  <div class="separator"></div>
  <div class="ticket-product-name">${esc(d.proveedor)}</div>
  <div class="total-line"><div>Monto:</div><div>${money(d.montoServicio)}</div></div>
  <div class="total-line"><div>Recargo:</div><div>${money(d.comision)}</div></div>
  <div class="total-line ticket-total-final"><div>TOTAL:</div><div>${money(d.total)}</div></div>
  <div class="separator"></div>
  <div class="ticket-block">Método: ${esc(labelMetodoServicio(d.metodoPago))}</div>
  <div class="separator"></div>
  <div class="footer">
    <div class="ticket-gracias">Gracias por su compra</div>
    <div>¡Vuelva pronto!</div>
    <div class="ticket-web">farmacapital.mx</div>
  </div>
</div>`;
}

export function printServicioTicket(raw, config) {
  const d = normalizarServicioTicket(raw);
  return openThermalPrintWindow(servicioTicketInner(d, config), d.folio || "Recarga FarmaCapital");
}
