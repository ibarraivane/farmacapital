// =====================================================================
// FarmaCapital — Reporte mensual en PDF (pdfmake)
//
// Las gráficas se dibujan como vectores dentro del documento (canvas de
// pdfmake), no como imagen de un <canvas> del navegador: una imagen
// rasterizada se ve mal impresa y pesa de más.
//
// Ninguna información depende sólo del color: el mapa de calor lleva la
// cifra impresa y las variaciones llevan flecha además del color, para
// que el reporte se lea igual en blanco y negro.
// =====================================================================
import {
  COLOR, CONFIG, DIAS_CORTO, mxn, num, dec, pct, variacion,
  fechaCorta, nombreMes, nombreArchivo,
} from './config';

const ANCHO = 468;           // ancho útil en carta con márgenes de 40/72
const TOTAL_PAGINAS = 9;

export async function generarPDF(data, onProgreso) {
  onProgreso?.('Cargando el generador…', 15);
  const pdfMakeMod = await import('pdfmake/build/pdfmake');
  const vfsMod     = await import('pdfmake/build/vfs_fonts');
  const pdfMake    = pdfMakeMod.default ?? pdfMakeMod;
  pdfMake.vfs = (vfsMod.default ?? vfsMod).pdfMake?.vfs ?? (vfsMod.default ?? vfsMod).vfs;

  onProgreso?.('Armando el documento…', 55);
  const doc = construirDocumento(data);

  onProgreso?.('Generando descarga…', 85);
  const { anio, mes } = data.meta;
  await new Promise((resolve) => {
    pdfMake.createPdf(doc).download(nombreArchivo('reporte', anio, mes, 'pdf'), resolve);
  });
  onProgreso?.('Listo', 100);
}

// =====================================================================
function construirDocumento(d) {
  const periodo = nombreMes(d.meta.anio, d.meta.mes);

  return {
    pageSize: 'LETTER',
    pageMargins: [40, 56, 40, 46],
    info: { title: `FarmaCapital — ${periodo}`, author: 'FarmaCapital' },
    defaultStyle: { font: 'Roboto', fontSize: 9, color: COLOR.tinta },
    styles: ESTILOS,

    header: (pagina) => pagina === 1 ? null : ({
      margin: [40, 24, 40, 0],
      columns: [
        { text: 'FarmaCapital', style: 'headerTxt' },
        { text: periodo, style: 'headerTxt', alignment: 'center' },
        { text: `pág. ${pagina} de ${TOTAL_PAGINAS}`, style: 'headerTxt', alignment: 'right' },
      ],
    }),

    footer: () => ({
      margin: [40, 10, 40, 0],
      text: 'Confidencial — uso interno. Contiene costos y márgenes.',
      style: 'footerTxt',
    }),

    content: [
      ...pagPortada(d, periodo),
      ...pagCrecimiento(d),
      ...pagTiempo(d),
      ...pagProductos(d),
      ...pagInventario(d),
      ...pagDinero(d),
      ...pagPersonal(d),
      ...pagCronologia(d),
      ...pagAnexo(d),
    ],
  };
}

// =====================================================================
// Página 1 — Portada y resumen ejecutivo
// =====================================================================
function pagPortada(d, periodo) {
  const r = d.resumen, p = d.previo;

  const tarjetas = [
    ['Venta neta',        mxn(r.venta_neta),        variacion(r.venta_neta, p.venta_neta)],
    ['Utilidad bruta',    `${mxn(r.utilidad_bruta)}  (${pct(r.margen_pct)})`,
                          variacion(r.utilidad_bruta, p.utilidad_bruta)],
    ['Tickets',           num(r.tickets),           variacion(r.tickets, p.tickets)],
    ['Ticket promedio',   mxn(r.ticket_promedio),   variacion(r.ticket_promedio, p.ticket_promedio)],
    ['Piezas por ticket', dec(r.piezas_x_ticket, 2),variacion(r.piezas_x_ticket, p.piezas_x_ticket)],
    ['Venta por hora',    mxn(r.venta_por_hora),    variacion(r.venta_por_hora, p.venta_por_hora)],
  ];

  const celda = ([etiqueta, valor, v]) => ({
    stack: [
      { text: etiqueta, style: 'kpiEtiqueta' },
      { text: valor, style: 'kpiValor' },
      { text: v.texto, fontSize: 9, bold: true,
        color: v.valor === null ? COLOR.gris : (v.sube ? COLOR.jade : COLOR.rojo) },
    ],
    margin: [0, 0, 0, 14],
  });

  return [
    { text: 'FarmaCapital', style: 'marca' },
    { text: `Reporte del mes · ${periodo}`, style: 'titulo' },
    {
      text: d.meta.parcial
        ? `Periodo parcial: del 1 al ${new Date(d.meta.hasta).getUTCDate() - 1} de ${periodo.split(' ')[0]}. `
          + 'Las comparativas usan el mismo tramo del mes anterior.'
        : 'Periodo completo.',
      style: 'sub',
    },
    { text: `Generado el ${fechaCorta(d.meta.generado_at)} por ${d.meta.generado_por || 'administrador'}`,
      style: 'sub', margin: [0, 0, 0, 18] },

    linea(),
    { text: 'Resumen ejecutivo', style: 'h2', margin: [0, 14, 0, 12] },
    { columns: [celda(tarjetas[0]), celda(tarjetas[1]), celda(tarjetas[2])], columnGap: 16 },
    { columns: [celda(tarjetas[3]), celda(tarjetas[4]), celda(tarjetas[5])], columnGap: 16 },

    linea(),
    { text: 'Lo que dicen los números', style: 'h2', margin: [0, 14, 0, 8] },
    { ul: conclusiones(d), style: 'conclusion' },

    ...avisos(d),
    { text: '', pageBreak: 'after' },
  ];
}

