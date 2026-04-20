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
//   - Vendedor → MODULOS_DISPONIBLES_VENDEDOR (nunca los BLOQUEADOS aunque
//     un admin los agregue a modulos_custom).
//   - Doctora → MODULOS_DOCTORA_LISTA.

// Módulos PROHIBIDOS para vendedores (incluso si el admin los agrega a su modulos_custom).
export const MODULOS_BLOQUEADOS_VENDEDOR = [
  "dash",         // Dashboard con datos sensibles del negocio
  "rrhh",         // RR.HH.
  "config_cons",  // Metas y Precios (configuración del negocio)
  "promo",        // Promociones (estrategia comercial)
  "dev",          // Devoluciones (requiere admin)
  "fact",         // Facturación CFDI
  "banners",      // Banners de la tienda online
  "usuarios",     // Gestión de usuarios
  "bot",          // Asistente IA (costos por uso)
];

// Módulos disponibles para vendedor (por default o por custom).
// El vendedor siempre arranca con NAV_VENDEDOR (midia, pos, cons_cobro).
// Estos son los ADICIONALES que un admin le puede habilitar.
export const MODULOS_DISPONIBLES_VENDEDOR = [
  "midia",      // Su pantalla de inicio (default del rol)
  "pos",        // POS principal (default del rol)
  "cons_cobro", // Cobrar consultas (default del rol)
  "inv",        // Inventario (consulta, catálogo, lotes)
  "cli",        // Clientes (ver / registrar)
  "cof",        // COFEPRIS (bitácora al vender controlados)
  "caja",       // Corte de caja (admin puede habilitarlo a un líder de turno)
  "pwa",        // Instalar app
];

// Módulos para doctora.
export const MODULOS_DISPONIBLES_DOCTORA = [
  "cons_dr",    // Consultas (agenda + ficha)
  "rep_dr",     // Reportes
  "cons",       // Consultorio (vista completa si admin lo habilita)
  "cli",        // Clientes
  "pwa",        // Instalar app
];

// Retorna la lista de ids permitidos para un rol. 'admin' devuelve "all".
export function modulosPermitidosParaRol(rol) {
  if (rol === "admin")    return "all";
  if (rol === "vendedor") return MODULOS_DISPONIBLES_VENDEDOR;
  if (rol === "doctora")  return MODULOS_DISPONIBLES_DOCTORA;
  return [];
}

// ¿Puede este usuario ver este módulo?
// 1. Admin siempre puede.
// 2. Si el rol lo bloquea categóricamente → no.
// 3. Si tiene modulos_custom, se respeta (siempre que esté en la lista permitida).
// 4. Si no, se valida contra la lista default del rol.
export function puedeVerModulo(usuario, moduloId) {
  if (!usuario || !moduloId) return false;
  if (usuario.rol === "admin") return true;

  // Regla dura: un vendedor no puede ver bloqueados bajo ninguna circunstancia.
  if (usuario.rol === "vendedor" && MODULOS_BLOQUEADOS_VENDEDOR.includes(moduloId)) {
    return false;
  }

  const permitidos = modulosPermitidosParaRol(usuario.rol);
  if (permitidos === "all") return true;
  if (!Array.isArray(permitidos)) return false;
  return permitidos.includes(moduloId);
}

// Filtra una lista de ids contra lo que el rol permite.
export function filtrarModulosPorRol(ids, rol) {
  if (rol === "admin") return ids;
  const permitidos = modulosPermitidosParaRol(rol);
  if (permitidos === "all") return ids;
  if (!Array.isArray(permitidos)) return [];
  return ids.filter((id) => permitidos.includes(id));
}
