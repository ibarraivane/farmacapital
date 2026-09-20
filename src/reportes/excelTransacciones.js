// =====================================================================
// FarmaCapital — Exportación de transacciones a Excel (ExcelJS)
//
// Reglas de formato (no negociables, son el motivo de este archivo):
//  · Fechas como fecha real y horas como hora real, nunca texto.
//  · Números como números. Ni un solo valor numérico guardado como texto.
//  · Encabezado congelado, autofiltro y tabla con nombre en cada hoja.
//  · Sin celdas combinadas en hojas de datos.
//  · Sin subtotales intercalados: la hoja Detalle debe ser plana para
//    que una tabla dinámica funcione sin limpieza previa.
// =====================================================================
import {
  ARGB, CONFIG, MESES, DIAS, aFecha, aHora,
  obtenerHoja, nombreArchivo,
} from './config';

const F = {
  mxn:   '"$"#,##0.00',
  pct:   '0.0%',
  ent:   '#,##0',
  dec1:  '#,##0.0',
  fecha: 'dd/mm/yyyy',
  hora:  'hh:mm',
};

// ---------------------------------------------------------------------
// Definición de hojas: orden, título, columnas y de dónde salen
// ---------------------------------------------------------------------
const HOJAS = [
  {
    id: 'transacciones', nombre: 'Transacciones', tabla: 'tblTransacciones',
    cols: [
      { k: 'folio',           t: 'Folio',          w: 14 },
      { k: 'fecha',           t: 'Fecha',          w: 12, tipo: 'fecha' },
      { k: 'hora',            t: 'Hora',           w: 9,  tipo: 'hora' },
      { k: 'dia_semana',      t: 'Día',            w: 12 },
      { k: 'turno',           t: 'Turno',          w: 12 },
      { k: 'vendedor',        t: 'Vendedor',       w: 20 },
      { k: 'canal',           t: 'Canal',          w: 12 },
      { k: 'metodo_pago',     t: 'Método de pago', w: 15 },
      { k: 'subtotal',        t: 'Subtotal',       w: 13, tipo: 'mxn' },
      { k: 'descuento',       t: 'Descuento',      w: 12, tipo: 'mxn' },
      { k: 'total',           t: 'Total',          w: 13, tipo: 'mxn' },
      { k: 'piezas',          t: 'Piezas',         w: 9,  tipo: 'ent' },
      { k: 'partidas',        t: 'Partidas',       w: 10, tipo: 'ent' },
      { k: 'cliente',         t: 'Cliente',        w: 18 },
      { k: 'estado',          t: 'Estado',         w: 12 },
      { k: 'caja_sesion_id',  t: 'Sesión de caja', w: 20 },
    ],
  },
  {
    id: 'detalle', nombre: 'Detalle', tabla: 'tblDetalle',
    cols: [
      { k: 'folio',           t: 'Folio',          w: 14 },
      { k: 'fecha',           t: 'Fecha',          w: 12, tipo: 'fecha' },
      { k: 'hora',            t: 'Hora',           w: 9,  tipo: 'hora' },
      { k: 'turno',           t: 'Turno',          w: 12 },
      { k: 'vendedor',        t: 'Vendedor',       w: 20 },
      { k: 'codigo_barras',   t: 'Código',         w: 16 },
      { k: 'descripcion',     t: 'Descripción',    w: 42 },
      { k: 'categoria',       t: 'Categoría',      w: 18 },
      { k: 'laboratorio',     t: 'Laboratorio',    w: 18 },
      { k: 'cantidad',        t: 'Cantidad',       w: 10, tipo: 'ent' },
      { k: 'precio_unitario', t: 'Precio unit.',   w: 13, tipo: 'mxn' },
      { k: 'descuento',       t: 'Descuento',      w: 12, tipo: 'mxn' },
      { k: 'importe',         t: 'Importe',        w: 13, tipo: 'mxn' },
      { k: 'costo_unitario',  t: 'Costo unit.',    w: 13, tipo: 'mxn' },
      { k: 'costo_total',     t: 'Costo total',    w: 13, tipo: 'mxn' },
      { k: 'utilidad',        t: 'Utilidad',       w: 13, tipo: 'mxn' },
      { k: 'margen_pct',      t: 'Margen',         w: 10, tipo: 'pct', alerta: 'margen' },
      { k: 'lote',            t: 'Lote',           w: 14 },
      { k: 'caducidad',       t: 'Caducidad',      w: 12, tipo: 'fecha' },
      { k: 'metodo_pago',     t: 'Método de pago', w: 15 },
    ],
  },
  {
    id: 'diario', nombre: 'Resumen diario', tabla: 'tblDiario',
    cols: [
      { k: 'fecha',           t: 'Fecha',          w: 12, tipo: 'fecha' },
      { k: 'dia_semana',      t: 'Día',            w: 12 },
      { k: 'venta_neta',      t: 'Venta neta',     w: 15, tipo: 'mxn' },
      { k: 'tickets',         t: 'Tickets',        w: 10, tipo: 'ent' },
      { k: 'ticket_promedio', t: 'Ticket prom.',   w: 14, tipo: 'mxn' },
      { k: 'piezas',          t: 'Piezas',         w: 10, tipo: 'ent' },
      { k: 'costo',           t: 'Costo',          w: 14, tipo: 'mxn' },
      { k: 'utilidad',        t: 'Utilidad',       w: 14, tipo: 'mxn', calc: (r) => num(r.venta_neta) - num(r.costo) },
      { k: 'margen_pct',      t: 'Margen',         w: 10, tipo: 'pct', alerta: 'margen',
        calc: (r) => (num(r.venta_neta) ? (num(r.venta_neta) - num(r.costo)) / num(r.venta_neta) : 0) },
      { k: 'efectivo',        t: 'Efectivo',       w: 14, tipo: 'mxn' },
      { k: 'tarjeta',         t: 'Tarjeta',        w: 14, tipo: 'mxn' },
      { k: 'spei',            t: 'SPEI',           w: 14, tipo: 'mxn' },
      { k: 'mercadopago',     t: 'MercadoPago',    w: 14, tipo: 'mxn' },
    ],
  },
  {
    id: 'productos', nombre: 'Resumen por producto', tabla: 'tblProductos',
    cols: [
      { k: 'codigo_barras',   t: 'Código',         w: 16 },
      { k: 'descripcion',     t: 'Descripción',    w: 42 },
      { k: 'categoria',       t: 'Categoría',      w: 18 },
      { k: 'piezas',          t: 'Piezas',         w: 10, tipo: 'ent' },
      { k: 'importe',         t: 'Importe',        w: 15, tipo: 'mxn' },
      { k: 'costo',           t: 'Costo',          w: 15, tipo: 'mxn' },
      { k: 'utilidad',        t: 'Utilidad',       w: 15, tipo: 'mxn' },
      { k: 'margen_pct',      t: 'Margen',         w: 10, tipo: 'pct', alerta: 'margen' },
      { k: 'part_venta',      t: '% de la venta',  w: 13, tipo: 'pct' },
      { k: 'clase_abc',       t: 'Clase ABC',      w: 11 },
      { k: 'stock_actual',    t: 'Stock',          w: 10, tipo: 'ent' },
      { k: 'dias_cobertura',  t: 'Días cobertura', w: 15, tipo: 'dec1' },
      { k: 'ultima_venta',    t: 'Última venta',   w: 13, tipo: 'fecha' },
    ],
  },
  {
    id: 'pagos_servicio', nombre: 'Pagos de servicio', tabla: 'tblServicios',
    cols: [
      { k: 'fecha',       t: 'Fecha',          w: 12, tipo: 'fecha' },
      { k: 'hora',        t: 'Hora',           w: 9,  tipo: 'hora' },
      { k: 'tipo',        t: 'Tipo',           w: 16 },
      { k: 'referencia',  t: 'Referencia',     w: 22 },
      { k: 'monto',       t: 'Monto',          w: 14, tipo: 'mxn' },
      { k: 'comision',    t: 'Comisión',       w: 13, tipo: 'mxn' },
      { k: 'metodo_pago', t: 'Método de pago', w: 15 },
      { k: 'vendedor',    t: 'Vendedor',       w: 20 },
    ],
  },
  {
    id: 'cortes', nombre: 'Cortes de caja', tabla: 'tblCortes',
    cols: [
      { k: 'fecha',              t: 'Fecha',        w: 12, tipo: 'fecha' },
      { k: 'turno',              t: 'Turno',        w: 12 },
      { k: 'vendedor',           t: 'Vendedor',     w: 20 },
      { k: 'abierta_at',         t: 'Apertura',     w: 9,  tipo: 'hora' },
      { k: 'cerrada_at',         t: 'Cierre',       w: 9,  tipo: 'hora' },
      { k: 'horas',              t: 'Horas',        w: 9,  tipo: 'dec1' },
      { k: 'fondo_inicial',      t: 'Fondo',        w: 13, tipo: 'mxn' },
      { k: 'efectivo_declarado', t: 'Declarado',    w: 14, tipo: 'mxn' },
      { k: 'efectivo_sistema',   t: 'Sistema',      w: 14, tipo: 'mxn' },
      { k: 'esperado',           t: 'Esperado',     w: 14, tipo: 'mxn' },
      { k: 'diferencia',         t: 'Diferencia',   w: 13, tipo: 'mxn', alerta: 'negativo' },
      { k: 'tarjeta',            t: 'Tarjeta',      w: 13, tipo: 'mxn' },
      { k: 'spei',               t: 'SPEI',         w: 13, tipo: 'mxn' },
      { k: 'mercadopago',        t: 'MercadoPago',  w: 14, tipo: 'mxn' },
      { k: 'total_general',      t: 'Total general',w: 15, tipo: 'mxn' },
      { k: 'estado',             t: 'Estado',       w: 12 },
    ],
  },
  {
    id: 'devoluciones', nombre: 'Devoluciones', tabla: 'tblDevoluciones',
    cols: [
      { k: 'fecha',           t: 'Fecha',    w: 12, tipo: 'fecha' },
      { k: 'folio_original',  t: 'Folio original', w: 16 },
      { k: 'producto',        t: 'Producto', w: 42 },
      { k: 'cantidad',        t: 'Cantidad', w: 10, tipo: 'ent' },
      { k: 'importe',         t: 'Importe',  w: 14, tipo: 'mxn' },
      { k: 'motivo',          t: 'Motivo',   w: 32 },
      { k: 'autorizo',        t: 'Autorizó', w: 20 },
    ],
  },
];

