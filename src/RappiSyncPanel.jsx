import { useCallback, useEffect, useState } from "react";
import { Download, Pause, Play, RefreshCw, ShoppingBag, TrendingUp } from "lucide-react";
import { C_LIGHT, BRAND } from "./constants";
import { supabase } from "./supabase";
import { AyudaDesplegable, Box, Btn, Tag, showToast, SkeletonTable } from "./ui";
import RappiPreciosPanel from "./RappiPreciosPanel";
import {
  csvCargaRappi,
  descargarTextoCsv,
  nombreArchivoCargaRappi,
  reservaMostradorDe,
} from "./lib/rappiCargaCsv";

const PAGE_CARGA = 1000;
const SELECT_CARGA = [
  "id", "sku", "nombre", "codigo_barras", "stock", "precio", "activo",
  "requiere_receta", "controlado", "categoria", "venta_unidad",
  "unidades_por_caja", "presentacion", "forma_farmaceutica",
].join(",");

async function fetchProductosCargaRappi() {
  const all = [];
  let from = 0;
  let select = SELECT_CARGA;
  for (;;) {
    const { data, error } = await supabase
      .from("productos")
      .select(select)
      .order("id")
      .range(from, from + PAGE_CARGA - 1);
    if (error && /controlado/i.test(error.message || "") && select.includes("controlado")) {
      select = SELECT_CARGA.replace(",controlado", "");
      continue;
    }
    if (error) throw error;
    all.push(...(data || []));
    if (!data || data.length < PAGE_CARGA) return all;
    from += PAGE_CARGA;
  }
}

async function descargarCsvPartnerRappi() {
  const [cfgRes, productos] = await Promise.all([
    supabase.from("configuracion").select("valor").eq("clave", "rappi_reserva_mostrador").maybeSingle(),
    fetchProductosCargaRappi(),
  ]);
  const reserva = reservaMostradorDe(cfgRes.data?.valor);
  const csv = csvCargaRappi(productos, reserva);
  const filas = Math.max(0, csv.trim().split("\n").length - 1);
  if (!filas) throw new Error("No hay productos con SKU para armar el CSV");
  descargarTextoCsv(nombreArchivoCargaRappi(), csv);
  return { filas, reserva };
}

const C = C_LIGHT;
const STALE_MS = 10 * 60 * 1000;

function upsertConfig(clave, valor) {
  const tok = sessionStorage.getItem("farmacapital_session_token");
  if (!tok) return Promise.resolve({ error: { message: "Sesión no iniciada" } });
  return supabase.rpc("empleado_upsert_configuracion", {
    p_session_token: tok,
    p_clave: clave,
    p_valor: String(valor),
  });
}

function fmtWhen(iso) {
  if (!iso) return "—";
  try {
    return new Date(iso).toLocaleString("es-MX", {
      dateStyle: "short",
      timeStyle: "short",
    });
  } catch {
    return iso;
  }
}

const SUB_KEY = "farmacapital_rappi_subtab";

function loadSubTab() {
  try {
    const saved = sessionStorage.getItem(SUB_KEY);
    return saved === "precios" || saved === "disponibilidad" ? saved : "precios";
  } catch {
    return "precios";
  }
}

export default function RappiSyncPanel() {
  const [sub, setSub] = useState(loadSubTab);
  const [descargando, setDescargando] = useState(false);
  const selectSub = (id) => {
    setSub(id);
    try { sessionStorage.setItem(SUB_KEY, id); } catch { /* noop */ }
  };

  const onDescargarCsv = async () => {
    setDescargando(true);
    try {
      const { filas, reserva } = await descargarCsvPartnerRappi();
      showToast(`CSV listo: ${filas} SKUs · stock − ${reserva}. Súbelo en Rappi Partner → Subir plantilla.`, "success");
    } catch (err) {
      showToast(err.message || "No se pudo armar el CSV de Rappi", "error");
    }
    setDescargando(false);
  };

  return (
    <div>
      <div style={{
        padding: "12px 24px 0",
        display: "flex",
        alignItems: "flex-end",
        justifyContent: "space-between",
        gap: 12,
        flexWrap: "wrap",
        borderBottom: `1px solid ${C.border}`,
        background: C.card,
      }}>
        <div style={{ display: "flex", gap: 6 }}>
          {[
            { id: "precios", label: "Precios en línea", icon: TrendingUp },
            { id: "disponibilidad", label: "Disponibilidad", icon: ShoppingBag },
          ].map((t) => {
            const active = sub === t.id;
            const Icon = t.icon;
            return (
              <button
                key={t.id}
                type="button"
                onClick={() => selectSub(t.id)}
                style={{
                  display: "inline-flex", alignItems: "center", gap: 6,
                  padding: "10px 14px", marginBottom: -1,
                  background: "transparent", border: "none",
                  borderBottom: `2px solid ${active ? BRAND.primary : "transparent"}`,
                  color: active ? BRAND.primary : C.textMid,
                  fontWeight: 700, fontSize: 13, cursor: "pointer",
                }}
              >
                <Icon size={15} strokeWidth={2.1} aria-hidden />
                {t.label}
              </button>
            );
          })}
        </div>
        <div style={{ paddingBottom: 8 }}>
          <Btn
            sm
            col={BRAND.primary}
            onClick={onDescargarCsv}
            dis={descargando}
            style={{ display: "inline-flex", gap: 6, alignItems: "center" }}
          >
            <Download size={14} aria-hidden />
            {descargando ? "Armando CSV…" : "Descargar CSV Rappi"}
          </Btn>
        </div>
      </div>
      {sub === "precios" ? <RappiPreciosPanel /> : <RappiDisponibilidadPanel />}
    </div>
  );
}

