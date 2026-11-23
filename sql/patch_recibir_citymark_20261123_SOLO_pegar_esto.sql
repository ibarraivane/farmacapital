-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- City Mark 20261123 · $1,710.16 · 36 renglones · 50 pzas
-- Merge a GitHub NO crea la cola. Sin dollar-quote. Sin producto_imagenes.
-- Caducidad null: MMAA de la caja. No inventar 0000.
-- =============================================================================

rollback;

-- ========== City Mark 20261123 ==========
-- City Mark · folio 20261123 · 2026-11-23 · total $1,710.16 · 36 renglones
-- 30 alta(s) stock 0. 6 ya estaban: solo costo / ficha vacia, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_cm_20261123 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null,
  imagen text,
  lote text
) on commit drop;

insert into _fc_cm_20261123 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
  (1, '037836007279', 'FC-36007279', 'Conseguau Aloe Vera shampoo para perro', 'SH PERRO CONSE GUAU ALOE VERA 400ML', 2, 45.66, 58, 'marca', 'Mascotas', null, 'Shampoo', 'Conseguau', 'Grisi', '400 ml', null, null, false, true, null, null),
  (2, '7501054555728', 'FC-54555728', 'Nivea Milk Nutritiva pack 1 L + 100 ml', 'CRM NIVEA 1LT PACK + CRM NIVEA 100ML', 1, 262.98, 329, 'marca', 'Cuidado de la piel', null, 'Crema corporal', 'Nivea', 'Beiersdorf', 'Pack 1 L + 100 ml', null, null, false, false, null, null),
  (3, '7501103300200', 'FC-03300200', 'T.Taio Bath Time esponja redonda estampada', 'TTAIO ESPONJA REDONDA ESTAMPADA', 2, 16.74, 21, 'marca', 'Cuidado personal', null, 'Esponja', 'T.Taio', null, '1 pieza', null, null, false, false, null, null),
  (4, '037836050930', 'FC-36050930', 'Ricitos de Oro jabón líquido y shampoo lavanda lechuga', 'RICITOS DE ORO 400ML JBN LIQ Y SH LAV LECHUGA + DOSIFICADOR', 1, 85.90, 108, 'marca', 'Cuidado bebé', null, 'Pack', 'Ricitos de Oro', 'Grisi', '400 ml + dosificador', null, null, false, false, null, null),
  (5, '7501019031137', 'FC-19031137', 'Saba Amore Regular con alas', 'TAS SANIT SABA AMORE REG ALAS C/8', 2, 12.85, 17, 'marca', 'Higiene femenina', null, 'Toallas sanitarias', 'Saba', 'Essity', 'Caja con 8 piezas', null, null, false, false, null, null),
  (6, '7501019006388', 'FC-19006388', 'Saba Invisible con alas', 'TAS SANIT SABA INV ALAS C/14 E638', 1, 35.99, 45, 'marca', 'Higiene femenina', null, 'Toallas sanitarias', 'Saba', 'Essity', 'Caja con 14 piezas', null, null, false, false, null, null),
  (7, '850040940619', 'FC-40940619', 'Ricitos de Oro shampoo lavanda pack', 'SH RICITOS DE ORO 500ML LAVANDA + 100ML SH LAVANDA', 1, 98.50, 124, 'marca', 'Cuidado bebé', null, 'Shampoo', 'Ricitos de Oro', 'Grisi', '500 ml + 100 ml', null, null, false, false, null, null),
  (8, '7501054549796', 'FC-54549796', 'Nivea Milk Nutritiva extra seca', 'CRA CORP NIV MILK N EX/SECA 100ML', 2, 26.96, 34, 'marca', 'Cuidado de la piel', null, 'Crema corporal', 'Nivea', 'Beiersdorf', '100 ml', null, null, false, false, null, null),
  (9, '037836021060', 'FC-36021060', 'Ricitos de Oro gel manzanilla', 'GEL RICITOS DE ORO MZLLA 125 ML', 1, 37.29, 47, 'marca', 'Cuidado bebé', null, 'Gel', 'Ricitos de Oro', 'Grisi', '125 ml', null, null, false, false, null, null),
  (10, '037836033797', 'FC-36033797', 'Ricitos de Oro Bio Pure', 'RICITOS DE ORO 100ML BIO PURE', 1, 18.90, 24, 'marca', 'Cuidado bebé', null, 'Loción', 'Ricitos de Oro', 'Grisi', '100 ml', null, null, false, false, null, null),
  (11, '037836040368', 'FC-36040368', 'Ricitos de Oro agua de colonia spray', 'AGUA COL RICITOS ORO SPY 100 ML', 1, 39.07, 49, 'marca', 'Cuidado bebé', null, 'Spray', 'Ricitos de Oro', 'Grisi', '100 ml', null, null, false, false, null, null),
  (12, '037836040535', 'FC-36040535', 'Ricitos de Oro crema corporal lavanda', 'RICITOS DE ORO 100ML CRA CORP LAVANDA C3 6 AB', 2, 18.89, 24, 'marca', 'Cuidado bebé', null, 'Crema corporal', 'Ricitos de Oro', 'Grisi', '100 ml', null, null, false, false, null, null),
  (13, '037836041259', 'FC-36041259', 'Hinds crema líquida rosa', 'CRA HINDS LIQ RSA RCA 90ML', 2, 18.74, 24, 'marca', 'Cuidado de la piel', null, 'Crema líquida', 'Hinds', 'Grisi', '90 ml', null, null, false, false, null, null),
  (14, '037836041297', 'FC-36041297', 'Hinds Inspiration crema líquida', 'CRA HINDS INSP LIQ RCA 90ML MAY27', 2, 16.30, 21, 'marca', 'Cuidado de la piel', null, 'Crema líquida', 'Hinds', 'Grisi', '90 ml', null, null, false, false, null, null),
  (15, '037836041389', 'FC-36041389', 'Hinds Hidratación Extra crema líquida pesca', 'CRA HINDS HID-EXT LIQ PSCA 90ML', 2, 18.74, 24, 'marca', 'Cuidado de la piel', null, 'Crema líquida', 'Hinds', 'Grisi', '90 ml', null, null, false, false, null, null),
  (16, '7501007528939', 'FC-07528939', 'Lubriderm Reparación Intensiva', 'CRA LUBRIDERM THINT PSEC120ML', 1, 31.59, 40, 'marca', 'Cuidado de la piel', null, 'Crema corporal', 'Lubriderm', 'Johnson & Johnson', '120 ml', null, null, false, true, null, null),
  (17, '7702035469151', 'FC-35469151', 'Lubriderm UV', 'CRA LUBRIDERM UV FPS15 120ML DIC27', 1, 34.41, 44, 'marca', 'Cuidado de la piel', null, 'Crema corporal', 'Lubriderm', 'Johnson & Johnson', '120 ml', null, 'FPS 15', false, true, null, null),
  (18, '7702031244486', 'FC-31244486', 'Lubriderm piel normal', 'CRA LUBRIDERM P/NORMAL 120ML', 1, 31.59, 40, 'marca', 'Cuidado de la piel', null, 'Crema corporal', 'Lubriderm', 'Johnson & Johnson', '120 ml', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/lubriderm-piel-normal-120ml.jpg', null),
  (19, '037836084829', 'FC-36084829', 'Ricitos de Oro shampoo manzanilla miel + crema corporal', 'RICITOS DE ORO 400ML SH MNZLLA MIEL + 100ML CRA CORP', 1, 85.90, 108, 'marca', 'Cuidado bebé', null, 'Pack', 'Ricitos de Oro', 'Grisi', '400 ml + 100 ml', null, null, false, false, null, null),
  (20, '7501022130063', 'FC-22130063', 'Ricitos de Oro shampoo miel', 'SH GRISI RICITOS ORO MIEL 100 ML', 1, 29.80, 38, 'marca', 'Cuidado bebé', null, 'Shampoo', 'Ricitos de Oro', 'Grisi', '100 ml', null, null, false, false, null, null),
  (21, '5050456009190', 'FC-56009190', 'Playboy Goddess Come desodorante spray', 'DESOD PLAYBOY GODDES COM SPY 150ML', 1, 53.42, 67, 'marca', 'Desodorantes', null, 'Spray', 'Playboy', null, '150 ml', null, null, false, false, null, null),
  (22, '5050456009176', 'FC-56009176', 'Playboy Play It Sexy desodorante spray', 'DESOD PLAYBOY PLAY SEXY SPY 150ML', 1, 51.61, 65, 'marca', 'Desodorantes', null, 'Spray', 'Playboy', null, '150 ml', null, null, false, false, null, null),
  (23, '5050456009206', 'FC-56009206', 'Playboy Wham Glam desodorante spray', 'DESOD PLAY BOY WHAM GLAM SPY 150ML', 1, 53.50, 67, 'marca', 'Desodorantes', null, 'Spray', 'Playboy', null, '150 ml', null, null, false, false, null, null),
  (24, '7501019006371', 'FC-19006371', 'Saba Invisible con alas', 'TAS SANIT SABA INV ALAS C/10', 1, 21.35, 27, 'marca', 'Higiene femenina', null, 'Toallas sanitarias', 'Saba', 'Essity', 'Caja con 10 piezas', null, null, false, false, null, null),
  (25, '7501019035876', 'FC-19035876', 'Saba Amore Nocturna Super Absorción con alas', 'TAS SANIT SABA AMORE NOCSUP-ABC/A 8', 3, 14.18, 18, 'marca', 'Higiene femenina', null, 'Toallas sanitarias', 'Saba', 'Essity', 'Caja con 8 piezas', null, null, false, false, null, null),
  (26, '7501017360604', 'FC-17360604', 'Kotex Anti Flujo Abundante sin alas', 'TAS SAN KOTEX ANT FLUJO ABUNDANTE S/A 10PZ', 2, 21.21, 27, 'marca', 'Higiene femenina', null, 'Toallas sanitarias', 'Kotex', 'Kimberly-Clark', 'Paquete con 10 piezas', null, null, false, false, null, null),
  (27, '7501017360789', 'FC-17360789', 'Kotex Anatómica Delgada con alas', 'TAS SANIT KOTEX ANAT DELG ALAS 10', 1, 18.11, 23, 'marca', 'Higiene femenina', null, 'Toallas sanitarias', 'Kotex', 'Kimberly-Clark', 'Paquete con 10 piezas', null, null, false, false, null, null),
  (28, '7501943410893', 'FC-43410893', 'Kotex Protect rosa', 'TAS SANIT KOTEXP1 ROSA C7', 1, 9.92, 13, 'marca', 'Higiene femenina', null, 'Toallas sanitarias', 'Kotex', 'Kimberly-Clark', 'Paquete con 7 piezas', null, null, false, false, null, null),
  (29, '7501019031144', 'FC-19031144', 'Saba Amore Regular sin alas', 'TAS SANIT SABA AMORE REG S/ALAS 8', 1, 10.82, 14, 'marca', 'Higiene femenina', null, 'Toallas sanitarias', 'Saba', 'Essity', 'Caja con 8 piezas', null, null, false, false, null, null),
  (30, '7501048335305', 'FC-48335305', 'Protec agua oxigenada', 'PROTEC AGUA OXIGENADA 480 ML', 2, 13.60, 22, 'generico', 'Botiquin', null, 'Solución', 'Protec', null, '480 ml', 'Peróxido de hidrógeno', null, false, true, null, null),
  (31, '7502004531366', 'FC-04531366', 'Selecta agua oxigenada', 'SELECTA AGUA OXIGENADA 250ML', 2, 8.42, 14, 'generico', 'Botiquin', null, 'Solución', 'Selecta', null, '250 ml', 'Peróxido de hidrógeno', null, false, false, null, null),
  (32, '7502004530758', 'FC-04530758', 'Selecta agua oxigenada', 'SELECTA AGUA OXIGENADA 110ML', 2, 5.25, 9, 'generico', 'Botiquin', null, 'Solución', 'Selecta', null, '110 ml', 'Peróxido de hidrógeno', null, false, false, null, null),
  (33, '5050456009183', 'FC-56009183', 'Playboy Keep It Real desodorante spray', 'DESOD PLAY BOY KEEP IREAL SPY 150ML', 1, 53.50, 67, 'marca', 'Desodorantes', null, 'Spray', 'Playboy', null, '150 ml', null, null, false, false, null, null),
  (34, '4068359345674', 'FC-59345674', 'Koleston Rubio Mediano 70', 'KOLESTON TIN RUBIO MEDIANO 70', 1, 53.34, 67, 'marca', 'Cuidado del cabello', null, 'Tinte', 'Koleston', 'Wella', 'Kit 1 pieza', null, '70', false, false, null, null),
  (35, '4068359345797', 'FC-59345797', 'Koleston Rubio Mate 72', 'TIN KOLESTON RUBIO MATE 72', 1, 53.34, 67, 'marca', 'Cuidado del cabello', null, 'Tinte', 'Koleston', 'Wella', 'Kit 1 pieza', null, '72', false, false, null, null),
  (36, '7501056340131', 'FC-56340131', 'Sedal Rizos Obedientes crema para peinar', 'CRA SEDAL RIZOS OBEDIE 300ML', 1, 50.07, 63, 'marca', 'Cuidado del cabello', null, 'Crema para peinar', 'Sedal', 'Unilever', '300 ml', null, null, false, true, null, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when not exists (
      select 1 from public.productos p where p.sku = t.sku
    ) then t.sku
    when t.ean is not null and not exists (
      select 1 from public.productos p
      where p.sku = ('FC-ND-' || right(t.ean, 8))
    ) then 'FC-ND-' || right(t.ean, 8)
    when t.ean is not null then
      'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
    else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta City Mark 20261123 · 2026-11-23 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.imagen,
  t.imagen
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_cm_20261123
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = t.ean
  ))
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
      and (
        t.ean is null
        or nullif(btrim(p.codigo_barras), '') is null
        or nullif(btrim(p.codigo_barras), '') = t.ean
      )
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = (
      case
        when not exists (
          select 1 from public.productos x where x.sku = t.sku
        ) then t.sku
        when t.ean is not null and not exists (
          select 1 from public.productos x
          where x.sku = ('FC-ND-' || right(t.ean, 8))
        ) then 'FC-ND-' || right(t.ean, 8)
        when t.ean is not null then
          'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
        else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
      end
    )
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_cm_20261123
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_cm_20261123
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'City Mark',
  '20261123',
  '2026-11-23',
  1710.16,
  'borrador',
  'City Mark · folio 20261123 · ticket PUBLICO EN GENERAL · Cajera 1 · 36 renglones · 50 pzas · P.U. con IVA (suma = total $1,710.16) · tarjeta crédito · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '20261123'
    and coalesce(proveedor, '') ilike '%city mark%'
);

