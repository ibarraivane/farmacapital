-- EANs de caja (fotos 01-oct-2026) → productos IFC 126446 + Equilibrio 446466.
-- Costo / cantidades del ticket NO se tocan.
-- SKU canónico: FC- + últimos 8 del EAN (si choca con otro EAN → FC-ND- + 8).
-- Ricino: EAN 3311000001292 ya existía como FC-00001292 — se reusa.
-- SER181: caja dice RUQUIMAX (hidroxicloroquina), no «Ruquimox».
-- Idempotente. Pegar TODO en Supabase → SQL Editor → Run.

begin;

create temp table _fc_ean_20260930 (
  sku_viejo text not null,
  ean text not null,
  sku_nuevo text not null,
  nombre text,
  marca text,
  presentacion text,
  forma text,
  principio text,
  concentracion text,
  laboratorio text,
  folio text not null,
  snap_like text not null
) on commit drop;

insert into _fc_ean_20260930 (
  sku_viejo, ean, sku_nuevo, nombre, marca, presentacion, forma,
  principio, concentracion, laboratorio, folio, snap_like
) values
  -- IFC 126446
  (
    'FC-IFC-CORTA-TRY12', '6932119800025', 'FC-19800025',
    'Cortaúñas Try mediano C/12', 'Try', 'Paquete C/12 (no venta individual)', 'Accesorio',
    null, null, null, '126446', '%CORTAUNAS TRY%'
  ),
  (
    'FC-IFC-CORTA-BOBO12', '6976824588236', 'FC-24588236',
    'Cortaúñas Bobo mediano sin cadena C/12', 'Bobo', 'Paquete C/12', 'Accesorio',
    null, null, null, '126446', '%CORTAUNAS BOBO%'
  ),
  (
    'FC-IFC-PINZA-LADY', '7501370204577', 'FC-70204577',
    'Curtis Lady pinza tijera cejas', 'Curtis', '1 pieza · modelo 57LC', 'Accesorio',
    null, null, 'Curtis', '126446', '%PINZA DEPILAR LADY%'
  ),
  (
    'FC-IFC-YOLI-ENCH', '7501370202023', 'FC-70202023',
    'Yoli enchinador de pestañas', 'Yoli', '1 pieza · modelo 102CV', 'Accesorio',
    null, null, 'Curtis', '126446', '%YOLI ENCHINADOR%'
  ),
  (
    'FC-IFC-ALICATA-GDE', '6855265655229', 'FC-65655229',
    'Alicata / set manicure económico mango colores', null, 'Pieza / set', 'Accesorio',
    null, null, null, '126446', '%ALICATA ECONOMICA%'
  ),
  (
    'FC-IFC-MER-RICINO', '3311000001292', 'FC-00001292',
    'Mercurio aceite de ricino 50 ml', 'Mercurio', 'Frasco 50 ml', 'Aceite',
    null, null, 'Droguería Mercurio', '126446', '%ACEITE RICINO%'
  ),
  -- Equilibrio 446466
  (
    'EQ-AVT195', '7506624900809', 'FC-24900809',
    'Tusilen adulto jarabe 118 ml', 'Tusilen', 'Frasco 118 ml', 'Jarabe',
    'Dextrometorfano / guaifenesina / fenilefrina', '0.300/2.4/0.050 g/100 ml', 'Avitus / Allen',
    '446466', '%TUSILEN AD%'
  ),
  (
    'EQ-SER181', '7501258215947', 'FC-58215947',
    'Ruquimax hidroxicloroquina 200 mg C/20', 'Ruquimax', 'Caja con 20 tabletas', 'Tableta',
    'Hidroxicloroquina', '200 mg', 'Serral',
    '446466', '%RUQUIMOX%'
  );

-- 1) Si el EAN ya tiene producto distinto del sku_viejo, no duplicar: solo alinear ficha/recepción.
-- 2) Si no existe el EAN: poner barcode (+ SKU canónico si libre) en el sku_viejo.

