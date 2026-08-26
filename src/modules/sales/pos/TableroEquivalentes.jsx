import React from "react";
import { C_LIGHT } from "../../../constants";
import { $ } from "../../../utils";
import { posDestacadoTarjeta, posSubtituloProducto, posTituloProducto } from "../../../utils/posProductDisplay";
import { etiquetaTipoProducto } from "../../../utils/equivalentesPos";
import { useImagenesPrincipales } from "../../../hooks/useProductoImagenes";

function etiquetaSustanciaVisible(value) {
  return String(value || "")
    .replace(/\bcaolin\b/gi, "Caolín")
    .replace(/\bneomicina\b/gi, "Neomicina")
    .replace(/\bpectina\b/gi, "Pectina");
}

function fotoTarjeta(producto, fotoDe) {
  return fotoDe?.(producto?.id) || producto?.imagen_url || producto?.imagen_mobile_url || "";
}

function TarjetaProducto({ producto, onSelect, onAdd, estadoStock, diferencia, fotoDe }) {
  const C = C_LIGHT;
  const foto = fotoTarjeta(producto, fotoDe);
  const titulo = posTituloProducto(producto) || producto.nombre;
  const tipo = etiquetaTipoProducto(producto);
  const destacado = posDestacadoTarjeta(producto);
  const subtitulo = posSubtituloProducto(producto) || producto.sku;
  const estado = estadoStock?.(producto) || {};
  const agotado = Boolean(estado.agotado);
  return (
    <article style={{ border: `1px solid ${C.border}`, borderRadius: 12, background: C.card, padding: 10, display: "flex", flexDirection: "column", gap: 6, minWidth: 0, height: "100%", boxSizing: "border-box" }}>
      <button type="button" onClick={() => onSelect(producto)} aria-label={`Ver ficha de ${titulo}`} style={{ border: 0, padding: 0, background: "transparent", cursor: "pointer", textAlign: "left", color: "inherit", font: "inherit", display: "flex", flexDirection: "column", gap: 6, minWidth: 0 }}>
        <div style={{ height: 200, borderRadius: 10, overflow: "hidden", background: foto ? "#fff" : C.amberDim, border: `1px solid ${C.border}`, display: "flex", alignItems: "center", justifyContent: "center", padding: 4, boxSizing: "border-box" }}>
          {foto ? <img src={foto} alt="" style={{ width: "100%", height: "100%", objectFit: "contain" }} /> : <span style={{ fontSize: 18, fontWeight: 900, color: "#92400e", textAlign: "center", lineHeight: 1.1, overflowWrap: "anywhere" }}>{producto.marca || titulo}</span>}
        </div>
        <div style={{ minWidth: 0 }}>
          <div style={{ fontSize: 15, fontWeight: 900, color: C.text, lineHeight: 1.2 }}>{titulo}</div>
          {producto.marca && !titulo.toLowerCase().includes(String(producto.marca).toLowerCase()) && (
            <div style={{ fontSize: 12, fontWeight: 750, color: C.textMid, marginTop: 2, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{producto.marca}</div>
          )}
        </div>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 8, minHeight: 22 }}>
          {tipo ? <span style={{ fontSize: 10, fontWeight: 850, borderRadius: 7, padding: "3px 7px", background: tipo === "Marca" ? C.purpleDim : C.tealDim, color: tipo === "Marca" ? C.purple : C.teal }}>{tipo}</span> : <span />}
          <span style={{ fontSize: 12, fontWeight: 800, color: agotado ? C.red : C.green }}>{estado.etiqueta || (agotado ? "No disponible" : "Disponible")}</span>
        </div>
        {destacado ? (
          <div style={{ padding: "6px 8px", borderRadius: 8, background: C.blueDim, color: C.blue, fontSize: 11, fontWeight: 800, lineHeight: 1.3 }}>
            {destacado}
          </div>
        ) : null}
        {subtitulo ? (
          <div style={{ fontSize: 12, color: C.textMid, lineHeight: 1.3 }}>{subtitulo}</div>
        ) : null}
        {diferencia ? (
          <div style={{ fontSize: 10, fontWeight: 800, lineHeight: 1.25, color: C.amber }}>{diferencia}</div>
        ) : null}
      </button>
      <div style={{ marginTop: "auto", display: "flex", alignItems: "center", justifyContent: "space-between", gap: 10, paddingTop: 2 }}>
        <span style={{ fontSize: 17, fontWeight: 900, color: C.blue }}>{$(producto.precio)}</span>
        <button type="button" disabled={agotado} onClick={() => onAdd(producto)} style={{ minHeight: 40, padding: "8px 13px", border: 0, borderRadius: 9, background: agotado ? C.border : C.blue, color: agotado ? C.textDim : "#fff", fontSize: 12, fontWeight: 850, cursor: agotado ? "not-allowed" : "pointer" }}>Agregar</button>
      </div>
    </article>
  );
}