/** Conclusiones generadas de los datos, no escritas a mano. */
function conclusiones(d) {
  const out = [];
  const r = d.resumen, p = d.previo;
  const v = variacion(r.venta_neta, p.venta_neta);

  if (v.valor !== null) {
    // Descomposición: ¿creció por más gente o por ticket más grande?
    const dTickets = (r.tickets - p.tickets) * (p.ticket_promedio || 0);
    const dTicket  = (r.ticket_promedio - p.ticket_promedio) * (r.tickets || 0);
    const motor = Math.abs(dTickets) > Math.abs(dTicket) ? 'más clientes' : 'un ticket más grande';
    out.push(`La venta ${v.sube ? 'subió' : 'bajó'} ${pct(Math.abs(v.valor))} contra el mes anterior. `
      + `El movimiento vino sobre todo de ${motor}.`);
  } else {
    out.push('No hay mes anterior completo para comparar.');
  }

  const inv = d.inventario || {};
  const nAgot = (inv.agotados || []).length;
  if (nAgot > 0) {
    out.push(`${nAgot} producto${nAgot === 1 ? '' : 's'} con demanda están en cero. `
      + `Venta perdida estimada: ${mxn(inv.venta_perdida_total)}.`);
  }

  const cad = inv.caducidad_resumen || {};
  if (num(cad.v90) > 0) {
    out.push(`${mxn(cad.v90)} a costo caducan en los próximos 90 días, `
      + `de los cuales ${mxn(cad.v30)} en los próximos 30.`);
  }

  if (num(inv.sin_rotacion_total) > 0) {
    out.push(`${mxn(inv.sin_rotacion_total)} parados en ${num(inv.sin_rotacion_skus)} productos `
      + `sin una sola venta en ${CONFIG.DIAS_SIN_ROTACION} días.`);
  }

  const caja = d.dinero?.caja || {};
  if (num(caja.faltantes) > 0 || num(caja.sobrantes) > 0) {
    out.push(`Caja: ${mxn(caja.faltantes)} de faltantes y ${mxn(caja.sobrantes)} de sobrantes `
      + `en ${num(caja.cortes)} cortes. No se compensan entre sí.`);
  }

  return out;
}

/** Advertencias sobre la calidad del propio reporte. */
function avisos(d) {
  const lista = [];
  const pctCosto = Number(d.resumen.pct_costo_historico) || 0;
  if (pctCosto < 0.99) {
    lista.push(`Margen aproximado: sólo ${pct(pctCosto)} de la venta tiene costo histórico registrado. `
      + 'El resto se valuó con el costo actual del catálogo.');
  }
  if (num(d.dinero?.pagos_servicio_total) > 0) {
    lista.push('Los pagos de servicio (recargas, CFE) se reportan aparte y no forman parte de la venta. '
      + 'Si el hallazgo P0 de reconcile_shift_cash sigue abierto, parte de los sobrantes de caja son fantasma.');
  }
  if (!lista.length) return [];
  return [{
    margin: [0, 14, 0, 0],
    table: { widths: ['*'], body: [[{ ul: lista, style: 'aviso', margin: [6, 6, 6, 6] }]] },
    layout: bordeSuave(),
  }];
}

// =====================================================================
// Página 2 — Crecimiento
// =====================================================================
function pagCrecimiento(d) {
  const sem = d.crecimiento.semanas || [];
  const meses = d.crecimiento.serie_meses || [];
  const r = d.resumen, p = d.previo;

  const dTickets = (r.tickets - p.tickets) * (p.ticket_promedio || 0);
  const dTicket  = (r.ticket_promedio - p.ticket_promedio) * (r.tickets || 0);

  return [
    { text: 'Crecimiento', style: 'h1' },

    { text: 'Venta por semana', style: 'h2' },
    barras(sem.map((s) => ({
      etiqueta: `S${s.n}${s.parcial ? '*' : ''}`,
      valor: Number(s.venta) || 0,
    })), ANCHO, 120),
    tabla(
      ['Semana', 'Del', 'Al', 'Venta', 'Tickets', 'Variación'],
      sem.map((s) => [
        `Semana ${s.n}${s.parcial ? ' (parcial)' : ''}`,
        fechaCorta(s.inicio), fechaCorta(s.fin),
        mxn(s.venta), num(s.tickets),
        s.variacion === null ? '—' : coloreado(s.variacion),
      ]),
      ['*', 50, 50, 70, 50, 60], [3, 4, 5]
    ),
    { text: '* Semana parcial: no abarca los siete días dentro del mes.',
      style: 'nota', margin: [0, 4, 0, 14] },

    { text: 'Últimos 6 meses', style: 'h2' },
    linea2(meses.map((m) => Number(m.venta) || 0),
           meses.map((m) => fechaCorta(m.mes).slice(3)), ANCHO, 110),

    { text: 'De dónde vino el cambio', style: 'h2', margin: [0, 16, 0, 6] },
    {
      text: 'Separa dos cosas que se confunden siempre: si vendiste más porque entró más gente, '
          + 'o porque cada quien se llevó más. La acción que sigue es distinta en cada caso.',
      style: 'nota', margin: [0, 0, 0, 8],
    },
    tabla(
      ['Componente', 'Efecto en la venta'],
      [
        ['Cambio en número de tickets', coloreado(null, mxn(dTickets), dTickets >= 0)],
        ['Cambio en ticket promedio',   coloreado(null, mxn(dTicket),  dTicket  >= 0)],
        [{ text: 'Cambio total', bold: true },
         { text: mxn(dTickets + dTicket), bold: true, alignment: 'right' }],
      ],
      ['*', 120], [1]
    ),
    { text: '', pageBreak: 'after' },
  ];
}

