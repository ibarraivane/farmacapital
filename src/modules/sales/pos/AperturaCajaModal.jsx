import { useState, useEffect, useCallback } from "react";
import { C_LIGHT, BRAND } from "../../../constants";
import { etiquetaTurno, inferirTurno, turnoDePerfil, etiquetaDiaDescanso } from "../../../constants/turnos";
import { hayPiezasDenominacion } from "../../../constants/caja";
import ArqueoDenominaciones from "../../../components/ArqueoDenominaciones";
import { abrirSesionCaja, fetchJornadaHoy } from "../../../utils/cajaSesion";
import { showToast } from "../../../ui";

/**
 * Pantalla bloqueante: el vendedor no vende hasta contar el fondo que le entregaron.
 * Esa confirmación es también la hora de entrada.
 */
export default function AperturaCajaModal({ usuario, onAbierta }) {
  const C = C_LIGHT;
  const [denoms, setDenoms] = useState({});
  const [nota, setNota] = useState("");
  const [saving, setSaving] = useState(false);
  const [jornada, setJornada] = useState(null);
  const turnoHabitual = turnoDePerfil(usuario) || inferirTurno();
  const turnoAsignado = turnoDePerfil(usuario);
  const turnoAbrir = jornada?.turno_abrir || (jornada?.cubre_ambos ? inferirTurno() : turnoHabitual);
  const nombre = (usuario?.nombre || "Vendedor").split(" ")[0];

  const [revisando, setRevisando] = useState(false);
  const ocupadaPor = jornada?.caja_ocupada_por || null;

  const cargarJornada = useCallback(async () => {
    const { jornada: j } = await fetchJornadaHoy();
    if (j) setJornada(j);
    return j;
  }, []);

  useEffect(() => {
    let cancel = false;
    fetchJornadaHoy().then(({ jornada: j }) => {
      if (!cancel && j) setJornada(j);
    });
    return () => { cancel = true; };
  }, []);

  const revisarDeNuevo = async () => {
    setRevisando(true);
    const j = await cargarJornada();
    setRevisando(false);
    if (j?.caja_ocupada_por) {
      showToast(`${j.caja_ocupada_por} sigue con la caja abierta.`, "info");
    }
  };

  const setPiezas = (d, value) => {
    setDenoms((p) => ({ ...p, [d]: value }));
  };

  const confirmar = async () => {
    if (!turnoAsignado) {
      showToast("RH debe asignarte un turno antes de abrir caja.", "warning");
      return;
    }
    if (jornada?.es_descanso) {
      showToast("Hoy es tu día de descanso.", "warning");
      return;
    }
    if (!hayPiezasDenominacion(denoms) && !nota.trim()) {
      showToast("Cuenta el efectivo que te entregaron, o deja una nota si abres en ceros.", "warning");
      return;
    }
    setSaving(true);
    try {
      const { sesion, error } = await abrirSesionCaja({ denoms, nota });
      if (error) {
        showToast(error, "error");
        return;
      }
      showToast("Caja abierta. Ya puedes vender.", "success");
      onAbierta?.(sesion);
    } catch (e) {
      showToast(e?.message || "Se cayó la conexión. Intenta de nuevo.", "error");
    } finally {
      setSaving(false);
    }
  };

  // El cajón es uno solo. Mary sale 15:30 y Erika entra 15:00, así que media
  // hora al día las dos están en el piso: más vale decirlo aquí que dejar que
  // cuente el fondo y se lo rechacen al confirmar.
  if (ocupadaPor) {
    return (
      <div style={{
        position: "fixed", inset: 0, zIndex: 2000, background: C.bg,
        overflowY: "auto", fontFamily: "var(--fc-body)",
      }}>
        <div style={{ maxWidth: 560, margin: "0 auto", padding: "28px 20px 48px" }}>
          <div style={{
            fontSize: 11, fontWeight: 800, letterSpacing: 1.2,
            textTransform: "uppercase", color: BRAND.primary, marginBottom: 8,
          }}>
            Caja ocupada
          </div>
          <h1 style={{ margin: 0, color: C.text, fontSize: 22, fontWeight: 800 }}>
            {ocupadaPor} todavía no corta
          </h1>
          <p style={{ color: C.textMid, fontSize: 14, lineHeight: 1.5, margin: "10px 0 0" }}>
            La caja es una sola. En cuanto <strong>{ocupadaPor}</strong> cuente su
            cajón y guarde el corte, abres la tuya. Las ventas de mientras
            quedan en el turno de ella.
          </p>
          <button
            type="button"
            onClick={revisarDeNuevo}
            disabled={revisando}
            style={{
              marginTop: 22, padding: "12px 20px", borderRadius: 10,
              border: `1px solid ${C.border}`, background: C.card,
              color: C.text, fontSize: 14, fontWeight: 700,
              fontFamily: "inherit", cursor: revisando ? "default" : "pointer",
              opacity: revisando ? 0.6 : 1,
            }}
          >
            {revisando ? "Revisando…" : "Ya cortó, revisar"}
          </button>
        </div>
      </div>
    );
  }

  if (jornada?.es_descanso) {
    const dia = etiquetaDiaDescanso(jornada.dia_descanso) || "hoy";
    return (
      <div style={{
        position: "fixed", inset: 0, zIndex: 2000, background: C.bg,
        overflowY: "auto", fontFamily: "var(--fc-body)",
      }}>
        <div style={{ maxWidth: 560, margin: "0 auto", padding: "28px 20px 48px" }}>
          <div style={{
            fontSize: 11, fontWeight: 800, letterSpacing: 1.2,
            textTransform: "uppercase", color: BRAND.primary, marginBottom: 8,
          }}>
            Día de descanso
          </div>
          <h1 style={{ margin: 0, color: C.text, fontSize: 22, fontWeight: 800 }}>
            Hoy descansas, {nombre}
          </h1>
          <p style={{ color: C.textMid, fontSize: 14, lineHeight: 1.5, margin: "10px 0 0" }}>
            Tu día libre es el <strong>{dia}</strong>. La compañera cubre matutino y vespertino.
            No abras caja hoy.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div style={{
      position: "fixed",
      inset: 0,
      zIndex: 2000,
      background: C.bg,
      overflowY: "auto",
      fontFamily: "var(--fc-body)",
    }}>
      <div style={{ maxWidth: 560, margin: "0 auto", padding: "28px 20px 48px" }}>
        <div style={{
          fontSize: 11,
          fontWeight: 800,
          letterSpacing: 1.2,
          textTransform: "uppercase",
          color: BRAND.primary,
          marginBottom: 8,
        }}>
          {jornada?.cubre_ambos ? "Día de cobertura · ambos turnos" : "Inicio de turno"}
        </div>
        <h1 style={{ margin: 0, color: C.text, fontSize: 22, fontWeight: 800 }}>
          Abre caja para empezar, {nombre}
        </h1>
        <p style={{ color: C.textMid, fontSize: 14, lineHeight: 1.5, margin: "10px 0 0" }}>
          Cuenta las piezas que te entregaron. El total se calcula solo.
          Esta hora queda como tu entrada.
          {!turnoAsignado
            ? " RH aún no te asigna turno: no puedes abrir caja."
            : jornada?.cubre_ambos
              ? <> Hoy cubres <strong>los dos turnos</strong>. Este conteo es el <strong>{etiquetaTurno(turnoAbrir)}</strong>. Al corte, vuelves a abrir el siguiente.</>
              : <> Turno: <strong>{etiquetaTurno(turnoAbrir)}</strong>.</>}
        </p>

        <div style={{
          marginTop: 22,
          background: C.card,
          border: `1px solid ${C.border}`,
          borderRadius: 14,
          padding: 18,
        }}>
          <div style={{
            color: C.textDim,
            fontSize: 10,
            fontWeight: 700,
            letterSpacing: 1,
            textTransform: "uppercase",
            marginBottom: 12,
          }}>
            Arqueo de apertura
          </div>
          <ArqueoDenominaciones denoms={denoms} onChange={setPiezas} disabled={saving} />
        </div>

        <div style={{ marginTop: 16 }}>
          <label style={{
            display: "block",
            color: C.textMid,
            fontSize: 11,
            fontWeight: 700,
            marginBottom: 6,
          }}>
            Nota (si el fondo no cuadra o abres en ceros)
          </label>
          <textarea
            value={nota}
            onChange={(e) => setNota(e.target.value)}
            rows={2}
            maxLength={400}
            placeholder="Ej. Faltaban dos de $20; me entregaron $1,460"
            style={{
              width: "100%",
              boxSizing: "border-box",
              padding: "10px 12px",
              borderRadius: 8,
              border: `1px solid ${C.border}`,
              background: C.card,
              color: C.text,
              fontSize: 13,
              fontFamily: "inherit",
              resize: "vertical",
            }}
          />
        </div>

        <button
          type="button"
          onClick={confirmar}
          disabled={saving || !turnoAsignado}
          style={{
            marginTop: 18,
            width: "100%",
            padding: "14px 18px",
            border: "none",
            borderRadius: 10,
            background: BRAND.gradient,
            color: "#fff",
            fontWeight: 800,
            fontSize: 15,
            cursor: saving ? "wait" : "pointer",
          }}
        >
          {saving ? "Abriendo…" : !turnoAsignado ? "Falta asignar turno en RH" : "Confirmar y empezar turno"}
        </button>
      </div>
    </div>
  );
}
