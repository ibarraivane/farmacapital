import { useState, useEffect, useCallback } from "react";
import { C_LIGHT, BRAND } from "./constants";
import { supabase } from "./supabase";
import { Box, Btn, showToast } from "./ui";
import { CONSULTA_PRECIO_DEFAULT } from "./utils/consultaConstants";
import { CATEGORIAS_CONSUMIBLE_CONSULTORIO_SUGERIDAS } from "./utils/consumiblesConsultorio";

const C = C_LIGHT;

async function upsertConfig(clave, valor) {
  const { data: ex } = await supabase.from("configuracion").select("id").eq("clave", clave).maybeSingle();
  if (ex?.id) {
    const { error } = await supabase.from("configuracion").update({ valor: String(valor) }).eq("id", ex.id);
    return error;
  }
  const { error } = await supabase.from("configuracion").insert({ clave, valor: String(valor) });
  return error;
}

const DEFAULT_ESTIMADO_RECETA_EXTERNA = 350;

const METAS_DEF = {
  meta_ventas_dia:     { def: 3000,  label: "Ventas diarias",     hint: "Objetivo de ingresos en caja por día",     unidad: "$", grupo: "ventas" },
  meta_ventas_semana:  { def: 20000, label: "Ventas semanales",   hint: "Objetivo de ingresos últimos 7 días",       unidad: "$", grupo: "ventas" },
  meta_ventas_mes:     { def: 80000, label: "Ventas mensuales",   hint: "Objetivo de ingresos del mes en curso",     unidad: "$", grupo: "ventas" },
  meta_ticket_prom:    { def: 250,   label: "Ticket promedio",    hint: "Objetivo de importe promedio por venta",    unidad: "$", grupo: "ventas" },
  meta_consultas_dia:  { def: 8,     label: "Consultas por día",  hint: "Objetivo de citas completadas por día",      unidad: "#", grupo: "consultas" },
  meta_consultas_mes:  { def: 180,   label: "Consultas por mes",  hint: "Objetivo de citas completadas en el mes",    unidad: "#", grupo: "consultas" },
};
const METAS_KEYS = Object.keys(METAS_DEF);

const fmtMXN = (n) => `$${Number(n).toLocaleString("es-MX")}`;

function TabButton({ active, onClick, children }) {
  return (
    <button
      type="button"
      onClick={onClick}
      style={{
        padding: "9px 16px",
        borderRadius: 8,
        border: `1px solid ${active ? BRAND.primary : C.border}`,
        background: active ? BRAND.primary + "16" : "transparent",
        color: active ? BRAND.primary : C.textMid,
        fontSize: 13,
        fontWeight: 700,
        cursor: "pointer",
      }}
    >
      {children}
    </button>
  );
}

function InputMeta({ clave, valor, onChange }) {
  const def = METAS_DEF[clave];
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 4 }}>
      <label style={{ color: C.textMid, fontSize: 11, fontWeight: 700 }}>{def.label.toUpperCase()}</label>
      <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
        <span style={{ color: C.textDim, fontWeight: 700, fontSize: 15, width: 14 }}>{def.unidad}</span>
        <input
          type="number"
          min="0"
          step={def.unidad === "$" ? "50" : "1"}
          value={valor}
          onChange={(e) => onChange(clave, e.target.value)}
          style={{
            width: "100%",
            maxWidth: 200,
            padding: "10px 12px",
            borderRadius: 8,
            border: `1px solid ${C.border}`,
            fontSize: 15,
            fontWeight: 700,
            background: "#fff",
            color: C.text,
          }}
        />
      </div>
      <div style={{ color: C.textDim, fontSize: 11 }}>
        {def.hint} · Sugerencia: <strong>{def.unidad === "$" ? fmtMXN(def.def) : def.def}</strong>
      </div>
    </div>
  );
}