// =====================================================================
// Página 3 — Cuándo se vende
// =====================================================================
function pagTiempo(d) {
  const t = d.tiempo;
  const horas = []; for (let h = 8; h <= 22; h++) horas.push(h);

  const q = t.quincena || {};
  const efectoQ = num(q.promedio_resto)
    ? (num(q.promedio_quincena) - num(q.promedio_resto)) / num(q.promedio_resto) : null;

  return [
    { text: 'Cuándo se vende', style: 'h1' },

    { text: 'Importe por hora y día de la semana', style: 'h2' },
    heatmap(t.heatmap || [], horas, 'venta', (v) => (v >= 1000 ? `${Math.round(v / 1000)}k` : Math.round(v))),

    { text: 'Tickets por hora y día de la semana', style: 'h2', margin: [0, 14, 0, 6] },
    heatmap(t.heatmap || [], horas, 'tickets', (v) => Math.round(v)),
    { text: 'Las dos matrices no coinciden. Donde hay muchos tickets y poco importe está el tráfico; '
          + 'donde hay pocos tickets y mucho importe está la venta grande.', style: 'nota' },

    { text: 'Días destacados', style: 'h2', margin: [0, 14, 0, 6] },
    tabla(
      ['', 'Fecha', 'Venta', 'Tickets'],
      [
        ['Mejor día', fechaCorta(t.mejor_dia?.dia), mxn(t.mejor_dia?.venta), num(t.mejor_dia?.tickets)],
        ['Día más bajo', fechaCorta(t.peor_dia?.dia), mxn(t.peor_dia?.venta), num(t.peor_dia?.tickets)],
      ],
      [90, 80, 90, 70], [2, 3]
    ),

    { text: 'Promedio por día de la semana', style: 'h2', margin: [0, 14, 0, 6] },
    barras((t.por_dow || []).map((x) => ({
      etiqueta: DIAS_CORTO[x.dow], valor: Number(x.venta_promedio) || 0,
    })), ANCHO, 100),

    { text: 'Efecto quincena', style: 'h2', margin: [0, 12, 0, 6] },
    tabla(
      ['Tramo', 'Venta promedio por día'],
      [
        ['Días 1, 2, 15 y 16', mxn(q.promedio_quincena)],
        ['Resto del mes',      mxn(q.promedio_resto)],
        [{ text: 'Diferencia', bold: true },
         { text: efectoQ === null ? '—' : pct(efectoQ), bold: true, alignment: 'right',
           color: efectoQ >= 0 ? COLOR.jade : COLOR.rojo }],
      ],
      ['*', 150], [1]
    ),

    ...((t.horas_muertas || []).length ? [
      { text: 'Horas con poco movimiento', style: 'h2', margin: [0, 12, 0, 6] },
      { text: `Franjas con menos de ${CONFIG.UMBRAL_HORA_MUERTA} tickets por hora en promedio. `
            + 'Es el insumo directo para decidir horarios de personal.', style: 'nota' },
      tabla(['Hora', 'Tickets por día'],
        t.horas_muertas.map((h) => [`${String(h.hora).padStart(2, '0')}:00`, dec(h.tickets_por_dia, 1)]),
        [80, 100], [1]),
    ] : []),

    { text: '', pageBreak: 'after' },
  ];
}