function Seccion({ titulo, productos, diferencia, fotoDe, ...props }) {
  if (!productos?.length) return null;
  return (
    <section style={{ marginTop: 8 }}>
      <div style={{ fontSize: 12, fontWeight: 900, color: C_LIGHT.text }}>{titulo}</div>
      <div className="pos-related-products-grid" style={{ display: "grid", gridTemplateColumns: "repeat(2, minmax(0, 1fr))", gap: 8, marginTop: 5, alignItems: "stretch" }}>
        {productos.map((p) => <TarjetaProducto key={p.id} producto={p} diferencia={typeof diferencia === "function" ? diferencia(p) : diferencia} fotoDe={fotoDe} {...props} />)}
      </div>
    </section>
  );
}

const ESTILO_GRILLA = `@media (min-width: 1180px){.pos-related-products-grid{grid-template-columns:repeat(4,minmax(0,1fr))!important}} @media (max-width: 620px){.pos-related-products-grid{grid-template-columns:1fr!important}}`;

function MarcoTablero({ titulo, children }) {
  return (
    <div style={{ border: `1px solid ${C_LIGHT.border}`, borderRadius: 14, background: C_LIGHT.bg, padding: 10, marginBottom: 10 }}>
      <div style={{ fontSize: 16, fontWeight: 900, color: C_LIGHT.text }}>{titulo}</div>
      {children}
      <style>{ESTILO_GRILLA}</style>
    </div>
  );
}

/** Búsqueda genérica (leche, pañal…): mismas tarjetas, sin agrupar por activo. */
export function TableroResultados({ productos, titulo, onSelect, onAdd, estadoStock }) {
  const fotoDe = useImagenesPrincipales();
  if (!productos?.length) return null;
  return (
    <MarcoTablero titulo={titulo}>
      <div className="pos-related-products-grid" style={{ display: "grid", gridTemplateColumns: "repeat(2, minmax(0, 1fr))", gap: 8, marginTop: 8, alignItems: "stretch" }}>
        {productos.map((p) => <TarjetaProducto key={p.id} producto={p} onSelect={onSelect} onAdd={onAdd} estadoStock={estadoStock} fotoDe={fotoDe} />)}
      </div>
    </MarcoTablero>
  );
}

export default function TableroEquivalentes({ grupo, onSelect, onAdd, estadoStock }) {
  const fotoDe = useImagenesPrincipales();
  if (!grupo?.total) return null;
  const otras = [...(grupo.otroContenido || []), ...(grupo.otrasPresentaciones || [])];
  const idsOtroContenido = new Set((grupo.otroContenido || []).map((p) => p.id));
  return (
    <MarcoTablero titulo={`${grupo.total} opciones con ${etiquetaSustanciaVisible(grupo.etiqueta)}`}>
      <Seccion titulo="Misma presentación" productos={grupo.mismaConfiguracion} onSelect={onSelect} onAdd={onAdd} estadoStock={estadoStock} fotoDe={fotoDe} />
      <Seccion titulo="Otras presentaciones" productos={otras} diferencia={(p) => idsOtroContenido.has(p.id) ? "Cambia contenido" : "Cambia forma, vía o concentración"} onSelect={onSelect} onAdd={onAdd} estadoStock={estadoStock} fotoDe={fotoDe} />
    </MarcoTablero>
  );
}