export default function ConfigConsultorioModule() {
  const [tab, setTab] = useState("metas");

  // Metas
  const [metas, setMetas] = useState(() => {
    const init = {};
    METAS_KEYS.forEach((k) => { init[k] = String(METAS_DEF[k].def); });
    return init;
  });

  // Precios y ajustes
  const [precio, setPrecio] = useState(String(CONSULTA_PRECIO_DEFAULT));
  const [estimadoRecetaExterna, setEstimadoRecetaExterna] = useState(String(DEFAULT_ESTIMADO_RECETA_EXTERNA));
  const [cats, setCats] = useState(() => new Set(["Botiquín"]));

  const [guardando, setGuard] = useState(false);

  const cargar = useCallback(async () => {
    const claves = [
      "precio_consulta",
      "consumibles_categorias",
      "estimado_receta_externa",
      ...METAS_KEYS,
    ];
    const { data } = await supabase.from("configuracion").select("clave,valor").in("clave", claves);
    const map = Object.fromEntries((data || []).map((r) => [r.clave, r.valor]));

    if (map.precio_consulta) {
      const n = parseFloat(map.precio_consulta);
      if (Number.isFinite(n) && n > 0) setPrecio(String(n));
    }
    if (map.estimado_receta_externa) {
      const n = parseFloat(map.estimado_receta_externa);
      if (Number.isFinite(n) && n >= 0) setEstimadoRecetaExterna(String(n));
    }
    if (map.consumibles_categorias) {
      try {
        const j = JSON.parse(map.consumibles_categorias);
        if (Array.isArray(j) && j.length) setCats(new Set(j.map(String)));
      } catch {
        /* keep default */
      }
    }

    setMetas((prev) => {
      const next = { ...prev };
      METAS_KEYS.forEach((k) => {
        if (map[k] != null) {
          const n = parseFloat(map[k]);
          if (Number.isFinite(n) && n > 0) next[k] = String(n);
        }
      });
      return next;
    });
  }, []);

  useEffect(() => { cargar(); }, [cargar]);

  const toggleCat = (c) => {
    setCats((prev) => {
      const n = new Set(prev);
      if (n.has(c)) n.delete(c);
      else n.add(c);
      return n;
    });
  };

  const setMeta = (k, v) => setMetas((p) => ({ ...p, [k]: v }));

  const guardarMetas = async () => {
    for (const k of METAS_KEYS) {
      const n = parseFloat(metas[k]);
      if (!Number.isFinite(n) || n <= 0) {
        showToast(`Indica un valor válido (> 0) para "${METAS_DEF[k].label}".`, "warning");
        return;
      }
    }
    setGuard(true);
    try {
      for (const k of METAS_KEYS) {
        const err = await upsertConfig(k, String(parseFloat(metas[k])));
        if (err) throw err;
      }
      showToast("Metas guardadas. El Dashboard las mostrará al recargar.", "success");
    } catch (e) {
      console.error(e);
      showToast("No se pudo guardar: " + (e?.message || e), "error");
    }
    setGuard(false);
  };

  const guardarPrecios = async () => {
    const n = parseFloat(precio);
    if (!Number.isFinite(n) || n <= 0) {
      showToast("Indica un precio de consulta válido.", "warning");
      return;
    }
    const est = parseFloat(estimadoRecetaExterna);
    if (!Number.isFinite(est) || est < 0) {
      showToast("Indica un estimado válido para receta surtida fuera (puede ser 0).", "warning");
      return;
    }
    if (cats.size === 0) {
      showToast("Selecciona al menos una categoría de consumibles para consultorio.", "warning");
      return;
    }
    setGuard(true);
    try {
      const e1 = await upsertConfig("precio_consulta", String(n));
      const e2 = await upsertConfig("consumibles_categorias", JSON.stringify([...cats]));
      const e3 = await upsertConfig("estimado_receta_externa", String(est));
      if (e1 || e2 || e3) throw e1 || e2 || e3;
      showToast("Ajustes guardados. El POS y la tienda usarán el nuevo precio al recargar.", "success");
    } catch (e) {
      console.error(e);
      showToast("No se pudo guardar: " + (e?.message || e), "error");
    }
    setGuard(false);
  };

  return (
    <div style={{ padding: 24, maxWidth: 820 }}>
      <h1 style={{ color: C.text, fontSize: 20, fontWeight: 800, margin: "0 0 8px" }}>🎯 Metas y Precios</h1>
      <p style={{ color: C.textMid, fontSize: 13, marginBottom: 20, lineHeight: 1.5 }}>
        Ajusta las <strong>metas</strong> que alimentan el Dashboard (ventas, ticket, consultas) y los <strong>precios</strong> usados por el POS, la tienda y el consultorio.
      </p>

      <div style={{ display: "flex", gap: 8, marginBottom: 20, flexWrap: "wrap" }}>
        <TabButton active={tab === "metas"} onClick={() => setTab("metas")}>🎯 Metas operativas</TabButton>
        <TabButton active={tab === "precios"} onClick={() => setTab("precios")}>💰 Precios y ajustes</TabButton>
      </div>

      {tab === "metas" && (
        <>
          <Box style={{ padding: 20, marginBottom: 16 }}>
            <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1, marginBottom: 14 }}>METAS DE VENTAS</div>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(240px,1fr))", gap: 16 }}>
              {METAS_KEYS.filter((k) => METAS_DEF[k].grupo === "ventas").map((k) => (
                <InputMeta key={k} clave={k} valor={metas[k]} onChange={setMeta} />
              ))}
            </div>
          </Box>

          <Box style={{ padding: 20, marginBottom: 16 }}>
            <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1, marginBottom: 14 }}>METAS DE CONSULTAS</div>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(240px,1fr))", gap: 16 }}>
              {METAS_KEYS.filter((k) => METAS_DEF[k].grupo === "consultas").map((k) => (
                <InputMeta key={k} clave={k} valor={metas[k]} onChange={setMeta} />
              ))}
            </div>
          </Box>

          <Box style={{ padding: 16, marginBottom: 20, background: C.blueDim, border: `1px solid ${C.blue}25` }}>
            <div style={{ color: C.blue, fontSize: 12, fontWeight: 700, marginBottom: 4 }}>💡 ¿Cómo se usan estas metas?</div>
            <ul style={{ color: C.textMid, fontSize: 12, margin: 0, paddingLeft: 18, lineHeight: 1.55 }}>
              <li>Cada KPI del Dashboard muestra una <strong>barra de progreso</strong> con el % de cumplimiento contra la meta.</li>
              <li>La meta mensual se <strong>prorratea</strong> según el día del mes transcurrido para darte un semáforo honesto día a día.</li>
              <li>La sección <em>"Lo que necesitas hacer hoy"</em> usa los mismos datos para priorizar acciones.</li>
            </ul>
          </Box>

          <Btn col={BRAND.primary} onClick={guardarMetas} dis={guardando}>
            {guardando ? "Guardando…" : "Guardar metas"}
          </Btn>
        </>
      )}

      {tab === "precios" && (
        <>
          <Box style={{ padding: 20, marginBottom: 16 }}>
            <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1, marginBottom: 10 }}>PRECIO DE LA CONSULTA (MXN)</div>
            <input
              type="number"
              min="1"
              step="1"
              value={precio}
              onChange={(e) => setPrecio(e.target.value)}
              style={{
                width: "100%",
                maxWidth: 200,
                padding: "10px 12px",
                borderRadius: 8,
                border: `1px solid ${C.border}`,
                fontSize: 16,
                fontWeight: 700,
              }}
            />
            <div style={{ color: C.textDim, fontSize: 11, marginTop: 8 }}>
              Valor por defecto en sistema: ${CONSULTA_PRECIO_DEFAULT}. Debe coincidir con lo que cobras en caja y con la tienda en línea.
            </div>
          </Box>

          <Box style={{ padding: 20, marginBottom: 16 }}>
            <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1, marginBottom: 10 }}>ESTIMADO — RECETA SURTIDA FUERA DE FARMAX (MXN)</div>
            <p style={{ color: C.textMid, fontSize: 12, marginBottom: 12, lineHeight: 1.45 }}>
              Cuando en la ficha de consulta se indica que la receta se surtió en otra farmacia, el dashboard multiplica ese número de citas por este monto para mostrar una <strong>oportunidad perdida aproximada</strong>. Ajústalo al ticket promedio que suelen llevar esas recetas.
            </p>
            <input
              type="number"
              min="0"
              step="10"
              value={estimadoRecetaExterna}
              onChange={(e) => setEstimadoRecetaExterna(e.target.value)}
              style={{
                width: "100%",
                maxWidth: 200,
                padding: "10px 12px",
                borderRadius: 8,
                border: `1px solid ${C.border}`,
                fontSize: 16,
                fontWeight: 700,
              }}
            />
            <div style={{ color: C.textDim, fontSize: 11, marginTop: 8 }}>Por defecto en sistema: ${DEFAULT_ESTIMADO_RECETA_EXTERNA} MXN.</div>
          </Box>

          <Box style={{ padding: 20, marginBottom: 16 }}>
            <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1, marginBottom: 10 }}>CATEGORÍAS DE PRODUCTOS = CONSUMIBLES EN CONSULTORIO</div>
            <p style={{ color: C.textMid, fontSize: 12, marginBottom: 12, lineHeight: 1.45 }}>
              En <strong>Inventario</strong>, asigna estos productos a una de estas categorías (o crea categorías con el mismo nombre). Solo aparecerán como consumibles en la ficha de la doctora: gasas, jeringas, guantes, material de curación — no analgésicos ni antibióticos de venta.
            </p>
            <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
              {CATEGORIAS_CONSUMIBLE_CONSULTORIO_SUGERIDAS.map((c) => (
                <label key={c} style={{ display: "flex", alignItems: "center", gap: 10, cursor: "pointer", fontSize: 13 }}>
                  <input type="checkbox" checked={cats.has(c)} onChange={() => toggleCat(c)} />
                  <span>{c}</span>
                </label>
              ))}
            </div>
          </Box>

          <Box style={{ padding: 16, marginBottom: 20, background: C.blueDim, border: `1px solid ${C.blue}25` }}>
            <div style={{ color: C.blue, fontSize: 12, fontWeight: 700, marginBottom: 4 }}>¿Dónde se editan los demás precios?</div>
            <ul style={{ color: C.textMid, fontSize: 12, margin: 0, paddingLeft: 18, lineHeight: 1.55 }}>
              <li><strong>Medicamentos y productos:</strong> módulo <strong>Inventario</strong> (precio de venta y costo).</li>
              <li><strong>Procedimientos</strong> (PA, glucometría, nebulización, etc.): menú <strong>Consultorio</strong> → pestaña Procedimientos.</li>
            </ul>
          </Box>

          <Btn col={BRAND.primary} onClick={guardarPrecios} dis={guardando}>
            {guardando ? "Guardando…" : "Guardar precios y ajustes"}
          </Btn>
        </>
      )}
    </div>
  );
}
