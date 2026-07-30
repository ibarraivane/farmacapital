/**
 * Definición de tours de onboarding FarmaCapital.
 *
 * Cada paso usa como `target` un selector CSS que normalmente es
 * `[data-tour="..."]`. Si el target no existe en el DOM cuando
 * arranca el tour, ese paso se filtra (ver OnboardingTour.jsx)
 * para que nunca reviente en producción.
 */

export const TOURS = {
  // ────── POS (Punto de venta) ──────
  pos: {
    label: "Tour del Punto de Venta",
    storageKey: "farmacapital_tour_pos_",
    steps: [
      {
        target: '[data-tour="pos-buscador"]',
        title: "1. Busca productos",
        content:
          "Escanea el código de barras de la caja con la pistola USB, o escribe SKU/nombre. Enter agrega al carrito al instante.",
        placement: "bottom",
        disableBeacon: true,
      },
      {
        target: '[data-tour="pos-favoritos"]',
        title: "2. Favoritos rápidos",
        content:
          "Los productos marcados como favoritos (⭐) aparecen aquí para un acceso en un click, ideal para medicamentos que vendes cada día.",
        placement: "bottom",
      },
      {
        target: '[data-tour="pos-carrito"]',
        title: "3. Carrito de venta",
        content:
          "Aquí ves las líneas que vas agregando. Puedes ajustar cantidad, quitar una línea o aplicar descuentos por ítem.",
        placement: "left",
      },
      {
        target: '[data-tour="pos-cliente"]',
        title: "4. Cliente y receta",
        content:
          "Captura teléfono del cliente para asociarle la venta (y sus recetas). Si la venta es con receta, podrás indicar si proviene de médico FarmaCapital o externo al cerrar.",
        placement: "top",
      },
      {
        target: '[data-tour="pos-cobrar"]',
        title: "5. Cobrar y generar ticket",
        content:
          "Elige método de pago (efectivo, tarjeta o MercadoPago) y pulsa Cobrar. El sistema genera ticket, descuenta inventario y registra en caja automáticamente.",
        placement: "top",
      },
    ],
  },

  // ────── Inventario ──────
  inv: {
    label: "Tour del Inventario",
    storageKey: "farmacapital_tour_inv_",
    steps: [
      {
        target: '[data-tour="inv-agregar"]',
        title: "Agrega tu primer producto",
        content:
          "Haz click aquí para registrar un producto nuevo: SKU, nombre, precio y stock inicial. Los lotes se administran en la sección «Lotes».",
        placement: "bottom",
        disableBeacon: true,
      },
      {
        target: '[data-tour="inv-buscar"]',
        title: "Busca rápido",
        content:
          "Filtra por nombre, SKU o código de barras. Si escaneas con pistola, la captura llega directo a este campo.",
        placement: "bottom",
      },
      {
        target: '[data-tour="inv-tabla"]',
        title: "Stock y alertas",
        content:
          "Los productos en rojo tienen stock bajo o por caducar. Puedes abrir cada fila para editar precio, existencias y lotes.",
        placement: "top",
      },
    ],
  },

  // ────── Corte de caja ──────
  caja: {
    label: "Tour de Corte de Caja",
    storageKey: "farmacapital_tour_caja_",
    steps: [
      {
        target: '[data-tour="caja-turno"]',
        title: "1. Elige el turno",
        content:
          "Selecciona si es corte matutino (8:00–16:00) o vespertino (16:00–22:00). FarmaCapital toma solo las ventas de ese rango para calcular el efectivo esperado.",
        placement: "bottom",
        disableBeacon: true,
      },
      {
        target: '[data-tour="caja-declarado"]',
        title: "2. Captura lo contado",
        content:
          "Escribe el efectivo físico que cuenta el cajero, y los totales de tarjeta y MercadoPago. Si hubo alguna incidencia, anótala en Notas.",
        placement: "right",
      },
      {
        target: '[data-tour="caja-diferencia"]',
        title: "3. Revisa la diferencia",
        content:
          "FarmaCapital compara lo declarado contra lo que registró el sistema. Verde = ok; rojo = faltante; amarillo = sobrante. Así detectas errores al momento.",
        placement: "left",
      },
      {
        target: '[data-tour="caja-guardar"]',
        title: "4. Guardar corte",
        content:
          "Al guardar, el corte queda en el historial con hora, empleado y desglose. Ya puedes cerrar turno con tranquilidad.",
        placement: "top",
      },
    ],
  },

  // ────── Consultorio ──────
  cons: {
    label: "Tour de Consultorio",
    storageKey: "farmacapital_tour_cons_",
    steps: [
      {
        target: '[data-tour="cons-kpis"]',
        title: "1. Estado del día",
        content:
          "De un vistazo ves cuántos pacientes están esperando, en consulta, completadas y pagadas. Si ves muchos «⏳ Esperando», el consultorio está saturado.",
        placement: "bottom",
        disableBeacon: true,
      },
      {
        target: '[data-tour="cons-lista"]',
        title: "2. Agenda del día",
        content:
          "Aquí la lista de citas. «📞 Llamar» inicia la consulta (y bloquea iniciar otra hasta que termines). «Terminar consulta» la marca completada y guarda la duración.",
        placement: "top",
      },
      {
        target: '[data-tour="cons-lista"]',
        title: "3. Cobro y recetas",
        content:
          "El cobro de la consulta se hace en el POS → pestaña «Consultas». Si la doctora registró medicamentos en la receta y el paciente los compra en FarmaCapital, el sistema los marca como surtidos automáticamente.",
        placement: "top",
      },
    ],
  },
};

export function tourStorageKey(tourId, usuarioId) {
  const t = TOURS[tourId];
  if (!t) return null;
  return `${t.storageKey}${usuarioId || "anon"}`;
}