// =====================================================================
// Página 4 — Qué se vende
// =====================================================================
function pagProductos(d) {
  const p = d.productos;
  const abc = p.abc || {};

  const lista = (arr, colVal, encabezado) => tabla(
    ['#', 'Producto', encabezado],
    (arr || []).slice(0, 15).map((x, i) => [String(i + 1), x.descripcion, colVal(x)]),
    [16, '*', 62], [2]
  );

  return [
    { text: 'Qué se vende', style: 'h1' },

    {
      columns: [
        { width: '*', stack: [
          { text: 'Top 15 por importe', style: 'h3' },
          lista(p.top_importe, (x) => mxn(x.importe), 'Importe'),
        ]},
        { width: '*', stack: [
          { text: 'Top 15 por piezas', style: 'h3' },
          lista(p.top_piezas, (x) => num(x.piezas), 'Piezas'),
        ]},
      ],
      columnGap: 14,
    },

    { text: 'Top 15 por utilidad', style: 'h2', margin: [0, 14, 0, 4] },
    { text: 'El que casi nadie mira y el que dice qué te da de comer. Un producto puede ser el primero '
          + 'en ventas y el número treinta en lo que deja.', style: 'nota' },
    tabla(
      ['#', 'Producto', 'Piezas', 'Importe', 'Utilidad', 'Margen'],
      (p.top_utilidad || []).slice(0, 15).map((x, i) => [
        String(i + 1), x.descripcion, num(x.piezas), mxn(x.importe), mxn(x.utilidad),
        { text: pct(x.margen_pct), alignment: 'right',
          color: Number(x.margen_pct) < CONFIG.MARGEN_MINIMO_ALERTA ? COLOR.rojo : COLOR.tinta },
      ]),
      [16, '*', 44, 66, 66, 46], [2, 3, 4, 5]
    ),

    { text: 'Concentración del catálogo (ABC)', style: 'h2', margin: [0, 14, 0, 6] },
    tabla(
      ['Clase', 'Productos', 'Venta', '% de la venta', 'Qué significa'],
      [
        ['A', num(abc.A), mxn(abc.venta_A), pct(0.80), 'Nunca deben faltar'],
        ['B', num(abc.B), mxn(abc.venta_B), pct(0.15), 'Reposición normal'],
        ['C', num(abc.C), mxn(abc.venta_C), pct(0.05), 'Revisar si vale tenerlos'],
      ],
      [36, 56, 76, 70, '*'], [1, 2, 3]
    ),
    { text: `Los 10 productos principales hacen el ${pct(p.concentracion_top10)} de la venta.`,
      style: 'nota', margin: [0, 4, 0, 14] },

    { text: 'Venta y margen por categoría', style: 'h2' },
    tabla(
      ['Categoría', 'Piezas', 'Importe', 'Utilidad', 'Margen'],
      (p.categorias || []).map((c) => [
        c.categoria, num(c.piezas), mxn(c.importe), mxn(c.utilidad),
        { text: pct(c.margen_pct), alignment: 'right',
          color: Number(c.margen_pct) < CONFIG.MARGEN_MINIMO_ALERTA ? COLOR.rojo : COLOR.tinta },
      ]),
      ['*', 56, 76, 76, 52], [1, 2, 3, 4]
    ),
    { text: '', pageBreak: 'after' },
  ];
}

// =====================================================================
// Página 5 — Inventario y dinero parado
// =====================================================================
function pagInventario(d) {
  const i = d.inventario;
  const cad = i.caducidad_resumen || {};

  return [
    { text: 'Inventario y dinero parado', style: 'h1' },

    { text: 'Agotados con demanda', style: 'h2' },
    { text: 'Productos en cero que vendieron en los últimos 30 días. La venta perdida es una estimación: '
          + 'sin historial diario de existencias no se sabe cuántos días exactos estuvieron en cero.',
      style: 'nota' },
    tabla(
      ['Producto', 'Piezas/día', 'Días sin venta', 'Venta perdida'],
      (i.agotados || []).slice(0, 18).map((x) => [
        x.descripcion, dec(x.piezas_dia, 2), num(x.dias_sin_venta),
        { text: mxn(x.venta_perdida), alignment: 'right', color: COLOR.rojo },
      ]),
      ['*', 60, 70, 76], [1, 2, 3]
    ),
    { text: `Venta perdida estimada del mes: ${mxn(i.venta_perdida_total)}`,
      style: 'destacado', margin: [0, 4, 0, 14] },

    { text: 'Caducidades próximas', style: 'h2' },
    tabla(
      ['Corte', 'Valor a costo'],
      [
        ['Vencen en 30 días', { text: mxn(cad.v30), alignment: 'right', color: COLOR.rojo, bold: true }],
        ['Vencen en 60 días', { text: mxn(cad.v60), alignment: 'right' }],
        ['Vencen en 90 días', { text: mxn(cad.v90), alignment: 'right' }],
      ],
      [140, 100], [1]
    ),
    tabla(
      ['Producto', 'Lote', 'Piezas', 'Caduca', 'Días', 'Valor', '¿Alcanza?'],
      (i.caducidades || []).slice(0, 18).map((x) => [
        x.descripcion, x.lote || '—', num(x.cantidad), fechaCorta(x.caducidad),
        num(x.dias_restantes), mxn(x.valor_costo),
        { text: x.alcanza ? 'Sí' : 'NO', alignment: 'center', bold: !x.alcanza,
          color: x.alcanza ? COLOR.jade : COLOR.rojo },
      ]),
      ['*', 50, 40, 52, 32, 60, 48], [2, 4, 5]
    ),
    { text: '"¿Alcanza?" compara las piezas del lote contra tu velocidad de venta real. '
          + 'Lo que dice NO es lo que hay que rematar o devolver ahora, no cuando ya venció.',
      style: 'nota', margin: [0, 4, 0, 14] },

    { text: 'Inventario sin rotación', style: 'h2' },
    { text: `Sin una sola venta en ${CONFIG.DIAS_SIN_ROTACION} días. `
          + `Total parado: ${mxn(i.sin_rotacion_total)} en ${num(i.sin_rotacion_skus)} productos.`,
      style: 'destacado' },
    tabla(
      ['Producto', 'Categoría', 'Stock', 'Valor a costo', 'Última venta'],
      (i.sin_rotacion || []).slice(0, 18).map((x) => [
        x.descripcion, x.categoria, num(x.stock), mxn(x.valor_costo),
        x.ultima_venta ? fechaCorta(x.ultima_venta) : 'Nunca',
      ]),
      ['*', 90, 46, 78, 66], [2, 3]
    ),
    { text: '', pageBreak: 'after' },
  ];
}

