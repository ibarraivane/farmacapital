import { useCallback, useEffect, useState } from "react";
import { Percent } from "lucide-react";
import { C_LIGHT } from "./constants";
import { PageHero } from "./components/AdminChrome";
import { supabase } from "./supabase";
import { Box, Tag, Btn, Inp, Modal, showToast, SkeletonTable } from "./ui";
import { $, logAudit } from "./utils";
import { rolEsAdmin } from "./utils/permissions";

const C = C_LIGHT;

function sessionTok() {
  return sessionStorage.getItem("farmacapital_session_token");
}

function fmtCuando(iso) {
  if (!iso) return "—";
  return new Date(iso).toLocaleString("es-MX", {
    day: "2-digit",
    month: "short",
    hour: "2-digit",
    minute: "2-digit",
  });
}

const ESTADO_LABEL = {
  pendiente_aprobacion: { text: "Pendiente de aprobación", color: C.amber },
  aprobada: { text: "Aprobada · lista para cobrar", color: C.greenDark },
  rechazada: { text: "Rechazada", color: C.red },
  cobrada: { text: "Cobrada", color: C.textMid },
  cancelada_por_cierre_turno: { text: "Cancelada (cierre de turno)", color: C.textDim },
};

function EstadoTag({ estado }) {
  const info = ESTADO_LABEL[estado] || { text: estado, color: C.textMid };
  return <Tag col={info.color}>{info.text}</Tag>;
}

/**
 * Compra de personal (precio de empleado).
 * - vendedor: arma el carrito en el POS y ahí presiona "Compra de personal"
 *   (este módulo NO arma carritos); aquí solo ve el estado de sus propias
 *   solicitudes y cobra las que ya fueron aprobadas.
 * - admin/gerente: ve la cola completa con costo y margen por línea, y
 *   aprueba o rechaza.
 * El vendedor nunca recibe costo ni margen: esos campos solo llegan por la
 * RPC admin_personal_compra_listar_pendientes.
 */
