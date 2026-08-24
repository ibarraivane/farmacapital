import { useCallback, useEffect, useMemo, useState } from "react";
import { C_LIGHT, BRAND } from "./constants";
import { supabase } from "./supabase";
import { showToast } from "./ui";

const C = C_LIGHT;
const money = (n) => {
  if (n == null || n === "") return "—";
  return `$${Number(n).toLocaleString("es-MX", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
};
const pct = (n) => {
  const x = Number(n);
  if (!Number.isFinite(x)) return "—";
  return `${(x <= 1 ? x * 100 : x).toFixed(1)}%`;
};

function sessionTok() {
  return sessionStorage.getItem("farmacapital_session_token");
}

export default function MonitorPreciosModule() {
  const [tab, setTab] = useState("pvp");
  const [estado, setEstado] = useState("PENDIENTE");
  const [rows, setRows] = useState([]);
  const [mapeos, setMapeos] = useState([]);
  const [anomalias, setAnomalias] = useState([]);
  const [loading, setLoading] = useState(true);
  const [sel, setSel] = useState(() => new Set());
  const [editId, setEditId] = useState(null);
  const [editPrecio, setEditPrecio] = useState("");
  const [busy, setBusy] = useState(false);
  const [fuenteImport, setFuenteImport] = useState("lista_distribuidor");

  const cargarPvp = useCallback(async (est = estado) => {
    const tok = sessionTok();
    if (!tok) return [];
    const { data, error } = await supabase.rpc("admin_listar_propuestas_precio", {
      p_session_token: tok,
      p_estado: est,
    });
    if (error) throw error;
    return Array.isArray(data) ? data : [];
  }, [estado]);

  const cargar = useCallback(async () => {
    setLoading(true);
    const tok = sessionTok();
    if (!tok) {
      setRows([]);
      setMapeos([]);
      setAnomalias([]);
      setLoading(false);
      return;
    }
    try {
      const [pvp, map, ano] = await Promise.all([
        cargarPvp(estado),
        supabase.rpc("admin_listar_mapeos_monitor", {
          p_session_token: tok,
          p_estado: "POR_VERIFICAR",
        }),
        supabase.rpc("admin_listar_anomalias_monitor", { p_session_token: tok }),
      ]);
      setRows(pvp);
      if (map.error) throw map.error;
      if (ano.error) throw ano.error;
      setMapeos(Array.isArray(map.data) ? map.data : []);
      setAnomalias(Array.isArray(ano.data) ? ano.data : []);
    } catch (err) {
      showToast(err.message || "No se pudo cargar el monitor. ¿Corriste el SQL?", "error");
      setRows([]);
    }
    setSel(new Set());
    setLoading(false);
  }, [cargarPvp, estado]);

  useEffect(() => { cargar(); }, [cargar]);

  const pendientes = estado === "PENDIENTE";
  const impacto = useMemo(
    () => rows.reduce((s, r) => s + (Number(r.impacto_estimado) || 0), 0),
    [rows]
  );

  const toggle = (id) => {
    setSel((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const aprobar = async (ids, precio) => {
    if (!ids.length) return;
    setBusy(true);
    const { data, error } = await supabase.rpc("admin_aprobar_propuestas_precio", {
      p_session_token: sessionTok(),
      p_ids: ids,
      p_precio: precio == null || precio === "" ? null : Number(precio),
    });
    setBusy(false);
    if (error) {
      showToast(error.message || "No se pudo aprobar", "error");
      return;
    }
    showToast(`Precios actualizados: ${data?.aprobadas ?? ids.length}`, "success");
    setEditId(null);
    cargar();
  };

  const rechazar = async (ids) => {
    if (!ids.length) return;
    setBusy(true);
    const { data, error } = await supabase.rpc("admin_rechazar_propuestas_precio", {
      p_session_token: sessionTok(),
      p_ids: ids,
    });
    setBusy(false);
    if (error) {
      showToast(error.message || "No se pudo rechazar", "error");
      return;
    }
    showToast(`Rechazadas: ${data?.rechazadas ?? ids.length}`, "info");
    cargar();
  };

  const decidirMapeo = async (id, accion) => {
    setBusy(true);
    const { error } = await supabase.rpc("admin_decidir_mapeo_monitor", {
      p_session_token: sessionTok(),
      p_id: id,
      p_accion: accion,
    });
    setBusy(false);
    if (error) {
      showToast(error.message || "No se pudo guardar el mapeo", "error");
      return;
    }
    showToast(accion === "ACEPTAR" ? "Mapeo aceptado" : "Mapeo invalidado", "success");
    cargar();
  };

  const resolverAnomalia = async (id, accion) => {
    setBusy(true);
    const { error } = await supabase.rpc("admin_resolver_anomalia_monitor", {
      p_session_token: sessionTok(),
      p_id: id,
      p_accion: accion,
    });
    setBusy(false);
    if (error) {
      showToast(error.message || "No se pudo resolver", "error");
      return;
    }
    showToast(accion === "ACEPTAR" ? "Anomalía aceptada (entra a la mediana)" : "Captura descartada", "success");
    cargar();
  };

  const onRastrear = async () => {
    setBusy(true);
    try {
      const resp = await fetch("/api/monitor-precios/job?action=rastrear", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-session-token": sessionTok() || "",
        },
        body: JSON.stringify({ session_token: sessionTok() }),
      });
      const data = await resp.json().catch(() => ({}));
      if (!resp.ok) throw new Error(data.error || "rastreo_failed");
      showToast(
        `Buscó precios: ${data.insertadas || 0} datos nuevos · compra ${data.matches_compra || 0} · venta ${data.busquedas_venta || 0}`,
        "success"
      );
      cargar();
    } catch (err) {
      showToast(err.message || "No se pudo buscar ahora", "error");
    }
    setBusy(false);
  };

  const onCsv = async (file) => {
    if (!file) return;
    const csvText = await file.text();
    setBusy(true);
    try {
      const resp = await fetch("/api/monitor-precios/job?action=import", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-session-token": sessionTok() || "",
        },
        body: JSON.stringify({
          csvText,
          fuente: fuenteImport,
          archivo: file.name,
          url_origen: `archivo:${file.name}`,
        }),
      });
      const data = await resp.json().catch(() => ({}));
      if (!resp.ok) throw new Error(data.error || "import_failed");
      showToast(
        `Importadas ${data.capturas || 0} capturas · ${data.propuestas || 0} propuestas · ${data.llamadas_modelo || 0} llamadas al modelo`,
        "success"
      );
      cargar();
    } catch (err) {
      showToast(err.message || "No se pudo importar el CSV", "error");
    }
    setBusy(false);
  };

  return (
    <div style={{ padding: 20, maxWidth: 1280 }}>
      <h2 style={{ margin: "0 0 6px", fontSize: 18, color: C.text }}>
        Precios que se buscan solos
      </h2>
      <p style={{ margin: "0 0 16px", fontSize: 13, color: C.textMid, lineHeight: 1.45, maxWidth: 760 }}>
        Dos veces al día llena Referencias: Abarrotero, Scorpion y MayoreoTotal en compra;
        Similares y Del Ahorro en venta si la tienda responde.
        <strong> Otros</strong> es el promedio cuando hay más de una cadena.
        Exprezo / Zorro no tiene lista pública: se actualiza importando el CSV.
        Un PVP no cambia hasta que lo apruebes aquí.
      </p>

      <div style={{
        display: "flex", gap: 10, flexWrap: "wrap", alignItems: "center",
        marginBottom: 16, padding: 12, border: `1px solid ${C.border}`,
        borderRadius: 10, background: C.card,
      }}
      >
        <label style={{ fontSize: 12, fontWeight: 700, color: C.textMid }}>
          Cargar CSV
          <select
            value={fuenteImport}
            onChange={(e) => setFuenteImport(e.target.value)}
            style={{ marginLeft: 8, padding: "6px 8px", borderRadius: 6, border: `1px solid ${C.border}` }}
          >
            <option value="lista_distribuidor">Lista de distribuidor (compra)</option>
            <option value="profeco_qqp">PROFECO QQP (venta)</option>
            <option value="datos_gob_patente">datos.gob.mx patente (venta)</option>
          </select>
        </label>
        <input
          type="file"
          accept=".csv,text/csv"
          disabled={busy}
          onChange={(e) => {
            const f = e.target.files && e.target.files[0];
            e.target.value = "";
            if (f) onCsv(f);
          }}
        />
        <button
          type="button"
          disabled={busy}
          onClick={onRastrear}
          style={{
            padding: "8px 14px", borderRadius: 8, border: `1px solid ${BRAND.primary}`,
            background: BRAND.primary, color: "#fff", fontWeight: 700, fontSize: 12, cursor: "pointer",
          }}
        >
          {busy ? "Buscando…" : "Buscar precios ahora"}
        </button>
        <span style={{ fontSize: 11, color: C.textDim }}>
          Columnas: nombre/producto, precio. EAN opcional. El precio tiene que venir en el archivo.
        </span>
      </div>

      <div style={{ display: "flex", gap: 8, marginBottom: 14, flexWrap: "wrap" }}>
        {[
          ["pvp", `Propuestas PVP (${rows.length})`],
          ["mapeos", `Mapeos por verificar (${mapeos.length})`],
          ["anomalias", `Anomalías (${anomalias.length})`],
        ].map(([id, label]) => (
          <button
            key={id}
            type="button"
            onClick={() => setTab(id)}
            style={{
              padding: "6px 12px",
              borderRadius: 8,
              border: `1px solid ${tab === id ? BRAND.primary : C.border}`,
              background: tab === id ? C.blueDim : C.card,
              color: tab === id ? BRAND.primary : C.textMid,
              fontWeight: 700,
              fontSize: 12,
              cursor: "pointer",
            }}
          >
            {label}
          </button>
        ))}
      </div>

      {tab === "pvp" && (
        <>
          <div style={{ display: "flex", gap: 10, flexWrap: "wrap", marginBottom: 14 }}>
            <Stat label="Filas" value={String(rows.length)} />
            <Stat label="Impacto stock" value={money(impacto)} />
            <Stat label="Mapeos pendientes" value={String(mapeos.length)} />
          </div>
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 12 }}>
            {["PENDIENTE", "APROBADA", "RECHAZADA", "EDITADA", "TODAS"].map((e) => (
              <button
                key={e}
                type="button"
                onClick={() => setEstado(e)}
                style={{
                  padding: "6px 12px",
                  borderRadius: 8,
                  border: `1px solid ${estado === e ? BRAND.primary : C.border}`,
                  background: estado === e ? C.blueDim : C.card,
                  color: estado === e ? BRAND.primary : C.textMid,
                  fontWeight: 700,
                  fontSize: 12,
                  cursor: "pointer",
                }}
              >
                {e}
              </button>
            ))}
          </div>
          {pendientes && (
            <div style={{ display: "flex", gap: 8, marginBottom: 12, flexWrap: "wrap" }}>
              <button type="button" style={btnPrimary} onClick={() => aprobar([...sel])} disabled={busy}>
                Aprobar seleccionadas ({sel.size})
              </button>
              <button type="button" style={btnGhost} onClick={() => rechazar([...sel])} disabled={busy}>
                Rechazar seleccionadas
              </button>
            </div>
          )}
          {loading ? (
            <p style={{ color: C.textMid }}>Cargando…</p>
          ) : rows.length === 0 ? (
            <p style={{ color: C.textMid, fontSize: 13 }}>
              No hay propuestas. Sube un CSV de PROFECO o corre
              <code style={{ marginLeft: 6 }}>/api/monitor-precios/job</code>
              {" "}tras el SQL <code>sql/patch_monitor_precios_20260824.sql</code>.
            </p>
          ) : (
            <div style={{ overflowX: "auto", border: `1px solid ${C.border}`, borderRadius: 10, background: C.card }}>
              <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 12 }}>
                <thead>
                  <tr style={{ background: C.cardDark, textAlign: "left" }}>
                    {pendientes && <th style={th} />}
                    <th style={th}>Producto</th>
                    <th style={th}>Compra</th>
                    <th style={{ ...th, textAlign: "right" }}>PVP actual</th>
                    <th style={{ ...th, textAlign: "right" }}>Ref. mercado</th>
                    <th style={{ ...th, textAlign: "right" }}>Fuentes</th>
                    <th style={{ ...th, textAlign: "right" }}>Sugerido</th>
                    <th style={{ ...th, textAlign: "right" }}>Margen</th>
                    <th style={{ ...th, textAlign: "right" }}>Impacto</th>
                    <th style={th} />
                  </tr>
                </thead>
                <tbody>
                  {rows.map((r) => (
                    <tr key={r.id} style={{ borderTop: `1px solid ${C.border}` }}>
                      {pendientes && (
                        <td style={td}>
                          <input type="checkbox" checked={sel.has(r.id)} onChange={() => toggle(r.id)} />
                        </td>
                      )}
                      <td style={td}>
                        <div style={{ fontWeight: 700 }}>{r.nombre || "—"}</div>
                        <div style={{ color: C.textDim, fontSize: 11 }}>
                          {r.sku}
                          {r.fecha_dato_mas_reciente
                            ? ` · dato ${String(r.fecha_dato_mas_reciente).slice(0, 10)}`
                            : ""}
                        </div>
                      </td>
                      <td style={td}>
                        <div style={{ fontWeight: 700 }}>{money(r.costo_compra ?? r.costo_usado)}</div>
                        {r.proveedor_compra ? (
                          <div style={{ color: C.blue, fontSize: 11, fontWeight: 700 }}>{r.proveedor_compra}</div>
                        ) : null}
                      </td>
                      <td style={{ ...td, textAlign: "right" }}>{money(r.precio_actual)}</td>
                      <td style={{ ...td, textAlign: "right" }}>
                        {money(r.referencia_caja)}
                        <div style={{ color: C.textDim, fontSize: 10 }}>
                          {r.referencia_unitaria != null ? `${money(r.referencia_unitaria)} / pza` : ""}
                        </div>
                      </td>
                      <td style={{ ...td, textAlign: "right" }}>{r.n_fuentes ?? "—"}</td>
                      <td style={{ ...td, textAlign: "right", fontWeight: 800 }}>
                        {money(r.pvp_sugerido)}
                        {r.piso != null && (
                          <div style={{ color: C.textDim, fontSize: 10 }}>piso {money(r.piso)}</div>
                        )}
                      </td>
                      <td style={{ ...td, textAlign: "right" }}>{pct(r.margen_resultante)}</td>
                      <td style={{ ...td, textAlign: "right" }}>{money(r.impacto_estimado)}</td>
                      <td style={td}>
                        {pendientes && (
                          <div style={{ display: "flex", gap: 6, flexWrap: "wrap", justifyContent: "flex-end" }}>
                            <button type="button" style={btnTiny} disabled={busy} onClick={() => aprobar([r.id])}>
                              Aprobar
                            </button>
                            <button
                              type="button"
                              style={btnTiny}
                              onClick={() => {
                                setEditId(r.id);
                                setEditPrecio(String(r.pvp_sugerido ?? ""));
                              }}
                            >
                              Editar
                            </button>
                            <button type="button" style={btnTiny} disabled={busy} onClick={() => rechazar([r.id])}>
                              Rechazar
                            </button>
                          </div>
                        )}
                        {editId === r.id && (
                          <div style={{ marginTop: 8, display: "flex", gap: 6, justifyContent: "flex-end" }}>
                            <input
                              type="number"
                              step="0.5"
                              min={r.piso || 0}
                              value={editPrecio}
                              onChange={(e) => setEditPrecio(e.target.value)}
                              style={{
                                width: 88, padding: "6px 8px", borderRadius: 6,
                                border: `1px solid ${C.border}`, fontSize: 12,
                              }}
                            />
                            <button type="button" style={btnTiny} onClick={() => aprobar([r.id], editPrecio)}>
                              Guardar y aprobar
                            </button>
                          </div>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </>
      )}

      {tab === "mapeos" && (
        <div style={{ overflowX: "auto", border: `1px solid ${C.border}`, borderRadius: 10, background: C.card }}>
          {mapeos.length === 0 ? (
            <p style={{ padding: 16, color: C.textMid, fontSize: 13 }}>No hay mapeos por verificar.</p>
          ) : (
            <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 12 }}>
              <thead>
                <tr style={{ background: C.cardDark }}>
                  <th style={th}>Producto</th>
                  <th style={th}>Fuente</th>
                  <th style={th}>Confianza</th>
                  <th style={th}>Razón</th>
                  <th style={th} />
                </tr>
              </thead>
              <tbody>
                {mapeos.map((m) => (
                  <tr key={m.id} style={{ borderTop: `1px solid ${C.border}` }}>
                    <td style={td}>
                      <div style={{ fontWeight: 700 }}>{m.nombre || "—"}</div>
                      <div style={{ color: C.textDim, fontSize: 11 }}>{m.sku}</div>
                    </td>
                    <td style={td}>{m.fuente}</td>
                    <td style={td}>{m.confianza}</td>
                    <td style={td}>{m.razon}</td>
                    <td style={td}>
                      <button type="button" style={btnTiny} disabled={busy} onClick={() => decidirMapeo(m.id, "ACEPTAR")}>Aceptar</button>
                      {" "}
                      <button type="button" style={btnTiny} disabled={busy} onClick={() => decidirMapeo(m.id, "RECHAZAR")}>Rechazar</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      )}

      {tab === "anomalias" && (
        <div style={{ overflowX: "auto", border: `1px solid ${C.border}`, borderRadius: 10, background: C.card }}>
          {anomalias.length === 0 ? (
            <p style={{ padding: 16, color: C.textMid, fontSize: 13 }}>
              No hay saltos &gt; 40 % pendientes. Eso evita que un scrape roto envenene la mediana.
            </p>
          ) : (
            <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 12 }}>
              <thead>
                <tr style={{ background: C.cardDark }}>
                  <th style={th}>Producto</th>
                  <th style={th}>Fuente</th>
                  <th style={th}>Precio</th>
                  <th style={th}>Δ</th>
                  <th style={th}>Origen</th>
                  <th style={th} />
                </tr>
              </thead>
              <tbody>
                {anomalias.map((a) => (
                  <tr key={a.id} style={{ borderTop: `1px solid ${C.border}` }}>
                    <td style={td}>
                      <div style={{ fontWeight: 700 }}>{a.nombre || "—"}</div>
                      <div style={{ color: C.textDim, fontSize: 11 }}>{a.sku}</div>
                    </td>
                    <td style={td}>{a.fuente}</td>
                    <td style={td}>{money(a.precio)}</td>
                    <td style={td}>{a.delta_vs_anterior != null ? `${(Number(a.delta_vs_anterior) * 100).toFixed(0)}%` : "—"}</td>
                    <td style={td}>
                      <div style={{ fontSize: 11, color: C.textDim, maxWidth: 220, overflow: "hidden", textOverflow: "ellipsis" }}>
                        {a.url_origen}
                      </div>
                    </td>
                    <td style={td}>
                      <button type="button" style={btnTiny} disabled={busy} onClick={() => resolverAnomalia(a.id, "ACEPTAR")}>Aceptar</button>
                      {" "}
                      <button type="button" style={btnTiny} disabled={busy} onClick={() => resolverAnomalia(a.id, "DESCARTAR")}>Descartar</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      )}
    </div>
  );
}

function Stat({ label, value }) {
  return (
    <div style={{
      background: C.card, border: `1px solid ${C.border}`, borderRadius: 10,
      padding: "10px 14px", minWidth: 140,
    }}
    >
      <div style={{ fontSize: 16, fontWeight: 800, color: C.text }}>{value}</div>
      <div style={{ fontSize: 11, color: C.textDim }}>{label}</div>
    </div>
  );
}

const th = { padding: "8px 10px", fontSize: 10, textTransform: "uppercase", letterSpacing: "0.04em", color: C.textDim };
const td = { padding: "8px 10px", verticalAlign: "top" };
const btnPrimary = {
  padding: "8px 14px", borderRadius: 8, border: "none",
  background: BRAND.primary, color: "#fff", fontWeight: 700, fontSize: 12, cursor: "pointer",
};
const btnGhost = {
  padding: "8px 14px", borderRadius: 8, border: `1px solid ${C.border}`,
  background: C.card, color: C.textMid, fontWeight: 700, fontSize: 12, cursor: "pointer",
};
const btnTiny = {
  padding: "4px 8px", borderRadius: 6, border: `1px solid ${C.border}`,
  background: C.card, color: C.text, fontWeight: 700, fontSize: 11, cursor: "pointer",
};