// =====================================================================
// Página 6 — Dinero y caja
// =====================================================================
function pagDinero(d) {
  const m = d.dinero;
  const totalMezcla = (m.mezcla_pago || []).reduce((s, x) => s + Number(x.importe), 0) || 1;
  const comision = (metodo, importe) => {
    if (metodo === 'tarjeta')     return Number(importe) * CONFIG.COMISION_TARJETA;
    if (metodo === 'mercadopago') return Number(importe) * CONFIG.COMISION_MERCADOPAGO;
    return 0;
  };
  const caja = m.caja || {};

  return [
    { text: 'Dinero y caja', style: 'h1' },

    { text: 'Mezcla de pago', style: 'h2' },
    tabla(
      ['Método', 'Tickets', 'Importe', '% del total', 'Comisión est.', 'Neto'],
      (m.mezcla_pago || []).map((x) => {
        const c = comision(x.metodo, x.importe);
        return [
          etiquetaMetodo(x.metodo), num(x.tickets), mxn(x.importe),
          pct(Number(x.importe) / totalMezcla),
          c ? mxn(c) : '—',
          mxn(Number(x.importe) - c),
        ];
      }),
      ['*', 50, 76, 62, 70, 76], [1, 2, 3, 4, 5]
    ),
    ...(CONFIG.COMISION_TARJETA === 0 ? [{
      text: 'Las tasas de comisión de terminal y MercadoPago están en cero en la configuración. '
          + 'Hasta cargarlas, la columna de neto es igual al importe.',
      style: 'nota', margin: [0, 4, 0, 12],
    }] : [{ text: '', margin: [0, 0, 0, 12] }]),

    { text: 'Pagos de servicio', style: 'h2' },
    { text: 'Recargas, CFE y similares. Mueven efectivo pero el ingreso real es la comisión. '
          + 'No forman parte de la venta en ningún indicador de este reporte.', style: 'nota' },
    tabla(
      ['Tipo', 'Operaciones', 'Volumen', 'Comisión ganada'],
      (m.pagos_servicio || []).map((x) => [
        x.tipo, num(x.operaciones), mxn(x.monto), mxn(x.comision),
      ]).concat([[
        { text: 'Total', bold: true },
        { text: '', alignment: 'right' },
        { text: mxn(m.pagos_servicio_total), bold: true, alignment: 'right' },
        { text: mxn(m.pagos_servicio_comision), bold: true, alignment: 'right' },
      ]]),
      ['*', 70, 86, 90], [1, 2, 3]
    ),

    { text: 'Descuentos y devoluciones', style: 'h2', margin: [0, 14, 0, 6] },
    tabla(
      ['Concepto', 'Monto'],
      [
        ['Descuentos aplicados', mxn(m.descuentos_total)],
        ['Devoluciones', mxn(d.resumen.devoluciones)],
        ['Eventos de devolución', num(d.resumen.devoluciones_n)],
      ],
      ['*', 100], [1]
    ),
    ...((m.devoluciones_top || []).length ? [
      { text: 'Productos más devueltos', style: 'h3', margin: [0, 8, 0, 4] },
      { text: 'Un producto que se devuelve seguido es una señal, no ruido.', style: 'nota' },
      tabla(['Producto', 'Eventos', 'Piezas', 'Importe'],
        m.devoluciones_top.map((x) => [x.descripcion, num(x.eventos), num(x.piezas), mxn(x.importe)]),
        ['*', 56, 50, 76], [1, 2, 3]),
    ] : []),

    { text: 'Diferencias de caja del mes', style: 'h2', margin: [0, 14, 0, 6] },
    { text: 'Faltantes y sobrantes van separados, nunca netos: $500 de faltante y $500 de sobrante '
          + 'no son cero, son dos problemas.', style: 'nota' },
    tabla(
      ['Concepto', 'Valor'],
      [
        ['Cortes del mes', num(caja.cortes)],
        ['Faltantes acumulados', { text: mxn(caja.faltantes), alignment: 'right', color: COLOR.rojo }],
        ['Sobrantes acumulados', { text: mxn(caja.sobrantes), alignment: 'right' }],
        [`Cortes fuera de tolerancia (±${mxn(CONFIG.TOLERANCIA_CAJA)})`, num(caja.fuera_tolerancia)],
        ['Turnos forzados (sin cierre confiable)', num(caja.forzados)],
      ],
      ['*', 110], [1]
    ),
    { text: '', pageBreak: 'after' },
  ];
}