function RappiDisponibilidadPanel() {
  const [loading, setLoading] = useState(true);
  const [paused, setPaused] = useState(false);
  const [reserva, setReserva] = useState("2");
  const [saving, setSaving] = useState(false);
  const [errors, setErrors] = useState([]);
  const [stale, setStale] = useState([]);
  const [pendingCount, setPendingCount] = useState(0);

  const load = useCallback(async () => {
    setLoading(true);
    const cutoff = new Date(Date.now() - STALE_MS).toISOString();
    const [cfgRes, errRes, staleRes, pendRes] = await Promise.all([
      supabase.from("configuracion").select("clave,valor").in("clave", ["rappi_sync_paused", "rappi_reserva_mostrador"]),
      supabase
        .from("rappi_sync_queue")
        .select("id,sku,estado,intentos,last_error,payload,created_at,processed_at")
        .eq("estado", "error")
        .order("created_at", { ascending: false })
        .limit(40),
      supabase
        .from("rappi_sync_queue")
        .select("id,sku,estado,intentos,last_error,payload,created_at,available_at")
        .eq("estado", "pendiente")
        .lt("created_at", cutoff)
        .order("created_at", { ascending: true })
        .limit(40),
      supabase
        .from("rappi_sync_queue")
        .select("id", { count: "exact", head: true })
        .eq("estado", "pendiente"),
    ]);
    const cfg = {};
    for (const row of cfgRes.data || []) cfg[row.clave] = row.valor;
    setPaused(String(cfg.rappi_sync_paused || "").toLowerCase() === "true");
    setReserva(cfg.rappi_reserva_mostrador || "2");
    setErrors(errRes.data || []);
    setStale(staleRes.data || []);
    setPendingCount(pendRes.count || 0);
    setLoading(false);
    if (errRes.error && /rappi_sync_queue/.test(errRes.error.message || "")) {
      showToast("Corré sql/patch_rappi_sync_20260819.sql en Supabase para crear la cola.", "error");
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const togglePause = async () => {
    setSaving(true);
    const next = !paused;
    const { data, error } = await upsertConfig("rappi_sync_paused", next ? "true" : "false");
    setSaving(false);
    if (error || data?.success === false) {
      showToast(error?.message || data?.error || "No se pudo pausar el sync", "error");
      return;
    }
    setPaused(next);
    showToast(next ? "Sync Rappi pausado. La cola sigue acumulando cambios." : "Sync Rappi reanudado.", "success");
  };

  return (
    <div style={{ padding: "18px 24px 40px", maxWidth: 920 }}>
      <div style={{ display: "flex", alignItems: "flex-start", justifyContent: "space-between", gap: 16, flexWrap: "wrap", marginBottom: 16 }}>
        <div>
          <h2 style={{ margin: 0, fontSize: 16, fontWeight: 800, color: C.text, display: "flex", alignItems: "center", gap: 8 }}>
            <ShoppingBag size={18} strokeWidth={2.2} aria-hidden />
            Rappi · disponibilidad
          </h2>
          <AyudaDesplegable>
            Se publica <code>stock − {reserva}</code> piezas de colchón. Receta y controlados no salen.
            Sin <code>RAPPI_CLIENT_ID</code> el worker no llama a Rappi: queda inerte.
          </AyudaDesplegable>
        </div>
        <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
          <Btn sm ol onClick={load} dis={loading} style={{ display: "inline-flex", gap: 6, alignItems: "center" }}>
            <RefreshCw size={14} aria-hidden />
            Actualizar
          </Btn>
          <Btn
            sm
            col={paused ? BRAND.primary : C.red}
            onClick={togglePause}
            dis={saving}
            style={{ display: "inline-flex", gap: 6, alignItems: "center" }}
          >
            {paused ? <Play size={14} aria-hidden /> : <Pause size={14} aria-hidden />}
            {paused ? "Reanudar sync" : "Pausar sync"}
          </Btn>
        </div>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(160px, 1fr))", gap: 10, marginBottom: 18 }}>
        <Box style={{ padding: 14 }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: C.textDim, letterSpacing: 0.4, textTransform: "uppercase" }}>Estado</div>
          <div style={{ marginTop: 6 }}>
            <Tag col={paused ? C.amber : C.green} sm>{paused ? "Pausado" : "Activo"}</Tag>
          </div>
        </Box>
        <Box style={{ padding: 14 }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: C.textDim, letterSpacing: 0.4, textTransform: "uppercase" }}>Pendientes</div>
          <div style={{ marginTop: 6, fontSize: 22, fontWeight: 800, color: C.text }}>{pendingCount}</div>
        </Box>
        <Box style={{ padding: 14 }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: C.textDim, letterSpacing: 0.4, textTransform: "uppercase" }}>Errores</div>
          <div style={{ marginTop: 6, fontSize: 22, fontWeight: 800, color: errors.length ? C.red : C.text }}>{errors.length}</div>
        </Box>
        <Box style={{ padding: 14 }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: C.textDim, letterSpacing: 0.4, textTransform: "uppercase" }}>Desfasados</div>
          <div style={{ marginTop: 6, fontSize: 22, fontWeight: 800, color: stale.length ? C.amber : C.text }}>{stale.length}</div>
          <div style={{ fontSize: 11, color: C.textDim, marginTop: 4 }}>Pendiente &gt; 10 min</div>
        </Box>
      </div>

      <Box style={{ padding: 16, marginBottom: 14 }}>
        <div style={{ fontWeight: 800, fontSize: 13, color: C.text, marginBottom: 10 }}>SKUs desincronizados</div>
        {loading ? (
          <SkeletonTable rows={4} cols={4} />
        ) : stale.length === 0 ? (
          <div style={{ color: C.textMid, fontSize: 13 }}>Nada pendiente viejo. La cola se drena con el webhook o el cron diario.</div>
        ) : (
          <QueueTable rows={stale} />
        )}
      </Box>

      <Box style={{ padding: 16 }}>
        <div style={{ fontWeight: 800, fontSize: 13, color: C.text, marginBottom: 10 }}>Últimos errores</div>
        {loading ? (
          <SkeletonTable rows={4} cols={4} />
        ) : errors.length === 0 ? (
          <div style={{ color: C.textMid, fontSize: 13 }}>Sin errores registrados.</div>
        ) : (
          <QueueTable rows={errors} showError />
        )}
      </Box>
    </div>
  );
}

