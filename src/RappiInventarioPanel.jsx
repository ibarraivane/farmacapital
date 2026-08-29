import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { AlertTriangle, Download, RefreshCw, Upload } from "lucide-react";
import { C_LIGHT, BRAND } from "./constants";
import { supabase } from "./supabase";
import { Box, Btn, Tag, showToast, SkeletonTable } from "./ui";
import { inventarioProductMatchesBusqueda } from "./utils/fuzzySearch";
import {
  DEFAULT_RESERVA,
  INCIDENTE_PIOGLITAZONA,
  RAPPI_SKU_PREFIX,
  buildFilasInventario,
  csvCargaSegura,
  csvCruceCompleto,
  parseRappiInventarioCsv,
  resumirCruce,
} from "./lib/rappiInventario";

const C = C_LIGHT;
const PAGE = 1000;

async function fetchAllProductos() {
  const all = [];
  let from = 0;
  for (;;) {
    const { data, error } = await supabase
      .from("productos")
      .select("id,sku,nombre,codigo_barras,stock,precio,activo,requiere_receta,categoria")
      .order("id")
      .range(from, from + PAGE - 1);
    if (error) throw error;
    all.push(...(data || []));
    if (!data || data.length < PAGE) break;
    from += PAGE;
  }
  return all;
}

