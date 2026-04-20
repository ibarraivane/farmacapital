-- Expansión de configuración: Metas, precios y bonos.
-- Las claves se insertan sin sobreescribir si ya existen (idempotente).

INSERT INTO configuracion (clave, valor) VALUES
  -- ── TAB 1 · Precios de servicios ────────────────────────────
  -- (precio_consulta ya existe en seed_metas_dashboard.sql / seed anterior)
  ('precio_toma_presion',       '60'),
  ('precio_glucometria',        '80'),
  ('precio_inyeccion_im',       '120'),
  ('precio_inyeccion_iv',       '180'),
  ('precio_nebulizacion',       '250'),
  ('precio_curacion_simple',    '200'),
  ('precio_curacion_compleja',  '380'),
  ('precio_sutura_1_3',         '500'),
  ('precio_sutura_4_mas',       '750'),
  ('precio_retiro_puntos',      '150'),
  ('precio_vendaje',            '200'),
  ('precio_lavado_oido',        '180'),
  ('precio_prueba_embarazo',    '100'),
  ('descuento_max_vendedor',    '5'),
  ('descuento_max_admin',       '25'),

  -- ── TAB 2 · Metas de ventas por turno ───────────────────────
  ('meta_matutino_lv',          '1500'),
  ('meta_vespertino_lv',        '1500'),
  ('meta_sabado_matutino',      '1800'),
  ('meta_sabado_vespertino',    '1800'),
  ('meta_domingo',              '2200'),

  -- ── TAB 2 · Ajustes automáticos por fecha (%) ───────────────
  ('ajuste_quincena',           '25'),
  ('ajuste_dia_pago',           '30'),
  ('ajuste_viernes',            '15'),
  ('ajuste_lunes',              '-10'),
  ('ajuste_domingo',            '-10'),

  -- ── TAB 3 · Bonos mensuales por cumplimiento ────────────────
  ('bono_70_89',                '500'),
  ('bono_90_99',                '700'),
  ('bono_100_109',              '1200'),
  ('bono_110_plus',             '1800'),
  ('extra_antiguedad_por_anio', '100'),
  ('extra_sin_faltas',          '300'),
  ('extra_fidelizacion',        '200'),
  ('extra_fidelizacion_min',    '15'),

  -- ── TAB 4 · Metas del consultorio (nuevas) ──────────────────
  -- (meta_consultas_dia y meta_consultas_mes ya existen)
  ('meta_procedimientos_dia',   '4'),
  ('meta_procedimientos_mes',   '80'),
  ('meta_recetas_mes',          '120'),
  ('bono_doctora_80_99',        '500'),
  ('bono_doctora_100_plus',     '1500')
ON CONFLICT (clave) DO NOTHING;
