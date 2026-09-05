import { useCallback, useEffect, useMemo, useState } from "react";
import { BarChart3, Receipt, Wallet } from "lucide-react";
import { C_LIGHT, BRAND } from "./constants";
import { supabase } from "./supabase";
import { $ } from "./utils";
import { Box, Btn, KPI, KPI_ROW, SkeletonKPIs, SkeletonTable, Tag, showToast } from "./ui";
import { parseRpcJsonObject } from "./utils/rpcJson";
import { rangoReporteMexico } from "./lib/dashboardVentas";
import { hoyISOMexico } from "./lib/fecha";
import {
  CATEGORIA_COMPRA_INVENTARIO,
  etiquetaCategoriaGasto,
  gastoAfectaPl,
  opcionesCategoriaGasto,
} from "./constants/categoriasGasto";
import {
  MENSAJE_FLUJO_SIN_CONFIG,
  PISO_FONDO_FLUJO,
  anioMesDe,
  flujoEstaConfigurado,
  labelSemana,
  maxAbsSemanas,
  parseFlujoBundle,
  pctBarra,
  textoCompletitud,
  textoOrigenPiso,
} from "./lib/flujoCaja";

const C = C_LIGHT;

const inp = {
  padding: "9px 11px",
  borderRadius: 8,
  border: `1px solid ${C.border}`,
  fontSize: 13,
  fontWeight: 600,
  background: "#fff",
  color: C.text,
  minWidth: 0,
};

function irAjustesFinanzas(setPage) {
  try {
    sessionStorage.setItem("farmacapital_config_tab", "finanzas");
  } catch { /* noop */ }
  if (typeof setPage === "function") setPage("config_cons");
}

function Banner({ nivel, titulo, children }) {
  const bg = nivel === "ok" ? C.greenDim : nivel === "info" ? C.amberDim : C.amberDim;
  const bd = nivel === "ok" ? `${C.green}40` : `${C.amber}55`;
  const fg = nivel === "ok" ? C.greenDark : C.text;
  return (
    <Box style={{ padding: 14, marginBottom: 14, background: bg, border: `1px solid ${bd}` }}>
      {titulo ? (
        <div style={{ color: fg, fontWeight: 800, fontSize: 13, marginBottom: 6 }}>{titulo}</div>
      ) : null}
      <div style={{ color: C.textMid, fontSize: 12.5, lineHeight: 1.5 }}>{children}</div>
    </Box>
  );
}

function SubNav({ value, onChange }) {
  const items = [
    { id: "flujo", label: "Flujo", disabled: false, Icon: Wallet },
    { id: "resultados", label: "Resultados", disabled: true, Icon: BarChart3 },
    { id: "gastos", label: "Gastos", disabled: false, Icon: Receipt },
  ];
  return (
    <div
      className="fc-dash-tabs"
      style={{
        display: "flex",
        gap: 2,
        marginBottom: 16,
        flexWrap: "nowrap",
        overflowX: "auto",
        borderBottom: `1px solid ${C.border}`,
      }}
    >
      {items.map((it) => {
        const active = value === it.id;
        const Icon = it.Icon;
        return (
          <button
            key={it.id}
            type="button"
            disabled={it.disabled}
            title={it.disabled ? "P&L bloqueado: falta la cobertura de costo de lo vendido (consulta 4)." : undefined}
            onClick={() => { if (!it.disabled) onChange(it.id); }}
            className={`fc-dash-nav-tab${active ? " is-active" : ""}`}
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: 7,
              padding: "8px 12px",
              marginBottom: -1,
              border: "none",
              borderBottom: `2px solid ${active ? BRAND.primary : "transparent"}`,
              background: "transparent",
              color: it.disabled ? C.textDim : active ? BRAND.primary : C.textMid,
              fontWeight: 700,
              fontSize: 13,
              cursor: it.disabled ? "not-allowed" : "pointer",
              opacity: it.disabled ? 0.55 : 1,
              whiteSpace: "nowrap",
              flexShrink: 0,
            }}
          >
            <Icon size={15} strokeWidth={2.1} aria-hidden />
            {it.label}{it.disabled ? " · pronto" : ""}
          </button>
        );
      })}
    </div>
  );
}

