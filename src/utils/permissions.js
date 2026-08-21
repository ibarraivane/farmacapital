// Permisos por rol — fuente de verdad de qué módulos puede ver cada perfil.
// Se aplica en dos capas:
//   1. En el modal "Módulos" de Usuarios: filtra los candidatos que un admin
//      puede marcar para un usuario no-admin. Evita que el admin habilite
//      accidentalmente módulos sensibles.
//   2. En Admin.renderPage(): bloquea el acceso con una pantalla 🔒 si un
//      usuario navega (o deep-linka) a un módulo fuera de su rol.
//
// Regla general:
//   - Admin → todos los módulos (siempre).
//   - Vendedor → piso operativo, sin finanzas ni costos. Nunca los BLOQUEADOS
//     aunque un admin los agregue a modulos_custom. Devoluciones sí: el piso
//     identifica la venta con folio o teléfono.
//   - Doctora → agenda clínica y expediente (sin POS/caja/finanzas).

export const MODULOS_BLOQUEADOS_VENDEDOR = [
  "dash",         // Dashboard con datos sensibles del negocio
  "rrhh",         // RR.HH. / nómina
  "config_cons",  // Metas y Precios
  "promo",        // Promociones
  "fact",         // Facturación CFDI
  "banners",      // Banners de la tienda online
  "usuarios",     // Gestión de usuarios
  "bot",          // Asistente IA (costos por uso)
  "cli",          // Clientes & Puntos (alta en el POS al vender)
  "cof",          // Módulo COFEPRIS (licencias / bitácora completa; receta va en POS)
  "trans",        // Transacciones / consolidado
  "cons",         // Consultorio (configuración clínica)
  "exp_dr",       // Expedientes
];

// Default del rol (barra lateral). Pedidos online vive como pestaña del POS.
export const NAV_VENDEDOR_DEFAULT = [
  "midia",
  "pos",
  "dev",
  "agenda",
  "inv",
  "caja",
  "ayuda",
  "pwa",
];

// Lo que un admin PUEDE habilitar de más (atajo; no finanzas).
export const MODULOS_DISPONIBLES_VENDEDOR = [
  ...NAV_VENDEDOR_DEFAULT,
  "ped_online",
];

export const MODULOS_DISPONIBLES_DOCTORA = [
  "cons_dr",
  "exp_dr",
  "ayuda",
];

export function rolEsAdmin(rol) {
  return rol === "admin" || rol === "gerente";
}

export function modulosPermitidosParaRol(rol) {
  if (rolEsAdmin(rol)) return "all";
  if (rol === "vendedor") return MODULOS_DISPONIBLES_VENDEDOR;
  if (rol === "doctora")  return MODULOS_DISPONIBLES_DOCTORA;
  return [];
}

export function defaultIdsPorRolPermisos(rol) {
  if (rolEsAdmin(rol)) return null;
  if (rol === "vendedor") return NAV_VENDEDOR_DEFAULT;
  if (rol === "doctora")  return MODULOS_DISPONIBLES_DOCTORA;
  return [];
}

// 1. Admin siempre puede.
// 2. Si el rol lo bloquea categóricamente → no.
// 3. Si tiene modulos_custom.activos, se respeta (∩ whitelist).
// 4. Si no, default del rol.
export function puedeVerModulo(usuario, moduloId) {
  if (!usuario || !moduloId) return false;
  if (moduloId === "ayuda") return true;
  if (rolEsAdmin(usuario.rol)) return true;

  if (usuario.rol === "vendedor" && MODULOS_BLOQUEADOS_VENDEDOR.includes(moduloId)) {
    return false;
  }

  const permitidos = modulosPermitidosParaRol(usuario.rol);
  if (permitidos === "all") return true;
  if (!Array.isArray(permitidos) || !permitidos.includes(moduloId)) return false;

  const custom = Array.isArray(usuario.modulos_custom?.activos)
    ? usuario.modulos_custom.activos
    : null;
  if (custom && custom.length > 0) {
    return custom.includes(moduloId);
  }

  const defaults = defaultIdsPorRolPermisos(usuario.rol);
  if (!Array.isArray(defaults)) return true;
  return defaults.includes(moduloId);
}

export function filtrarModulosPorRol(ids, rol) {
  if (rolEsAdmin(rol)) return ids;
  const permitidos = modulosPermitidosParaRol(rol);
  if (permitidos === "all") return ids;
  if (!Array.isArray(permitidos)) return [];
  return ids.filter((id) => permitidos.includes(id));
}