export default function ComprasPersonalModule({ usuario }) {
  const esAdmin = rolEsAdmin(usuario?.rol);
  const [loading, setLoading] = useState(true);
  const [pendientes, setPendientes] = useState([]); // admin
  const [propias, setPropias] = useState([]); // vendedor
  const [procesandoId, setProcesandoId] = useState(null);
  const [cobrarModal, setCobrarModal] = useState(null); // {id, total_final, empleado_beneficiario_nombre}

  const cargar = useCallback(async () => {
    const tok = sessionTok();
    if (!tok) return;
    setLoading(true);
    try {
      if (esAdmin) {
        const { data, error } = await supabase.rpc("admin_personal_compra_listar_pendientes", {
          p_session_token: tok,
        });
        if (error) throw error;
        setPendientes(Array.isArray(data) ? data : []);
      } else {
        const { data, error } = await supabase.rpc("empleado_personal_compra_listar_propias", {
          p_session_token: tok,
        });
        if (error) throw error;
        setPropias(Array.isArray(data) ? data : []);
      }
    } catch (e) {
      showToast(`No se pudo cargar: ${e?.message || e}`, "error");
    }
    setLoading(false);
  }, [esAdmin]);

  useEffect(() => {
    cargar();
  }, [cargar]);

  const aprobar = async (id) => {
    const tok = sessionTok();
    if (!tok) return;
    setProcesandoId(id);
    try {
      const { error } = await supabase.rpc("admin_personal_compra_aprobar", {
        p_session_token: tok,
        p_id: id,
      });
      if (error) throw error;
      logAudit(usuario, "COMPRA_PERSONAL_APROBAR", "personal_compras", id, {});
      showToast("Compra de personal aprobada", "success");
      cargar();
    } catch (e) {
      showToast(`No se pudo aprobar: ${e?.message || e}`, "error");
    }
    setProcesandoId(null);
  };

  const rechazar = async (id) => {
    const motivo = window.prompt("Motivo del rechazo (opcional):", "");
    if (motivo === null) return; // canceló
    const tok = sessionTok();
    if (!tok) return;
    setProcesandoId(id);
    try {
      const { error } = await supabase.rpc("admin_personal_compra_rechazar", {
        p_session_token: tok,
        p_id: id,
        p_motivo: motivo || null,
      });
      if (error) throw error;
      logAudit(usuario, "COMPRA_PERSONAL_RECHAZAR", "personal_compras", id, { motivo });
      showToast("Compra de personal rechazada", "success");
      cargar();
    } catch (e) {
      showToast(`No se pudo rechazar: ${e?.message || e}`, "error");
    }
    setProcesandoId(null);
  };

  const cobrar = async (metodoPago, montoEfectivo, montoTarjeta) => {
    if (!cobrarModal) return;
    const tok = sessionTok();
    if (!tok) return;
    setProcesandoId(cobrarModal.id);
    try {
      const { data, error } = await supabase.rpc("empleado_personal_compra_cobrar", {
        p_session_token: tok,
        p_id: cobrarModal.id,
        p_metodo_pago: metodoPago,
        p_monto_efectivo: metodoPago === "mixto" ? montoEfectivo : null,
        p_monto_tarjeta: metodoPago === "mixto" ? montoTarjeta : null,
      });
      if (error) throw error;
      const row = Array.isArray(data) ? data[0] : data;
      logAudit(usuario, "COMPRA_PERSONAL_COBRAR", "pedidos", row?.pedido_id, {
        compra_personal_id: cobrarModal.id,
        total: cobrarModal.total_final,
        metodo_pago: metodoPago,
      });
      showToast(`Cobrada. Venta #${row?.pedido_id}`, "success");
      setCobrarModal(null);
      cargar();
    } catch (e) {
      showToast(`No se pudo cobrar: ${e?.message || e}`, "error");
    }
    setProcesandoId(null);
  };

  return (
    <div style={{ padding: 16, maxWidth: 960, margin: "0 auto" }}>
      <PageHero Icon={Percent}>Compra de personal</PageHero>

      {!esAdmin && (
        <Box
          style={{
            marginBottom: 16,
            background: C.blueDim,
            border: `1px solid ${C.borderHi}`,
            padding: 12,
            fontSize: 13,
            color: C.text,
          }}
        >
          Para armar una compra de personal nueva, ve al <b>Punto de Venta</b>, carga los productos
          en el carrito y presiona <b>“Compra de personal”</b>. Aquí ves el estado de tus solicitudes
          y cobras las que ya fueron aprobadas.
        </Box>
      )}

      {loading ? (
        <SkeletonTable rows={4} cols={4} />
      ) : esAdmin ? (
        pendientes.length === 0 ? (
          <p style={{ color: C.textMid }}>No hay compras de personal pendientes de aprobar.</p>
        ) : (
          pendientes.map((pc) => (
            <Box key={pc.id} style={{ marginBottom: 12, padding: 14 }}>
              <div style={{ display: "flex", justifyContent: "space-between", flexWrap: "wrap", gap: 8 }}>
                <div>
                  <div style={{ fontWeight: 800, color: C.text }}>
                    Beneficiario: {pc.empleado_beneficiario_nombre}
                  </div>
                  <div style={{ fontSize: 12, color: C.textMid }}>
                    Armada por {pc.vendedor_nombre} · {fmtCuando(pc.creado_at)}
                  </div>
                </div>
                <EstadoTag estado={pc.estado} />
              </div>

              <div style={{ marginTop: 10, borderTop: `1px solid ${C.border}`, paddingTop: 8 }}>
                {(Array.isArray(pc.items) ? pc.items : []).map((it, i) => (
                  <div
                    key={i}
                    style={{
                      display: "grid",
                      gridTemplateColumns: "1fr auto auto auto auto",
                      gap: 8,
                      fontSize: 12,
                      padding: "4px 0",
                      borderBottom: i < pc.items.length - 1 ? `1px dashed ${C.border}` : "none",
                      alignItems: "center",
                    }}
                  >
                    <span style={{ color: C.text }}>
                      {it.nombre} × {it.cantidad}
                    </span>
                    <span style={{ color: C.textMid }} title="Precio de lista">
                      {$(it.precio_venta)}
                    </span>
                    <span style={{ color: C.textMid }} title="Costo">
                      costo {$(it.costo)}
                      {it.costo_estimado ? " (est.)" : ""}
                    </span>
                    <span style={{ color: C.blue }} title="Margen">
                      margen {it.margen_pct}%
                    </span>
                    <span style={{ color: C.greenDark, fontWeight: 700 }} title="Precio final">
                      → {$(it.precio_final)} (−{it.descuento_pct}%)
                    </span>
                  </div>
                ))}
              </div>

              <div style={{ marginTop: 10, display: "flex", justifyContent: "space-between", flexWrap: "wrap", gap: 8 }}>
                <div style={{ fontSize: 12, color: C.textMid }}>
                  Lista {$(pc.total_lista)} · Descuento {$(pc.total_descuento)} · Uso este mes antes de esta
                  compra: {$(pc.uso_mensual_previo)}
                  {pc.excede_tope_mensual && (
                    <span style={{ color: C.red, fontWeight: 700 }}> · excede el tope mensual</span>
                  )}
                  {pc.excede_limite_producto && (
                    <span style={{ color: C.red, fontWeight: 700 }}> · excede piezas por producto</span>
                  )}
                </div>
                <div style={{ fontWeight: 900, color: C.text }}>Total: {$(pc.total_final)}</div>
              </div>

              <div style={{ marginTop: 10, display: "flex", gap: 8 }}>
                <Btn col={C.green} dis={procesandoId === pc.id} onClick={() => aprobar(pc.id)}>
                  Aprobar
                </Btn>
                <Btn col={C.red} outline dis={procesandoId === pc.id} onClick={() => rechazar(pc.id)}>
                  Rechazar
                </Btn>
              </div>
            </Box>
          ))
        )
      ) : propias.length === 0 ? (
        <p style={{ color: C.textMid }}>Todavía no has armado ninguna compra de personal.</p>
      ) : (
        propias.map((pc) => (
          <Box key={pc.id} style={{ marginBottom: 10, padding: 14 }}>
            <div style={{ display: "flex", justifyContent: "space-between", flexWrap: "wrap", gap: 8 }}>
              <div>
                <div style={{ fontWeight: 800, color: C.text }}>{pc.empleado_beneficiario_nombre}</div>
                <div style={{ fontSize: 12, color: C.textMid }}>{fmtCuando(pc.creado_at)}</div>
                {pc.estado === "rechazada" && pc.motivo_rechazo && (
                  <div style={{ fontSize: 12, color: C.red, marginTop: 4 }}>Motivo: {pc.motivo_rechazo}</div>
                )}
              </div>
              <div style={{ textAlign: "right" }}>
                <EstadoTag estado={pc.estado} />
                <div style={{ fontWeight: 900, color: C.text, marginTop: 4 }}>{$(pc.total_final)}</div>
              </div>
            </div>
            {pc.estado === "aprobada" && (
              <div style={{ marginTop: 10 }}>
                <Btn col={C.green} dis={procesandoId === pc.id} onClick={() => setCobrarModal(pc)}>
                  Cobrar {$(pc.total_final)}
                </Btn>
              </div>
            )}
          </Box>
        ))
      )}

      {cobrarModal && (
        <CobrarModal
          compra={cobrarModal}
          procesando={procesandoId === cobrarModal.id}
          onClose={() => setCobrarModal(null)}
          onConfirm={cobrar}
        />
      )}
    </div>
  );
}

