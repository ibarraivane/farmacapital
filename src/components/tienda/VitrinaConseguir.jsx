import { useMemo } from "react";
import { PackageSearch } from "lucide-react";
import { BRAND } from "../../constants";
import RecompraStrip from "../RecompraStrip";
import {
  RUBROS_BAJO_PEDIDO,
  TEXTO_RESERVA,
  copyMarcasSeccion,
  filtrarSeccion,
  filtrarVitrina,
  seccionConseguirPorId,
} from "../../lib/bajoPedido";

/**
 * Página de categoría: Dermocosmética o Vitaminas y suplementos.
 */
export default function VitrinaConseguir({
  productos,
  loading,
  stack,
  renderProducto,
  onIrAFormulario,
  seccion = "",
  rubro = "",
  setPage,
  formulario = null,
}) {
  const sec = seccionConseguirPorId(seccion);
  const rubrosSeccion = sec ? RUBROS_BAJO_PEDIDO.filter((r) => sec.rubros.includes(r.id)) : [];
  const esDerma = sec?.id === "dermatologia";
  const esNutri = sec?.id === "nutricion";

  const pool = useMemo(
    () => filtrarSeccion(productos, seccion, { incluirAnaquel: false }),
    [productos, seccion]
  );
  const lista = useMemo(
    () => (rubro ? filtrarSeccion(productos, seccion, { rubro, incluirAnaquel: false }) : pool),
    [productos, seccion, rubro, pool]
  );
  const conteo = useMemo(() => {
    const m = { "": pool.length };
    rubrosSeccion.forEach((r) => {
      m[r.id] = filtrarVitrina(productos, r.id).length;
    });
    return m;
  }, [productos, pool.length, rubrosSeccion]);

  const hayAlgo = pool.length > 0;
  const vacio = !loading && !hayAlgo;
  const copyMarcas = copyMarcasSeccion(productos, seccion);

  const irChip = (id) => {
    if (typeof setPage !== "function" || !sec) return;
    setPage(sec.page, { rubro: id, replace: true, search: "" });
  };

  const chip = (id, label) => {
    const on = rubro === id;
    return (
      <button
        key={id || "todos"}
        type="button"
        role="tab"
        aria-selected={on}
        onClick={() => irChip(id)}
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

  const titulo = sec ? sec.titulo : "Pedidos especiales";
  const formLink = typeof onIrAFormulario === "function" ? (
    <button
      type="button"
      onClick={onIrAFormulario}
      style={{
        background: "none",
        border: "none",
        padding: 0,
        color: BRAND.secondary,
        fontWeight: 700,
        cursor: "pointer",
        fontSize: 14,
        fontFamily: "inherit",
      }}
    >
      ¿No está en la lista? Pídelo aquí
    </button>
  ) : null;

  const grid = (items) =>
    items.length ? (
      <div
        style={{
          display: "grid",
          gap: stack ? 16 : 18,
          gridTemplateColumns: stack ? "1fr" : "repeat(auto-fill, minmax(min(100%, 220px), 1fr))",
          alignItems: "stretch",
          marginBottom: 12,
        }}
      >
        {items.map((p) => renderProducto(p))}
      </div>
    ) : (
      <div style={{ color: "#64748b", fontSize: 14, padding: "8px 0 20px" }}>
        Aún no hay productos en este rubro. Pídelo en el formulario.
      </div>
    );

  return (
    <section style={{ maxWidth: 1200, margin: "0 auto", padding: "clamp(20px,4vw,32px) 16px 8px" }} aria-labelledby="vitrina-conseguir-titulo">
      <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 6 }}>
        <div style={{ width: 40, height: 40, borderRadius: 12, background: BRAND.gradient, display: "grid", placeItems: "center", color: "#fff", flexShrink: 0 }}>
          <PackageSearch size={20} aria-hidden />
        </div>
        <h1 id="vitrina-conseguir-titulo" style={{ margin: 0, fontSize: "clamp(22px,5vw,26px)", fontWeight: 800, color: "#0f172a" }}>
          {titulo}
        </h1>
      </div>
      {sec?.subtitulo ? (
        <p style={{ margin: "0 0 8px", color: "#0f172a", fontWeight: 700, fontSize: 15 }}>{sec.subtitulo}</p>
      ) : null}
      <p style={{ margin: "0 0 8px", color: "#475569", fontSize: 14, lineHeight: 1.6, maxWidth: 760 }}>
        {copyMarcas} {TEXTO_RESERVA}
      </p>
      {!vacio ? <p style={{ margin: "0 0 14px", fontSize: 14 }}>{formLink}</p> : null}

      {vacio ? (
        <>
          <p style={{ color: "#64748b", fontSize: 14, margin: "0 0 16px" }}>
            Aún no hay productos en esta página. Cuéntanos qué necesitas.
          </p>
          {formulario}
        </>
      ) : null}

      {loading && !hayAlgo ? (
        <div style={{ color: "#64748b", fontSize: 14, padding: "12px 0 24px" }}>Cargando productos…</div>
      ) : null}

      {esNutri && rubrosSeccion.length > 1 ? (
        <div role="tablist" aria-label="Rubros" style={{ display: "flex", gap: 8, overflowX: "auto", paddingBottom: 6, marginBottom: 16 }}>
          {chip("", "Todos")}
          {rubrosSeccion.map((r) => chip(r.id, r.label))}
        </div>
      ) : null}

      {!vacio && (rubro || esDerma) ? (
        grid(lista)
      ) : null}

      {!vacio && !rubro && esNutri
        ? rubrosSeccion.map((r) => {
            const items = filtrarVitrina(productos, r.id);
            if (!items.length) return null;
            return (
              <RecompraStrip
                key={r.id}
                title={r.label}
                actionLabel="Ver todo"
                onAction={() => irChip(r.id)}
              >
                {items.map((p) => renderProducto(p))}
              </RecompraStrip>
            );
          })
        : null}

      {!vacio ? formulario : null}
    </section>
  );
}
