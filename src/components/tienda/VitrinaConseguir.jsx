import { useEffect, useMemo, useState } from "react";
import { ChevronLeft, PackageSearch } from "lucide-react";
import { BRAND } from "../../constants";
import RecompraStrip from "../RecompraStrip";
import EnlacesSeccionConseguir from "./EnlacesSeccionConseguir";
import {
  RUBROS_BAJO_PEDIDO,
  filtrarVitrina,
  filtrarVitrinaSeccion,
  seccionConseguirPorId,
} from "../../lib/bajoPedido";

/**
 * Vitrina de /conseguir.
 * Hub (sin sección): dos enlaces — Dermatología / Vitaminas y suplementos.
 * Sección: cuadrícula o bandas del grupo. Nutrición filtra por vitamina / suplemento / proteína.
 */
export default function VitrinaConseguir({
  productos,
  loading,
  stack,
  renderProducto,
  onIrAFormulario,
  seccion = "",
  setPage,
}) {
  const sec = seccionConseguirPorId(seccion);
  const rubrosSeccion = sec ? RUBROS_BAJO_PEDIDO.filter((r) => sec.rubros.includes(r.id)) : RUBROS_BAJO_PEDIDO;
  const [rubro, setRubro] = useState("");

  useEffect(() => {
    setRubro("");
  }, [seccion]);

  const pool = useMemo(
    () => (sec ? filtrarVitrinaSeccion(productos, sec.id) : filtrarVitrina(productos)),
    [productos, sec]
  );

  const conteo = useMemo(() => {
    const m = { "": pool.length };
    rubrosSeccion.forEach((r) => { m[r.id] = filtrarVitrina(productos, r.id).length; });
    return m;
  }, [productos, pool.length, rubrosSeccion]);

  const lista = useMemo(
    () => (rubro ? filtrarVitrina(productos, rubro) : pool),
    [productos, rubro, pool]
  );
  const hayAlgo = pool.length > 0;
  const esHub = !sec;

  const chip = (id, label) => {
    const on = rubro === id;
    return (
      <button
        key={id || "todos"}
        type="button"
        role="tab"
        aria-selected={on}
        onClick={() => setRubro(id)}
        style={{
          flexShrink: 0,
          padding: "8px 14px",
          borderRadius: 999,
          border: `1px solid ${on ? BRAND.primary : "#e2e8f0"}`,
          background: on ? BRAND.primary : "#fff",
          color: on ? "#fff" : "#334155",
          fontWeight: 700,
          fontSize: 13,
          cursor: "pointer",
          fontFamily: "inherit",
          minHeight: 40,
        }}
      >
        {label}
        {conteo[id] ? <span style={{ opacity: 0.75, marginLeft: 6 }}>{conteo[id]}</span> : null}
      </button>
    );
  };

  const titulo = sec ? sec.titulo : "Te lo conseguimos";

  return (
    <section style={{ maxWidth: 1200, margin: "0 auto", padding: "clamp(20px,4vw,32px) 16px 8px" }} aria-labelledby="vitrina-conseguir-titulo">
      {sec && typeof setPage === "function" ? (
        <button
          type="button"
          onClick={() => setPage("conseguir", { seccion: "", search: "" })}
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: 4,
            margin: "0 0 10px",
            padding: 0,
            border: "none",
            background: "none",
            color: BRAND.secondary,
            fontWeight: 700,
            fontSize: 13,
            cursor: "pointer",
            fontFamily: "inherit",
          }}
        >
          <ChevronLeft size={16} aria-hidden /> Te lo conseguimos
        </button>
      ) : null}

      <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 6 }}>
        <div style={{ width: 40, height: 40, borderRadius: 12, background: BRAND.gradient, display: "grid", placeItems: "center", color: "#fff", flexShrink: 0 }}>
          <PackageSearch size={20} aria-hidden />
        </div>
        <h1 id="vitrina-conseguir-titulo" style={{ margin: 0, fontSize: "clamp(22px,5vw,26px)", fontWeight: 800, color: "#0f172a" }}>
          {titulo}
        </h1>
      </div>
      <p style={{ margin: "0 0 14px", color: "#475569", fontSize: 14, lineHeight: 1.6, maxWidth: 760 }}>
        {sec
          ? `${sec.desc} Con precio: los encargas y apartas con tarjeta; se cobra cuando los tenemos.`
          : "Elige dermatología o vitaminas y suplementos. Traemos del mayorista en 24-48 hrs."}
        {" "}
        {typeof onIrAFormulario === "function" ? (
          <button type="button" onClick={onIrAFormulario} style={{ background: "none", border: "none", padding: 0, color: BRAND.secondary, fontWeight: 700, cursor: "pointer", fontSize: 14, fontFamily: "inherit" }}>
            ¿No está en la lista? Pídelo abajo.
          </button>
        ) : null}
      </p>

      {esHub ? (
        <div style={{ marginBottom: 22 }}>
          <EnlacesSeccionConseguir setPage={setPage} productos={productos} stack={stack} />
        </div>
      ) : null}

      {!esHub && rubrosSeccion.length > 1 ? (
        <div role="tablist" aria-label="Rubros" style={{ display: "flex", gap: 8, overflowX: "auto", paddingBottom: 6, marginBottom: 16 }}>
          {chip("", "Todos")}
          {rubrosSeccion.map((r) => chip(r.id, r.label))}
        </div>
      ) : null}

      {loading && !hayAlgo ? (
        <div style={{ color: "#64748b", fontSize: 14, padding: "12px 0 24px" }}>Cargando productos…</div>
      ) : esHub ? null : rubro || sec?.id === "dermatologia" ? (
        lista.length ? (
          <div
            style={{
              display: "grid",
              gap: stack ? 16 : 18,
              gridTemplateColumns: stack ? "1fr" : "repeat(auto-fill, minmax(min(100%, 220px), 1fr))",
              alignItems: "stretch",
              marginBottom: 12,
            }}
          >
            {lista.map((p) => renderProducto(p))}
          </div>
        ) : (
          <div style={{ color: "#64748b", fontSize: 14, padding: "8px 0 20px" }}>
            Aún no hay productos en este rubro. Pídelo en el formulario de abajo.
          </div>
        )
      ) : (
        rubrosSeccion.map((r) => {
          const items = filtrarVitrina(productos, r.id);
          return (
            <RecompraStrip
              key={r.id}
              title={r.label}
              empty={items.length === 0}
              actionLabel={items.length > 4 ? "Ver todo" : undefined}
              onAction={items.length > 4 ? () => setRubro(r.id) : undefined}
            >
              {items.map((p) => renderProducto(p))}
            </RecompraStrip>
          );
        })
      )}

      {esHub && !loading && hayAlgo ? (
        <div style={{ color: "#64748b", fontSize: 13, margin: "4px 0 8px" }}>
          {pool.length} productos bajo pedido en las dos páginas.
        </div>
      ) : null}

      {!esHub && !rubro && sec?.id !== "dermatologia" && !hayAlgo && !loading ? (
        <div style={{ color: "#64748b", fontSize: 14, padding: "8px 0 20px" }}>
          Aún no hay productos en esta página. Pídelo en el formulario de abajo.
        </div>
      ) : null}
    </section>
  );
}