function CobrarModal({ compra, procesando, onClose, onConfirm }) {
  const [metodo, setMetodo] = useState("efectivo");
  const [montoEfectivo, setMontoEfectivo] = useState("");
  const [montoTarjeta, setMontoTarjeta] = useState("");

  const metodos = [
    { id: "efectivo", label: "Efectivo" },
    { id: "tarjeta", label: "Tarjeta" },
    { id: "mixto", label: "Mixto" },
  ];

  const puedeConfirmar =
    metodo !== "mixto" ||
    (Number(montoEfectivo) > 0 &&
      Number(montoTarjeta) > 0 &&
      Math.round((Number(montoEfectivo) + Number(montoTarjeta)) * 100) === Math.round(compra.total_final * 100));

  return (
    <Modal open onClose={onClose} title={`Cobrar compra de personal — ${$(compra.total_final)}`}>
      <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
        <div style={{ display: "flex", gap: 8 }}>
          {metodos.map((m) => (
            <Btn key={m.id} col={metodo === m.id ? C.blue : C.textDim} outline={metodo !== m.id} onClick={() => setMetodo(m.id)}>
              {m.label}
            </Btn>
          ))}
        </div>
        {metodo === "mixto" && (
          <div style={{ display: "flex", gap: 8 }}>
            <Inp
              placeholder="Efectivo"
              inputMode="decimal"
              value={montoEfectivo}
              onChange={(e) => setMontoEfectivo(e.target.value)}
            />
            <Inp
              placeholder="Tarjeta"
              inputMode="decimal"
              value={montoTarjeta}
              onChange={(e) => setMontoTarjeta(e.target.value)}
            />
          </div>
        )}
        <Btn
          col={C.green}
          full
          dis={procesando || !puedeConfirmar}
          onClick={() => onConfirm(metodo, Number(montoEfectivo) || 0, Number(montoTarjeta) || 0)}
        >
          {procesando ? "Procesando..." : `Confirmar cobro ${$(compra.total_final)}`}
        </Btn>
      </div>
    </Modal>
  );
}
