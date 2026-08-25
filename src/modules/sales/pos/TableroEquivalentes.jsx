import React from "react";
import { C_LIGHT } from "../../../constants";
import { $ } from "../../../utils";
import { posSubtituloProducto, posTituloProducto } from "../../../utils/posProductDisplay";
import { etiquetaTipoProducto } from "../../../utils/equivalentesPos";

function etiquetaSustanciaVisible(value) {
  return String(value || "")
    .replace(/\bcaolin\b/gi, "Caolín")
    .replace(/\bneomicina\b/gi, "Neomicina")
    .replace(/\bpectina\b/gi, "Pectina");
}

function TarjetaProducto({ producto, onSelect, onAdd, estadoStock, diferencia }) {
  const C = C_LIGHT;
  const foto = producto.imagen_url || producto.imagen_mobile_url || "";
  const titulo = posTituloProducto(producto) || producto.nombre;
  const tipo = etiquetaTipoProducto(producto);
  const activos = etiquetaSustanciaVisible(producto.principio_activo || producto.denominacion_generica || "");
  const estado = estadoStock?.(producto) || {};
  const agotado = Boolean(estado.agotado);
  return (
    <article style={{ border: `1px solid ${C.border}`, borderRadius: 12, background: C.card, padding: 9, display: "grid", gridTemplateRows: "auto auto auto auto auto 1fr auto auto", gap: 6, minWidth: 0, height: "100%", boxSizing: "border-box" }}>
      <button type="button" onClick={() => onSelect(producto)} aria-label={`Ver ficha de ${titulo}`} style={{ border: 0, padding: 0, background: "transparent", cursor: "pointer", textAlign: "left", color: "inherit", font: "inherit", display: "contents" }}>
        <div style={{ height: 100, borderRadius: 9, overflow: "hidden", background: foto ? "#fff" : C.amberDim, border: `1px solid ${C.border}`, display: "flex", alignItems: "center", justifyContent: "center", padding: 6, boxSizing: "border-box" }}>
          {foto ? <img src={foto} alt="" style={{ maxWidth: "100%", maxHeight: "100%", objectFit: "contain" }} /> : <span style={{ fontSize: 18, fontWeight: 900, color: "#92400e", textAlign: "center", lineHeight: 1.1, overflowWrap: "anywhere" }}>{producto.marca || titulo}</span>}
        </div>
        <div style={{ height: 50, minHeight: 50, overflow: "hidden" }}>
          <div style={{ fontSize: 15, fontWeight: 900, color: C.text, lineHeight: 1.12, display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", overflow: "hidden" }}>{titulo}</div>
          {producto.marca && !titulo.toLowerCase().includes(String(producto.marca).toLowerCase()) && <div style={{ fontSize: 11, fontWeight: 750, color: C.textMid, marginTop: 2, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{producto.marca}</div>}
        </div>
        <div style={{ height: 23, minHeight: 23, display: "flex", alignItems: "center", gap: 5, flexWrap: "wrap" }}>
          {tipo && <span style={{ fontSize: 10, fontWeight: 850, borderRadius: 7, padding: "3px 7px", background: tipo === "Marca" ? C.purpleDim : C.tealDim, color: tipo === "Marca" ? C.purple : C.teal }}>{tipo}</span>}
        </div>
        <div style={{ height: 43, minHeight: 43 }}>
          {activos && <div style={{ height: "100%", padding: "5px 7px", borderRadius: 7, background: C.blueDim, color: C.blue, fontSize: 10, fontWeight: 800, lineHeight: 1.25, boxSizing: "border-box", overflow: "hidden", display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical" }}>Activos: {activos}</div>}
        </div>
        <div style={{ height: 43, minHeight: 43, fontSize: 11, color: C.textMid, lineHeight: 1.25, overflow: "hidden", display: "-webkit-box", WebkitLineClamp: 3, WebkitBoxOrient: "vertical" }}>{posSubtituloProducto(producto) || producto.sku}</div>
        <div style={{ minHeight: 26, fontSize: 10, fontWeight: 800, lineHeight: 1.25, color: C.amber }}>{diferencia || ""}</div>
      </button>
      <div style={{ minHeight: 20, display: "flex", alignItems: "center", justifyContent: "space-between", gap: 8, flexWrap: "wrap" }}>
        <span />
        <span style={{ fontSize: 12, fontWeight: 800, color: agotado ? C.red : C.green }}>{estado.etiqueta || (agotado ? "No disponible" : "Disponible")}</span>
      </div>
      <div style={{ minHeight: 42, display: "flex", alignItems: "center", justifyContent: "space-between", gap: 10 }}>
        <span style={{ fontSize: 17, fontWeight: 900, color: C.blue }}>{$(producto.precio)}</span>
        <button type="button" disabled={agotado} onClick={() => onAdd(producto)} style={{ minHeight: 42, padding: "8px 13px", border: 0, borderRadius: 9, background: agotado ? C.border : C.blue, color: agotado ? C.textDim : "#fff", fontSize: 12, fontWeight: 850, cursor: agotado ? "not-allowed" : "pointer" }}>Agregar</button>
      </div>
    </article>
  );
}

function Seccion({ titulo, productos, diferencia, ...props }) {
  if (!productos?.length) return null;
  return (
    <section style={{ marginTop: 8 }}>
      <div style={{ fontSize: 12, fontWeight: 900, color: C_LIGHT.text }}>{titulo}</div>
      <div className="pos-related-products-grid" style={{ display: "grid", gridTemplateColumns: "repeat(2, minmax(0, 1fr))", gap: 8, marginTop: 5 }}>
        {productos.map((p) => <TarjetaProducto key={p.id} producto={p} diferencia={typeof diferencia === "function" ? diferencia(p) : diferencia} {...props} />)}
      </div>
    </section>
  );
}

export default function TableroEquivalentes({ grupo, onSelect, onAdd, estadoStock }) {
  if (!grupo?.total) return null;
  const otras = [...(grupo.otroContenido || []), ...(grupo.otrasPresentaciones || [])];
  const idsOtroContenido = new Set((grupo.otroContenido || []).map((p) => p.id));
  return (
    <div style={{ border: `1px solid ${C_LIGHT.border}`, borderRadius: 14, background: C_LIGHT.bg, padding: 10, marginBottom: 10 }}>
      <div style={{ fontSize: 16, fontWeight: 900, color: C_LIGHT.text }}>{grupo.total} opciones con {etiquetaSustanciaVisible(grupo.etiqueta)}</div>
      <Seccion titulo="Misma presentación" productos={grupo.mismaConfiguracion} onSelect={onSelect} onAdd={onAdd} estadoStock={estadoStock} />
      <Seccion titulo="Otras presentaciones" productos={otras} diferencia={(p) => idsOtroContenido.has(p.id) ? "Cambia contenido" : "Cambia forma, vía o concentración"} onSelect={onSelect} onAdd={onAdd} estadoStock={estadoStock} />
      <style>{`@media (min-width: 1180px){.pos-related-products-grid{grid-template-columns:repeat(4,minmax(0,1fr))!important}} @media (max-width: 620px){.pos-related-products-grid{grid-template-columns:1fr!important}}`}</style>
    </div>
  );
}
