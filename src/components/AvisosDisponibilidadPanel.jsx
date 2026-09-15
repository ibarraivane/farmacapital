import { useCallback, useEffect, useState } from "react";
import { supabase } from "../supabase";
import { Box, Btn, Tag, showToast } from "../ui";
import {
  AVISO_ESTADOS_UI,
  buildAvisoDisponibilidadWhatsApp,
  estadoUiAviso,
} from "../lib/encargoMedicamentos";

function sessionTok() {
  return sessionStorage.getItem("farmacapital_session_token");
}

/**
 * Cola Caso A dentro de Pedidos online (hermana de pedidos pagados).
 * No mezcla con el gate de pago MP.
 */
export default function AvisosDisponibilidadPanel({ C, isNarrow }) {
  const [filtro, setFiltro] = useState("listos");
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [busyId, setBusyId] = useState(null);

  const load = useCallback(async () => {
    const tok = sessionTok();
    if (!tok) {
      setRows([]);
      setLoading(false);
      return;
    }
    setLoading(true);
    const { data, error } = await supabase.rpc("empleado_listar_avisos_disponibilidad", {
      p_session_token: tok,
      p_filtro: filtro,
      p_limite: 100,
    });
    setLoading(false);
    if (error) {
      showToast("No se pudieron cargar avisos: " + error.message, "error");
      setRows([]);
      return;
    }
    setRows(Array.isArray(data) ? data : []);
  }, [filtro]);

  useEffect(() => {
    load();
  }, [load]);

  async function marcarNotificado(id) {
    const tok = sessionTok();
    if (!tok) return;
    setBusyId(id);
    const { error } = await supabase.rpc("empleado_marcar_aviso_notificado", {
      p_session_token: tok,
      p_aviso_id: id,
    });
    setBusyId(null);
    if (error) {
      showToast("No se pudo marcar: " + error.message, "error");
      return;
    }
    showToast("Marcado como avisado", "success");
    load();
  }

  const chips = [
    { id: "listos", label: "Listos para avisar" },
    { id: "pendientes", label: "Esperando stock" },
    { id: "avisados", label: "Ya avisados" },
    { id: "todos", label: "Todos" },
  ];

  return (
    <div style={{ marginTop: 8 }}>
      <div
        style={{
          background: "#ecfdf5",
          border: "1px solid #a7f3d0",
          borderRadius: 10,
          padding: "10px 14px",
          marginBottom: 12,
          fontSize: 12,
          color: "#065f46",
          lineHeight: 1.45,
        }}
      >
        <strong>Avisos de disponibilidad (Caso A):</strong> clientes que pidieron
        enterarse cuando un producto agotado vuelva. Un clic abre WhatsApp con el
        mensaje listo; luego marca «Avisado».
      </div>

      <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 12 }}>
        {chips.map((c) => (
          <button
            key={c.id}
            type="button"
            onClick={() => setFiltro(c.id)}
            style={{
              border: `1px solid ${filtro === c.id ? (C?.blue || "#2563eb") : (C?.border || "#e5e7eb")}`,
              background: filtro === c.id ? (C?.blueDim || "#eff6ff") : "#fff",
              color: filtro === c.id ? (C?.blue || "#1d4ed8") : (C?.textMid || "#4b5563"),
              borderRadius: 999,
              padding: "6px 12px",
              fontWeight: 700,
              fontSize: 12,
              cursor: "pointer",
            }}
          >
            {c.label}
          </button>
        ))}
        <Btn sm ol onClick={load} col={C?.blue || "#2563eb"}>
          Actualizar
        </Btn>
      </div>

      {loading ? (
        <div style={{ color: C?.textMid || "#6b7280", padding: 24, textAlign: "center" }}>
          Cargando avisos…
        </div>
      ) : !rows.length ? (
        <div style={{ color: C?.textMid || "#6b7280", padding: 28, textAlign: "center" }}>
          {filtro === "listos"
            ? "No hay avisos listos (nadie esperando un producto que ya tenga stock)."
            : "Sin avisos en este filtro."}
        </div>
      ) : (
        rows.map((a) => {
          const estado =
            a.estado_ui ||
            estadoUiAviso({ notificado: a.notificado, producto_stock: a.producto_stock });
          const wa = buildAvisoDisponibilidadWhatsApp({
            telefono: a.cliente_telefono,
            nombre: a.cliente_nombre,
            producto_nombre: a.producto_nombre,
          });
          const tagCol =
            estado === AVISO_ESTADOS_UI.listo_avisar
              ? C?.green || "#16a34a"
              : estado === AVISO_ESTADOS_UI.avisado
                ? C?.blue || "#2563eb"
                : C?.amber || "#d97706";
          const tagLabel =
            estado === AVISO_ESTADOS_UI.listo_avisar
              ? "Listo para avisar"
              : estado === AVISO_ESTADOS_UI.avisado
                ? "Avisado"
                : "Esperando stock";

          return (
            <Box
              key={a.id}
              style={{ padding: isNarrow ? 12 : 16, marginBottom: 10, minWidth: 0 }}
            >
              <div
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  gap: 10,
                  flexWrap: "wrap",
                  alignItems: "flex-start",
                }}
              >
                <div style={{ minWidth: 0 }}>
                  <div style={{ display: "flex", gap: 8, flexWrap: "wrap", alignItems: "center" }}>
                    <div style={{ fontWeight: 800, color: C?.text || "#111", fontSize: 14 }}>
                      {a.producto_nombre || `Producto #${a.producto_id}`}
                    </div>
                    <Tag col={tagCol} sm>
                      {tagLabel}
                    </Tag>
                    <Tag col={C?.textDim || "#9ca3af"} sm>
                      stock {Number(a.producto_stock) || 0}
                    </Tag>
                  </div>
                  <div style={{ marginTop: 6, fontSize: 13, fontWeight: 700, color: C?.text || "#111" }}>
                    {a.cliente_nombre || "Cliente"}
                  </div>
                  <div style={{ fontSize: 12, color: C?.textMid || "#6b7280" }}>
                    📱 {a.cliente_telefono}
                  </div>
                  <div style={{ fontSize: 11, color: C?.textDim || "#9ca3af", marginTop: 2 }}>
                    Pedido el {a.created_at ? new Date(a.created_at).toLocaleString("es-MX") : "—"}
                  </div>
                </div>
                <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
                  {wa && !a.notificado ? (
                    <a
                      href={wa}
                      target="_blank"
                      rel="noreferrer"
                      onClick={() => {
                        // Tras abrir WA, el staff marca avisado
                      }}
                      style={{
                        display: "inline-flex",
                        alignItems: "center",
                        gap: 6,
                        padding: "7px 14px",
                        borderRadius: 8,
                        border: "none",
                        background: "#25D366",
                        color: "#fff",
                        fontWeight: 700,
                        fontSize: 12,
                        textDecoration: "none",
                      }}
                    >
                      💬 WhatsApp (1 clic)
                    </a>
                  ) : null}
                  {!a.notificado ? (
                    <Btn
                      sm
                      col={C?.green || "#16a34a"}
                      dis={busyId === a.id}
                      onClick={() => marcarNotificado(a.id)}
                    >
                      ✓ Marcar avisado
                    </Btn>
                  ) : null}
                </div>
              </div>
            </Box>
          );
        })
      )}
    </div>
  );
}