const num = (v) => (v === null || v === undefined || v === '' ? 0 : Number(v));

// ---------------------------------------------------------------------
// Construcción
// ---------------------------------------------------------------------
/** PR 1: Portada + Transacciones + Detalle + Diario + Cortes + por hora. */
const HOJAS_PR1 = new Set(['transacciones', 'detalle', 'diario', 'cortes']);

export async function generarExcel(anio, mes, onProgreso) {
  const ExcelJS = (await import('exceljs')).default ?? (await import('exceljs'));

  const wb = new ExcelJS.Workbook();
  wb.creator = 'FarmaCapital';
  wb.created = new Date();

  const hojas = HOJAS.filter((h) => HOJAS_PR1.has(h.id));

  // --- Descarga de datos ---------------------------------------------
  const datos = {};
  for (let i = 0; i < hojas.length; i++) {
    const h = hojas[i];
    onProgreso?.(`Consultando ${h.nombre.toLowerCase()}…`, 10 + (i / hojas.length) * 60);
    datos[h.id] = await obtenerHoja(anio, mes, h.id);
  }
  onProgreso?.('Consultando ventas por hora…', 72);
  const porHora = await obtenerHoja(anio, mes, 'por_hora');

  onProgreso?.('Armando el archivo…', 80);

  // --- Hoja 1: Portada ------------------------------------------------
  portada(wb, anio, mes, datos);

  // --- Hojas de datos -------------------------------------------------
  for (const h of hojas) hojaDatos(wb, h, datos[h.id]);

  // --- Hoja de matriz hora × día --------------------------------------
  hojaPorHora(wb, porHora);

  onProgreso?.('Generando descarga…', 95);
  const buffer = await wb.xlsx.writeBuffer();
  descargar(buffer, nombreArchivo('transacciones', anio, mes, 'xlsx'));
  onProgreso?.('Listo', 100);
}

