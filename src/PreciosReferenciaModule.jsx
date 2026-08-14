import { useState, useEffect, useCallback, useMemo } from "react";
import { C_LIGHT } from "./constants";
import { supabase } from "./supabase";
import { showToast, HorizontalScrollSync, SkeletonTable } from "./ui";
import {
  FUENTES_COMPRA,
  FUENTES_VENTA,
  FUENTE_META,
  buildReferenciasPorProducto,
  dedupeReferenciasActuales,
  diffPctCompra,
  diffPctVenta,
  calcMejorCompra,
  calcPrecioSugeridoVenta,
  colorDiffCompra,
  colorDiffVenta,
  fmtPrecioRef,
} from "./lib/preciosReferencia";
import { inventarioProductMatchesBusqueda } from "./utils/fuzzySearch";
import ImportReferenciaPrecios from "./components/ImportReferenciaPrecios";

const BRAND = { primary: "#0D1B2A", gradient: "linear-gradient(135deg,#0D1B2A,#1E3ABA)" };

function DiffBadge({ pct, mode, C }) {
  if (pct == null) return <span style={{ color: C.textDim }}>—</span>;
  const tone = mode === "compra" ? colorDiffCompra(pct) : colorDiffVenta(pct);
  const col =
    tone === "oportunidad" || tone === "ok" ? C.green :
    tone === "caro" ? C.red : C.textMid;
  const bg =
    tone === "oportunidad" || tone === "ok" ? C.greenDim :
    tone === "caro" ? C.redDim : C.cardDark;
  const prefix = parseFloat(pct) > 0 ? "+" : "";
  return (
    <span style={{ padding: "2px 7px", borderRadius: 20, fontSize: 10, fontWeight: 700, color: col, background: bg }}>
      {prefix}{pct}%
    </span>
  );
}