export default function FlujoCajaTab({ usuario, setPage, showConfirm }) {
  const [sub, setSub] = useState("flujo");
  const [periodo, setPeriodo] = useState("mes");
  const [bundle, setBundle] = useState(null);
  const [loading, setLoading] = useState(true);
  const [errorCarga, setErrorCarga] = useState(null);
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState(() => ({
    fecha: hoyISOMexico(),
    categoria: "renta",
    concepto: "",
    monto: "",
    proveedor: "",
    es_recurrente: false,
  }));

  const rango = useMemo(() => rangoReporteMexico(periodo), [periodo]);

  const cargar = useCallback(async () => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) {
      showToast("Sesión no iniciada", "error");
      setLoading(false);
      return;
    }
    setLoading(true);
    setErrorCarga(null);
    const { data, error } = await supabase.rpc("admin_flujo_caja_bundle", {
      p_session_token: tok,
      p_desde: rango.desdeFecha,
      p_hasta: rango.hastaFecha,
    });
    if (error) {
      console.error("[FlujoCaja] bundle:", error);
      const msg = error.message || "error";
      const sqlPendiente = /could not find|does not exist|schema cache/i.test(msg);
      const texto = sqlPendiente
        ? "Falta aplicar en Supabase sql/patch_finanzas_gastos_20260904.sql y sql/patch_finanzas_flujo_caja_20260904.sql."
        : "No se pudo cargar el flujo: " + msg;
      showToast(texto, "error");
      setErrorCarga(texto);
      setBundle(null);
      setLoading(false);
      return;
    }
    setBundle(parseFlujoBundle(data));
    setLoading(false);
  }, [rango.desdeFecha, rango.hastaFecha]);

  useEffect(() => { cargar(); }, [cargar]);

  const configurado = flujoEstaConfigurado(bundle);
  const alertas = bundle?.alertas || [];
  const alertaCompletitud = alertas.find((a) => a.tipo === "completitud");
  const alertaMed = alertas.find((a) => a.tipo === "medicamento");
  const alertaCub = alertas.find((a) => a.tipo === "cubetas");
  const semanas = bundle?.semanas || [];
  const maxSem = maxAbsSemanas(semanas);
  const incompleta = bundle?.completitud?.incompleta !== false;
  const mesMarca = bundle?.completitud?.mes || anioMesDe(rango.hastaFecha);

  const registrar = async () => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) { showToast("Sesión no iniciada", "error"); return; }
    const monto = parseFloat(String(form.monto).replace(",", "."));
    if (!Number.isFinite(monto) || monto <= 0) {
      showToast("El monto tiene que ser mayor a 0.", "warning");
      return;
    }
    if (!String(form.concepto || "").trim()) {
      showToast("Escribe el concepto.", "warning");
      return;
    }
    setSaving(true);
    const { data, error } = await supabase.rpc("admin_registrar_gasto", {
      p_session_token: tok,
      p_gasto: {
        fecha: form.fecha || hoyISOMexico(),
        categoria: form.categoria,
        concepto: String(form.concepto).trim(),
        monto,
        proveedor: String(form.proveedor || "").trim() || null,
        es_recurrente: Boolean(form.es_recurrente),
        periodicidad: form.es_recurrente ? "mensual" : null,
        afecta_pl: gastoAfectaPl(form.categoria, true),
      },
    });
    setSaving(false);
    const out = parseRpcJsonObject(data);
    if (error || !out.success) {
      showToast(out.error || error?.message || "No se guardó el gasto", "error");
      return;
    }
    showToast("Gasto guardado", "success");
    setForm((f) => ({ ...f, concepto: "", monto: "", proveedor: "" }));
    cargar();
  };

  const eliminar = (g) => {
    const run = async () => {
      const tok = sessionStorage.getItem("farmacapital_session_token");
      if (!tok) return;
      const { data, error } = await supabase.rpc("admin_eliminar_gasto", {
        p_session_token: tok,
        p_id: g.id,
      });
      const out = parseRpcJsonObject(data);
      if (error || !out.success) {
        showToast(out.error || error?.message || "No se eliminó", "error");
        return;
      }
      showToast("Gasto eliminado", "success");
      cargar();
    };
    if (typeof showConfirm === "function") {
      showConfirm("Eliminar gasto", `¿Quitar ${g.concepto} (${$(g.monto)})?`, run, true);
    } else {
      run();
    }
  };

  const marcarSinCompra = async (marcar) => {
    const tok = sessionStorage.getItem("farmacapital_session_token");
    if (!tok) return;
    const { data, error } = await supabase.rpc("admin_marcar_periodo_sin_compra", {
      p_session_token: tok,
      p_anio_mes: mesMarca,
      p_sin_compra: marcar,
    });
    const out = parseRpcJsonObject(data);
    if (error || !out.success) {
      showToast(out.error || error?.message || "No se pudo marcar", "error");
      return;
    }
    cargar();
  };

  if (loading && !bundle) {
    return (
      <div>
        <SubNav value={sub} onChange={setSub} />
        <SkeletonKPIs count={4} />
        <SkeletonTable rows={4} cols={6} />
      </div>
    );
  }

  if (errorCarga) {
    return (
      <div>
        <SubNav value={sub} onChange={setSub} />
        <Box style={{ padding: 22, background: C.redDim, border: `1px solid ${C.red}40` }}>
          <div style={{ color: C.text, fontWeight: 800, fontSize: 16, marginBottom: 8 }}>
            No se pudo cargar el flujo
          </div>
          <p style={{ color: C.textMid, fontSize: 13, lineHeight: 1.55, margin: "0 0 12px" }}>{errorCarga}</p>
          <Btn ol col={BRAND.primary} onClick={cargar}>Reintentar</Btn>
        </Box>
      </div>
    );
  }

  if (!configurado) {
    return (
      <div>
        <SubNav value={sub} onChange={setSub} />
        <Box style={{ padding: 22, background: C.amberDim, border: `1px solid ${C.amber}55` }}>
          <div style={{ color: C.text, fontWeight: 800, fontSize: 16, marginBottom: 8 }}>
            Falta una apertura de caja con fondo
          </div>
          <p style={{ color: C.textMid, fontSize: 13, lineHeight: 1.55, margin: "0 0 12px" }}>
            {bundle?.mensaje || MENSAJE_FLUJO_SIN_CONFIG}
          </p>
          <p style={{ color: C.textMid, fontSize: 13, lineHeight: 1.55, margin: "0 0 16px" }}>
            Lo que entra lo leemos de los cortes. La semilla es el <strong style={{ color: C.text }}>fondo de la primera apertura</strong>
            {" "}(en esta farmacia, a partir del {PISO_FONDO_FLUJO}). No uses el fondo de hoy: ese crecimiento ya viaja en los cortes.
          </p>
          {typeof setPage === "function" ? (
            <Btn ol col={BRAND.primary} onClick={() => irAjustesFinanzas(setPage)}>
              Override opcional en Metas y Precios
            </Btn>
          ) : null}
        </Box>
      </div>
    );
  }

  const quedoCol = incompleta ? C.textMid : (Number(bundle.quedo) >= 0 ? C.green : C.red);
  const cajaCol = incompleta ? C.textMid : C.teal;

  return (
    <div>
      <SubNav value={sub} onChange={setSub} />

      <div style={{ display: "flex", gap: 6, marginBottom: 16, flexWrap: "wrap", alignItems: "center" }}>
        {[["dia", "Hoy"], ["semana", "Esta semana"], ["mes", "Este mes"]].map(([v, l]) => (
          <button
            key={v}
            type="button"
            onClick={() => setPeriodo(v)}
            style={{
              padding: "6px 14px",
              borderRadius: 8,
              border: `1px solid ${periodo === v ? BRAND.primary : C.border}`,
              background: periodo === v ? `${BRAND.primary}18` : "transparent",
              color: periodo === v ? BRAND.primary : C.textMid,
              fontSize: 12,
              fontWeight: 700,
              cursor: "pointer",
            }}
          >
            {l}
          </button>
        ))}
        <span style={{ color: C.textDim, fontSize: 11 }}>
          {bundle.desde} → {bundle.hasta}
          {" · "}
          {textoOrigenPiso(bundle)}
          {bundle.recortado_por_fondo ? ` · recortado al ${bundle.piso_aplicado}` : ""}
        </span>
      </div>

      {sub === "resultados" ? (
        <Banner nivel="info" titulo="Resultados (P&L) no está en esta fase">
          Falta la cobertura de costo de lo vendido (consulta 4). Un P&L con costos faltantes infla el margen.
          Esta pestaña solo muestra dinero contado.
        </Banner>
      ) : null}

      {sub === "flujo" && (
        <>
          <div style={KPI_ROW}>
            <KPI
              label="Entró"
              value={$(bundle.entro)}
              col={C.teal}
              icon="↓"
              sub="Cortes vigentes · total_general. No es una estimación."
            />
            <KPI
              label="Salió"
              value={$(bundle.salio?.total)}
              col={C.red}
              icon="↑"
              sub={`Medicamento ${$(bundle.salio?.medicamento)} · Nómina ${$(bundle.salio?.nomina)} · Gastos ${$(bundle.salio?.otros_gastos)} · Liquidación MP ${$(bundle.salio?.liquidacion_mp)}`}
            />
            <KPI
              label="Quedó"
              value={$(bundle.quedo)}
              col={quedoCol}
              icon="="
              sub={textoCompletitud(bundle.completitud)}
            />
            <KPI
              label="En caja hoy"
              value={$(bundle.en_caja_hoy)}
              col={cajaCol}
              icon="▣"
              sub={
                Number(bundle.comprometido_30d) > 0
                  ? `Comprometido a 30 días (recurrentes capturados): ${$(bundle.comprometido_30d)}. No es todo libre.`
                  : "Saldo inicial + cortes − salidas desde el piso. No descuenta lo que no capturaste."
              }
            />
          </div>

          <Banner
            nivel={alertaCompletitud?.nivel === "ok" ? "ok" : "ambar"}
            titulo={alertaCompletitud?.nivel === "ok" ? "Captura completa" : "Captura incompleta"}
          >
            {alertaCompletitud?.texto || textoCompletitud(bundle.completitud)}
            <div style={{ marginTop: 10, display: "flex", gap: 8, flexWrap: "wrap", alignItems: "center" }}>
              <label style={{ display: "flex", alignItems: "center", gap: 8, fontSize: 12, color: C.text, cursor: "pointer" }}>
                <input
                  type="checkbox"
                  checked={Boolean(bundle.completitud?.sin_compra)}
                  onChange={(e) => marcarSinCompra(e.target.checked)}
                />
                Este mes ({mesMarca}) no hubo compra a proveedor
              </label>
              {usuario?.nombre ? (
                <span style={{ color: C.textDim, fontSize: 11 }}>Lo marca {usuario.nombre}</span>
              ) : null}
            </div>
          </Banner>

          <Banner nivel="info" titulo="Comprar medicamento no es pérdida">
            {alertaMed?.texto}
          </Banner>

          <Banner nivel="info" titulo="Cajón ≠ saldo Mercado Pago">
            {alertaCub?.texto}
            <div style={{ marginTop: 10, display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(min(100%,160px),1fr))", gap: 10 }}>
              <div>
                <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700 }}>CAJÓN (ya en el corte)</div>
                <div style={{ color: C.text, fontWeight: 800 }}>{$(bundle.cubetas?.cajon_cobrado_servicios)}</div>
              </div>
              <div>
                <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700 }}>LIQUIDACIÓN MP</div>
                <div style={{ color: C.red, fontWeight: 800 }}>−{$(bundle.cubetas?.saldo_mp_liquidacion)}</div>
              </div>
              <div>
                <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700 }}>COMPENSACIÓN MP</div>
                <div style={{ color: C.textMid, fontWeight: 800 }}>{$(bundle.cubetas?.saldo_mp_compensacion)}</div>
                <div style={{ color: C.textDim, fontSize: 10 }}>No está en el cajón</div>
              </div>
              <div>
                <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700 }}>UTILIDAD SERVICIOS</div>
                <div style={{ color: C.green, fontWeight: 800 }}>{$(bundle.cubetas?.utilidad_servicios)}</div>
                <div style={{ color: C.textDim, fontSize: 10 }}>P&L, no flujo</div>
              </div>
            </div>
          </Banner>

          <Box style={{ padding: 16, marginBottom: 16, overflow: "auto" }}>
            <div style={{ color: C.text, fontWeight: 800, fontSize: 14, marginBottom: 6 }}>Por semana</div>
            <p style={{ color: C.textDim, fontSize: 12, margin: "0 0 12px", lineHeight: 1.45 }}>
              Lo que entró sale de los cortes, no de una estimación. v1: medicamento, nómina y gastos se teclean.
            </p>
            {!semanas.length ? (
              <div style={{ color: C.textMid, fontSize: 12 }}>Sin semanas en este período.</div>
            ) : (
              <table style={{ width: "100%", minWidth: 640, borderCollapse: "collapse", fontSize: 12 }}>
                <thead>
                  <tr style={{ background: C.cardDark }}>
                    {["Semana", "Entró", "Medicamento", "Nómina", "Gastos", "Quedó"].map((h) => (
                      <th key={h} style={{ padding: "8px 10px", textAlign: h === "Semana" ? "left" : "right", color: C.textMid, fontWeight: 700, borderBottom: `1px solid ${C.border}` }}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {semanas.map((s, i) => (
                    <tr key={s.semana || i} style={{ background: i % 2 ? C.bg : "transparent" }}>
                      <td style={{ padding: "10px", borderBottom: `1px solid ${C.border}`, fontWeight: 700, color: C.text }}>
                        {labelSemana(s.semana)}
                        <div style={{ height: 6, background: C.border, borderRadius: 4, marginTop: 6, overflow: "hidden" }}>
                          <div style={{ width: `${pctBarra(s.entro, maxSem)}%`, height: "100%", background: C.teal, borderRadius: 4 }} />
                        </div>
                      </td>
                      <td style={{ padding: "10px", borderBottom: `1px solid ${C.border}`, textAlign: "right", fontVariantNumeric: "tabular-nums", color: C.teal, fontWeight: 700 }}>{$(s.entro)}</td>
                      <td style={{ padding: "10px", borderBottom: `1px solid ${C.border}`, textAlign: "right", fontVariantNumeric: "tabular-nums" }}>{$(s.medicamento)}</td>
                      <td style={{ padding: "10px", borderBottom: `1px solid ${C.border}`, textAlign: "right", fontVariantNumeric: "tabular-nums" }}>{$(s.nomina)}</td>
                      <td style={{ padding: "10px", borderBottom: `1px solid ${C.border}`, textAlign: "right", fontVariantNumeric: "tabular-nums" }}>{$(s.gastos)}</td>
                      <td style={{ padding: "10px", borderBottom: `1px solid ${C.border}`, textAlign: "right", fontVariantNumeric: "tabular-nums", fontWeight: 800, color: Number(s.quedo) >= 0 ? C.green : C.red }}>{$(s.quedo)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </Box>
        </>
      )}

      {sub === "gastos" && (
        <>
          <Banner nivel="info" titulo="v1: casi todo se teclea">
            Automático de verdad: lo que entró por caja y la liquidación de recargas (se resta sola; no la captures otra vez).
            Nómina, renta, luz y pago a Nadro/Levic van a mano. No hay columna “lo que llega solo”.
          </Banner>

          <Box style={{ padding: 16, marginBottom: 16 }}>
            <div style={{ color: C.text, fontWeight: 800, fontSize: 14, marginBottom: 10 }}>Alta rápida — menos de 10 segundos</div>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(min(100%,160px),1fr))", gap: 10, alignItems: "end" }}>
              <label style={{ display: "flex", flexDirection: "column", gap: 4, fontSize: 11, fontWeight: 700, color: C.textMid }}>
                FECHA
                <input type="date" value={form.fecha} onChange={(e) => setForm((f) => ({ ...f, fecha: e.target.value }))} style={inp} />
              </label>
              <label style={{ display: "flex", flexDirection: "column", gap: 4, fontSize: 11, fontWeight: 700, color: C.textMid }}>
                CATEGORÍA
                <select
                  value={form.categoria}
                  onChange={(e) => setForm((f) => ({ ...f, categoria: e.target.value }))}
                  style={inp}
                >
                  {opcionesCategoriaGasto().map((o) => (
                    <option key={o.id} value={o.id}>{o.label}</option>
                  ))}
                </select>
              </label>
              <label style={{ display: "flex", flexDirection: "column", gap: 4, fontSize: 11, fontWeight: 700, color: C.textMid, gridColumn: "span 2" }}>
                CONCEPTO
                <input
                  value={form.concepto}
                  onChange={(e) => setForm((f) => ({ ...f, concepto: e.target.value }))}
                  placeholder={form.categoria === CATEGORIA_COMPRA_INVENTARIO ? "Ej. Pago Nadro 4-sep" : "Ej. Renta septiembre"}
                  style={inp}
                />
              </label>
              <label style={{ display: "flex", flexDirection: "column", gap: 4, fontSize: 11, fontWeight: 700, color: C.textMid }}>
                MONTO
                <input
                  type="number"
                  min={0}
                  step="0.01"
                  value={form.monto}
                  onChange={(e) => setForm((f) => ({ ...f, monto: e.target.value }))}
                  placeholder="0.00"
                  style={inp}
                />
              </label>
              <label style={{ display: "flex", flexDirection: "column", gap: 4, fontSize: 11, fontWeight: 700, color: C.textMid }}>
                PROVEEDOR (opcional)
                <input
                  value={form.proveedor}
                  onChange={(e) => setForm((f) => ({ ...f, proveedor: e.target.value }))}
                  placeholder="Nadro, CFE…"
                  style={inp}
                />
              </label>
              <label style={{ display: "flex", alignItems: "center", gap: 8, fontSize: 12, color: C.text, paddingBottom: 8 }}>
                <input
                  type="checkbox"
                  checked={form.es_recurrente}
                  onChange={(e) => setForm((f) => ({ ...f, es_recurrente: e.target.checked }))}
                />
                Recurrente (entra a comprometido 30 días)
              </label>
              <Btn col={BRAND.primary} onClick={registrar} dis={saving || !usuario}>
                {saving ? "Guardando…" : "Guardar"}
              </Btn>
            </div>
            {form.categoria === CATEGORIA_COMPRA_INVENTARIO ? (
              <p style={{ color: C.textMid, fontSize: 12, margin: "10px 0 0", lineHeight: 1.45 }}>
                Esta salida cuenta en Flujo. <strong style={{ color: C.text }}>No es pérdida</strong>: el servidor pone afecta_pl = false.
              </p>
            ) : null}
          </Box>

          <Box style={{ padding: 0, overflow: "auto" }}>
            <table style={{ width: "100%", minWidth: 560, borderCollapse: "collapse", fontSize: 12 }}>
              <thead>
                <tr style={{ background: C.cardDark }}>
                  {["Fecha", "Categoría", "Concepto", "Origen", "P&L", "Monto", ""].map((h) => (
                    <th key={h || "x"} style={{ padding: "10px 12px", textAlign: h === "Monto" ? "right" : "left", color: C.textMid, fontWeight: 700, borderBottom: `1px solid ${C.border}` }}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {!(bundle.gastos || []).length ? (
                  <tr>
                    <td colSpan={7} style={{ padding: 16, color: C.textMid }}>
                      Sin gastos capturados en este período. Un mes vacío se ve excelente — por eso la alerta de captura.
                    </td>
                  </tr>
                ) : (bundle.gastos || []).map((g, i) => (
                  <tr key={g.id} style={{ background: i % 2 ? C.bg : "transparent" }}>
                    <td style={{ padding: "10px 12px", borderBottom: `1px solid ${C.border}` }}>{g.fecha}</td>
                    <td style={{ padding: "10px 12px", borderBottom: `1px solid ${C.border}` }}>{etiquetaCategoriaGasto(g.categoria)}</td>
                    <td style={{ padding: "10px 12px", borderBottom: `1px solid ${C.border}`, color: C.text, fontWeight: 600 }}>{g.concepto}</td>
                    <td style={{ padding: "10px 12px", borderBottom: `1px solid ${C.border}` }}>
                      <Tag sm col={g.origen === "manual" ? C.textMid : C.teal}>{g.origen === "manual" ? "manual (v1)" : g.origen}</Tag>
                    </td>
                    <td style={{ padding: "10px 12px", borderBottom: `1px solid ${C.border}`, color: C.textDim, fontSize: 11 }}>
                      {g.afecta_pl === false ? "No (inventario)" : "Sí"}
                    </td>
                    <td style={{ padding: "10px 12px", borderBottom: `1px solid ${C.border}`, textAlign: "right", fontWeight: 800, fontVariantNumeric: "tabular-nums" }}>{$(g.monto)}</td>
                    <td style={{ padding: "10px 8px", borderBottom: `1px solid ${C.border}` }}>
                      <button
                        type="button"
                        onClick={() => eliminar(g)}
                        style={{
                          padding: "4px 8px",
                          borderRadius: 6,
                          border: `1px solid ${C.red}40`,
                          background: C.redDim,
                          color: C.red,
                          fontSize: 10,
                          fontWeight: 700,
                          cursor: "pointer",
                        }}
                      >
                        Quitar
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </Box>
        </>
      )}
    </div>
  );
}
