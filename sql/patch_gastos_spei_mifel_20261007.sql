-- SPEI Mifel 7-oct-2026 · tickets de salida para Flujo de caja
-- Capturas: Digital Evoluciona ****8716 → Juan Maistro ($200) y Nana ($1,000)
-- Idempotente por clave de rastreo en notas. No inventa categoría de nómina RH.
-- Ver LEERME_gastos_spei_mifel_20261007.md

begin;

-- ---------------------------------------------------------------------------
-- 1) $200 · Juan Maistro (Misael Isac Ramirez Valdes) · Banorte
--    Folio 53973518 · 07/10/2026 03:03 · MIFB000233404
--    Alias «Maistro» → mantenimiento (si era otra cosa, editar categoría en Flujo)
-- ---------------------------------------------------------------------------
insert into public.gastos (
  fecha, categoria, concepto, monto,
  origen, es_recurrente, proveedor, metodo_pago,
  deducible, notas, afecta_pl
)
select
  date '2026-10-07',
  'mantenimiento',
  'SPEI Juan Maistro · Misael Isac Ramirez Valdes',
  200.00,
  'manual',
  false,
  'Juan Maistro',
  'spei',
  true,
  'Folio 53973518 · ref 071026 · clave 20261007400420000MIFB000233404 · Banorte ****8547 · origen Mifel Digital Evoluciona ****8716 · 03:03 h',
  true
where not exists (
  select 1 from public.gastos g
   where g.eliminado_at is null
     and g.notas like '%20261007400420000MIFB000233404%'
);

-- ---------------------------------------------------------------------------
-- 2) $1,000 · Nana (Angel Gerardo Rodriguez Valero) · Scotiabank
--    Folio 53975588 · 07/10/2026 03:52 · MIFB000236078
--    Categoría otros (si es nómina/anticipo, reclasificar en Flujo → Gastos)
-- ---------------------------------------------------------------------------
insert into public.gastos (
  fecha, categoria, concepto, monto,
  origen, es_recurrente, proveedor, metodo_pago,
  deducible, notas, afecta_pl
)
select
  date '2026-10-07',
  'otros',
  'SPEI Nana · Angel Gerardo Rodriguez Valero',
  1000.00,
  'manual',
  false,
  'Nana',
  'spei',
  true,
  'Folio 53975588 · ref 071026 · clave 20261007400420000MIFB000236078 · Scotiabank ****2156 · origen Mifel Digital Evoluciona ****8716 · 03:52 h',
  true
where not exists (
  select 1 from public.gastos g
   where g.eliminado_at is null
     and g.notas like '%20261007400420000MIFB000236078%'
);

commit;

select g.id, g.fecha, g.categoria, g.concepto, g.monto, g.metodo_pago, g.proveedor,
       left(g.notas, 80) as notas
  from public.gastos g
 where g.eliminado_at is null
   and (
     g.notas like '%20261007400420000MIFB000233404%'
     or g.notas like '%20261007400420000MIFB000236078%'
   )
 order by g.monto;
