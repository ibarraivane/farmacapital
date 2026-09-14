-- PVP baratos del ticket Bodega F-42 folio 77827.
-- Unitario = importe del renglón ÷ piezas (Escudo $4.48, no $8.97).
-- Techo higiene 2.2× (Sedal $9.08 → $20).
-- Idempotente: solo pisa si el PVP sigue por arriba del sugerido.
-- Medicamentos: no van aquí.

begin;

-- Escudo Rosa Cuidado 110 g · $4.48 → $42 ⇒ $10
update public.productos
   set precio = 10
 where sku = 'FC-43489004'
   and activo = true
   and costo > 0
   and precio > 10;

-- Nivea Milk 400 ml + 100 ml · catálogo $22.30 → $207 ⇒ $50
update public.productos
   set precio = 50
 where sku = 'FC-54558682'
   and activo = true
   and costo > 0
   and precio > 50;

-- Jabón Grisi Neutro 150 g · $6.96 → $56 ⇒ $16
update public.productos
   set precio = 16
 where sku = 'FC-22105207'
   and activo = true
   and costo > 0
   and precio > 16;

-- Escudo Antibacterial Frescura 110 g · $7.23 → $42 ⇒ $16
update public.productos
   set precio = 16
 where sku = 'FC-25605514'
   and activo = true
   and costo > 0
   and precio > 16;

-- Escudo Antibacterial Original (Azul Rey) 135 g · $13.65 → $42 ⇒ $31
update public.productos
   set precio = 31
 where sku = 'FC-25652716'
   and activo = true
   and costo > 0
   and precio > 31;

-- Jabón Grisi Avena 125 g · $21.72 → $56 ⇒ $31
update public.productos
   set precio = 31
 where sku = 'FC-22150801'
   and activo = true
   and costo > 0
   and precio > 31;

-- Jabón Dove Original 135 g · $15.10 → $47 ⇒ $34
update public.productos
   set precio = 34
 where sku = 'FC-38891190'
   and activo = true
   and costo > 0
   and precio > 34;

-- Toallas Kotex nocturna C/5 · $5.01 → $16 ⇒ $12
update public.productos
   set precio = 12
 where sku = 'FC-43427754'
   and activo = true
   and costo > 0
   and precio > 12;

-- Claris desmaquillantes aloe C/40 · $9.43 → $27 ⇒ $21
update public.productos
   set precio = 21
 where sku = 'FC-21012303'
   and activo = true
   and costo > 0
   and precio > 21;

-- Saba Invisible C/10 · $10.17 → $29 ⇒ $16
update public.productos
   set precio = 16
 where sku = 'FC-19006371'
   and activo = true
   and costo > 0
   and precio > 16;

-- Palmolive Neutro-Bal 120 g · $13.07 → $37 ⇒ $29
update public.productos
   set precio = 29
 where sku = 'FC-46683133'
   and activo = true
   and costo > 0
   and precio > 29;

commit;
