import { useCallback, useEffect, useMemo, useState } from "react";
import { Banknote, BarChart3, Receipt } from "lucide-react";
import { C_LIGHT, BRAND } from "./constants";
import { SegmentedNav } from "./components/SegmentedNav";
import { Switch } from "./components/Switch";
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
  PISO_FONDO_FLUJO,
  anioMesDe,
  flujoEstaConfigurado,
  labelSemana,
  maxAbsSemanas,
  parseFlujoBundle,
  pctBarra,
} from "./lib/flujoCaja";

const C = C_LIGHT;

const TITLE_RESULTADOS = "Disponible cuando el sistema sepa cuánto costó lo que vendiste.";

const MESES_LARGOS = [
  "enero", "febrero", "marzo", "abril", "mayo", "junio",
  "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre",
];

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

function partesYmd(iso) {
  const [y, m, d] = String(iso || "").slice(0, 10).split("-").map(Number);
  if (!y || !m || !d) return null;
  return { y, m, d };
}

function leyendaRango(desde, hasta) {
  const a = partesYmd(desde);
  const b = partesYmd(hasta);
  if (!a || !b) return "";
  const mesA = MESES_LARGOS[a.m - 1];
  const mesB = MESES_LARGOS[b.m - 1];
  if (a.y === b.y && a.m === b.m) return `${a.d} – ${b.d} de ${mesA}`;
  if (a.y === b.y) return `${a.d} de ${mesA} – ${b.d} de ${mesB}`;
  return `${a.d} de ${mesA} de ${a.y} – ${b.d} de ${mesB} de ${b.y}`;
}

function leyendaApertura(fecha, saldo) {
  const p = partesYmd(fecha);
  if (!p) return "";
  const money = Number.isFinite(Number(saldo))
    ? Number(saldo).toLocaleString("es-MX", { style: "currency", currency: "MXN" })
    : "";
  return `Caja abierta el ${p.d} de ${MESES_LARGOS[p.m - 1]}${money ? ` con ${money}` : ""}`;
}

function subtextoSalio(salio) {
  const s = salio || {};
  const parts = [
    { n: Number(s.medicamento) || 0, label: "medicamento" },
    { n: Number(s.nomina) || 0, label: "nómina" },
    { n: Number(s.otros_gastos) || 0, label: "gastos" },
    { n: Number(s.liquidacion_mp) || 0, label: "liquidación Mercado Pago" },
  ].filter((p) => p.n !== 0);
  if (parts.length === 1 && parts[0].label === "liquidación Mercado Pago") {
    return "Todo de liquidación Mercado Pago";
  }
  if (parts.length === 0) return "Sin salidas en este período";
  if (parts.length === 1) return `Todo de ${parts[0].label}`;
  return parts.map((p) => p.label).join(" · ");
}

function esCero(n) {
  return !(Number(n) || 0);
}

function nombreCorto(nombre) {
  const t = String(nombre || "").trim();
  if (!t) return "";
  return t.split(/\s+/)[0];
}

function FlujoRails({ sub, onSub, periodo, onPeriodo }) {
  return (
    <div className="fc-flujo-rails">
      <SegmentedNav
        size="sm"
        activation="auto"
        idPrefix="flujo"
        ariaLabel="Secciones de flujo de caja"
        value={sub}
        onChange={onSub}
        items={[
          { id: "flujo", label: "Flujo", Icon: Banknote },
          { id: "resultados", label: "Resultados · pronto", Icon: BarChart3, disabled: true, title: TITLE_RESULTADOS },
          { id: "gastos", label: "Gastos", Icon: Receipt },
        ]}
      />
      <SegmentedNav
        size="sm"
        activation="auto"
        ariaLabel="Período del flujo"
        value={periodo}
        onChange={onPeriodo}
        items={[
          { id: "dia", label: "Hoy" },
          { id: "semana", label: "Esta semana" },
          { id: "mes", label: "Este mes" },
        ]}
      />
    </div>
  );
}