update public.productos p
set
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean),
  sku = case
    when p.sku = t.sku_viejo
      and not exists (
        select 1 from public.productos x
        where x.sku = t.sku_nuevo and x.id <> p.id
      )
      and (
        not exists (
          select 1 from public.productos y
          where y.sku = t.sku_nuevo
            and coalesce(y.codigo_barras, '') <> ''
            and y.codigo_barras <> t.ean
        )
      )
      then t.sku_nuevo
    when p.sku = t.sku_viejo
      and exists (
        select 1 from public.productos x
        where x.sku = t.sku_nuevo
          and coalesce(x.codigo_barras, '') <> ''
          and x.codigo_barras <> t.ean
      )
      then 'FC-ND-' || right(t.ean, 8)
    else p.sku
  end,
  nombre = coalesce(t.nombre, p.nombre),
  marca = coalesce(nullif(btrim(p.marca), ''), t.marca),
  presentacion = coalesce(t.presentacion, p.presentacion),
  forma_farmaceutica = coalesce(t.forma, p.forma_farmaceutica),
  principio_activo = coalesce(t.principio, p.principio_activo),
  concentracion = coalesce(t.concentracion, p.concentracion),
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), t.laboratorio),
  updated_at = now()
from _fc_ean_20260930 t
where p.sku = t.sku_viejo
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Si el EAN ya existía (p. ej. ricino FC-00001292 / pinza Lady): enriquecer ficha vacía.
update public.productos p
set
  nombre = case
    when coalesce(nullif(btrim(p.nombre), ''), '') in ('', t.sku_viejo) or p.nombre ilike '%ruquimox%'
      then coalesce(t.nombre, p.nombre)
    else p.nombre
  end,
  marca = coalesce(nullif(btrim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), t.forma),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), t.principio),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), t.laboratorio),
  updated_at = now()
from _fc_ean_20260930 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Renglones grises Recibir: poner EAN de pistola + producto_id resuelto por EAN/SKU nuevo.
update public.recepcion_items i
set
  codigo_escaneado = t.ean,
  producto_id = coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku_nuevo),
    public.fc_buscar_producto_escaneo(t.sku_viejo),
    i.producto_id
  ),
  nombre_snapshot = coalesce(t.nombre, i.nombre_snapshot),
  pendiente_alta = (
    coalesce(
      public.fc_buscar_producto_escaneo(t.ean),
      public.fc_buscar_producto_escaneo(t.sku_nuevo),
      public.fc_buscar_producto_escaneo(t.sku_viejo),
      i.producto_id
    ) is null
  )
from public.recepciones r
join _fc_ean_20260930 t on t.folio = r.folio
where i.recepcion_id = r.id
  and r.estado = 'borrador'
  and (
    i.nombre_snapshot ilike t.snap_like
    or coalesce(i.codigo_escaneado, '') = t.sku_viejo
    or i.producto_id = public.fc_buscar_producto_escaneo(t.sku_viejo)
  );

-- Si quedó producto huérfano sku_viejo sin EAN y ya hay producto con el EAN: no borrar (puede tener historial).
-- Solo apuntar recepción al del EAN (arriba).

select
  t.folio,
  t.sku_viejo,
  t.ean,
  t.sku_nuevo,
  p.sku as sku_actual,
  p.codigo_barras,
  left(p.nombre, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA' else 'OK' end as rx
from _fc_ean_20260930 t
left join lateral (
  select * from public.productos
  where id = coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku_nuevo),
    public.fc_buscar_producto_escaneo(t.sku_viejo)
  )
) p on true
left join public.recepciones r
  on r.folio = t.folio and r.estado = 'borrador'
left join public.recepcion_items i
  on i.recepcion_id = r.id
 and (
   i.codigo_escaneado = t.ean
   or i.nombre_snapshot ilike t.snap_like
 )
order by t.folio, t.sku_viejo;

commit;
