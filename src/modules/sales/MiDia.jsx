// MiDia: pantalla principal del vendedor al iniciar sesión.
// Muestra solo % y conteos (nunca montos de ventas en pesos) para no exponer
// información de negocio al personal de piso.
import { useState, useEffect, useCallback, useMemo } from "react";
import { Gauge, ShoppingCart, ClipboardList, Target, Award, Zap, Flame, Users as UsersIcon } from "lucide-react";
import { C_LIGHT, BRAND } from "../../constants";
import { supabase } from "../../supabase";
import { showToast } from "../../ui";
import { idEmpleadoUsuarios } from "../../utils/usuarioId";
import { saludoUsuario } from "../../utils";
import { turnoDePerfil, etiquetaDiaDescanso } from "../../constants/turnos";
import {
  inferirTurno, inicioDelTurno, finDelTurno, claveMetaTurno,
  calcularMultiplicador, cargarConfigMetas, escalonBono, bonosActivos,
} from "../../utils/turnosMetas";
import { fetchJornadaHoy } from "../../utils/cajaSesion";

const C = C_LIGHT;

const fmtFechaLargaEs = (d) => {
  const meses = ["enero","febrero","marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre"];
  const dias  = ["domingo","lunes","martes","miércoles","jueves","viernes","sábado"];
  return `${dias[d.getDay()]} ${d.getDate()} de ${meses[d.getMonth()]}`;
};
const fmtHora = (d) => d.toLocaleTimeString("es-MX", { hour: "2-digit", minute: "2-digit" });

function ProgressBar({ pct, col, height = 14 }) {
  const clamped = Math.max(0, Math.min(100, pct));
  return (
    <div style={{ width: "100%", height, background: C.border + "70", borderRadius: height / 2, overflow: "hidden" }}>
      <div style={{
        width: `${clamped}%`, height: "100%",
        background: col,
        borderRadius: height / 2,
        transition: "width .5s ease",
      }} />
    </div>
  );
}

function KpiCell({ icon, value, label, col }) {
  return (
    <div style={{
      background: C.card, border: `1px solid ${C.border}`, borderRadius: 12,
      padding: "16px 14px", display: "flex", flexDirection: "column", gap: 6,
    }}>
      <div style={{ fontSize: 22 }}>{icon}</div>
      <div style={{ color: col || C.text, fontWeight: 800, fontSize: 22, lineHeight: 1 }}>{value}</div>
      <div style={{ color: C.textMid, fontSize: 11, fontWeight: 700, textTransform: "uppercase", letterSpacing: 0.4 }}>{label}</div>
    </div>
  );
}

function Logro({ icon: Icon, titulo, sub, col }) {
  return (
    <div style={{
      display: "flex", alignItems: "center", gap: 12,
      padding: "12px 14px", background: C.card, border: `1px solid ${C.border}`, borderRadius: 10,
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 10, display: "grid", placeItems: "center",
        background: (col || BRAND.primary) + "18", color: col || BRAND.primary,
      }}>
        <Icon size={18} strokeWidth={2.3} />
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ color: C.text, fontWeight: 700, fontSize: 13 }}>{titulo}</div>
        {sub && <div style={{ color: C.textMid, fontSize: 11.5, marginTop: 1 }}>{sub}</div>}
      </div>
    </div>
  );
}

