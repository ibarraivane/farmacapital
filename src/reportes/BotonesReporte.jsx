// =====================================================================
// FarmaCapital — Botones de exportación en la vista Transacciones
//
// Reemplaza el botón de descarga anterior.
// Sólo se renderiza para el rol admin, y además el servidor lo valida:
// ocultar el botón no es un control de acceso.
//
// ExcelJS y pdfmake se cargan con import() dinámico dentro de los
// módulos generadores, nunca en el bundle inicial.
// =====================================================================
import { useState, useMemo, useCallback } from 'react';
import {
  COLOR, MESES, obtenerReporteMensual, registrarAuditoria,
} from './config';

const AHORA = new Date();

export default function BotonesReporte({ rol, mostrarPdf = false }) {
  const [anio, setAnio] = useState(AHORA.getFullYear());
  const [mes,  setMes]  = useState(AHORA.getMonth() + 1);
  const [tarea, setTarea] = useState(null);   // 'pdf' | 'excel' | null
  const [ultima, setUltima] = useState('excel');
  const [paso, setPaso] = useState('');
  const [avance, setAvance] = useState(0);
  const [error, setError] = useState(null);

  const anios = useMemo(() => {
    const y = AHORA.getFullYear();
    return [y, y - 1, y - 2];
  }, []);

  const progreso = useCallback((texto, valor) => {
    setPaso(texto);
    if (typeof valor === 'number') setAvance(valor);
  }, []);

  const descargarPDF = useCallback(async () => {
    setTarea('pdf'); setUltima('pdf'); setError(null); setAvance(5); setPaso('Consultando ventas…');
    try {
      const data = await obtenerReporteMensual(anio, mes);
      progreso('Calculando indicadores…', 40);
      const { generarPDF } = await import('./pdfReporteMensual');
      await generarPDF(data, progreso);
      registrarAuditoria('exporta_reporte_mensual_pdf', `${anio}-${mes}`);
    } catch (e) {
      setError(e.message || 'No se pudo generar el reporte.');
    } finally {
      setTarea(null); setPaso(''); setAvance(0);
    }
  }, [anio, mes, progreso]);

  const descargarExcel = useCallback(async () => {
    setTarea('excel'); setUltima('excel'); setError(null); setAvance(5); setPaso('Consultando transacciones…');
    try {
      const { generarExcel } = await import('./excelTransacciones');
      await generarExcel(anio, mes, progreso);
      registrarAuditoria('exporta_transacciones_excel', `${anio}-${mes}`);
    } catch (e) {
      setError(e.message || 'No se pudo generar el archivo.');
    } finally {
      setTarea(null); setPaso(''); setAvance(0);
    }
  }, [anio, mes, progreso]);

  if (rol !== 'admin') return null;

  const ocupado = tarea !== null;

  return (
    <div style={S.caja}>
      <div style={S.fila}>
        <select
          className="farmacapital-field-select farmacapital-field-input"
          value={mes}
          onChange={(e) => setMes(Number(e.target.value))}
          disabled={ocupado}
          style={S.select}
          aria-label="Mes"
        >
          {MESES.map((m, i) => <option key={m} value={i + 1}>{m}</option>)}
        </select>

        <select
          className="farmacapital-field-select farmacapital-field-input"
          value={anio}
          onChange={(e) => setAnio(Number(e.target.value))}
          disabled={ocupado}
          style={S.select}
          aria-label="Año"
        >
          {anios.map((a) => <option key={a} value={a}>{a}</option>)}
        </select>

        {mostrarPdf && (
          <button type="button" onClick={descargarPDF} disabled={ocupado} style={S.primario}>
            {tarea === 'pdf' ? 'Generando…' : 'Reporte del mes (PDF)'}
          </button>
        )}

        <button type="button" onClick={descargarExcel} disabled={ocupado} style={mostrarPdf ? S.secundario : S.primario}>
          {tarea === 'excel' ? 'Generando…' : 'Exportar a Excel'}
        </button>
      </div>

      {ocupado && (
        <div style={S.progresoCaja} role="status" aria-live="polite">
          <div style={S.barraFondo}>
            <div style={{ ...S.barra, width: `${avance}%` }} />
          </div>
          <span style={S.paso}>{paso}</span>
        </div>
      )}

      {error && (
        <div style={S.error} role="alert">
          {error}
          <button type="button" onClick={ultima === 'pdf' ? descargarPDF : descargarExcel} style={S.reintentar}>
            Reintentar
          </button>
        </div>
      )}

      <p style={S.aviso}>
        Documento de uso interno. Incluye costos y márgenes.
      </p>
    </div>
  );
}

// ---------------------------------------------------------------------
// Estilos en línea para que el componente se pueda pegar tal cual.
// Si el repo usa Tailwind o CSS modules, migrarlos ahí.
// ---------------------------------------------------------------------
const S = {
  caja:   { display: 'flex', flexDirection: 'column', gap: 8 },
  fila:   { display: 'flex', flexWrap: 'wrap', gap: 8, alignItems: 'center' },
  select: {
    height: 38, padding: '0 10px', borderRadius: 8, fontSize: 14,
    border: `1px solid ${COLOR.grisClaro}`, background: '#ffffff', color: '#0f172a',
    colorScheme: 'light', WebkitTextFillColor: '#0f172a', caretColor: '#0f172a',
  },
  primario: {
    height: 38, padding: '0 16px', borderRadius: 8, border: 'none', cursor: 'pointer',
    background: COLOR.azul, color: '#fff', fontSize: 14, fontWeight: 600,
  },
  secundario: {
    height: 38, padding: '0 16px', borderRadius: 8, cursor: 'pointer',
    border: `1px solid ${COLOR.azul}`, background: '#fff', color: COLOR.azul,
    fontSize: 14, fontWeight: 600,
  },
  progresoCaja: { display: 'flex', alignItems: 'center', gap: 10 },
  barraFondo: { flex: 1, height: 6, background: COLOR.grisClaro, borderRadius: 3, overflow: 'hidden' },
  barra: { height: '100%', background: COLOR.azul, transition: 'width 200ms ease' },
  paso:  { fontSize: 12, color: COLOR.gris, minWidth: 190 },
  error: {
    display: 'flex', alignItems: 'center', gap: 10, fontSize: 13,
    color: COLOR.rojo, background: '#FDECEF', padding: '8px 12px', borderRadius: 8,
  },
  reintentar: {
    border: 'none', background: 'transparent', color: COLOR.azul,
    textDecoration: 'underline', cursor: 'pointer', fontSize: 13,
  },
  aviso: { fontSize: 11, color: COLOR.gris, margin: 0 },
};