function FlujoHead({ setPage, onRegistrar }) {
  return (
    <div className="fc-flujo-head">
      <h2>Flujo de caja</h2>
      <div className="fc-flujo-actions">
        <button
          type="button"
          className="fc-btn-tertiary"
          onClick={() => showToast("La exportación llega en una siguiente versión.", "info")}
        >
          Exportar XLS
        </button>
        {typeof setPage === "function" ? (
          <Btn sm ol col={C.textMid} onClick={() => irAjustesFinanzas(setPage)}>
            Ajustes de finanzas
          </Btn>
        ) : null}
        <Btn sm col={BRAND.primary} onClick={onRegistrar}>+ Registrar gasto</Btn>
      </div>
    </div>
  );
}

function Fold({ title, children }) {
  return (
    <details className="fc-fold">
      <summary>{title}</summary>
      <div className="fc-fold-body">{children}</div>
    </details>
  );
}

function moneyCell(n, { color, weight } = {}) {
  const zero = esCero(n);
  return {
    padding: "10px",
    borderBottom: `1px solid ${C.border}`,
    textAlign: "right",
    fontVariantNumeric: "tabular-nums",
    color: zero ? "#94a3b8" : (color || C.text),
    fontWeight: zero ? 400 : (weight || 700),
  };
}