// =====================================================================
// Página 7 — Personal
// =====================================================================
function pagPersonal(d) {
  const p = d.personal;

  return [
    { text: 'Personal', style: 'h1' },
    { text: 'Ordenado por venta por hora, nunca por venta total. La venta total depende del tráfico '
          + 'de la farmacia y de las horas trabajadas, y ninguna de las dos las controla el vendedor. '
          + 'Las horas van siempre al lado de la cifra de venta.', style: 'nota', margin: [0, 0, 0, 10] },

    tabla(
      ['Vendedor', 'Horas', 'Turnos', 'Venta', 'Venta/hora', 'Tickets', 'Ticket prom.', 'Pzas/tkt', 'Puntualidad'],
      (p.personal || []).map((x) => [
        x.vendedor, dec(x.horas, 1), num(x.turnos), mxn(x.venta),
        { text: mxn(x.venta_por_hora), alignment: 'right', bold: true },
        num(x.tickets), mxn(x.ticket_promedio), dec(x.piezas_x_ticket, 2),
        { text: pct(x.puntualidad), alignment: 'right',
          color: Number(x.puntualidad) < 0.9 ? COLOR.rojo : COLOR.tinta },
      ]),
      ['*', 34, 34, 60, 58, 40, 56, 42, 52], [1, 2, 3, 4, 5, 6, 7, 8]
    ),

    { text: 'Cuidado y precisión en caja', style: 'h2', margin: [0, 16, 0, 4] },
    { text: 'Dato de control, no puntaje competitivo. No se convierte en ranking ni en descuento.',
      style: 'nota' },
    tabla(
      ['Vendedor', 'Turnos', 'Faltantes', 'Sobrantes'],
      (p.personal || []).map((x) => [
        x.vendedor, num(x.turnos),
        { text: mxn(x.faltantes), alignment: 'right', color: Number(x.faltantes) > 0 ? COLOR.rojo : COLOR.tinta },
        { text: mxn(x.sobrantes), alignment: 'right' },
      ]),
      ['*', 56, 80, 80], [1, 2, 3]
    ),

    ...((p.turnos_forzados || []).length ? [
      { text: 'Turnos sin cierre confiable', style: 'h2', margin: [0, 14, 0, 4] },
      { text: 'Excluidos del cálculo de horas. Requieren arqueo manual.', style: 'nota' },
      tabla(['Vendedor', 'Fecha', 'Turno'],
        p.turnos_forzados.map((x) => [x.vendedor, fechaCorta(x.fecha), x.turno]),
        ['*', 80, 90], []),
    ] : []),

    { text: '', pageBreak: 'after' },
  ];
}

// =====================================================================
// Página 8 — Cronología
// =====================================================================
function pagCronologia(d) {
  const dias = d.tiempo.por_dia || [];
  return [
    { text: 'Día por día', style: 'h1' },
    { text: 'Para ubicar un día raro y luego buscarlo en el Excel.', style: 'nota', margin: [0, 0, 0, 10] },
    tabla(
      ['Fecha', 'Venta', 'Tickets', 'Ticket promedio'],
      dias.map((x) => [
        fechaCorta(x.dia), mxn(x.venta), num(x.tickets),
        mxn(Number(x.tickets) ? Number(x.venta) / Number(x.tickets) : 0),
      ]),
      ['*', 100, 70, 110], [1, 2, 3]
    ),
    { text: '', pageBreak: 'after' },
  ];
}

// =====================================================================
// Página 9 — Anexo de definiciones
// =====================================================================
function pagAnexo(d) {
  const filas = [
    ['Venta neta', 'Suma de tickets completados menos devoluciones. Es el número que encabeza el reporte.'],
    ['Venta bruta', 'Suma de tickets completados, sin restar devoluciones.'],
    ['Ticket promedio', 'Venta neta entre número de tickets.'],
    ['Piezas por ticket', 'Piezas vendidas entre número de tickets.'],
    ['Costo de lo vendido', 'Suma de costo unitario por cantidad de cada partida.'],
    ['Utilidad bruta', 'Venta neta menos costo de lo vendido. No descuenta gastos ni nómina.'],
    ['Margen', 'Utilidad bruta entre venta neta.'],
    ['Venta por hora', 'Venta neta entre horas de caja abierta y cerrada correctamente.'],
    ['Velocidad', 'Piezas vendidas en los últimos 30 días entre 30.'],
    ['Días de cobertura', 'Stock actual entre velocidad.'],
    ['Venta perdida', 'Velocidad por días sin venta por precio de venta. Es una estimación.'],
    ['Clase A / B / C', 'A: productos que acumulan el 80% de la venta. B: hasta el 95%. C: el resto.'],
    ['Puntualidad', `Turnos abiertos dentro de los ${CONFIG.TOLERANCIA_PUNTUALIDAD} minutos posteriores `
      + 'al inicio del turno asignado, entre turnos totales.'],
  ];

  const exclusiones = [
    'Pedidos con estado distinto de "completado" no suman a la venta.',
    'Los pagos de servicio (recargas, CFE) no son venta y van en su propio bloque.',
    'Los turnos en estado forzado se excluyen del cálculo de horas y de venta por hora.',
    'Todo se calcula en hora local de la Ciudad de México, no en UTC.',
    `Las comparativas del mes anterior usan ${d.meta.parcial ? 'el mismo tramo de días' : 'el mes completo'}.`,
  ];

  return [
    { text: 'Anexo: cómo se calcula cada número', style: 'h1' },
    { text: 'Está aquí para que ningún número se discuta después.', style: 'nota', margin: [0, 0, 0, 10] },
    tabla(['Indicador', 'Definición'], filas, [120, '*'], []),
    { text: 'Qué queda excluido', style: 'h2', margin: [0, 16, 0, 6] },
    { ul: exclusiones, style: 'nota' },
  ];
}

