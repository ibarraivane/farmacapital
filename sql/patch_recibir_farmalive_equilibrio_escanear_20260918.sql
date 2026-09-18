-- ============================================================================
-- Recibir: escanear Farmalive 12790 + Equilibrio 20260914
--
-- Qué falló:
--   1) Los parches del 16-sep enlazaron folio '127790'. El ticket vivo es
--      12790 (a veces se ve 127900). Las 6 amarillas nunca se ligaron.
--   2) Aspirina 3-pack se dio de alta con EAN OCR 7501008849949. El real
--      (ticket + caja Bayer) es 7501008499429.
--   3) Teatrical 19 g: el ticket trae 12 dígitos (650240079009 / 078996);
--      la caja escanea 13 (6502400079009 / 0078996). fc_match no los veía.
--   4) Equilibrio: si codigo_escaneado quedó en SKU (EQ-AMS160), el EAN
--      de la caja no abría el gris.
--
-- Esto:
--   - Match pistola: 12↔13, dígito extra, Genomma 6502400…, pares conocidos.
--   - Alta de los 6 (o repara EAN). Stock 0 hasta Recibir + MMAA de la caja.
--   - Enlaza Farmalive 12790 / 127790 / 127900 por EAN o nombre.
--   - Equilibrio: codigo_escaneado = EAN de catálogo (no el SKU).
--   - fc_recepcion_json manda codigo_barras para que la pistola no dependa
--     de que el catálogo entero haya cargado en la tablet.
--
-- Pegar TODO en Supabase → SQL Editor → Run. Idempotente.
-- ============================================================================

begin;

create or replace function public.fc_match_codigo_barras(p_scan text, p_stored text)
returns boolean
language sql
immutable
parallel safe
as $$
  with n as (
    select
      regexp_replace(coalesce(p_scan, ''), '\D', '', 'g') as scan,
      regexp_replace(coalesce(p_stored, ''), '\D', '', 'g') as stored
  )
  select
    case
      when n.scan = '' or n.stored = '' then false
      when n.scan = n.stored then true
      when length(n.scan) >= 12 and length(n.stored) >= 12
        and right(n.scan, 12) = right(n.stored, 12) then true
      when length(n.scan) = 12 and length(n.stored) = 13
        and n.stored = '0' || n.scan then true
      when length(n.stored) = 12 and length(n.scan) = 13
        and n.scan = '0' || n.stored then true
      when length(n.scan) >= 8 and length(n.stored) = length(n.scan) + 1
        and n.stored like n.scan || '_' then true
      when length(n.stored) >= 8 and length(n.scan) = length(n.stored) + 1
        and n.scan like n.stored || '_' then true
      when length(n.scan) = 13 and length(n.stored) = 12
        and n.scan like '6502400%' and n.stored like '650240%'
        and substring(n.scan from 8) = substring(n.stored from 7) then true
      when length(n.stored) = 13 and length(n.scan) = 12
        and n.stored like '6502400%' and n.scan like '650240%'
        and substring(n.stored from 8) = substring(n.scan from 7) then true
      when n.scan in ('7501868900233', '7501868990023')
       and n.stored in ('7501868900233', '7501868990023') then true
      when n.scan in ('747589705123', '714706903205')
       and n.stored in ('747589705123', '714706903205') then true
      when n.scan in ('650240079009', '6502400079009', '6502400070009')
       and n.stored in ('650240079009', '6502400079009', '6502400070009') then true
      when n.scan in ('650240078996', '6502400078996')
       and n.stored in ('650240078996', '6502400078996') then true
      else false
    end
  from n;
$$;

grant execute on function public.fc_match_codigo_barras(text, text) to anon, authenticated, service_role;

create or replace function public.fc_recepcion_json(p_recepcion_id bigint)
returns jsonb
language plpgsql
stable
set search_path = public
as $$
declare
  v_rec public.recepciones%rowtype;
  v_items jsonb;
  v_subtotal numeric;
  v_renglones int;
  v_piezas int;
  v_pendientes int;
  v_sin_confirmar int;
  v_sin_cad int;