// ---------------------------------------------------------------------
function portada(wb, anio, mes, datos) {
  const ws = wb.addWorksheet('Portada');
  ws.columns = [{ width: 34 }, { width: 24 }, { width: 24 }];

  const titulo = ws.getCell('A1');
  titulo.value = 'FarmaCapital — Transacciones';
  titulo.font = { size: 18, bold: true, color: { argb: ARGB.tinta } };
  ws.getRow(1).height = 26;

  const meta = [
    ['Periodo', `${MESES[mes - 1]} ${anio}`],
    ['Generado', new Date()],
    ['Zona horaria', 'America/Mexico_City'],
    ['Confidencialidad', 'Uso interno. Contiene costos y márgenes.'],
    ['Aviso', 'Herramienta de gestión. No sustituye la contabilidad ni los CFDI.'],
  ];
  meta.forEach(([k, v], i) => {
    const r = ws.getRow(3 + i);
    r.getCell(1).value = k;
    r.getCell(1).font = { bold: true, color: { argb: ARGB.gris } };
    r.getCell(2).value = v;
    if (v instanceof Date) r.getCell(2).numFmt = 'dd/mm/yyyy hh:mm';
  });

  const tx = datos.transacciones || [];
  const det = datos.detalle || [];
  const venta  = tx.reduce((s, r) => s + num(r.total), 0);
  const piezas = det.reduce((s, r) => s + num(r.cantidad), 0);
  const costo  = det.reduce((s, r) => s + num(r.costo_total), 0);
  const importe= det.reduce((s, r) => s + num(r.importe), 0);

  const h = ws.getRow(10);
  h.getCell(1).value = 'Cifras de control';
  h.getCell(1).font = { bold: true, size: 13, color: { argb: ARGB.tinta } };

  const control = [
    ['Venta neta',        venta,               F.mxn],
    ['Tickets',           tx.length,           F.ent],
    ['Ticket promedio',   tx.length ? venta / tx.length : 0, F.mxn],
    ['Piezas',            piezas,              F.ent],
    ['Costo de lo vendido', costo,             F.mxn],
    ['Utilidad bruta',    importe - costo,     F.mxn],
    ['Margen',            importe ? (importe - costo) / importe : 0, F.pct],
  ];
  control.forEach(([k, v, f], i) => {
    const r = ws.getRow(11 + i);
    r.getCell(1).value = k;
    r.getCell(2).value = v;
    r.getCell(2).numFmt = f;
    r.getCell(2).font = { bold: true };
  });

  ws.getCell('A20').value = 'Estas cifras deben coincidir con el reporte del mes en PDF.';
  ws.getCell('A20').font = { italic: true, color: { argb: ARGB.gris } };
}

