/**
 * Datos fiscales y de contacto — FarmaCapital
 * Fuente: Constancia de Situación Fiscal SAT (enero 2025)
 *
 * domicilio_fiscal = domicilio registrado ante el SAT (facturación / CFDI)
 * direccion_comercial = ubicación física donde opera la farmacia (pick-up, mapas)
 */

export const FARMACIA_FISCAL = {
  razon_social: "LUIS ANGEL PALILLERO VENTURA",
  rfc: "PAVL911030NC8",
  curp: "PAVL911030HDFLNS03",
  /** Clave c_RegimenFiscal SAT */
  regimen_fiscal: "605",
  regimen_fiscal_texto:
    "Régimen de Sueldos y Salarios e Ingresos Asimilados a Salarios",
  codigo_postal: "09208",
  domicilio_fiscal:
    "Calle Frente 7 K Int 102, Col. Chinampac de Juárez, Iztapalapa, Ciudad de México, C.P. 09208",
  /** Nombre comercial (CSF sin nombre comercial registrado) */
  nombre_comercial: "FarmaCapital",
  /** Punto de venta / pick-up — distinto al domicilio fiscal */
  direccion_comercial:
    "Radiodifusora 100, Col. Chinampac de Juárez, Iztapalapa, CDMX, C.P. 09208",
  telefono: "5562530631",
  telefono_display: "55 6253 0631",
  email: "contacto@farmacapital.mx",
  sitio_web: "farmacapital.mx",
  inicio_operaciones: "2016-05-18",
  /** Listado oficial Google Maps — FarmaCapital */
  maps_url: "https://maps.app.goo.gl/qmSixa2qVSM5DD3QA",
  /**
   * Embed del mapa (OpenStreetMap): no requiere API key y pasa CSP.
   * El botón “Abrir en Google Maps” sigue usando maps_url.
   */
  maps_embed:
    "https://www.openstreetmap.org/export/embed.html?bbox=-99.0576916%2C19.3664047%2C-99.0476916%2C19.3764047&layer=mapnik&marker=19.3714047%2C-99.0526916",
  maps_lat: 19.3714047,
  maps_lng: -99.0526916,
};

/** Claves en tabla `configuracion` (Supabase) */
export const FARMACIA_CONFIG_KEYS = [
  "nombre_farmacia",
  "nombre_comercial",
  "razon_social",
  "rfc",
  "curp",
  "regimen_fiscal",
  "regimen_fiscal_texto",
  "codigo_postal",
  "domicilio_fiscal",
  "direccion_farmacia",
  "telefono_farmacia",
  "nombre_doctor",
];

export function configRowsToMap(rows) {
  const map = {};
  (rows || []).forEach((r) => {
    if (r?.clave) map[r.clave] = r.valor;
  });
  return map;
}

/** Fusiona filas de `configuracion` con defaults fiscales oficiales */
export function mergeFarmaciaConfig(map = {}, extra = {}) {
  const f = FARMACIA_FISCAL;
  return {
    ...extra,
    nombre_farmacia: map.nombre_farmacia || f.nombre_comercial,
    nombre_comercial: map.nombre_comercial || f.nombre_comercial,
    razon_social: map.razon_social || f.razon_social,
    rfc: map.rfc || f.rfc,
    curp: map.curp || f.curp,
    regimen_fiscal: map.regimen_fiscal || f.regimen_fiscal,
    regimen_fiscal_texto: map.regimen_fiscal_texto || f.regimen_fiscal_texto,
    codigo_postal: map.codigo_postal || f.codigo_postal,
    domicilio_fiscal: map.domicilio_fiscal || f.domicilio_fiscal,
    direccion_farmacia: map.direccion_farmacia || f.direccion_comercial,
    telefono_farmacia: map.telefono_farmacia || f.telefono,
    telefono_farmacia_display:
      map.telefono_farmacia_display || f.telefono_display,
  };
}