function TablaCompra({ productos, refsByProduct, C, busq }) {
  const fil = productos.filter((p) => inventarioProductMatchesBusqueda(p, busq));

  return (
    <HorizontalScrollSync>
      <table style={{ width: "100%", minWidth: 1100, borderCollapse: "collapse", fontSize: 12 }}>
        <thead>
          <tr style={{ background: C.cardDark }}>
            <th style={th(C)}>Producto</th>
            <th style={th(C)}>SKU</th>
            <th style={{ ...th(C), textAlign: "right" }}>Tu costo</th>
            {FUENTES_COMPRA.map((id) => (
              <th key={id} style={{ ...th(C), textAlign: "right" }} title={FUENTE_META[id]?.listaDistribuidor ? "Precio lista distribuidor" : ""}>
                {FUENTE_META[id]?.label}
              </th>
            ))}
            <th style={th(C)}>Mejor proveedor</th>
          </tr>
        </thead>
        <tbody>
          {!fil.length && (
            <tr><td colSpan={4 + FUENTES_COMPRA.length} style={{ textAlign: "center", padding: 32, color: C.textMid }}>Sin productos</td></tr>
          )}
          {fil.map((p, i) => {
            const refs = refsByProduct[p.id] || {};
            const mejor = calcMejorCompra(p.costo, refs);

            return (
              <tr key={p.id} style={{ background: i % 2 ? "#f8fafc" : "transparent" }}>
                <td style={td(C)}>{p.nombre}</td>
                <td style={{ ...td(C), fontFamily: "monospace", fontSize: 10, color: C.textMid }}>{p.sku || "—"}</td>
                <td style={{ ...td(C), textAlign: "right", fontWeight: 700 }}>{fmtPrecioRef(p.costo)}</td>
                {FUENTES_COMPRA.map((id) => {
                  const precio = refs[id]?.precio;
                  const pct = diffPctCompra(p.costo, precio);
                  const tone = colorDiffCompra(pct);
                  const col =
                    tone === "oportunidad" ? C.blue :
                    tone === "caro" ? C.red : C.textMid;
                  return (
                    <td key={id} style={{ ...td(C), textAlign: "right" }}>
                      {precio != null ? (
                        <div>
                          <span style={{ color: col, fontWeight: 600 }}>{fmtPrecioRef(precio)}</span>
                          <div><DiffBadge pct={pct} mode="compra" C={C} /></div>
                        </div>
                      ) : "—"}
                    </td>
                  );
                })}
                <td style={td(C)}>
                  {mejor ? (
                    <span style={{
                      fontWeight: 700,
                      color: mejor.masBaratoQueTuCosto ? C.blue : C.text,
                    }}>
                      {mejor.label}
                      {mejor.masBaratoQueTuCosto && mejor.ahorro != null ? (
                        <span style={{ fontSize: 10, color: C.blue, marginLeft: 4 }}>
                          (−{fmtPrecioRef(mejor.ahorro)})
                        </span>
                      ) : null}
                    </span>
                  ) : (
                    <span style={{ color: C.textDim, fontSize: 11 }}>Sin datos</span>
                  )}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </HorizontalScrollSync>
  );
}

function TablaVenta({ productos, refsByProduct, C, busq, onAplicar, applyingId }) {
  const fil = productos.filter((p) => inventarioProductMatchesBusqueda(p, busq));

  return (
    <HorizontalScrollSync>
      <table style={{ width: "100%", minWidth: 960, borderCollapse: "collapse", fontSize: 12 }}>
        <thead>
          <tr style={{ background: C.cardDark }}>
            <th style={th(C)}>Producto</th>
            <th style={{ ...th(C), textAlign: "right" }}>Tu venta</th>
            <th style={{ ...th(C), textAlign: "right" }}>Del Ahorro</th>
            <th style={{ ...th(C), textAlign: "right" }}>Similares</th>
            <th style={{ ...th(C), textAlign: "right" }}>Ref. mín.</th>
            <th style={{ ...th(C), textAlign: "right" }}>Sugerido</th>
            <th style={th(C)}>Nota</th>
            <th style={th(C)}>Acción</th>
          </tr>
        </thead>
        <tbody>
          {!fil.length && (
            <tr><td colSpan={8} style={{ textAlign: "center", padding: 32, color: C.textMid }}>Sin productos</td></tr>
          )}
          {fil.map((p, i) => {
            const refs = refsByProduct[p.id] || {};
            const fah = refs.fahorro?.precio;
            const sim = refs.similares?.precio;
            const dAho = diffPctVenta(p.precio, fah);
            const dSim = diffPctVenta(p.precio, sim);
            const { sugerido, refMin, nota } = calcPrecioSugeridoVenta(p, refs);
            const puedeAplicar = sugerido != null && Math.abs((parseFloat(p.precio) || 0) - sugerido) >= 0.01;

            return (
              <tr key={p.id} style={{ background: i % 2 ? "#f8fafc" : "transparent" }}>
                <td style={td(C)}>{p.nombre}</td>
                <td style={{ ...td(C), textAlign: "right", fontWeight: 700, color: BRAND.primary }}>{fmtPrecioRef(p.precio)}</td>
                <td style={{ ...td(C), textAlign: "right" }}>
                  {fah != null ? (
                    <>
                      <div>{fmtPrecioRef(fah)}</div>
                      <DiffBadge pct={dAho} mode="venta" C={C} />
                    </>
                  ) : "—"}
                </td>
                <td style={{ ...td(C), textAlign: "right" }}>
                  {sim != null ? (
                    <>
                      <div>{fmtPrecioRef(sim)}</div>
                      <DiffBadge pct={dSim} mode="venta" C={C} />
                    </>
                  ) : "—"}
                </td>
                <td style={{ ...td(C), textAlign: "right", color: C.textMid }}>
                  {refMin != null ? fmtPrecioRef(refMin) : "—"}
                </td>
                <td style={{ ...td(C), textAlign: "right", fontWeight: 800, color: sugerido != null ? C.green : C.textDim }}>
                  {sugerido != null ? fmtPrecioRef(sugerido) : "—"}
                </td>
                <td style={{ ...td(C), fontSize: 10, color: C.textMid, maxWidth: 140 }}>{nota}</td>
                <td style={td(C)}>
                  {puedeAplicar ? (
                    <button
                      type="button"
                      disabled={applyingId === p.id}
                      onClick={() => onAplicar(p, sugerido)}
                      style={{
                        padding: "4px 10px", borderRadius: 6, border: "none",
                        background: BRAND.gradient, color: "#fff", cursor: "pointer",
                        fontSize: 11, fontWeight: 700, opacity: applyingId === p.id ? 0.6 : 1,
                      }}
                    >
                      {applyingId === p.id ? "…" : "Aplicar"}
                    </button>
                  ) : (
                    <span style={{ color: C.textDim, fontSize: 10 }}>—</span>
                  )}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </HorizontalScrollSync>
  );
}

const th = (C) => ({
  padding: "9px 12px",
  textAlign: "left",
  color: C.textMid,
  fontWeight: 700,
  borderBottom: `1px solid ${C.border}`,
  whiteSpace: "nowrap",
});

const td = (C) => ({
  padding: "8px 12px",
  borderBottom: `1px solid ${C.border}`,
  color: C.text,
  verticalAlign: "top",
});

export default function PreciosReferenciaModule() {
  const C = C_LIGHT;
  const [tab, setTab] = useState("compra");
  const [productos, setProductos] = useState([]);
  const [refsByProduct, setRefsByProduct] = useState({});
  const [loading, setLoading] = useState(true);
  const [schemaOk, setSchemaOk] = useState(true);
  const [busq, setBusq] = useState("");
  const [applyingId, setApplyingId] = useState(null);

  const fetchAll = useCallback(async () => {
    setLoading(true);
    const prodRes = await supabase
      .from("productos")
      .select("id,sku,nombre,categoria,tipo,costo,precio,principio_activo,forma_farmaceutica,requiere_receta,marca")
      .eq("activo", true)
      .order("nombre");

    if (prodRes.error) {
      showToast("Error cargando productos: " + prodRes.error.message, "error");
      setLoading(false);
      return;
    }
    setProductos(prodRes.data || []);

    let refRows = [];
    const viewRes = await supabase.from("producto_precios_referencia_actual").select("*");
    if (viewRes.error) {
      const rawRes = await supabase
        .from("producto_precios_referencia")
        .select("producto_id,fuente,tipo,precio,fecha,origen,confianza,created_at,nombre_fuente")
        .order("fecha", { ascending: false })
        .limit(10000);
      if (rawRes.error) {
        setSchemaOk(false);
        setRefsByProduct({});
        setLoading(false);
        return;
      }
      refRows = dedupeReferenciasActuales(rawRes.data);
    } else {
      refRows = viewRes.data || [];
    }

    setSchemaOk(true);
    setRefsByProduct(buildReferenciasPorProducto(refRows));
    setLoading(false);
  }, []);

  useEffect(() => { fetchAll(); }, [fetchAll]);

  const stats = useMemo(() => {
    let compraOportunidad = 0;
    let ventaCaro = 0;
    let sinRefCompra = 0;
    let sinRefVenta = 0;

    for (const p of productos) {
      const refs = refsByProduct[p.id] || {};
      const mejor = calcMejorCompra(p.costo, refs);
      if (mejor?.masBaratoQueTuCosto) compraOportunidad += 1;
      if (!FUENTES_COMPRA.some((f) => refs[f]?.precio != null)) sinRefCompra += 1;

      const { refMin } = calcPrecioSugeridoVenta(p, refs);
      if (refMin == null) sinRefVenta += 1;
      else if ((parseFloat(p.precio) || 0) > refMin) ventaCaro += 1;
    }

    return { compraOportunidad, ventaCaro, sinRefCompra, sinRefVenta };
  }, [productos, refsByProduct]);

  const aplicarPrecio = async (producto, sugerido) => {
    const ok = window.confirm(
      `¿Aplicar precio sugerido ${fmtPrecioRef(sugerido)} a «${producto.nombre}»?\n\nTu precio actual: ${fmtPrecioRef(producto.precio)}`
    );
    if (!ok) return;

    setApplyingId(producto.id);
    const tok = sessionStorage.getItem("farmacapital_session_token");
    const { error } = await supabase.rpc("admin_editar_producto", {
      p_session_token: tok,
      p_producto_id: producto.id,
      p_patch: { precio: sugerido },
    });
    setApplyingId(null);

    if (error) {
      showToast("Error: " + error.message, "error");
      return;
    }
    showToast("Precio actualizado", "success");
    setProductos((prev) =>
      prev.map((x) => (x.id === producto.id ? { ...x, precio: sugerido } : x))
    );
  };

  const inpS = {
    padding: "8px 12px",
    borderRadius: 8,
    border: `1px solid ${C.border}`,
    fontSize: 13,
    outline: "none",
    background: C.card,
    color: C.text,
  };

  return (
    <div style={{ padding: "0 24px 24px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", flexWrap: "wrap", gap: 12, marginBottom: 16 }}>
        <div>
          <h2 style={{ margin: 0, color: C.text, fontSize: 18, fontWeight: 800 }}>Referencias de precio</h2>
          <p style={{ margin: "6px 0 0", color: C.textMid, fontSize: 12, maxWidth: 640, lineHeight: 1.45 }}>
            Precios de mercado (compra y venta). Las referencias se actualizan al importar listas o correr el job de Similares.
            Tu <strong>costo</strong> y <strong>precio de venta</strong> solo cambian con confirmación explícita.
          </p>
        </div>
        <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
          <ImportReferenciaPrecios productos={productos} onImported={fetchAll} />
          <button type="button" onClick={fetchAll} style={{
          padding: "8px 14px", borderRadius: 8, border: `1px solid ${C.border}`,
          background: C.card, color: C.textMid, fontWeight: 700, fontSize: 12, cursor: "pointer",
        }}>
          ↻ Actualizar
        </button>
        </div>
      </div>

      {!schemaOk && (
        <div style={{
          marginBottom: 16, padding: 14, borderRadius: 10,
          background: C.amberDim, border: `1px solid ${C.amber}`, color: C.amber, fontSize: 12,
        }}>
          ⚠️ Falta ejecutar el SQL de referencias en Supabase:{" "}
          <code style={{ fontSize: 11 }}>sql/patch_producto_precios_referencia.sql</code>
          {" "}y opcionalmente{" "}
          <code style={{ fontSize: 11 }}>sql/migrate_precios_competencia_a_referencias.sql</code>
        </div>
      )}

      <div style={{ display: "flex", gap: 8, marginBottom: 16, flexWrap: "wrap" }}>
        <span style={{ padding: "4px 12px", borderRadius: 20, fontSize: 11, fontWeight: 700, background: "#dbeafe", color: C.blue }}>
          Compra más barata disponible: {stats.compraOportunidad}
        </span>
        <span style={{ padding: "4px 12px", borderRadius: 20, fontSize: 11, fontWeight: 700, background: C.redDim, color: C.red }}>
          Venta más cara que ref.: {stats.ventaCaro}
        </span>
        <span style={{ padding: "4px 12px", borderRadius: 20, fontSize: 11, fontWeight: 700, background: C.cardDark, color: C.textMid }}>
          Sin ref. compra: {stats.sinRefCompra}
        </span>
        <span style={{ padding: "4px 12px", borderRadius: 20, fontSize: 11, fontWeight: 700, background: C.cardDark, color: C.textMid }}>
          Sin ref. venta: {stats.sinRefVenta}
        </span>
      </div>

      <div style={{ display: "flex", gap: 4, marginBottom: 16, borderBottom: `1px solid ${C.border}` }}>
        {[["compra", "🛒 Compra (proveedores)"], ["venta", "🏪 Venta (competencia)"]].map(([id, label]) => (
          <button
            key={id}
            type="button"
            onClick={() => setTab(id)}
            style={{
              padding: "8px 18px", border: "none", cursor: "pointer", fontWeight: 700, fontSize: 12,
              borderRadius: "8px 8px 0 0", background: "transparent",
              color: tab === id ? BRAND.primary : C.textMid,
              borderBottom: tab === id ? `2px solid ${BRAND.primary}` : "2px solid transparent",
            }}
          >
            {label}
          </button>
        ))}
      </div>

      <div style={{ marginBottom: 12 }}>
        <input
          placeholder="🔍 Buscar producto…"
          value={busq}
          onChange={(e) => setBusq(e.target.value)}
          style={{ ...inpS, maxWidth: 280 }}
        />
      </div>

      {tab === "compra" && (
        <p style={{ fontSize: 11, color: C.textDim, marginBottom: 10 }}>
          Azul = proveedor más barato que tu costo · Rojo = más caro.
          Nadro/Marzam = precio lista distribuidor, no precio de mercado libre.
        </p>
      )}

      {loading ? (
        <SkeletonTable rows={8} cols={8} />
      ) : tab === "compra" ? (
        <TablaCompra productos={productos} refsByProduct={refsByProduct} C={C} busq={busq} />
      ) : (
        <TablaVenta
          productos={productos}
          refsByProduct={refsByProduct}
          C={C}
          busq={busq}
          onAplicar={aplicarPrecio}
          applyingId={applyingId}
        />
      )}

      <p style={{ marginTop: 16, fontSize: 11, color: C.textDim }}>
        Scripts locales: <code>python3 scripts/importar_referencias_precio.py --fuente exprezo --archivo … --apply</code>
        {" · "}
        <code>python3 scripts/sync_precios_similares.py --apply --limit 50</code>
      </p>
    </div>
  );
}