function descargarCsv(filename, text) {
  const blob = new Blob(["\uFEFF" + text], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

function hoyISO() {
  return new Date().toISOString().slice(0, 10);
}

const FILTROS = [
  { id: "peligro", label: "Peligro" },
  { id: "incidente", label: "Este pedido" },
  { id: "publicables", label: "Sí publicar" },
  { id: "todos", label: "Todos" },
];

export default function RappiInventarioPanel() {
  const [loading, setLoading] = useState(true);
  const [productos, setProductos] = useState([]);
  const [queueRows, setQueueRows] = useState([]);
  const [reserva, setReserva] = useState(DEFAULT_RESERVA);
  const [rappiRows, setRappiRows] = useState([]);
  const [rappiFile, setRappiFile] = useState("");
  const [q, setQ] = useState("");
  const [filtro, setFiltro] = useState("peligro");
  const fileRef = useRef(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [prods, queueRes, cfgRes] = await Promise.all([
        fetchAllProductos(),
        supabase
          .from("rappi_sync_queue")
          .select("id,sku,estado,payload,created_at,processed_at")
          .order("created_at", { ascending: false })
          .limit(500),
        supabase.from("configuracion").select("clave,valor").eq("clave", "rappi_reserva_mostrador"),
      ]);
      setProductos(prods);
      setQueueRows(queueRes.data || []);
      const raw = cfgRes.data?.[0]?.valor;
      const n = Number(raw);
      setReserva(Number.isFinite(n) && n >= 0 ? Math.trunc(n) : DEFAULT_RESERVA);
      if (queueRes.error && /rappi_sync_queue/.test(queueRes.error.message || "")) {
        showToast("Falta sql/patch_rappi_sync_20260819.sql en Supabase.", "error");
      }
    } catch (err) {
      showToast(err.message || "No se pudo leer el inventario", "error");
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const { filas, rappiSinMatch, resumen } = useMemo(() => {
    const built = buildFilasInventario({
      productos,
      queueRows,
      rappiRows,
      reserva,
      prefix: RAPPI_SKU_PREFIX,
    });
    return { ...built, resumen: resumirCruce(built.filas, built.rappiSinMatch) };
  }, [productos, queueRows, rappiRows, reserva]);

  const incidente = filas.find((f) => f.incidente) || null;

  const visibles = useMemo(() => {
    return filas.filter((f) => {
      if (filtro === "peligro" && f.alerta !== "peligro" && f.alerta !== "incidente" && f.alerta !== "desfase") {
        return false;
      }
      if (filtro === "incidente" && !f.incidente) return false;
      if (filtro === "publicables" && !f.disponible) return false;
      if (q && !inventarioProductMatchesBusqueda({
        nombre: f.nombre,
        sku: f.sku,
        codigo_barras: f.ean,
        principio_activo: "",
      }, q)) return false;
      return true;
    });
  }, [filas, filtro, q]);

  const onCsv = (e) => {
    const file = e.target.files?.[0];
    e.target.value = "";
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      try {
        const parsed = parseRappiInventarioCsv(String(reader.result || ""));
        if (!parsed.rows.length) {
          showToast("El CSV no tiene SKU/EAN/stock. Exportá Productos desde el partner de Rappi.", "error");
          return;
        }
        setRappiRows(parsed.rows);
        setRappiFile(file.name);
        setFiltro("peligro");
        showToast(`${parsed.rows.length} filas de Rappi leídas. Cruzá la columna “Rappi tiene”.`, "success");
      } catch (err) {
        showToast(err.message || "No se pudo leer el CSV", "error");
      }
    };
    reader.readAsText(file, "UTF-8");
  };

  return (
    <div style={{ padding: "18px 24px 40px", maxWidth: 1100 }}>
      <div style={{ display: "flex", justifyContent: "space-between", gap: 16, flexWrap: "wrap", marginBottom: 14 }}>
        <div>
          <h2 style={{ margin: 0, fontSize: 16, fontWeight: 800, color: C.text }}>
            Inventario vs Rappi
          </h2>
          <p style={{ margin: "6px 0 0", color: C.textMid, fontSize: 13, maxWidth: 640, lineHeight: 1.45 }}>
            Tres columnas: lo que hay en FarmaCapital, lo que <strong>debemos</strong> publicar
            (stock − {reserva} de colchón) y lo que Rappi tiene si pegás el CSV del partner.
            La cola automática no está pegando a Rappi: esos cambios se quedan pendientes.
          </p>
        </div>
        <div style={{ display: "flex", gap: 8, flexWrap: "wrap", alignItems: "center" }}>
          <Btn sm ol onClick={load} dis={loading} style={{ display: "inline-flex", gap: 6, alignItems: "center" }}>
            <RefreshCw size={14} aria-hidden />
            Actualizar
          </Btn>
          <Btn
            sm
            ol
            onClick={() => fileRef.current?.click()}
            style={{ display: "inline-flex", gap: 6, alignItems: "center" }}
          >
            <Upload size={14} aria-hidden />
            CSV de Rappi
          </Btn>
          <Btn
            sm
            col={BRAND.primary}
            onClick={() => descargarCsv(`rappi_carga_segura_${hoyISO()}.csv`, csvCargaSegura(filas))}
            dis={!filas.length}
            style={{ display: "inline-flex", gap: 6, alignItems: "center" }}
          >
            <Download size={14} aria-hidden />
            Carga segura
          </Btn>
        </div>
      </div>
      <input ref={fileRef} type="file" accept=".csv,.txt,text/csv" hidden onChange={onCsv} />

      {incidente ? (
        <Box style={{ padding: 16, marginBottom: 14, border: `1px solid ${C.red}`, background: C.redDim || "#fef2f2" }}>
          <div style={{ display: "flex", gap: 8, alignItems: "flex-start" }}>
            <AlertTriangle size={18} color={C.red} style={{ flexShrink: 0, marginTop: 2 }} aria-hidden />
            <div style={{ fontSize: 13, lineHeight: 1.45, color: C.text }}>
              <strong>Pedido Rappi {INCIDENTE_PIOGLITAZONA.orderId}</strong>
              {" · "}{INCIDENTE_PIOGLITAZONA.fecha.slice(8)}/{INCIDENTE_PIOGLITAZONA.fecha.slice(5, 7)}
              {" · "}{INCIDENTE_PIOGLITAZONA.tienda}
              <div style={{ marginTop: 6 }}>
                Pedían <strong>{INCIDENTE_PIOGLITAZONA.qtyPedida}</strong> de {incidente.nombre}
                {" "}(<code>{incidente.sku}</code> / EAN {incidente.ean}) a ${INCIDENTE_PIOGLITAZONA.precioRappi}.
                Hoy hay <strong>{incidente.stockLocal}</strong> en inventario; con colchón de {reserva}
                {" "}Rappi debería tener <strong>{incidente.stockPublicado}</strong> (apagado).
                El 19 ago la cola ya pidió apagarlo y <strong>sigue pendiente</strong>: Rappi nunca se enteró.
              </div>
            </div>
          </div>
        </Box>
      ) : null}

      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(140px, 1fr))", gap: 10, marginBottom: 14 }}>
        <Stat label="Peligro" value={resumen.peligro + resumen.incidente} col={(resumen.peligro || resumen.incidente) ? C.red : C.text} hint="Apagar pendiente o Rappi vende de más" />
        <Stat label="Cola apagar" value={resumen.colaApagar} col={resumen.colaApagar ? C.amber : C.text} hint="Cambio local que no salió" />
        <Stat label="Sí publicar" value={resumen.publicables} hint={`stock − ${reserva} > 0`} />
        <Stat label="Rappi CSV" value={rappiRows.length ? resumen.conRappi : "—"} hint={rappiFile || "Partner → Productos → exportar"} />
      </div>

      {rappiFile ? (
        <div style={{ fontSize: 12, color: C.textMid, marginBottom: 12 }}>
          Archivo Rappi: <strong style={{ color: C.text }}>{rappiFile}</strong>
          {rappiSinMatch.length ? ` · ${rappiSinMatch.length} SKUs de Rappi no están en el inventario` : ""}
          {" · "}
          <button
            type="button"
            onClick={() => { setRappiRows([]); setRappiFile(""); }}
            style={{ background: "none", border: "none", color: BRAND.primary, fontWeight: 700, cursor: "pointer", padding: 0 }}
          >
            Quitar
          </button>
        </div>
      ) : (
        <div style={{ fontSize: 12, color: C.textMid, marginBottom: 12 }}>
          Sin CSV de Rappi se marca peligro lo que la cola quiere apagar (como la Pioglitazona).
          Para ver “lo que Rappi tenía”, exportá el inventario del partner y cargalo aquí.
        </div>
      )}

      <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 12, alignItems: "center" }}>
        {FILTROS.map((f) => (
          <button
            key={f.id}
            type="button"
            onClick={() => setFiltro(f.id)}
            style={{
              padding: "6px 10px",
              borderRadius: 999,
              border: `1px solid ${filtro === f.id ? BRAND.primary : C.border}`,
              background: filtro === f.id ? "#eff6ff" : C.card,
              color: filtro === f.id ? BRAND.primary : C.textMid,
              fontWeight: 700,
              fontSize: 12,
              cursor: "pointer",
            }}
          >
            {f.label}
          </button>
        ))}
        <input
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder="Buscar nombre, SKU o EAN"
          style={{
            flex: "1 1 180px",
            minWidth: 160,
            padding: "7px 10px",
            borderRadius: 8,
            border: `1px solid ${C.border}`,
            fontSize: 13,
          }}
        />
        <Btn
          sm
          ol
          onClick={() => descargarCsv(`rappi_cruce_${hoyISO()}.csv`, csvCruceCompleto(filas))}
          dis={!filas.length}
        >
          Exportar cruce
        </Btn>
      </div>

      {loading ? (
        <SkeletonTable rows={8} cols={7} />
      ) : (
        <div style={{ overflowX: "auto" }}>
          <table className="fc-tabla-cards" style={{ width: "100%", borderCollapse: "collapse", fontSize: 12 }}>
            <thead>
              <tr style={{ textAlign: "left", color: C.textDim }}>
                <th style={th}>Alerta</th>
                <th style={th}>Producto</th>
                <th style={th}>Local</th>
                <th style={th}>Publicar</th>
                <th style={th}>Cola</th>
                <th style={th}>Rappi tiene</th>
              </tr>
            </thead>
            <tbody>
              {visibles.length === 0 ? (
                <tr>
                  <td colSpan={6} style={{ ...td, color: C.textMid, padding: "16px 0" }}>
                    Nada en este filtro.
                  </td>
                </tr>
              ) : visibles.map((f) => (
                <tr key={f.id} style={{ borderTop: `1px solid ${C.border}`, background: f.incidente ? "rgba(220,38,38,0.04)" : undefined }}>
                  <td data-label="Alerta" style={td}><AlertaTag alerta={f.alerta} /></td>
                  <td data-label="Producto" data-primary style={{ ...td, minWidth: 180 }}>
                    <div style={{ fontWeight: 700 }}>{f.nombre}</div>
                    <div style={{ fontSize: 10, color: C.textDim, marginTop: 2 }}>
                      {f.sku} · {f.ean || "sin EAN"}
                    </div>
                  </td>
                  <td data-label="Local" style={td}>{f.stockLocal}</td>
                  <td data-label="Publicar" style={td}>
                    {f.disponible ? f.stockPublicado : <span style={{ color: C.textDim }}>0 · off</span>}
                  </td>
                  <td data-label="Cola" style={td}>
                    {f.colaPendiente
                      ? (f.colaQuiereApagar ? "apagar (pendiente)" : `prender ${f.colaStockRappi ?? ""}`)
                      : "—"}
                  </td>
                  <td data-label="Rappi tiene" style={td}>
                    {f.rappiStock == null ? "—" : f.rappiStock}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      <div style={{ marginTop: 10, fontSize: 12, color: C.textDim }}>
        {visibles.length} de {filas.length} fichas
        {" · "}Carga segura = SKU de Rappi + stock publicado. Subilo en Partner → Productos.
      </div>
    </div>
  );
}

function Stat({ label, value, hint, col }) {
  return (
    <Box style={{ padding: 14 }}>
      <div style={{ fontSize: 11, fontWeight: 700, color: C.textDim, letterSpacing: 0.4, textTransform: "uppercase" }}>{label}</div>
      <div style={{ marginTop: 6, fontSize: 22, fontWeight: 800, color: col || C.text }}>{value}</div>
      {hint ? <div style={{ fontSize: 11, color: C.textDim, marginTop: 4 }}>{hint}</div> : null}
    </Box>
  );
}

function AlertaTag({ alerta }) {
  if (alerta === "incidente") return <Tag col={C.red} sm>Pedido</Tag>;
  if (alerta === "peligro") return <Tag col={C.red} sm>Peligro</Tag>;
  if (alerta === "desfase") return <Tag col={C.amber} sm>Desfase</Tag>;
  if (alerta === "catalogo") return <Tag col={C.amber} sm>Catálogo</Tag>;
  return <Tag col={C.green} sm>Ok</Tag>;
}

const th = { padding: "6px 8px 8px 0", fontWeight: 700, fontSize: 11, letterSpacing: 0.3, textTransform: "uppercase" };
const td = { padding: "8px 8px 8px 0", color: C.text, verticalAlign: "top" };