function QueueTable({ rows, showError }) {
  return (
    <div style={{ overflowX: "auto" }}>
      <table className="fc-tabla-cards" style={{ width: "100%", borderCollapse: "collapse", fontSize: 12 }}>
        <thead>
          <tr style={{ textAlign: "left", color: C.textDim }}>
            <th style={th}>SKU</th>
            <th style={th}>Estado</th>
            <th style={th}>Intentos</th>
            <th style={th}>Cuándo</th>
            {showError ? <th style={th}>Error</th> : null}
          </tr>
        </thead>
        <tbody>
          {rows.map((r) => (
            <tr key={r.id} style={{ borderTop: `1px solid ${C.border}` }}>
              <td data-label="SKU" data-primary style={td}><code>{r.sku}</code></td>
              <td data-label="Estado" style={td}>{r.estado}</td>
              <td data-label="Intentos" style={td}>{r.intentos}</td>
              <td data-label="Cuándo" style={td}>{fmtWhen(r.processed_at || r.created_at)}</td>
              {showError ? (
                <td data-label="Error" data-wide style={{ ...td, color: C.red, maxWidth: 280 }}>{r.last_error || "—"}</td>
              ) : null}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

const th = { padding: "6px 8px 8px 0", fontWeight: 700, fontSize: 11, letterSpacing: 0.3, textTransform: "uppercase" };
const td = { padding: "8px 8px 8px 0", color: C.text, verticalAlign: "top" };
