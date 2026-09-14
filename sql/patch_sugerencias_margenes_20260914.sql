-- PVP que SIGUEN altos después de poner el costo del ticket.
-- Correr ANTES: sql/patch_corregir_costos_partida_qty_20260914.sql
-- NO usar costos partidos ($4.48 Escudo, $6.96 Grisi, etc.).
-- Idempotente: solo pisa si el PVP sigue por arriba del sugerido.

begin;

-- Escudo Rosa · costo ticket $8.97 · $42 → $20
update public.productos
   set precio = 20
 where sku = 'FC-43489004'
   and activo = true
   and costo >= 8
   and precio > 20;

-- Escudo Frescura 110 g · ticket $14.45 · $42 → $32
update public.productos
   set precio = 32
 where sku = 'FC-25605514'
   and activo = true
   and costo >= 14
   and precio > 32;

-- Escudo Azul 135 g · ticket $14.78 · $42 → $33
update public.productos
   set precio = 33
 where sku = 'FC-25652716'
   and activo = true
   and costo >= 14
   and precio > 33;

-- Grisi Neutro · ticket $20.87 · $56 → $46
update public.productos
   set precio = 46
 where sku = 'FC-22105207'
   and activo = true
   and costo >= 20
   and precio > 46;

-- Grisi Avena · ticket $21.72 · $56 → $48
update public.productos
   set precio = 48
 where sku = 'FC-22150801'
   and activo = true
   and costo >= 21
   and precio > 48;

-- Grisi Leche de Burra · ticket $21.88 · $56 → $49
update public.productos
   set precio = 49
 where sku = 'FC-22150092'
   and activo = true
   and costo >= 21
   and precio > 49;

-- Palmolive líquido · ticket $35.61 · $98 → $79
update public.productos
   set precio = 79
 where sku = 'FC-46059556'
   and activo = true
   and costo >= 35
   and precio > 79;

-- Obao Coco · ticket $24.95 · $68 → $55
update public.productos
   set precio = 55
 where sku = 'FC-52844825'
   and activo = true
   and costo >= 24
   and precio > 55;

-- Obao Piel Delicada · ticket $25.83 · $68 → $57
update public.productos
   set precio = 57
 where sku = 'FC-27250612'
   and activo = true
   and costo >= 25
   and precio > 57;

-- Nivea Milk 100 ml · ticket ~$25.86 · $69 → $57
update public.productos
   set precio = 57
 where sku = 'FC-54549796'
   and activo = true
   and costo >= 25
   and precio > 57;

-- Nivea Softmilk 100 ml · ~$26.30 · $69 → $58
update public.productos
   set precio = 58
 where sku = 'FC-54549819'
   and activo = true
   and costo >= 26
   and precio > 58;

-- Nivea Softmilk 400 ml · ticket $84.49 · $207 → $186
update public.productos
   set precio = 186
 where sku = 'FC-08802838'
   and activo = true
   and costo >= 80
   and precio > 186;

-- Nivea Milk 400+100 · ticket $85.87 · $207 → $189
update public.productos
   set precio = 189
 where sku = 'FC-54558682'
   and activo = true
   and costo >= 80
   and precio > 189;

-- Evenflo Colors · Farmalive $15.48 · $63 → $35
update public.productos
   set precio = 35
 where sku = 'FC-27512574'
   and activo = true
   and costo >= 15
   and precio > 35;

-- Pert kera+aguacate 100 ml · última compra $14.80 (sin ticket en repo) · $55 → $33
update public.productos
   set precio = 33
 where sku = 'FC-20500164'
   and activo = true
   and costo >= 14
   and precio > 33;

commit;
