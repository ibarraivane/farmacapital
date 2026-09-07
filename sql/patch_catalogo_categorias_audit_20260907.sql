-- Catálogo · categorías mal asignadas (auditoría 2026-09-07)
-- ─────────────────────────────────────────────────────────────
-- Casos claros del mismo tipo que Nasalub en Hidratación:
-- nutrición en Analgésico/Gastro, Pedialyte en Higiene,
-- antiácidos/bismuto en Herbolario/Suplemento, Broncolin
-- en Abarrotes/Producto/Herbolario, CS 500 mL en Dispositivo.
--
-- No toca stock, costo, PVP, caducidad ni fotos.
-- Idempotente. Pegar TODO en Supabase → SQL Editor → Run.

begin;

-- ── Nutrición infantil / Ensure / Glucerna → Suplemento ──────
-- Pediasure vainilla estaba en Analgésico; chocolate/fresa ya
-- están en Suplemento. Ensure Fresa y Glucerna chocolate/vainilla
-- estaban en Gastro; el resto de la familia en Suplemento.
update public.productos
set categoria = 'Suplemento'
where sku in (
  'FC-33950209',  -- Pediasure vainilla
  'FC-33954078',  -- Ensure Fresa
  'FC-33956133',  -- Glucerna chocolate
  'FC-33956126'   -- Glucerna Vainilla
)
  and categoria is distinct from 'Suplemento';

-- ── Pedialyte SR Coco → Bebidas (misma familia Pedialyte SR) ─
update public.productos
set categoria = 'Bebidas'
where sku = 'FC-3961366'
  and categoria is distinct from 'Bebidas';

-- ── Estomaquil / bismuto → Gastro ────────────────────────────
update public.productos
set categoria = 'Gastro'
where sku in (
  'FC-69200016',  -- Estomaquil Polvo C/20 (estaba en Suplemento)
  'FC-53601339',  -- Daclafin subsalicilato bismuto
  'FC-18752637',  -- Itamol (Subsalicilato de bismuto)
  'FC-D037156B'   -- Mercurio Bismuto Subnitrato
)
  and categoria is distinct from 'Gastro';

-- ── Familia Broncolin → Respiratorio ─────────────────────────
update public.productos
set categoria = 'Respiratorio'
where sku in (
  'FC-06903205',  -- Broncolin Paleta (Abarrotes)
  'FC-06910487',  -- Broncolin Bicoestol pastillas eucalipto
  'FC-06910609',  -- Broncolin Etiqueta Verde jarabe
  'FC-06910913',  -- Broncolin Bicoestol pastillas cereza
  'FC-06910906',  -- Broncolin Bicoestol pastillas naranja
  'FC-70100307'   -- Broncolin Etiqueta Azul jarabe
)
  and categoria is distinct from 'Respiratorio';

-- ── Solución CS PiSA 500 mL → Hidratación ────────────────────
-- Estaba en Dispositivo médico; el 250 mL ya está en Hidratación.
update public.productos
set categoria = 'Hidratación'
where sku = 'FC-25100123'
  and categoria is distinct from 'Hidratación';

commit;

select
  sku,
  left(nombre, 52) as nombre,
  categoria,
  stock
from public.productos
where sku in (
  'FC-33950209', 'FC-33954078', 'FC-33956133', 'FC-33956126',
  'FC-3961366',
  'FC-69200016', 'FC-53601339', 'FC-18752637', 'FC-D037156B',
  'FC-06903205', 'FC-06910487', 'FC-06910609', 'FC-06910913',
  'FC-06910906', 'FC-70100307',
  'FC-25100123'
)
order by categoria, nombre;
