/**
 * Registro crudo de una fuente. El precio llega de un archivo o URL
 * verificable; este módulo no inventa cifras.
 */

"use strict";

function crearRegistroCrudo(input) {
  const precio = Number(input && input.precio);
  const nombre = String((input && input.nombre_crudo) || "").trim();
  const fuente = String((input && input.fuente) || "").trim();
  const url = String((input && input.url_origen) || "").trim();
  const fecha = input && input.fecha_captura ? new Date(input.fecha_captura) : null;

  if (!fuente) throw new Error("registro_sin_fuente");
  if (!nombre) throw new Error("registro_sin_nombre");
  if (!Number.isFinite(precio) || precio < 0) throw new Error("registro_precio_invalido");
  if (!url) throw new Error("registro_sin_url_origen");
  if (!fecha || Number.isNaN(fecha.getTime())) throw new Error("registro_sin_fecha_captura");

  return {
    fuente,
    nombre_crudo: nombre,
    precio,
    moneda: String((input && input.moneda) || "MXN").trim() || "MXN",
    url_origen: url,
    fecha_captura: fecha.toISOString(),
    ciudad: (input && input.ciudad) || null,
    region: (input && input.region) || null,
    gtin_fuente: digitsOnly((input && (input.gtin_fuente || input.gtin || input.ean)) || ""),
    sku_externo: (input && input.sku_externo) || null,
    tipo: (input && input.tipo) || null,
  };
}

function digitsOnly(raw) {
  return String(raw || "").replace(/\D/g, "");
}

function huellaCaptura(reg) {
  const fechaDia = String(reg.fecha_captura || "").slice(0, 10);
  const partes = [
    reg.fuente || "",
    reg.url_origen || "",
    String(reg.nombre_crudo || "").trim().toLowerCase(),
    String(reg.precio),
    fechaDia,
    reg.ciudad || "",
    reg.gtin_fuente || "",
  ];
  return partes.join("|");
}

module.exports = {
  crearRegistroCrudo,
  digitsOnly,
  huellaCaptura,
};