begin
  select * into v_rec from public.recepciones where id = p_recepcion_id;
  if not found then
    return null;
  end if;

  select
    coalesce(jsonb_agg(
      jsonb_build_object(
        'id', i.id,
        'producto_id', i.producto_id,
        'codigo_escaneado', i.codigo_escaneado,
        'nombre', coalesce(pr.nombre, i.nombre_snapshot, i.codigo_escaneado),
        'sku', pr.sku,
        'codigo_barras', pr.codigo_barras,
        'cantidad', i.cantidad,
        'fecha_caducidad', i.fecha_caducidad,
        'numero_lote', i.numero_lote,
        'costo_estimado', i.costo_estimado,
        'costo_catalogo', pr.costo,
        'precio', pr.precio,
        'tipo', pr.tipo,
        'pendiente_alta', i.pendiente_alta,
        'confirmado', i.confirmado,
        'origen', i.origen,
        'lote_distinto', i.lote_distinto,
        'lote_id', i.lote_id,
        'lotes_piso', (
          select coalesce(jsonb_agg(l.numero_lote order by l.fecha_caducidad nulls first, l.id), '[]'::jsonb)
          from public.lotes l
          where l.producto_id = i.producto_id
            and coalesce(l.activo, true)
            and coalesce(l.cantidad_actual, 0) > 0
        )
      )
      order by i.confirmado, i.id
    ), '[]'::jsonb),
    coalesce(sum(i.cantidad * coalesce(i.costo_estimado, 0)), 0),
    count(*)::int,
    coalesce(sum(i.cantidad), 0)::int,
    count(*) filter (where i.pendiente_alta)::int,
    count(*) filter (where not i.confirmado)::int,
    count(*) filter (where i.lote_id is not null and i.fecha_caducidad is null)::int
  into v_items, v_subtotal, v_renglones, v_piezas, v_pendientes, v_sin_confirmar, v_sin_cad
  from public.recepcion_items i
  left join public.productos pr on pr.id = i.producto_id
  where i.recepcion_id = p_recepcion_id;

  return jsonb_build_object(
    'id', v_rec.id,
    'proveedor', v_rec.proveedor,
    'folio', v_rec.folio,
    'fecha', v_rec.fecha,
    'total_ticket', v_rec.total_ticket,
    'estado', v_rec.estado,
    'capturado_por', v_rec.capturado_por,
    'subtotal_estimado', round(v_subtotal, 2),
    'diferencia', case
      when v_rec.total_ticket is null then null
      else round(v_subtotal - v_rec.total_ticket, 2)
    end,
    'renglones', v_renglones,
    'piezas', v_piezas,
    'pendientes_alta', v_pendientes,
    'sin_confirmar', v_sin_confirmar,
    'sin_caducidad_anaquel', v_sin_cad,
    'updated_at', v_rec.updated_at,
    'cerrado_en', v_rec.cerrado_en,
    'items', v_items
  );
end;
$$;

-- Ensure chocolate ya está (FC-33950100). Si quedó inactivo, fc_buscar no lo ve.
update public.productos
set activo = true
where (sku = 'FC-33950100' or codigo_barras = '7501033954061')
  and coalesce(activo, true) is distinct from true;

-- Aspirina 3-pack: el patch del 16-sep guardó el EAN OCR. Corregir.
update public.productos
set
  codigo_barras = '7501008499429',
  sku = case
    when sku in ('FC-08849949', 'FC-08499429') then 'FC-08499429'
    else sku
  end,
  nombre = 'Aspirina tabletas 500 mg C/40 3-pack',
  marca = coalesce(nullif(btrim(marca), ''), 'Aspirina'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), '3 cajas con 40 tabletas'),
  descripcion = case
    when descripcion ilike '%7501008499429%' then descripcion
    else coalesce(nullif(btrim(descripcion), '') || ' ', '')
      || 'Farmalive 12790 · EAN caja 7501008499429 · OCR viejo 7501008849949'
  end
where codigo_barras = '7501008849949'
   or (sku = 'FC-08849949' and coalesce(codigo_barras, '') in ('', '7501008849949'));

create temp table _fc_alta_rx20260918 (
  ean text primary key,
  aliases text not null,
  sku text not null,
  nombre text not null,
  marca text not null,
  presentacion text not null,
  forma_farmaceutica text,
  categoria text not null,
  subcategoria text,
  descripcion text not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null
) on commit drop;

