import { useState, useEffect, useCallback, useMemo } from "react";
import { useMediaQuery } from "../../hooks/useMediaQuery";
import { C_LIGHT, BRAND } from "../../constants";
import { supabase } from "../../supabase";
import { Box, Btn, showToast } from "../../ui";
import { CONSULTA_PRECIO_DEFAULT } from "../../utils/consultaConstants";
import { CATEGORIAS_CONSUMIBLE_CONSULTORIO_SUGERIDAS } from "../../utils/consumiblesConsultorio";
import { invalidarCacheMetas } from "../../utils/turnosMetas";

const C = C_LIGHT;

// F6: sin INSERT/UPDATE directo; usa RPC SECURITY DEFINER.
async function upsertConfig(clave, valor) {
  const tok = sessionStorage.getItem("farmacapital_session_token");
  if (!tok) {
    const err = { message: "Sesión no iniciada" };
    console.error(`[ConfigCons] upsert ${clave}:`, err);
    return err;
  }
  const { data, error } = await supabase.rpc("empleado_upsert_configuracion", {
    p_session_token: tok,
    p_clave: clave,
    p_valor: String(valor),
  });
  if (error) {
    console.error(`[ConfigCons] upsert ${clave}:`, error);
    return error;
  }
  if (!data?.success) {
    const err = { message: data?.error || "Error al guardar" };
    console.error(`[ConfigCons] upsert ${clave}:`, err);
    return err;
  }
  return null;
}

function msgError(e) {
  if (!e) return "Error desconocido";
  if (typeof e === "string") return e;
  return e.message || e.hint || e.details || JSON.stringify(e);
}