// ---------------------------------------------------------------------
function hojaDatos(wb, def, filas) {
  const ws = wb.addWorksheet(def.nombre, {
    views: [{ state: 'frozen', ySplit: 1 }],
  });

  const rows = (filas || []).map((r) =>
    def.cols.map((c) => valorCelda(c, r))
  );

  ws.addTable({
    name: def.tabla,
    ref: 'A1',
    headerRow: true,
    // theme null: ExcelJS no impone estilo, así el formato manual sí se aplica
    style: { theme: null, showRowStripes: false },
    columns: def.cols.map((c) => ({ name: c.t, filterButton: true })),
    rows: rows.length ? rows : [def.cols.map(() => null)],
  });

  // Encabezado
  const head = ws.getRow(1);
  head.height = 22;
  head.eachCell((cell) => {
    cell.font = { bold: true, color: { argb: ARGB.blanco }, size: 11 };
    cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: ARGB.tinta } };
    cell.alignment = { vertical: 'middle', horizontal: 'left' };
  });

  // Columnas: ancho, formato y alineación
  def.cols.forEach((c, i) => {
    const col = ws.getColumn(i + 1);
    col.width = c.w;
    if (c.tipo && F[c.tipo]) col.numFmt = F[c.tipo];
    if (['mxn', 'ent', 'dec1', 'pct'].includes(c.tipo)) {
      col.alignment = { horizontal: 'right' };
    }
  });

  if (!rows.length) {
    ws.getCell('A2').value = 'Sin movimientos en el periodo';
    ws.getCell('A2').font = { italic: true, color: { argb: ARGB.gris } };
    return;
  }

  const ultima = rows.length + 1;

  // Franja alterna suave
  ws.addConditionalFormatting({
    ref: `A2:${letra(def.cols.length)}${ultima}`,
    rules: [{
      type: 'expression', priority: 50,
      formulae: ['MOD(ROW(),2)=0'],
      style: { fill: { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFF6F8FA' } } },
    }],
  });

  // Alertas por columna
  def.cols.forEach((c, i) => {
    if (!c.alerta) return;
    const col = letra(i + 1);
    const ref = `${col}2:${col}${ultima}`;
    if (c.alerta === 'negativo') {
      ws.addConditionalFormatting({ ref, rules: [{
        type: 'cellIs', operator: 'lessThan', priority: 10, formulae: ['0'],
        style: { font: { color: { argb: 'FF' + 'B00020' }, bold: true } },
      }]});
    }
    if (c.alerta === 'margen') {
      ws.addConditionalFormatting({ ref, rules: [{
        type: 'cellIs', operator: 'lessThan', priority: 10,
        formulae: [String(CONFIG.MARGEN_MINIMO_ALERTA)],
        style: { font: { color: { argb: 'FFB00020' } } },
      }]});
    }
  });

  // Caducidad próxima en rojo (solo hoja Detalle)
  const iCad = def.cols.findIndex((c) => c.k === 'caducidad');
  if (iCad >= 0) {
    const col = letra(iCad + 1);
    ws.addConditionalFormatting({
      ref: `${col}2:${col}${ultima}`,
      rules: [{
        type: 'expression', priority: 9,
        formulae: [`AND(${col}2<>"",${col}2<TODAY()+30)`],
        style: { font: { color: { argb: 'FFB00020' }, bold: true } },
      }],
    });
  }
}

function valorCelda(c, r) {
  const v = r[c.k];
  if (c.calc) return c.calc(r);
  switch (c.tipo) {
    case 'fecha': return aFecha(v);
    case 'hora':  return aHora(v);
    case 'mxn':
    case 'pct':
    case 'ent':
    case 'dec1':  return v === null || v === undefined ? null : Number(v);
    default:      return v ?? '';
  }
}

// ---------------------------------------------------------------------
function hojaPorHora(wb, filas) {
  const ws = wb.addWorksheet('Resumen por hora', {
    views: [{ state: 'frozen', xSplit: 1, ySplit: 2 }],
  });
  const horas = [];
  for (let h = 8; h <= 22; h++) horas.push(h);

  const mapa = {};
  (filas || []).forEach((r) => {
    mapa[`${r.dow}-${r.hora}`] = { importe: num(r.importe), tickets: num(r.tickets) };
  });

  const bloque = (titulo, campo, filaInicio, formato) => {
    const t = ws.getCell(`A${filaInicio}`);
    t.value = titulo;
    t.font = { bold: true, size: 12, color: { argb: ARGB.tinta } };

    const head = ws.getRow(filaInicio + 1);
    head.getCell(1).value = 'Hora';
    DIAS.forEach((d, i) => { head.getCell(i + 2).value = d; });
    head.eachCell((cell) => {
      cell.font = { bold: true, color: { argb: ARGB.blanco } };
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: ARGB.tinta } };
    });

    horas.forEach((h, j) => {
      const row = ws.getRow(filaInicio + 2 + j);
      row.getCell(1).value = `${String(h).padStart(2, '0')}:00`;
      DIAS.forEach((_, d) => {
        const cell = row.getCell(d + 2);
        cell.value = mapa[`${d}-${h}`]?.[campo] ?? 0;
        cell.numFmt = formato;
        cell.alignment = { horizontal: 'right' };
      });
    });

    const desde = filaInicio + 2;
    const hasta = filaInicio + 1 + horas.length;
    ws.addConditionalFormatting({
      ref: `B${desde}:H${hasta}`,
      rules: [{
        type: 'colorScale', priority: 20,
        cfvo: [{ type: 'min' }, { type: 'max' }],
        color: [{ argb: 'FFFFFFFF' }, { argb: ARGB.azul }],
      }],
    });
  };

  ws.getColumn(1).width = 10;
  for (let i = 2; i <= 8; i++) ws.getColumn(i).width = 14;

  bloque('Importe por hora y día de la semana', 'importe', 1, F.mxn);
  bloque('Tickets por hora y día de la semana', 'tickets', horas.length + 5, F.ent);
}

// ---------------------------------------------------------------------
const letra = (n) => {
  let s = '';
  while (n > 0) { const m = (n - 1) % 26; s = String.fromCharCode(65 + m) + s; n = (n - m - 1) / 26; }
  return s;
};

function descargar(buffer, nombre) {
  const blob = new Blob([buffer], {
    type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url; a.download = nombre;
  document.body.appendChild(a); a.click();
  document.body.removeChild(a);
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}