insert into _fc_alta_rx20260918 values
  (
    '6502400079009', '650240079009 6502400070009 6502400079009',
    'FC-00079009',
    'Crema Teatrical rosa lanolina 19 g',
    'Teatrical', 'Tarro 19 g', 'Crema',
    'Cuidado personal', 'Facial',
    'Farmalive 12790 · Teatrical rosa (lanolina) 19 g Genomma · EAN caja 6502400079009 · ticket 650240079009 · alias 6502400070009',
    15.11, 19
  ),
  (
    '6502400078996', '650240078996 6502400078996',
    'FC-00078996',
    'Crema Teatrical azul 19 g',
    'Teatrical', 'Tarro 19 g', 'Crema',
    'Cuidado personal', 'Facial',
    'Farmalive 12790 · Teatrical azul 19 g Genomma · EAN caja 6502400078996 · ticket 650240078996',
    15.11, 19
  ),
  (
    '7501088509926', '7501088509926 7501088599926',
    'FC-08850926',
    'Gotinal adulto nafazolina 1 mg/ml spray 15 ml',
    'Gotinal', 'Atomizador 15 ml', 'Spray nasal',
    'Medicamentos', 'Respiratorio',
    'Farmalive 12790 · Chinoin Gotinal adulto 1 mg/ml 15 ml · EAN 7501088509926 · Farmalisto/PLM',
    127.30, 160
  ),
  (
    '7501008499429', '7501008499429 7501008849949',
    'FC-08499429',
    'Aspirina tabletas 500 mg C/40 3-pack',
    'Aspirina', '3 cajas con 40 tabletas', 'Tableta',
    'Medicamentos', 'Analgésico',
    'Farmalive 12790 · Bayer Aspirina C/40 3-pack · EAN 7501008499429',
    115.15, 144
  ),
  (
    '7501008499245', '7501008499245',
    'FC-08499245',
    'Aspirina GO 500 mg granulado naranja C/10 sobres',
    'Aspirina', 'Caja con 10 sobres', 'Granulado',
    'Medicamentos', 'Analgésico',
    'Farmalive 12790 · Bayer Aspirina GO 500 mg C/10 · EAN 7501008499245',
    58.80, 74
  );

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, subcategoria
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') <> t.ean
        and not public.fc_match_codigo_barras(t.ean, p.codigo_barras)
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  'marca',
  t.descripcion,
  t.costo,
  t.precio,
  0,
  1,
  true,
  false,
  t.marca,
  t.presentacion,
  t.forma_farmaceutica,
  t.subcategoria
from _fc_alta_rx20260918 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and not exists (
    select 1 from public.productos p
    where public.fc_match_codigo_barras(t.ean, p.codigo_barras)
       or p.codigo_barras = t.ean
  );