function BotonGrande({ icon: Icon, titulo, sub, onClick, primary = false }) {
  return (
    <button
      type="button"
      onClick={onClick}
      style={{
        background: primary ? BRAND.primary : C.card,
        color: primary ? "#fff" : C.text,
        border: primary ? "none" : `1px solid ${C.border}`,
        borderRadius: 14, padding: "22px 20px", cursor: "pointer", textAlign: "left",
        display: "flex", flexDirection: "column", gap: 10, minHeight: 110,
        boxShadow: primary ? "0 4px 12px rgba(0,82,204,.25)" : "0 1px 3px rgba(0,0,0,.04)",
        transition: "transform .1s, box-shadow .2s",
      }}
      onMouseEnter={(e) => { e.currentTarget.style.transform = "translateY(-2px)"; }}
      onMouseLeave={(e) => { e.currentTarget.style.transform = "translateY(0)"; }}
    >
      <Icon size={26} strokeWidth={2.1} />
      <div>
        <div style={{ fontWeight: 800, fontSize: 16, letterSpacing: 0.3 }}>{titulo}</div>
        {sub && <div style={{ fontSize: 12, opacity: primary ? 0.9 : 0.7, marginTop: 2 }}>{sub}</div>}
      </div>
    </button>
  );
}

export default function MiDia({ usuario, setPage }) {
  const [now, setNow] = useState(() => new Date());
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState({
    ventasTurno: 0, metaTurno: 0, tickets: 0, itemsTotales: 0,
    ticketsConDosItems: 0, ticketsConCliente: 0,
    ventasMes: 0, metaMes: 0,
    diasTrabajados: 0, diasCumplidos: 0, rachaActual: 0,
    categoriaTop: null, totalUnidadesCategoriaTop: 0,
    citasEnEspera: 0,
    bonosOn: false,
  });
  const [jornada, setJornada] = useState(null);

  // Reloj vivo (solo para la hora visible).
  useEffect(() => {
    const t = setInterval(() => setNow(new Date()), 60 * 1000);
    return () => clearInterval(t);
  }, []);

  const turnoAsignado = turnoDePerfil(usuario);
  const turno = turnoAsignado || inferirTurno(now);

  const cargarDatos = useCallback(async () => {
    if (!usuario) return;
    setLoading(true);
    try {
      const empleadoId = await idEmpleadoUsuarios(usuario);
      if (!empleadoId) {
        showToast("Tu usuario no está vinculado a un empleado. Contacta al admin.", "warning");
        setLoading(false);
        return;
      }

      const hoy = new Date();
      const { jornada: j } = await fetchJornadaHoy();
      setJornada(j);
      const cubreAmbos = !!j?.cubre_ambos;
      const inicioTurno = cubreAmbos
        ? new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate(), 0, 0, 0).toISOString()
        : inicioDelTurno(hoy, turno).toISOString();
      const finTurno = cubreAmbos
        ? new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate(), 23, 59, 59, 999).toISOString()
        : finDelTurno(hoy, turno).toISOString();
      const inicioMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1).toISOString();

      const tok = sessionStorage.getItem("farmacapital_session_token");
      const [configMap, snapRes] = await Promise.all([
        cargarConfigMetas(),
        tok
          ? supabase.rpc("empleado_midia_snapshot", {
              p_session_token: tok,
              p_empleado_id: empleadoId,
              p_turno_start: inicioTurno,
              p_turno_end: finTurno,
              p_mes_start: inicioMes,
              p_fecha_citas: hoy.toISOString().slice(0, 10),
            })
          : Promise.resolve({ data: null, error: { message: "sin sesión" } }),
      ]);

      const snap = snapRes?.data || {};
      const pedTurno = snap.ped_turno || [];
      const pedMes = snap.ped_mes || [];
      const citasEspera = typeof snap.citas_espera === "number" ? snap.citas_espera : 0;

      // ── Meta del turno (si cubre ambos, es la meta de todo el día).
      const cubreAmbosMeta = !!j?.cubre_ambos;
      const multTurno = calcularMultiplicador(hoy, configMap);
      let metaTurno;
      if (cubreAmbosMeta) {
        const claveM = claveMetaTurno(hoy, "matutino");
        const claveV = claveMetaTurno(hoy, "vespertino");
        const mm = parseFloat(configMap[claveM] || 0);
        const mv = claveV === claveM ? 0 : parseFloat(configMap[claveV] || 0);
        metaTurno = Math.round((mm + mv) * multTurno);
      } else {
        const claveMeta = claveMetaTurno(hoy, turno);
        metaTurno = Math.round(parseFloat(configMap[claveMeta] || 0) * multTurno);
      }

      // ── KPIs del turno.
      const ventasTurno = pedTurno.reduce((a, p) => a + parseFloat(p.total || 0), 0);
      const tickets = pedTurno.length;
      const itemsTotales = pedTurno.reduce((a, p) => a + (p.pedido_items || []).reduce((b, i) => b + (i.cantidad || 0), 0), 0);
      const ticketsConDosItems = pedTurno.filter((p) => (p.pedido_items || []).length >= 2).length;
      const ticketsConCliente = pedTurno.filter((p) => p.cliente_id != null).length;

      // ── Categoría top del vendedor en el turno (para logro).
      const catCount = new Map();
      pedTurno.forEach((p) => (p.pedido_items || []).forEach((it) => {
        const cat = it.productos?.categoria || null;
        if (!cat) return;
        catCount.set(cat, (catCount.get(cat) || 0) + (it.cantidad || 0));
      }));
      let categoriaTop = null;
      let totalUnidadesCategoriaTop = 0;
      catCount.forEach((v, k) => { if (v > totalUnidadesCategoriaTop) { categoriaTop = k; totalUnidadesCategoriaTop = v; } });

      // ── Mes: agrupar ventas por día y comparar contra meta del día.
      const ventasPorDia = new Map();
      pedMes.forEach((p) => {
        const d = new Date(p.created_at);
        const k = d.toISOString().slice(0, 10);
        ventasPorDia.set(k, (ventasPorDia.get(k) || 0) + parseFloat(p.total || 0));
      });
      const diasTrabajados = ventasPorDia.size;
      let diasCumplidos = 0;
      let rachaActual = 0;
      // Iterar de hoy hacia atrás para calcular racha.
      const fechasOrdenadas = [...ventasPorDia.keys()].sort(); // asc
      const diaMeta = (d) => {
        // meta del día = meta matutino + meta vespertino (combinada), con ajuste por fecha.
        const claveM = claveMetaTurno(d, "matutino");
        const claveV = claveMetaTurno(d, "vespertino");
        // En sábado AM/PM son distintas; en L-V también. En domingo ambas apuntan a la misma.
        const mm = parseFloat(configMap[claveM] || 0);
        const mv = claveV === claveM ? 0 : parseFloat(configMap[claveV] || 0);
        const mult = calcularMultiplicador(d, configMap);
        return Math.round((mm + mv) * mult);
      };
      fechasOrdenadas.forEach((k) => {
        const v = ventasPorDia.get(k);
        const m = diaMeta(new Date(k + "T12:00:00"));
        if (m > 0 && v >= m) diasCumplidos++;
      });
      // Racha: desde el día más reciente hacia atrás, cuenta días consecutivos cumpliendo meta.
      for (let i = fechasOrdenadas.length - 1; i >= 0; i--) {
        const k = fechasOrdenadas[i];
        const v = ventasPorDia.get(k);
        const m = diaMeta(new Date(k + "T12:00:00"));
        if (m > 0 && v >= m) rachaActual++;
        else break;
      }

      const ventasMes = pedMes.reduce((a, p) => a + parseFloat(p.total || 0), 0);
      const metaMes = parseFloat(configMap.meta_ventas_mes || 0);

      setData({
        ventasTurno, metaTurno, tickets, itemsTotales,
        ticketsConDosItems, ticketsConCliente,
        ventasMes, metaMes,
        diasTrabajados, diasCumplidos, rachaActual,
        categoriaTop, totalUnidadesCategoriaTop,
        citasEnEspera: citasEspera,
        bonosOn: bonosActivos(configMap),
      });
    } catch (e) {
      console.warn("[MiDia] cargarDatos:", e?.message || e);
    }
    setLoading(false);
  }, [usuario, turno]);

  useEffect(() => { cargarDatos(); }, [cargarDatos]);

  // ── Realtime: recargar al insertar/actualizar pedidos del vendedor.
  useEffect(() => {
    if (!usuario?.id) return;
    let channel;
    let cancelled = false;
    (async () => {
      const empleadoId = await idEmpleadoUsuarios(usuario);
      if (!empleadoId || cancelled) return;
      channel = supabase
        .channel(`mi-dia-${empleadoId}`)
        .on("postgres_changes", {
          event: "*", schema: "public", table: "pedidos",
          filter: `atendido_por=eq.${empleadoId}`,
        }, () => { cargarDatos(); })
        .subscribe();
    })();
    return () => {
      cancelled = true;
      if (channel) supabase.removeChannel(channel);
    };
  }, [usuario, cargarDatos]);

  // ── Derivados
  const pctDia = data.metaTurno > 0 ? Math.round((data.ventasTurno / data.metaTurno) * 100) : 0;
  const pctMes = data.metaMes > 0 ? Math.round((data.ventasMes / data.metaMes) * 100) : 0;
  const faltaDia = Math.max(0, 100 - pctDia);
  const prodPorTicket = data.tickets > 0 ? (data.itemsTotales / data.tickets) : 0;
  const pctCruzada = data.tickets > 0 ? Math.round((data.ticketsConDosItems / data.tickets) * 100) : 0;
  const pctPuntos = data.tickets > 0 ? Math.round((data.ticketsConCliente / data.tickets) * 100) : 0;
  const escalon = data.bonosOn ? escalonBono(pctMes) : null;
  const escalonSiguiente = useMemo(() => {
    if (!escalon) return escalonBono(70);
    if (escalon.clave === "bono_70_89")  return { clave: "bono_90_99",   label: "90-99%" };
    if (escalon.clave === "bono_90_99")  return { clave: "bono_100_109", label: "100-109%" };
    if (escalon.clave === "bono_100_109")return { clave: "bono_110_plus",label: "110% o más" };
    return null;
  }, [escalon]);

  const colorPctDia = pctDia >= 100 ? C.green : pctDia >= 70 ? C.amber : C.red;
  const colorPctMes = pctMes >= 100 ? C.green : pctMes >= 70 ? C.amber : C.red;

  const logros = useMemo(() => {
    const out = [];
    if (data.rachaActual >= 3) {
      out.push({
        icon: Flame,
        col: C.red,
        titulo: `🔥 ${data.rachaActual} días consecutivos cumpliendo meta`,
        sub: "Racha activa. Mantén el ritmo.",
      });
    }
    if (data.categoriaTop && data.totalUnidadesCategoriaTop >= 3) {
      out.push({
        icon: Award,
        col: C.purple,
        titulo: `Líder en ${data.categoriaTop}`,
        sub: `${data.totalUnidadesCategoriaTop} unidades vendidas en el turno.`,
      });
    }
    if (pctPuntos >= 60 && data.tickets >= 3) {
      out.push({
        icon: UsersIcon,
        col: C.blue,
        titulo: "Cliente primero",
        sub: `${pctPuntos}% de tus tickets vinculados a un cliente registrado.`,
      });
    }
    if (data.tickets >= 20) {
      out.push({
        icon: Zap,
        col: C.amber,
        titulo: "Atención en ráfaga",
        sub: `${data.tickets} tickets en el turno.`,
      });
    }
    return out;
  }, [data, pctPuntos]);

  const saludo = saludoUsuario(usuario?.nombre);
  const turnoLabel = jornada?.es_descanso
    ? `descansas (${etiquetaDiaDescanso(jornada.dia_descanso) || "hoy"})`
    : jornada?.cubre_ambos
      ? "hoy cubres ambos turnos"
      : (turnoAsignado
        ? (turno === "matutino" ? "turno matutino" : "turno vespertino")
        : "sin turno asignado");

  return (
    <div style={{ padding: 24, maxWidth: 1100, margin: "0 auto", background: C.bg, minHeight: "100dvh", fontFamily: "var(--fc-body)" }}>

      {/* ── SECCIÓN 1: SALUDO ─────────────────────────────── */}
      <div style={{ marginBottom: 20 }}>
        <h1 style={{ margin: 0, color: C.text, fontSize: 22, fontWeight: 800 }}>
          👋 {saludo}
          <span style={{ color: C.textMid, fontWeight: 600, fontSize: 16 }}> · {turnoLabel}</span>
        </h1>
        <p style={{ margin: "6px 0 0", color: C.textMid, fontSize: 13, textTransform: "capitalize" }}>
          📅 {fmtFechaLargaEs(now)} · {fmtHora(now)}
        </p>
      </div>

      {/* ── SECCIÓN 2: META DEL DÍA ───────────────────────── */}
      <div style={{
        background: `linear-gradient(135deg, ${BRAND.primary}, ${BRAND.secondary})`,
        color: "#fff", borderRadius: 16, padding: "26px 28px", marginBottom: 18,
        boxShadow: "0 6px 20px rgba(0,82,204,.25)",
      }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 14 }}>
          <Target size={20} strokeWidth={2.3} />
          <div style={{ fontSize: 12, fontWeight: 700, letterSpacing: 1.5, opacity: 0.9 }}>TU META DE HOY</div>
        </div>
        <div style={{ display: "flex", alignItems: "baseline", gap: 8, marginBottom: 12 }}>
          <div style={{ fontSize: 54, fontWeight: 800, lineHeight: 1 }}>{pctDia}%</div>
          {data.metaTurno > 0 && (
            <div style={{ fontSize: 13, opacity: 0.85 }}>
              del objetivo del turno
            </div>
          )}
        </div>
        <div style={{ background: "rgba(255,255,255,.25)", height: 14, borderRadius: 7, overflow: "hidden", marginBottom: 14 }}>
          <div style={{ width: `${Math.min(100, pctDia)}%`, height: "100%", background: "#fff", borderRadius: 7, transition: "width .5s ease" }} />
        </div>
        <div style={{ fontSize: 14, fontWeight: 600, opacity: 0.95 }}>
          {data.metaTurno === 0
            ? "No hay meta configurada para este turno todavía."
            : pctDia >= 100 ? "¡Meta cumplida! Todo lo extra es impulso del mes."
            : pctDia >= 70  ? `¡Vas muy bien! Faltan ${faltaDia}% para cumplir.`
            : pctDia >= 40  ? `Vamos a medio camino — ${faltaDia}% para la meta.`
                            : `Arrancando el turno. ${faltaDia}% para la meta.`}
          {jornada?.cubre_ambos && (
            <div style={{ fontSize: 12, opacity: 0.9, marginTop: 8 }}>
              Hoy estás sola en caja: la meta es la de los dos turnos. Cierra el matutino a las 15:30 y abre el vespertino.
            </div>
          )}
        </div>
      </div>

      {/* ── SECCIÓN 3: KPIs DEL TURNO ─────────────────────── */}
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(min(100%, 160px), 1fr))", gap: 12, marginBottom: 20 }}>
        <KpiCell icon="🎫" value={data.tickets}                       label="Tickets"        col={C.blue}/>
        <KpiCell icon="💊" value={prodPorTicket.toFixed(1)}            label="Prod/Ticket"    col={C.purple}/>
        <KpiCell icon="🤝" value={`${pctCruzada}%`}                    label="Venta cruzada"  col={C.teal}/>
        <KpiCell icon="⭐" value={`${pctPuntos}%`}                     label="Con cliente"    col={C.green}/>
      </div>

      {/* ── SECCIÓN 4: TU MES ─────────────────────────────── */}
      <div style={{
        background: C.card, border: `1px solid ${C.border}`, borderRadius: 14,
        padding: "20px 22px", marginBottom: 18,
      }}>
        <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1.5, marginBottom: 10 }}>
          📅 TU MES · DÍA {now.getDate()}
        </div>
        {data.diasTrabajados > 0 ? (
          <div style={{ color: C.text, fontSize: 14, marginBottom: 10 }}>
            Cumpliste <strong>{data.diasCumplidos}</strong> de <strong>{data.diasTrabajados}</strong> días
            trabajados {data.diasTrabajados > 0 ? `(${Math.round((data.diasCumplidos / data.diasTrabajados) * 100)}%)` : ""}.
          </div>
        ) : (
          <div style={{ color: C.textMid, fontSize: 13, marginBottom: 10 }}>
            Sin registros este mes todavía.
          </div>
        )}

        {data.metaMes > 0 && (
          <>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 6, fontSize: 12, color: C.textMid, fontWeight: 700 }}>
              <span>META MENSUAL</span>
              <span style={{ color: colorPctMes, fontSize: 16 }}>{pctMes}%</span>
            </div>
            <ProgressBar pct={pctMes} col={colorPctMes} />
          </>
        )}

        {data.bonosOn && escalon ? (
          <div style={{ marginTop: 14, padding: "12px 14px", background: C.greenDim, border: `1px solid ${C.green}40`, borderRadius: 10 }}>
            <div style={{ color: C.greenDark, fontSize: 12, fontWeight: 700, marginBottom: 4 }}>
              🎁 Bono proyectado: escalón {escalon.label}
            </div>
            {escalonSiguiente && (
              <div style={{ color: C.textMid, fontSize: 12 }}>
                Si cierras fuerte los últimos días puedes subir al escalón <strong>{escalonSiguiente.label}</strong>.
              </div>
            )}
          </div>
        ) : data.bonosOn && data.metaMes > 0 ? (
          <div style={{ marginTop: 14, padding: "12px 14px", background: C.amberDim, border: `1px solid ${C.amber}40`, borderRadius: 10, fontSize: 12, color: C.textMid }}>
            Aún no alcanzas el primer escalón de bono (70%). Cada venta suma.
          </div>
        ) : null}
      </div>

      {/* ── SECCIÓN 5: LOGROS ─────────────────────────────── */}
      {logros.length > 0 && (
        <div style={{ marginBottom: 20 }}>
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1.5, marginBottom: 10 }}>
            🏆 TUS LOGROS
          </div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(min(100%, 260px), 1fr))", gap: 10 }}>
            {logros.map((l, i) => <Logro key={i} {...l} />)}
          </div>
        </div>
      )}

      {/* ── SECCIÓN 6: BOTONES DE ACCIÓN ──────────────────── */}
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(min(100%, 240px), 1fr))", gap: 14 }}>
        <BotonGrande
          icon={ShoppingCart}
          titulo="IR A VENDER"
          sub="Abrir Punto de Venta"
          primary
          onClick={() => setPage && setPage("pos")}
        />
        <BotonGrande
          icon={ClipboardList}
          titulo="LISTA DE ESPERA"
          sub={data.citasEnEspera > 0 ? `${data.citasEnEspera} paciente${data.citasEnEspera !== 1 ? "s" : ""} aguardando` : "Sin pacientes en espera"}
          onClick={() => setPage && setPage("pos", { posTab: "consultas" })}
        />
      </div>

      {loading && (
        <div style={{ position: "fixed", right: 16, bottom: 16, padding: "6px 12px", background: C.card, border: `1px solid ${C.border}`, borderRadius: 8, fontSize: 11, color: C.textMid, pointerEvents: "none", touchAction: "manipulation" }}>
          <Gauge size={12} style={{ verticalAlign: "middle", marginRight: 6 }} /> Cargando datos…
        </div>
      )}
    </div>
  );
}