// =====================================================================
// Componentes de dibujo
// =====================================================================

/** Gráfica de barras vertical, vectorial. */
function barras(datos, ancho, alto) {
  if (!datos.length) return { text: 'Sin datos en el periodo', style: 'nota' };
  const max = Math.max(...datos.map((d) => d.valor), 1);
  const n = datos.length;
  const paso = ancho / n;
  const w = Math.min(paso * 0.6, 46);
  const base = alto - 18;

  const canvas = [{ type: 'line', x1: 0, y1: base, x2: ancho, y2: base, lineWidth: 0.7, lineColor: COLOR.grisClaro }];
  const textos = [];

  datos.forEach((d, i) => {
    const h = Math.max(1, (d.valor / max) * (base - 14));
    const x = i * paso + (paso - w) / 2;
    canvas.push({ type: 'rect', x, y: base - h, w, h, color: COLOR.azul });
    textos.push({ text: etiquetaCorta(d.valor), fontSize: 7, color: COLOR.gris,
      absolutePosition: { x: 40 + x, y: 56 + (base - h) - 10 }, width: w, alignment: 'center' });
  });

  return {
    stack: [
      { canvas, margin: [0, 4, 0, 0] },
      { columns: datos.map((d) => ({ text: d.etiqueta, fontSize: 7, alignment: 'center', color: COLOR.gris })),
        margin: [0, 2, 0, 10] },
    ],
  };
}

/** Línea simple con marcadores. */
function linea2(valores, etiquetas, ancho, alto) {
  if (!valores.length) return { text: 'Sin datos', style: 'nota' };
  const max = Math.max(...valores, 1);
  const base = alto - 14;
  const paso = valores.length > 1 ? ancho / (valores.length - 1) : ancho;
  const pts = valores.map((v, i) => ({ x: i * paso, y: base - (v / max) * (base - 12) }));

  const canvas = [{ type: 'line', x1: 0, y1: base, x2: ancho, y2: base, lineWidth: 0.7, lineColor: COLOR.grisClaro }];
  for (let i = 1; i < pts.length; i++) {
    canvas.push({ type: 'line', x1: pts[i - 1].x, y1: pts[i - 1].y, x2: pts[i].x, y2: pts[i].y,
      lineWidth: 1.6, lineColor: COLOR.azul });
  }
  pts.forEach((p) => canvas.push({ type: 'ellipse', x: p.x, y: p.y, r1: 2.4, r2: 2.4, color: COLOR.azul }));

  return {
    stack: [
      { canvas, margin: [0, 4, 0, 0] },
      { columns: etiquetas.map((e) => ({ text: e, fontSize: 7, alignment: 'center', color: COLOR.gris })),
        margin: [0, 2, 0, 8] },
      { columns: valores.map((v) => ({ text: etiquetaCorta(v), fontSize: 7, alignment: 'center', color: COLOR.tinta })),
        margin: [0, 0, 0, 8] },
    ],
  };
}

/**
 * Mapa de calor como tabla. Lleva la cifra impresa dentro de cada celda
 * para que se lea igual en impresión en blanco y negro.
 */
function heatmap(celdas, horas, campo, fmt) {
  const mapa = {};
  let max = 0;
  celdas.forEach((c) => {
    const v = Number(c[campo]) || 0;
    mapa[`${c.dow}-${c.hora}`] = v;
    if (v > max) max = v;
  });
  max = max || 1;

  const head = [{ text: '', style: 'hmHead' },
    ...[1, 2, 3, 4, 5, 6, 0].map((d) => ({ text: DIAS_CORTO[d], style: 'hmHead' }))];

  const body = [head];
  horas.forEach((h) => {
    const fila = [{ text: `${String(h).padStart(2, '0')}h`, style: 'hmHora' }];
    [1, 2, 3, 4, 5, 6, 0].forEach((d) => {
      const v = mapa[`${d}-${h}`] || 0;
      const t = v / max;
      fila.push({
        text: v ? String(fmt(v)) : '',
        fontSize: 6.5, alignment: 'center', margin: [0, 2, 0, 2],
        color: t > 0.55 ? COLOR.blanco : COLOR.tinta,
        fillColor: mezclar(COLOR.azul, t),
      });
    });
    body.push(fila);
  });

  return {
    table: { widths: [24, ...Array(7).fill('*')], body },
    layout: {
      hLineWidth: () => 0.4, vLineWidth: () => 0.4,
      hLineColor: () => COLOR.blanco, vLineColor: () => COLOR.blanco,
      paddingLeft: () => 2, paddingRight: () => 2,
      paddingTop: () => 1, paddingBottom: () => 1,
    },
    margin: [0, 2, 0, 6],
  };
}

