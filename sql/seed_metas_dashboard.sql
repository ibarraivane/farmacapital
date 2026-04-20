-- Metas de desempeño por defecto para el Dashboard.
-- Los valores se pueden editar desde el módulo de Configuración (tabla `configuracion`).
-- Se insertan solo si la llave no existe; no sobreescriben ajustes previos.

INSERT INTO configuracion (clave, valor) VALUES
  ('meta_ventas_dia',     '3000'),
  ('meta_ventas_semana',  '20000'),
  ('meta_ventas_mes',     '80000'),
  ('meta_ticket_prom',    '250'),
  ('meta_consultas_dia',  '8'),
  ('meta_consultas_mes',  '180')
ON CONFLICT (clave) DO NOTHING;
