-- Permisos por usuario: permite al admin asignar módulos específicos
-- por encima del default del rol. Si es NULL, el usuario usa NAV_ADMIN/
-- NAV_VENDEDOR/NAV_DOCTORA según su rol.
--
-- Shape esperado:
--   { "activos": ["midia", "pos", "cons_cobro", "inv"] }
--
-- El frontend también valida contra utils/permissions.js para que un admin
-- no pueda habilitar módulos prohibidos para el rol (seguridad en capa).

ALTER TABLE usuarios
  ADD COLUMN IF NOT EXISTS modulos_custom JSONB DEFAULT NULL;

COMMENT ON COLUMN usuarios.modulos_custom IS
  'Permisos custom de navegación por usuario. NULL = default del rol. JSON { activos: string[] }.';