const fmtMXN = (n) => `$${Number(n || 0).toLocaleString("es-MX", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
const fmtPct = (n) => `${n >= 0 ? "+" : ""}${n}%`;

// ═══════════════════════════════════════════════════════════════
// DEFINICIÓN DECLARATIVA DE TODOS LOS CAMPOS
// tab: servicios | ventas | bonos | cons
// grupo: agrupa cards dentro del tab
// tipo: currency | percent | percent_signed | int
// ═══════════════════════════════════════════════════════════════
const FIELDS = {
  // ── TAB 1 · Precios de servicios ──────────────────────────────
  precio_consulta:           { tab:"servicios", grupo:"consulta",       label:"Consulta general",          def:CONSULTA_PRECIO_DEFAULT, tipo:"currency" },
  precio_toma_presion:       { tab:"servicios", grupo:"procedimientos", label:"Toma de presión",           def:60,   tipo:"currency" },
  precio_glucometria:        { tab:"servicios", grupo:"procedimientos", label:"Glucometría",               def:80,   tipo:"currency" },
  precio_inyeccion_im:       { tab:"servicios", grupo:"procedimientos", label:"Inyección IM",              def:120,  tipo:"currency" },
  precio_inyeccion_iv:       { tab:"servicios", grupo:"procedimientos", label:"Inyección IV",              def:180,  tipo:"currency" },
  precio_nebulizacion:       { tab:"servicios", grupo:"procedimientos", label:"Nebulización",              def:250,  tipo:"currency" },
  precio_curacion_simple:    { tab:"servicios", grupo:"procedimientos", label:"Curación simple",           def:200,  tipo:"currency" },
  precio_curacion_compleja:  { tab:"servicios", grupo:"procedimientos", label:"Curación compleja",         def:380,  tipo:"currency" },
  precio_sutura_1_3:         { tab:"servicios", grupo:"procedimientos", label:"Sutura 1-3 puntos",         def:500,  tipo:"currency" },
  precio_sutura_4_mas:       { tab:"servicios", grupo:"procedimientos", label:"Sutura 4+ puntos",          def:750,  tipo:"currency" },
  precio_retiro_puntos:      { tab:"servicios", grupo:"procedimientos", label:"Retiro de puntos",          def:150,  tipo:"currency" },
  precio_vendaje:            { tab:"servicios", grupo:"procedimientos", label:"Vendaje",                   def:200,  tipo:"currency" },
  precio_lavado_oido:        { tab:"servicios", grupo:"procedimientos", label:"Lavado de oído",            def:180,  tipo:"currency" },
  precio_prueba_embarazo:    { tab:"servicios", grupo:"procedimientos", label:"Prueba de embarazo",        def:100,  tipo:"currency" },
  descuento_max_vendedor:    { tab:"servicios", grupo:"descuentos",     label:"Vendedor",                  def:5,    tipo:"percent", max:100 },
  descuento_max_admin:       { tab:"servicios", grupo:"descuentos",     label:"Administrador",             def:25,   tipo:"percent", max:100 },

  // ── TAB 2 · Metas de ventas ───────────────────────────────────
  meta_ventas_mes:           { tab:"ventas",    grupo:"global",         label:"Meta mensual global",       def:80000, tipo:"currency" },
  meta_matutino_lv:          { tab:"ventas",    grupo:"turnos",         label:"Matutino L-V",              def:1500,  tipo:"currency" },
  meta_vespertino_lv:        { tab:"ventas",    grupo:"turnos",         label:"Vespertino L-V",            def:1500,  tipo:"currency" },
  meta_sabado_matutino:      { tab:"ventas",    grupo:"turnos",         label:"Sábado matutino",           def:1800,  tipo:"currency" },
  meta_sabado_vespertino:    { tab:"ventas",    grupo:"turnos",         label:"Sábado vespertino",         def:1800,  tipo:"currency" },
  meta_domingo:              { tab:"ventas",    grupo:"turnos",         label:"Domingo",                   def:2200,  tipo:"currency" },
  ajuste_quincena:           { tab:"ventas",    grupo:"ajustes",        label:"Quincena (día 15)",         def:25,    tipo:"percent_signed" },
  ajuste_dia_pago:           { tab:"ventas",    grupo:"ajustes",        label:"Día de pago (último día)",  def:30,    tipo:"percent_signed" },
  ajuste_viernes:            { tab:"ventas",    grupo:"ajustes",        label:"Viernes",                   def:15,    tipo:"percent_signed" },
  ajuste_lunes:              { tab:"ventas",    grupo:"ajustes",        label:"Lunes",                     def:-10,   tipo:"percent_signed" },
  ajuste_domingo:            { tab:"ventas",    grupo:"ajustes",        label:"Domingo (castigo)",         def:-10,   tipo:"percent_signed" },
  meta_ventas_dia:           { tab:"ventas",    grupo:"legacy",         label:"Ventas diarias (dashboard)",   def:3000,  tipo:"currency" },
  meta_ventas_semana:        { tab:"ventas",    grupo:"legacy",         label:"Ventas semanales (dashboard)", def:20000, tipo:"currency" },
  meta_ticket_prom:          { tab:"ventas",    grupo:"legacy",         label:"Ticket promedio",           def:250,   tipo:"currency" },

  // ── TAB 3 · Bonos por desempeño ───────────────────────────────
  bonos_activos:             { tab:"bonos",     grupo:"switch",         label:"Bonos al vendedor",         def:0,    tipo:"toggle" },
  bono_70_89:                { tab:"bonos",     grupo:"niveles",        label:"70-89% cumplimiento",       def:500,  tipo:"currency" },
  bono_90_99:                { tab:"bonos",     grupo:"niveles",        label:"90-99% cumplimiento",       def:700,  tipo:"currency" },
  bono_100_109:              { tab:"bonos",     grupo:"niveles",        label:"100-109% cumplimiento",     def:1200, tipo:"currency" },
  bono_110_plus:             { tab:"bonos",     grupo:"niveles",        label:"110% o más",                def:1800, tipo:"currency" },
  extra_antiguedad_por_anio: { tab:"bonos",     grupo:"extras",         label:"Antigüedad (por año)",      def:100,  tipo:"currency" },
  extra_sin_faltas:          { tab:"bonos",     grupo:"extras",         label:"Sin faltas al mes",         def:300,  tipo:"currency" },
  extra_fidelizacion:        { tab:"bonos",     grupo:"extras",         label:"Fidelización",              def:200,  tipo:"currency" },
  extra_fidelizacion_min:    { tab:"bonos",     grupo:"extras",         label:"Clientes mín. p/fidelizar", def:15,   tipo:"int" },

  // ── TAB 4 · Metas del consultorio ─────────────────────────────
  meta_consultas_dia:        { tab:"cons",      grupo:"consultas",      label:"Consultas por día",         def:8,    tipo:"int" },
  meta_consultas_mes:        { tab:"cons",      grupo:"consultas",      label:"Consultas por mes",         def:180,  tipo:"int" },
  meta_procedimientos_dia:   { tab:"cons",      grupo:"procedimientos", label:"Procedimientos por día",    def:4,    tipo:"int" },
  meta_procedimientos_mes:   { tab:"cons",      grupo:"procedimientos", label:"Procedimientos por mes",    def:80,   tipo:"int" },
  meta_recetas_mes:          { tab:"cons",      grupo:"recetas",        label:"Recetas completadas / mes", def:120,  tipo:"int" },
  bono_doctora_80_99:        { tab:"cons",      grupo:"bono_doctora",   label:"Bono 80-99%",               def:500,  tipo:"currency" },
  bono_doctora_100_plus:     { tab:"cons",      grupo:"bono_doctora",   label:"Bono 100% o más",           def:1500, tipo:"currency" },
  estimado_receta_externa:   { tab:"cons",      grupo:"avanzado",       label:"Estimado ticket receta afuera", def:350, tipo:"currency" },
};

const ALL_KEYS = Object.keys(FIELDS);
const keysInTab = (tab) => ALL_KEYS.filter((k) => FIELDS[k].tab === tab);

// Valida un valor según el tipo del campo. Devuelve { ok, num, msg }.
function validarCampo(clave, raw) {
  const def = FIELDS[clave];
  if (def.tipo === "toggle") {
    const on = raw === "1" || raw === 1 || raw === true || raw === "true";
    return { ok: true, num: on ? 1 : 0 };
  }
  const n = parseFloat(raw);
  if (!Number.isFinite(n)) return { ok: false, msg: `"${def.label}" debe ser un número.` };
  if (def.tipo === "currency" && n < 0) return { ok: false, msg: `"${def.label}" no puede ser negativo.` };
  if (def.tipo === "int" && (n < 0 || !Number.isInteger(n))) return { ok: false, msg: `"${def.label}" debe ser un entero ≥ 0.` };
  if (def.tipo === "percent") {
    const max = def.max ?? 100;
    if (n < 0 || n > max) return { ok: false, msg: `"${def.label}" debe estar entre 0 y ${max}%.` };
  }
  if (def.tipo === "percent_signed") {
    if (n < -100 || n > 200) return { ok: false, msg: `"${def.label}" fuera de rango razonable (-100% a +200%).` };
  }
  return { ok: true, num: n };
}

// ═══════════════════════════════════════════════════════════════
// UI HELPERS
// ═══════════════════════════════════════════════════════════════

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

function InputField({ clave, valor, onChange, compact = false }) {
  const def = FIELDS[clave];
  const esMoneda = def.tipo === "currency";
  const esPct = def.tipo === "percent" || def.tipo === "percent_signed";
  const simbolo = esMoneda ? "$" : esPct ? "%" : "#";
  const step = esMoneda ? "10" : "1";
  const min = def.tipo === "percent_signed" ? undefined : 0;
  const sugerencia = esMoneda ? fmtMXN(def.def) : esPct ? `${def.def}%` : def.def;

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 4 }}>
      <label style={{ color: C.textMid, fontSize: 11, fontWeight: 700, textTransform: "uppercase", letterSpacing: 0.3 }}>
        {def.label}
      </label>
      <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
        {!esPct && (
          <span style={{ color: C.textDim, fontWeight: 700, fontSize: 14, width: 12 }}>{simbolo}</span>
        )}
        <input
          type="number"
          step={step}
          min={min}
          value={valor}
          onChange={(e) => onChange(clave, e.target.value)}
          style={{
            width: "100%",
            maxWidth: compact ? 140 : 180,
            padding: "9px 11px",
            borderRadius: 8,
            border: `1px solid ${C.border}`,
            fontSize: 14,
            fontWeight: 700,
            background: "#fff",
            color: C.text,
          }}
        />
        {esPct && (
          <span style={{ color: C.textDim, fontWeight: 700, fontSize: 14 }}>{simbolo}</span>
        )}
      </div>
      {!compact && (
        <div style={{ color: C.textDim, fontSize: 10.5 }}>
          Sugerencia: <strong>{sugerencia}</strong>
        </div>
      )}
    </div>
  );
}

function SectionTitle({ children, sub }) {
  return (
    <div style={{ marginBottom: 12 }}>
      <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1 }}>{children}</div>
      {sub && <div style={{ color: C.textMid, fontSize: 11.5, marginTop: 3, lineHeight: 1.45 }}>{sub}</div>}
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// COMPONENTE PRINCIPAL
// ═══════════════════════════════════════════════════════════════

export default function ConfigConsultorioModule() {
  const isMobileCfg = useMediaQuery("(max-width: 768px)");
  const [tab, setTab] = useState("servicios");

  // Estado unificado: mapa clave → string. Se inicializa con los defaults.
  const [valores, setValores] = useState(() => {
    const init = {};
    ALL_KEYS.forEach((k) => { init[k] = String(FIELDS[k].def); });
    return init;
  });

  // Consumibles (JSON) vive aparte porque no es numérico.
  const [cats, setCats] = useState(() => new Set(["Botiquín"]));
  const [guardando, setGuard] = useState(false);

  // ── CARGA INICIAL ───────────────────────────────────────────
  const cargar = useCallback(async () => {
    const claves = [...ALL_KEYS, "consumibles_categorias"];
    const { data, error } = await supabase.from("configuracion").select("clave,valor").in("clave", claves);
    if (error) {
      console.error("[ConfigCons] cargar error:", error);
      showToast("No se pudo cargar configuración: " + msgError(error), "error");
      return;
    }
    const map = Object.fromEntries((data || []).map((r) => [r.clave, r.valor]));
    setValores((prev) => {
      const next = { ...prev };
      ALL_KEYS.forEach((k) => {
        if (map[k] == null || map[k] === "") return;
        if (FIELDS[k].tipo === "toggle") {
          const v = String(map[k]).toLowerCase();
          next[k] = (v === "1" || v === "true") ? "1" : "0";
        } else {
          next[k] = String(map[k]);
        }
      });
      return next;
    });
    if (map.consumibles_categorias) {
      try {
        const j = JSON.parse(map.consumibles_categorias);
        if (Array.isArray(j) && j.length) setCats(new Set(j.map(String)));
      } catch { /* default */ }
    }
  }, []);

  useEffect(() => { cargar(); }, [cargar]);

  const setValor = (k, v) => setValores((p) => ({ ...p, [k]: v }));

  const toggleCat = (c) => {
    setCats((prev) => {
      const n = new Set(prev);
      if (n.has(c)) n.delete(c); else n.add(c);
      return n;
    });
  };

  // ── GUARDAR (por tab) ───────────────────────────────────────
  const guardarTab = async (tabId) => {
    const keys = keysInTab(tabId);
    for (const k of keys) {
      const v = validarCampo(k, valores[k]);
      if (!v.ok) { showToast(v.msg, "warning"); return; }
    }
    setGuard(true);
    try {
      const errores = [];
      for (const k of keys) {
        const def = FIELDS[k];
        const v = validarCampo(k, valores[k]);
        const payload = def.tipo === "toggle" ? String(v.num) : String(parseFloat(valores[k]));
        const err = await upsertConfig(k, payload);
        if (err) errores.push({ k, err });
      }
      // Consumibles solo en tab cons (si alguien los marcó).
      if (tabId === "cons" && cats.size > 0) {
        const err = await upsertConfig("consumibles_categorias", JSON.stringify([...cats]));
        if (err) errores.push({ k: "consumibles_categorias", err });
      }
      if (errores.length) {
        const first = errores[0];
        throw new Error(`[${first.k}] ${msgError(first.err)}${errores.length > 1 ? ` (+${errores.length - 1} más)` : ""}`);
      }
      invalidarCacheMetas();
      showToast("Cambios guardados. Dashboard, POS y consultorio los usarán al recargar.", "success");
    } catch (e) {
      console.error("[ConfigCons] guardarTab error:", e);
      showToast("No se pudo guardar: " + msgError(e), "error");
    }
    setGuard(false);
  };

  // ── SIMULACIÓN BONOS (Tab 3) ────────────────────────────────
  const simulacionBono = useMemo(() => {
    const cumplimientoEj = 105;
    const antiguedadAnios = 2;
    const nivel = cumplimientoEj >= 110 ? parseFloat(valores.bono_110_plus)
                 : cumplimientoEj >= 100 ? parseFloat(valores.bono_100_109)
                 : cumplimientoEj >= 90  ? parseFloat(valores.bono_90_99)
                 : cumplimientoEj >= 70  ? parseFloat(valores.bono_70_89)
                 : 0;
    const extraAnt = (parseFloat(valores.extra_antiguedad_por_anio) || 0) * antiguedadAnios;
    const extraSinFalt = parseFloat(valores.extra_sin_faltas) || 0;
    const total = (Number.isFinite(nivel) ? nivel : 0) + extraAnt + extraSinFalt;
    return { cumplimientoEj, antiguedadAnios, nivel, extraAnt, extraSinFalt, total };
  }, [valores.bono_110_plus, valores.bono_100_109, valores.bono_90_99, valores.bono_70_89, valores.extra_antiguedad_por_anio, valores.extra_sin_faltas]);

  // ── PREVIEW AJUSTES (Tab 2) ─────────────────────────────────
  const previewAjuste = useMemo(() => {
    const base = parseFloat(valores.meta_matutino_lv) || 0;
    const pct = parseFloat(valores.ajuste_viernes) || 0;
    const ajustada = Math.round(base * (1 + pct / 100));
    return { base, pct, ajustada };
  }, [valores.meta_matutino_lv, valores.ajuste_viernes]);

  // ═══════════════════════════════════════════════════════════
  return (
    <div style={{ padding: 24, maxWidth: 960 }}>
      <h1 style={{ color: C.text, fontSize: 20, fontWeight: 800, margin: "0 0 8px" }}>🎯 Metas y Precios</h1>
      <p style={{ color: C.textMid, fontSize: 13, marginBottom: 20, lineHeight: 1.5 }}>
        Centro de control de <strong>precios, metas y bonos</strong> de la farmacia. Cada tab se guarda por separado.
      </p>

      <div style={{
        display: "flex",
        gap: 8,
        marginBottom: 20,
        flexWrap: isMobileCfg ? "nowrap" : "wrap",
        overflowX: isMobileCfg ? "auto" : "visible",
        WebkitOverflowScrolling: "touch",
        scrollbarWidth: "thin",
      }}>
        <div style={{ flexShrink: 0 }}>
          <TabButton active={tab === "servicios"} onClick={() => setTab("servicios")}>
            {isMobileCfg ? "💵 Precios" : "💵 Precios de servicios"}
          </TabButton>
        </div>
        <div style={{ flexShrink: 0 }}>
          <TabButton active={tab === "ventas"} onClick={() => setTab("ventas")}>
            {isMobileCfg ? "📈 Metas ventas" : "📈 Metas de ventas"}
          </TabButton>
        </div>
        <div style={{ flexShrink: 0 }}>
          <TabButton active={tab === "bonos"} onClick={() => setTab("bonos")}>
            {isMobileCfg ? "🏆 Bonos" : "🏆 Bonos por desempeño"}
          </TabButton>
        </div>
        <div style={{ flexShrink: 0 }}>
          <TabButton active={tab === "cons"} onClick={() => setTab("cons")}>
            {isMobileCfg ? "🩺 Metas cons." : "🩺 Metas del consultorio"}
          </TabButton>
        </div>
      </div>

      {/* ══════════════ TAB 1: PRECIOS DE SERVICIOS ══════════════ */}
      {tab === "servicios" && (
        <>
          <Box style={{ padding: 20, marginBottom: 16 }}>
            <SectionTitle>CONSULTA GENERAL</SectionTitle>
            <div style={{ maxWidth: 260 }}>
              <InputField clave="precio_consulta" valor={valores.precio_consulta} onChange={setValor} />
            </div>
          </Box>

          <Box style={{ padding: 20, marginBottom: 16 }}>
            <SectionTitle sub="Precios que cobra la doctora/o por procedimiento. Afectan caja y dashboard.">
              PROCEDIMIENTOS MÉDICOS
            </SectionTitle>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(min(100%,220px),1fr))", gap: 14 }}>
              {keysInTab("servicios").filter((k) => FIELDS[k].grupo === "procedimientos").map((k) => (
                <InputField key={k} clave={k} valor={valores[k]} onChange={setValor} compact />
              ))}
            </div>
          </Box>

          <Box style={{ padding: 20, marginBottom: 16 }}>
            <SectionTitle sub="Límite de descuento que puede aplicar cada rol en el POS sin requerir aprobación.">
              DESCUENTO MÁXIMO POR ROL
            </SectionTitle>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(min(100%,200px),1fr))", gap: 14 }}>
              {keysInTab("servicios").filter((k) => FIELDS[k].grupo === "descuentos").map((k) => (
                <InputField key={k} clave={k} valor={valores[k]} onChange={setValor} />
              ))}
            </div>
          </Box>

          <Btn col={BRAND.primary} onClick={() => guardarTab("servicios")} dis={guardando}>
            {guardando ? "Guardando…" : "Guardar precios de servicios"}
          </Btn>
        </>
      )}

      {/* ══════════════ TAB 2: METAS DE VENTAS ══════════════ */}
      {tab === "ventas" && (
        <>
          <Box style={{ padding: 20, marginBottom: 16 }}>
            <SectionTitle>META MENSUAL GLOBAL</SectionTitle>
            <div style={{ maxWidth: 260 }}>
              <InputField clave="meta_ventas_mes" valor={valores.meta_ventas_mes} onChange={setValor} />
            </div>
          </Box>

          <Box style={{ padding: 20, marginBottom: 16 }}>
            <SectionTitle sub="Objetivo de caja por turno. Los ajustes de abajo modifican estas metas según el día.">
              META POR TURNO
            </SectionTitle>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(min(100%,210px),1fr))", gap: 14 }}>
              {keysInTab("ventas").filter((k) => FIELDS[k].grupo === "turnos").map((k) => (
                <InputField key={k} clave={k} valor={valores[k]} onChange={setValor} compact />
              ))}
            </div>
          </Box>

          <Box style={{ padding: 20, marginBottom: 16 }}>
            <SectionTitle sub="Los porcentajes ajustan la meta del turno ese día específico. Pueden ser negativos.">
              AJUSTES AUTOMÁTICOS POR FECHA
            </SectionTitle>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(min(100%,200px),1fr))", gap: 14 }}>
              {keysInTab("ventas").filter((k) => FIELDS[k].grupo === "ajustes").map((k) => (
                <InputField key={k} clave={k} valor={valores[k]} onChange={setValor} />
              ))}
            </div>
            <div style={{ marginTop: 14, padding: "10px 12px", background: C.amberDim, border: `1px solid ${C.amber}40`, borderRadius: 8, fontSize: 12, color: C.textMid }}>
              <strong>Ejemplo:</strong> viernes {fmtPct(previewAjuste.pct)} → meta matutino {fmtMXN(previewAjuste.base)} sube a <strong>{fmtMXN(previewAjuste.ajustada)}</strong>.
            </div>
          </Box>

          <Box style={{ padding: 20, marginBottom: 16 }}>
            <SectionTitle sub="Usadas por el Dashboard en los KPIs principales. No afectan el cálculo por turno.">
              METAS HISTÓRICAS DEL DASHBOARD
            </SectionTitle>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(min(100%,220px),1fr))", gap: 14 }}>
              {keysInTab("ventas").filter((k) => FIELDS[k].grupo === "legacy").map((k) => (
                <InputField key={k} clave={k} valor={valores[k]} onChange={setValor} />
              ))}
            </div>
          </Box>

          <Btn col={BRAND.primary} onClick={() => guardarTab("ventas")} dis={guardando}>
            {guardando ? "Guardando…" : "Guardar metas de ventas"}
          </Btn>
        </>
      )}

      {/* ══════════════ TAB 3: BONOS POR DESEMPEÑO ══════════════ */}
      {tab === "bonos" && (
        <>
          <Box style={{ padding: 20, marginBottom: 16 }}>
            <SectionTitle sub="Apagado = solo salario base. El vendedor no ve escalones ni montos de bono. Enciéndelo cuando quieras pagar desempeño, sin pedir un cambio de código.">
              ACTIVAR BONOS
            </SectionTitle>
            <button
              type="button"
              onClick={() => setValor("bonos_activos", valores.bonos_activos === "1" ? "0" : "1")}
              aria-pressed={valores.bonos_activos === "1"}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 12,
                border: `1px solid ${valores.bonos_activos === "1" ? C.green : C.border}`,
                background: valores.bonos_activos === "1" ? C.greenDim : C.card,
                borderRadius: 10,
                padding: "12px 14px",
                cursor: "pointer",
                fontFamily: "inherit",
                width: "100%",
                maxWidth: 420,
                textAlign: "left",
              }}
            >
              <span style={{
                width: 44, height: 26, borderRadius: 13, padding: 3,
                background: valores.bonos_activos === "1" ? C.green : C.border,
                display: "flex", alignItems: "center",
                justifyContent: valores.bonos_activos === "1" ? "flex-end" : "flex-start",
                flexShrink: 0,
              }}>
                <span style={{ width: 20, height: 20, borderRadius: 10, background: "#fff", display: "block" }} />
              </span>
              <span>
                <span style={{ display: "block", fontWeight: 800, fontSize: 14, color: C.text }}>
                  {valores.bonos_activos === "1" ? "Bonos encendidos" : "Bonos apagados"}
                </span>
                <span style={{ display: "block", fontSize: 12, color: C.textMid, marginTop: 2 }}>
                  {valores.bonos_activos === "1"
                    ? "Mi Día muestra el escalón de bono. Recuerda pulsar Guardar."
                    : "Nómina = salario base. Los montos de abajo se guardan pero no se muestran."}
                </span>
              </span>
            </button>
          </Box>

          <Box style={{ padding: 20, marginBottom: 16, opacity: valores.bonos_activos === "1" ? 1 : 0.55 }}>
            <SectionTitle sub="Monto mensual según el % de meta cumplida. Menos de 70% = sin bono.">
              BONO POR CUMPLIMIENTO
            </SectionTitle>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(min(100%,220px),1fr))", gap: 14 }}>
              {keysInTab("bonos").filter((k) => FIELDS[k].grupo === "niveles").map((k) => (
                <InputField key={k} clave={k} valor={valores[k]} onChange={setValor} />
              ))}
            </div>
          </Box>

          <Box style={{ padding: 20, marginBottom: 16 }}>
            <SectionTitle sub="Se suman al bono por cumplimiento. Fidelización requiere registrar el mínimo de clientes abajo.">
              EXTRAS
            </SectionTitle>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(min(100%,220px),1fr))", gap: 14 }}>
              {keysInTab("bonos").filter((k) => FIELDS[k].grupo === "extras").map((k) => (
                <InputField key={k} clave={k} valor={valores[k]} onChange={setValor} />
              ))}
            </div>
          </Box>

          <Box style={{ padding: 16, marginBottom: 20, background: C.greenDim, border: `1px solid ${C.green}40` }}>
            <div style={{ color: C.greenDark, fontSize: 12, fontWeight: 700, marginBottom: 6 }}>
              🔮 Simulación en vivo
            </div>
            <div style={{ color: C.textMid, fontSize: 13, lineHeight: 1.55 }}>
              Vendedor con <strong>{simulacionBono.cumplimientoEj}%</strong> de cumplimiento, <strong>{simulacionBono.antiguedadAnios} años</strong> de antigüedad y <strong>sin faltas</strong>:
              <div style={{ marginTop: 6, fontSize: 13, color: C.text }}>
                {fmtMXN(simulacionBono.nivel)} <span style={{ color: C.textDim }}>(bono 100-109%)</span>
                {" + "}{fmtMXN(simulacionBono.extraAnt)} <span style={{ color: C.textDim }}>(antigüedad × 2)</span>
                {" + "}{fmtMXN(simulacionBono.extraSinFalt)} <span style={{ color: C.textDim }}>(sin faltas)</span>
                {" = "}
                <strong style={{ color: C.greenDark, fontSize: 15 }}>{fmtMXN(simulacionBono.total)}</strong>
              </div>
            </div>
          </Box>

          <Btn col={BRAND.primary} onClick={() => guardarTab("bonos")} dis={guardando}>
            {guardando ? "Guardando…" : "Guardar bonos"}
          </Btn>
        </>
      )}

      {/* ══════════════ TAB 4: METAS DEL CONSULTORIO ══════════════ */}
      {tab === "cons" && (
        <>
          <Box style={{ padding: 20, marginBottom: 16 }}>
            <SectionTitle>META DE CONSULTAS</SectionTitle>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(min(100%,210px),1fr))", gap: 14 }}>
              {keysInTab("cons").filter((k) => FIELDS[k].grupo === "consultas").map((k) => (
                <InputField key={k} clave={k} valor={valores[k]} onChange={setValor} />
              ))}
            </div>
          </Box>

          <Box style={{ padding: 20, marginBottom: 16 }}>
            <SectionTitle sub="Procedimientos médicos realizados en el consultorio (PA, inyecciones, curaciones, etc.).">
              META DE PROCEDIMIENTOS
            </SectionTitle>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(min(100%,210px),1fr))", gap: 14 }}>
              {keysInTab("cons").filter((k) => FIELDS[k].grupo === "procedimientos").map((k) => (
                <InputField key={k} clave={k} valor={valores[k]} onChange={setValor} />
              ))}
            </div>
          </Box>

          <Box style={{ padding: 20, marginBottom: 16 }}>
            <SectionTitle sub="Recetas cuyos medicamentos fueron efectivamente surtidos en FarmaCapital.">
              META DE RECETAS
            </SectionTitle>
            <div style={{ maxWidth: 220 }}>
              <InputField clave="meta_recetas_mes" valor={valores.meta_recetas_mes} onChange={setValor} />
            </div>
          </Box>

          <Box style={{ padding: 20, marginBottom: 16 }}>
            <SectionTitle sub="Bono mensual de la doctora/o según % de meta mensual de consultas cumplida.">
              BONO DOCTORA
            </SectionTitle>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(min(100%,220px),1fr))", gap: 14 }}>
              {keysInTab("cons").filter((k) => FIELDS[k].grupo === "bono_doctora").map((k) => (
                <InputField key={k} clave={k} valor={valores[k]} onChange={setValor} />
              ))}
            </div>
          </Box>

          <Box style={{ padding: 20, marginBottom: 16 }}>
            <SectionTitle sub="Cuando la receta de la consulta se surtió fuera de FarmaCapital, el dashboard multiplica el nº de esas citas por este monto para estimar la oportunidad perdida.">
              AJUSTES AVANZADOS
            </SectionTitle>
            <div style={{ maxWidth: 260, marginBottom: 14 }}>
              <InputField clave="estimado_receta_externa" valor={valores.estimado_receta_externa} onChange={setValor} />
            </div>
            <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1, marginBottom: 8 }}>
              CATEGORÍAS DE CONSUMIBLES EN CONSULTORIO
            </div>
            <p style={{ color: C.textMid, fontSize: 12, marginBottom: 10, lineHeight: 1.45 }}>
              Productos asignados a estas categorías aparecen como consumibles en la ficha de la doctora (gasas, jeringas, guantes, curación).
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

          <Btn col={BRAND.primary} onClick={() => guardarTab("cons")} dis={guardando}>
            {guardando ? "Guardando…" : "Guardar metas del consultorio"}
          </Btn>
        </>
      )}
    </div>
  );
}