/** Tabla estándar. alineadasDerecha = índices de columna numéricas. */
function tabla(encabezados, filas, anchos, alineadasDerecha = []) {
  const head = encabezados.map((h, i) => ({
    text: h, style: 'thead',
    alignment: alineadasDerecha.includes(i) ? 'right' : 'left',
  }));

  const body = [head];
  if (!filas.length) {
    body.push([{ text: 'Sin datos en el periodo', colSpan: encabezados.length,
      style: 'nota', margin: [4, 6, 4, 6] }, ...Array(encabezados.length - 1).fill({})]);
  } else {
    filas.forEach((f) => body.push(f.map((celda, i) => {
      if (celda && typeof celda === 'object') return { fontSize: 8, ...celda };
      return { text: celda ?? '', fontSize: 8,
        alignment: alineadasDerecha.includes(i) ? 'right' : 'left' };
    })));
  }

  return {
    table: { headerRows: 1, widths: anchos, body, dontBreakRows: true },
    layout: {
      hLineWidth: (i) => (i === 1 ? 0.8 : 0.3),
      vLineWidth: () => 0,
      hLineColor: (i) => (i === 1 ? COLOR.tinta : COLOR.grisClaro),
      paddingLeft: () => 4, paddingRight: () => 4,
      paddingTop: () => 3, paddingBottom: () => 3,
      fillColor: (i) => (i === 0 ? null : (i % 2 === 0 ? '#F6F8FA' : null)),
    },
    margin: [0, 4, 0, 8],
  };
}

// --- utilidades de dibujo --------------------------------------------
const linea = () => ({ canvas: [{ type: 'line', x1: 0, y1: 0, x2: ANCHO, y2: 0, lineWidth: 0.8, lineColor: COLOR.grisClaro }] });

const bordeSuave = () => ({
  hLineWidth: () => 0.6, vLineWidth: () => 0.6,
  hLineColor: () => COLOR.grisClaro, vLineColor: () => COLOR.grisClaro,
});

function coloreado(valor, texto, sube) {
  const v = valor !== null && valor !== undefined ? Number(valor) : null;
  const arriba = sube !== undefined ? sube : v >= 0;
  const t = texto ?? `${arriba ? '▲' : '▼'} ${Math.abs((v || 0) * 100).toFixed(1)}%`;
  return { text: t, alignment: 'right', color: arriba ? COLOR.jade : COLOR.rojo };
}

function etiquetaCorta(v) {
  const n = Number(v) || 0;
  if (n >= 1000) return `${Math.round(n / 1000)}k`;
  return String(Math.round(n));
}

/** Mezcla el azul con blanco según intensidad 0..1. */
function mezclar(hex, t) {
  const c = hex.replace('#', '');
  const r = parseInt(c.slice(0, 2), 16), g = parseInt(c.slice(2, 4), 16), b = parseInt(c.slice(4, 6), 16);
  const m = (x) => Math.round(255 - (255 - x) * Math.min(Math.max(t, 0), 1));
  return `#${[m(r), m(g), m(b)].map((x) => x.toString(16).padStart(2, '0')).join('')}`;
}

function etiquetaMetodo(m) {
  return { efectivo: 'Efectivo', tarjeta: 'Tarjeta', spei: 'SPEI', mercadopago: 'MercadoPago' }[m] || m;
}

// =====================================================================
const ESTILOS = {
  marca:     { fontSize: 11, bold: true, color: COLOR.azul, margin: [0, 0, 0, 2] },
  titulo:    { fontSize: 24, bold: true, color: COLOR.tinta, margin: [0, 0, 0, 4] },
  sub:       { fontSize: 9, color: COLOR.gris },
  h1:        { fontSize: 17, bold: true, color: COLOR.tinta, margin: [0, 0, 0, 10] },
  h2:        { fontSize: 12, bold: true, color: COLOR.tinta, margin: [0, 10, 0, 6] },
  h3:        { fontSize: 10, bold: true, color: COLOR.tinta, margin: [0, 6, 0, 4] },
  thead:     { fontSize: 8, bold: true, color: COLOR.tinta },
  nota:      { fontSize: 8, color: COLOR.gris, italics: true },
  aviso:     { fontSize: 8, color: COLOR.gris },
  destacado: { fontSize: 10, bold: true, color: COLOR.tinta },
  conclusion:{ fontSize: 10, color: COLOR.tinta, lineHeight: 1.3 },
  kpiEtiqueta:{ fontSize: 8, color: COLOR.gris, margin: [0, 0, 0, 2] },
  kpiValor:  { fontSize: 15, bold: true, color: COLOR.tinta, margin: [0, 0, 0, 2] },
  headerTxt: { fontSize: 7.5, color: COLOR.gris },
  footerTxt: { fontSize: 7, color: COLOR.gris, alignment: 'center' },
  hmHead:    { fontSize: 7, bold: true, alignment: 'center', color: COLOR.tinta },
  hmHora:    { fontSize: 7, color: COLOR.gris, alignment: 'right' },
};