export default function FlujoCajaTab({ usuario, setPage, showConfirm, demoBundle }) {
  const esDemo = Boolean(demoBundle);
  const [sub, setSub] = useState("flujo");
  const [periodo, setPeriodo] = useState("mes");
  const [bundle, setBundle] = useState(() => (demoBundle ? parseFlujoBundle(demoBundle) : null));
  const [loading, setLoading] = useState(!demoBundle);
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
    if (esDemo) {
      setBundle(parseFlujoBundle(demoBundle));
      setLoading(false);
      setErrorCarga(null);
      return;
    }
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
        ? "Falta aplicar en la base las actualizaciones de finanzas."
        : "No se pudo cargar el flujo: " + msg;
      showToast(texto, "error");
      setErrorCarga(texto);
      setBundle(null);
      setLoading(false);
      return;
    }
    setBundle(parseFlujoBundle(data));
    setLoading(false);
  }, [demoBundle, esDemo, rango.desdeFecha, rango.hastaFecha]);

  useEffect(() => { cargar(); }, [cargar]);

  const configurado = flujoEstaConfigurado(bundle);
  const semanas = bundle?.semanas || [];
  const maxSem = maxAbsSemanas(semanas);
  const incompleta = bundle?.completitud?.incompleta !== false;
  const mesMarca = bundle?.completitud?.mes || anioMesDe(rango.hastaFecha);
  const fechaApertura = bundle?.fecha_inicio || bundle?.piso_aplicado || PISO_FONDO_FLUJO;

  const registrar = async () => {
    if (esDemo) {
      showToast("Esta es una vista de ejemplo: aquí no se guarda.", "info");
      return;
    }
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
    if (esDemo) {
      setBundle((b) => (b ? { ...b, completitud: { ...(b.completitud || {}), sin_compra: marcar } } : b));
      return;
    }
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

  const irGastos = () => setSub("gastos");

  if (loading && !bundle) {
    return (
      <div>
        <FlujoRails sub={sub} onSub={setSub} periodo={periodo} onPeriodo={setPeriodo} />
        <SkeletonKPIs count={4} />
        <SkeletonTable rows={4} cols={6} />
      </div>
    );
  }

  if (errorCarga) {
    return (
      <div>
        <FlujoRails sub={sub} onSub={setSub} periodo={periodo} onPeriodo={setPeriodo} />
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
        <FlujoRails sub={sub} onSub={setSub} periodo={periodo} onPeriodo={setPeriodo} />
        <Box style={{ padding: 22, background: C.amberDim, border: `1px solid ${C.amber}55` }}>
          <div style={{ color: C.text, fontWeight: 800, fontSize: 16, marginBottom: 8 }}>
            Falta una apertura de caja con fondo
          </div>
          <p style={{ color: C.textMid, fontSize: 13, lineHeight: 1.55, margin: "0 0 12px" }}>
            No hay ninguna apertura de caja con fondo contado. El flujo usa esa primera apertura — no el fondo de hoy.
            Abre caja contando el cambio; no hace falta teclear un saldo en Ajustes.
          </p>
          <p style={{ color: C.textMid, fontSize: 13, lineHeight: 1.55, margin: "0 0 16px" }}>
            Lo que entra lo leemos de los cortes. El punto de partida es el{" "}
            <strong style={{ color: C.text }}>fondo de la primera apertura</strong>
            {" "}(en esta farmacia, a partir del 18 de agosto). No uses el fondo de hoy: ese crecimiento ya viaja en los cortes.
          </p>
          {typeof setPage === "function" ? (
            <Btn ol col={BRAND.primary} onClick={() => irAjustesFinanzas(setPage)}>
              Ajuste opcional en Metas y Precios
            </Btn>
          ) : null}
        </Box>
      </div>
    );
  }

  const quedoCol = incompleta ? C.textMid : (Number(bundle.quedo) >= 0 ? C.green : C.red);
  const cajaCol = incompleta ? C.textMid : C.teal;
  const liq = Number(bundle.cubetas?.saldo_mp_liquidacion) || 0;
  const utilidad = Number(bundle.cubetas?.utilidad_servicios) || 0;
  const marcadoPor = nombreCorto(usuario?.nombre);
  const leyenda = [
    leyendaRango(bundle.desde, bundle.hasta),
    leyendaApertura(fechaApertura, bundle.saldo_inicial),
  ].filter(Boolean).join(" · ");

  return (
    <div>
      <FlujoHead setPage={setPage} onRegistrar={irGastos} />
      <FlujoRails sub={sub} onSub={setSub} periodo={periodo} onPeriodo={setPeriodo} />

      <div className="fc-flujo-legend">
        <span>{leyenda}</span>
        <Fold title="ⓘ Cómo se calcula">
          Lo que entra sale de los cortes de caja. El punto de partida es la primera apertura con fondo
          {bundle.origen_piso === "config" ? " (o el ajuste que pusiste en Metas y Precios)" : ""}.
          {bundle.recortado_por_fondo ? " El período se recorta al día de esa apertura." : ""}
          {" "}Nómina, renta y pago a proveedor los capturas tú.
        </Fold>
      </div>

      {sub === "flujo" && (
        <div
          id="flujo-panel-flujo"
          role="tabpanel"
          aria-labelledby="flujo-tab-flujo"
          tabIndex={0}
        >
          <div style={KPI_ROW}>
            <KPI
              label="Entró"
              value={$(bundle.entro)}
              col={C.teal}
              sub="De los cortes de caja"
            />
            <KPI
              label="Salió"
              value={$(bundle.salio?.total)}
              col={C.red}
              sub={subtextoSalio(bundle.salio)}
            />
            <KPI
              label="Quedó"
              value={$(bundle.quedo)}
              col={quedoCol}
              sub={incompleta ? <span className="fc-chip-amber">Faltan gastos por capturar</span> : null}
            />
            <KPI
              label="En caja hoy"
              value={$(bundle.en_caja_hoy)}
              col={cajaCol}
              sub="Dinero contado hasta hoy"
            />
          </div>

          {incompleta ? (
            <div className="fc-alert">
              <h6>Faltan gastos por capturar este mes</h6>
              <p>
                Las ventas y los cortes entran solos. La nómina, la renta y el pago a proveedor los capturas tú — por eso Quedó se ve más alto de lo que realmente es.
              </p>
              <div className="fc-alert-foot">
                <Btn sm col={BRAND.primary} onClick={irGastos}>Capturar gastos</Btn>
                <Switch
                  id="flujo-sin-compra"
                  checked={Boolean(bundle.completitud?.sin_compra)}
                  onChange={marcarSinCompra}
                  label="Este mes no compré a proveedor"
                />
                {bundle.completitud?.sin_compra && marcadoPor ? (
                  <span className="fc-alert-attr">Marcado por {marcadoPor}</span>
                ) : null}
              </div>
            </div>
          ) : null}

          <section className="fc-recon">
            <h3 className="fc-recon-title">Recargas: el efectivo ya está contado</h3>
            <dl className="fc-recon-grid">
              <div>
                <dt>Cobrado en efectivo</dt>
                <dd>
                  {$(bundle.cubetas?.cajon_cobrado_servicios)}
                  <span className="fc-recon-note">entró al cajón</span>
                </dd>
              </div>
              <div>
                <dt>Descontado por Mercado Pago</dt>
                <dd className="is-neg">
                  −{$(bundle.cubetas?.saldo_mp_liquidacion)}
                  <span className="fc-recon-note">el mismo día</span>
                </dd>
              </div>
              <div>
                <dt>Te abonó Mercado Pago</dt>
                <dd>
                  {$(bundle.cubetas?.saldo_mp_compensacion)}
                  <span className="fc-recon-note">no pasa por el cajón</span>
                </dd>
              </div>
              <div>
                <dt>Tu ganancia</dt>
                <dd className="is-pos">
                  {$(bundle.cubetas?.utilidad_servicios)}
                  <span className="fc-recon-note">esto sí es utilidad</span>
                </dd>
              </div>
            </dl>
            <Fold title={`¿Por qué los ${$(liq)} aparecen dos veces?`}>
              Cuando cobras una recarga, el efectivo entra al cajón y se cuenta en el corte. Ese mismo día Mercado Pago te descuenta el monto de tu saldo. Es el mismo dinero pasando, no un error. Lo que de verdad ganaste fueron {$(utilidad)}.
            </Fold>
          </section>

          <Fold title="¿Por qué comprar medicamento no aparece como pérdida?">
            Porque cambiaste dinero por inventario. El dinero sale del flujo —ya no lo tienes— pero no perdiste nada: la mercancía vale lo que pagaste por ella. La ganancia o la pérdida se calcula cuando la vendes.
          </Fold>

          <Box style={{ padding: 16, marginBottom: 16, overflow: "auto" }}>
            <div style={{ color: C.text, fontWeight: 800, fontSize: 14, marginBottom: 12 }}>Por semana</div>
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
                      <td style={moneyCell(s.entro, { color: C.teal })}>{$(s.entro)}</td>
                      <td style={moneyCell(s.medicamento)}>{$(s.medicamento)}</td>
                      <td style={moneyCell(s.nomina)}>{$(s.nomina)}</td>
                      <td style={moneyCell(s.gastos)}>{$(s.gastos)}</td>
                      <td style={moneyCell(s.quedo, { color: Number(s.quedo) >= 0 ? C.green : C.red, weight: 800 })}>{$(s.quedo)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </Box>
        </div>
      )}

      {sub === "gastos" && (
        <div
          id="flujo-panel-gastos"
          role="tabpanel"
          aria-labelledby="flujo-tab-gastos"
          tabIndex={0}
        >
          <p style={{ color: C.textMid, fontSize: 12.5, lineHeight: 1.5, margin: "0 0 16px", maxWidth: "78ch" }}>
            Las ventas y los cortes entran solos. La liquidación de recargas se resta sola: no la captures otra vez.
            Nómina, renta, luz y pago a Nadro o Levic los escribes tú.
          </p>

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
                Esta salida cuenta en Flujo. <strong style={{ color: C.text }}>No es pérdida</strong>: cambiaste dinero por inventario.
              </p>
            ) : null}
          </Box>

          <Box style={{ padding: 0, overflow: "auto" }}>
            <table style={{ width: "100%", minWidth: 560, borderCollapse: "collapse", fontSize: 12 }}>
              <thead>
                <tr style={{ background: C.cardDark }}>
                  {["Fecha", "Categoría", "Concepto", "Origen", "Ganancias", "Monto", ""].map((h) => (
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
                      <Tag sm col={g.origen === "manual" ? C.textMid : C.teal}>{g.origen === "manual" ? "a mano" : g.origen}</Tag>
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
        </div>
      )}
    </div>
  );
}