-- Si ya existía: costo de este ticket, EAN canónico, aliases en ficha. No pisa PVP bueno.
update public.productos p
set
  costo = coalesce(p.costo, t.costo),
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end,
  activo = true,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean),
  marca = coalesce(nullif(btrim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
  descripcion = case
    when p.descripcion ilike '%' || t.ean || '%' then p.descripcion
    else coalesce(nullif(btrim(p.descripcion), '') || ' ', '') || t.descripcion
  end
from _fc_alta_rx20260918 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
   or public.fc_match_codigo_barras(t.ean, p.codigo_barras);

-- Folio del ticket vivo: 12790 en carga, 127790/127900 en parches y fotos.
create temp table _fc_folio_fl (
  folio text primary key
) on commit drop;
insert into _fc_folio_fl values ('12790'), ('127790'), ('127900');

update public.recepcion_items i
set
  producto_id = coalesce(
    i.producto_id,
    public.fc_buscar_producto_escaneo(i.codigo_escaneado),
    (
      select p.id from public.productos p
      where public.fc_match_codigo_barras(
        regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g'),
        p.codigo_barras
      )
      order by p.id
      limit 1
    )
  ),
  pendiente_alta = false,
  codigo_escaneado = coalesce(
    nullif(btrim(i.codigo_escaneado), ''),
    (
      select p.codigo_barras from public.productos p
      where p.id = coalesce(
        i.producto_id,
        public.fc_buscar_producto_escaneo(i.codigo_escaneado)
      )
    )
  )
from public.recepciones r
where i.recepcion_id = r.id
  and coalesce(r.proveedor, '') ilike '%farmalive%'
  and regexp_replace(coalesce(r.folio, ''), '\D', '', 'g') in (select folio from _fc_folio_fl)
  and coalesce(i.pendiente_alta, false)
  and i.producto_id is null
  and coalesce(
    public.fc_buscar_producto_escaneo(i.codigo_escaneado),
    (
      select p.id from public.productos p
      where public.fc_match_codigo_barras(
        regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g'),
        p.codigo_barras
      )
      limit 1
    )
  ) is not null;

-- Por nombre del renglón amarillo (por si el EAN del ticket sigue truncado).
update public.recepcion_items i
set
  producto_id = p.id,
  pendiente_alta = false,
  codigo_escaneado = coalesce(nullif(btrim(i.codigo_escaneado), ''), p.codigo_barras)
from public.recepciones r,
     public.productos p
where i.recepcion_id = r.id
  and coalesce(r.proveedor, '') ilike '%farmalive%'
  and regexp_replace(coalesce(r.folio, ''), '\D', '', 'g') in (select folio from _fc_folio_fl)
  and coalesce(i.pendiente_alta, false)
  and i.producto_id is null
  and (
    (
      i.nombre_snapshot ilike '%teatrical%'
      and i.nombre_snapshot ilike '%rosa%'
      and i.nombre_snapshot ilike '%19%'
      and public.fc_match_codigo_barras('6502400079009', p.codigo_barras)
    )
    or (
      i.nombre_snapshot ilike '%teatrical%'
      and i.nombre_snapshot ilike '%azul%'
      and i.nombre_snapshot ilike '%19%'
      and public.fc_match_codigo_barras('6502400078996', p.codigo_barras)
    )
    or (
      i.nombre_snapshot ilike '%gotinal%'
      and p.codigo_barras = '7501088509926'
    )
    or (
      i.nombre_snapshot ilike '%ensure%'
      and i.nombre_snapshot ilike '%choco%'
      and p.codigo_barras = '7501033954061'
    )
    or (
      i.nombre_snapshot ilike '%aspirina%go%'
      and p.codigo_barras = '7501008499245'
    )
    or (
      i.nombre_snapshot ilike '%aspirina%'
      and i.nombre_snapshot ilike '%3-pack%'
      and public.fc_match_codigo_barras('7501008499429', p.codigo_barras)
    )
  );

-- Equilibrio: el renglón tiene que llevar el EAN de la caja, no el SKU EQ-*.
update public.recepcion_items i
set codigo_escaneado = p.codigo_barras
from public.recepciones r,
     public.productos p
where i.recepcion_id = r.id
  and r.folio = '20260914'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
  and p.id = i.producto_id
  and nullif(btrim(p.codigo_barras), '') is not null
  and (
    i.codigo_escaneado is null
    or i.codigo_escaneado ~* '^(EQ|FC)-'
    or not public.fc_match_codigo_barras(i.codigo_escaneado, p.codigo_barras)
  );

commit;

select
  r.folio,
  r.proveedor,
  r.estado,
  count(*) as renglones,
  count(*) filter (where i.pendiente_alta) as siguen_pendiente_alta,
  count(*) filter (where not i.confirmado) as sin_confirmar,
  count(*) filter (where i.confirmado) as confirmados
from public.recepciones r
join public.recepcion_items i on i.recepcion_id = r.id
where regexp_replace(coalesce(r.folio, ''), '\D', '', 'g') in ('12790', '127790', '127900', '20260914')
   or r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
group by r.folio, r.proveedor, r.estado
order by r.folio;

select
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as ticket,
  case when i.pendiente_alta then 'SIGUE PENDIENTE' else 'OK' end as estado,
  left(p.nombre, 48) as catalogo,
  p.sku
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where coalesce(r.proveedor, '') ilike '%farmalive%'
  and regexp_replace(coalesce(r.folio, ''), '\D', '', 'g') in ('12790', '127790', '127900')
  and (
    coalesce(i.pendiente_alta, false)
    or i.nombre_snapshot ilike '%teatrical%19%'
    or i.nombre_snapshot ilike '%gotinal%'
    or i.nombre_snapshot ilike '%ensure%choco%'
    or i.nombre_snapshot ilike '%aspirina%'
  )
order by i.pendiente_alta desc, i.id;
