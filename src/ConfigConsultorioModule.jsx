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

/** Monto estimado (MXN) por receta de consultorio surtida fuera de Farmax — usado en dashboard. */
const DEFAULT_ESTIMADO_RECETA_EXTERNA = 350;

export default function ConfigConsultorioModule() {
  const [precio, setPrecio] = useState(String(CONSULTA_PRECIO_DEFAULT));
  const [estimadoRecetaExterna, setEstimadoRecetaExterna] = useState(String(DEFAULT_ESTIMADO_RECETA_EXTERNA));
  const [cats, setCats] = useState(() => new Set(["Botiquín"]));
  const [guardando, setGuard] = useState(false);

  const cargar = useCallback(async () => {
    const { data } = await supabase.from("configuracion").select("clave,valor").in("clave", ["precio_consulta", "consumibles_categorias", "estimado_receta_externa"]);
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
  }, []);

  useEffect(() => {
    cargar();
  }, [cargar]);

  const toggleCat = (c) => {
    setCats((prev) => {
      const n = new Set(prev);
      if (n.has(c)) n.delete(c);
      else n.add(c);
      return n;
    });
  };

  const guardar = async () => {
    const n = parseFloat(precio);
    if (!Number.isFinite(n) || n <= 0) {
      showToast("Indica un precio de consulta válido.", "warning");
      return;
    }
    if (cats.size === 0) {
      showToast("Selecciona al menos una categoría de consumibles para consultorio.", "warning");
      return;
    }
    const est = parseFloat(estimadoRecetaExterna);
    if (!Number.isFinite(est) || est < 0) {
      showToast("Indica un estimado válido para receta surtida fuera (puede ser 0).", "warning");
      return;
    }
    setGuard(true);
    try {
      const e1 = await upsertConfig("precio_consulta", String(n));
      const e2 = await upsertConfig("consumibles_categorias", JSON.stringify([...cats]));
      const e3 = await upsertConfig("estimado_receta_externa", String(est));
      if (e1 || e2 || e3) throw e1 || e2 || e3;
      showToast("Configuración guardada. La tienda y el POS usarán el nuevo precio al recargar.", "success");
    } catch (e) {
      console.error(e);
      showToast("No se pudo guardar: " + (e?.message || e), "error");
    }
    setGuard(false);
  };

  return (
    <div style={{ padding: 24, maxWidth: 720 }}>
      <h1 style={{ color: C.text, fontSize: 20, fontWeight: 800, margin: "0 0 8px" }}>⚙ Configuración del consultorio</h1>
      <p style={{ color: C.textMid, fontSize: 13, marginBottom: 24, lineHeight: 1.5 }}>
        Precio público de la consulta, categorías de productos que la doctora puede registrar como <strong>consumibles</strong> (material de curación, no el catálogo completo de medicamentos), y gestión de{" "}
        <strong>procedimientos</strong> desde el menú <strong>Consultorio</strong> (pestaña Procedimientos).
      </p>

      <Box style={{ padding: 18, marginBottom: 16 }}>
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

      <Box style={{ padding: 18, marginBottom: 16 }}>
        <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1, marginBottom: 10 }}>ESTIMADO — RECETA SURTIDA FUERA DE FARMAX (MXN)</div>
        <p style={{ color: C.textMid, fontSize: 12, marginBottom: 12, lineHeight: 1.45 }}>
          Cuando en la ficha de consulta se indica que la receta se surtió en otra farmacia, el dashboard multiplica ese número de citas por este monto para mostrar una <strong>oportunidad perdida aproximada</strong>. No es un dato contable exacto; ajústalo al ticket promedio que suelen llevar esas recetas.
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

      <Box style={{ padding: 18, marginBottom: 16 }}>
        <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1, marginBottom: 10 }}>CATEGORÍAS DE PRODUCTOS = CONSUMIBLES EN CONSULTORIO</div>
        <p style={{ color: C.textMid, fontSize: 12, marginBottom: 12, lineHeight: 1.45 }}>
          En <strong>Inventario</strong>, asigna estos productos a una de estas categorías (o crea categorías con el mismo nombre). Solo aparecerán como consumibles en la ficha de la doctora: gasas, jeringas, guantes, material de curación, etc. — no analgésicos ni antibióticos de venta.
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

      <Box style={{ padding: 18, marginBottom: 16, background: C.blueDim, border: `1px solid ${C.blue}25` }}>
        <div style={{ color: C.blue, fontSize: 13, fontWeight: 700, marginBottom: 6 }}>Precios de productos y procedimientos</div>
        <ul style={{ color: C.textMid, fontSize: 12, margin: 0, paddingLeft: 18, lineHeight: 1.6 }}>
          <li>
            <strong>Medicamentos y productos de farmacia:</strong> módulo <strong>Inventario</strong> (precio de venta y costo).
          </li>
          <li>
            <strong>Procedimientos</strong> (toma de PA, glucometría, nebulización, etc.): menú <strong>Consultorio</strong> → pestaña de procedimientos o el mismo módulo según tu flujo.
          </li>
        </ul>
      </Box>

      <Btn col={BRAND.primary} onClick={guardar} dis={guardando}>
        {guardando ? "Guardando…" : "Guardar configuración"}
      </Btn>
    </div>
  );
}