update public.recepciones
set
  total_ticket = 1710.16,
  fecha = '2026-11-23',
  proveedor = 'City Mark',
  notas = 'City Mark · folio 20261123 · ticket PUBLICO EN GENERAL · Cajera 1 · 36 renglones · 50 pzas · P.U. con IVA (suma = total $1,710.16) · tarjeta crédito · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '20261123'
  and coalesce(proveedor, '') ilike '%city mark%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '20261123'
  and coalesce(r.proveedor, '') ilike '%city mark%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  coalesce(nullif(btrim(t.ean), ''), t.sku),
  t.snap,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from _fc_cm_20261123 t
join public.recepciones r
  on r.folio = '20261123'
 and coalesce(r.proveedor, '') ilike '%city mark%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku),
    (
      select p2.id from public.productos p2
      where nullif(btrim(t.ean), '') is not null
        and nullif(btrim(p2.codigo_barras), '') = nullif(btrim(t.ean), '')
      order by p2.id
      limit 1
    ),
    (
      select p2.id from public.productos p2
      where p2.sku = t.sku
      order by p2.id
      limit 1
    )
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '20261123'
  and coalesce(r.proveedor, '') ilike '%city mark%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  t.lote,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku),
      (
        select p2.id from public.productos p2
        where t.ean is not null
          and nullif(btrim(p2.codigo_barras), '') = t.ean
        order by p2.id
        limit 1
      ),
      (
        select p2.id from public.productos p2
        where p2.sku = t.sku
        order by p2.id
        limit 1
      )
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_cm_20261123 t
order by t.linea;

commit;
