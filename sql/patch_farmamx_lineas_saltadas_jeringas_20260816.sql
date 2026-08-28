-- ============================================================================
-- Farma MX CAICA1CA108588 · 12 lineas que la carga original SALTO
--
-- El ticket SI las trae. El script no las creo porque, al haber ya una
-- "Jeringa-..." o "Cinta-..." o "Solucion-...", las tomo por ambiguas
-- y las dejo pendientes. Por eso al escanear la pieza el POS dice
-- sin registro: no existe el SKU, y el EAN de la bolsa no es el de la caja.
--
-- Jeringas: el ticket compro CAJAS (C/100 o C/50). Se da de alta a nivel
-- pieza para que el escaner de la bolsa pegue. Costo = costo_caja / piezas.
-- Donde ya existe el alta por foto (FC-...), se actualiza costo/stock/lote
-- y no se duplica.
--
-- Idempotente. Ejecutar en Supabase SQL Editor (desde el archivo).
-- ============================================================================

begin;

do $$
declare
  r record;
  v_pid bigint;
  v_lid bigint;
  v_precio numeric;
begin
  for r in
    select * from (values
      -- ean (pieza o caja), sku_fmx, sku_foto, nombre, marca, presentacion,
      -- categoria, costo_pieza, qty_piezas, lote, cad, ean_alt
      (
        '7506022300881'::text, 'FMX-506383'::text, 'FC-22300881'::text,
        'Jeringa SensiMedical insulina 1 mL 27G x 13 mm'::text,
        'SensiMedical'::text, 'Pieza 1 mL 27G x 13 mm (caja C/100)'::text,
        'Dispositivo médico'::text, 1.53::numeric, 100::integer,
        '2601973605'::text, '2031-01-01'::date
      ),
      (
        '7506022300775', 'FMX-506385', 'FC-22300775',
        'Jeringa SensiMedical 3 mL 22G x 32 mm negra',
        'SensiMedical', 'Pieza 3 mL 22G x 32 mm (caja C/100 negra)',
        'Dispositivo médico', 1.55, 100,
        '2506885602', '2030-06-01'::date
      ),
      (
        '7506022300690', 'FMX-307657', null,
        'Jeringa SensiMedical 10 mL 22G x 32 mm negra',
        'SensiMedical', 'Pieza 10 mL 22G x 32 mm (caja C/100 negra)',
        'Dispositivo médico', 2.42, 100,
        '2504864301', '2030-04-01'::date
      ),
      (
        '7506022314741', 'FMX-307658', null,
        'Jeringa SensiMedical 20 mL 21G x 32 mm verde',
        'SensiMedical', 'Pieza 20 mL 21G x 32 mm (caja C/50 verde)',
        'Dispositivo médico', 4.10, 50,
        '2512962201', '2030-12-13'::date
      ),
      (
        '7506022300829', 'FMX-506389', null,
        'Jeringa SensiMedical 5 mL 21G x 32 mm verde',
        'SensiMedical', 'Pieza 5 mL 21G x 32 mm (caja C/100 verde)',
        'Dispositivo médico', 1.65, 100,
        '2503853712', '2030-03-01'::date
      ),
      (
        '7506022300751', 'FMX-506388', null,
        'Jeringa SensiMedical 3 mL 21G x 32 mm verde',
        'SensiMedical', 'Pieza 3 mL 21G x 32 mm (caja C/100 verde)',
        'Dispositivo médico', 1.55, 100,
        '2506885503', '2030-06-06'::date
      ),
      (
        '7506022300843', 'FMX-506386', null,
        'Jeringa SensiMedical 5 mL 22G x 32 mm negra',
        'SensiMedical', 'Pieza 5 mL 22G x 32 mm (caja C/100 negra)',
        'Dispositivo médico', 1.65, 100,
        '2504864004', '2030-04-15'::date
      ),
      (
        '7501125100123', 'FMX-503319', 'FC-25100123',
        'Solucion CS PiSA cloruro de sodio 0.9% 500 mL',
        'PiSA', 'Frasco 500 mL',
        'Hidratación', 35.21, 2,
        'P25T706', '2027-10-31'::date
      ),
      (
        '7501125100116', 'FMX-503712', 'FC-25100116',
        'Solucion CS PiSA cloruro de sodio 0.9% 250 mL',
        'PiSA', 'Frasco 250 mL',
        'Hidratación', 30.36, 2,
        'P26F301', '2028-02-29'::date
      ),
      (
        '7506484500515', 'FMX-301135', 'FC-84500515',
        'Cintapore cinta microporosa blanca 1.25 cm x 5 m',
        'Cintapore', 'Rollo 1.25 cm x 5 m blanca',
        'Dispositivo médico', 4.75, 5,
        '250101-1', '2030-01-01'::date
      ),
      (
        '7506484500607', 'FMX-302174', null,
        'Cintapore cinta microporosa blanca 2.5 cm x 9.1 m',
        'Cintapore', 'Rollo 2.5 cm x 9.1 m blanca',
        'Dispositivo médico', 15.21, 4,
        '251101-3', '2030-11-01'::date
      ),
      (
        null, 'FMX-301136', null,
        'Cintapore cinta microporosa piel 2.5 cm x 5 m',
        'Cintapore', 'Rollo 2.5 cm x 5 m color piel',
        'Dispositivo médico', 10.45, 2,
        '251102-2', '2030-11-01'::date
      )
    ) as t(
      ean, sku_fmx, sku_foto, nombre, marca, presentacion,
      categoria, costo, qty, lote, cad
    )
  loop
    v_precio := ceil(r.costo * 1.6);

    select p.id into v_pid
    from public.productos p
    where p.sku in (r.sku_fmx, coalesce(r.sku_foto, ''))
       or (r.ean is not null and p.codigo_barras = r.ean)
    order by case
      when p.sku = r.sku_fmx then 1
      when p.sku = r.sku_foto then 2
      else 3
    end
    limit 1;

    if v_pid is null then
      select f.producto_id into v_pid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', r.nombre,
          'sku', r.sku_fmx,
          'codigo_barras', r.ean,
          'categoria', r.categoria,
          'tipo', 'marca',
          'descripcion', 'Farma MX CAICA1CA108588 · ' || r.sku_fmx || ' · ' || r.nombre,
          'costo', r.costo,
          'precio', v_precio,
          'stock_minimo', 1,
          'activo', true,
          'requiere_receta', false
        ),
        r.qty,
        r.lote,
        r.cad,
        r.costo,
        null::bigint,
        'Farma MX'
      ) f;

      update public.productos set
        marca = r.marca,
        presentacion = r.presentacion,
        forma_farmaceutica = case
          when r.nombre ilike '%jeringa%' then 'Jeringa'
          when r.nombre ilike '%cinta%' then 'Cinta'
          else 'Solucion inyectable'
        end,
        subcategoria = case
          when r.nombre ilike '%jeringa%' then 'Jeringa hipodermica'
          when r.nombre ilike '%cinta%' then 'Cinta microporosa'
          else 'Solucion parenteral'
        end
      where id = v_pid;

      raise notice 'CREADO % id %', r.sku_fmx, v_pid;
    else
      update public.productos set
        sku = coalesce(nullif(sku, ''), r.sku_fmx),
        codigo_barras = coalesce(nullif(codigo_barras, ''), r.ean),
        costo = r.costo,
        precio = case when coalesce(precio, 0) <= 0.01 then v_precio else precio end,
        categoria = r.categoria,
        marca = coalesce(nullif(marca, ''), r.marca),
        presentacion = coalesce(nullif(presentacion, ''), r.presentacion)
      where id = v_pid;

      if r.lote is not null and not exists (
        select 1 from public.lotes l
        where l.producto_id = v_pid and l.numero_lote = r.lote
      ) then
        insert into public.lotes (
          producto_id, numero_lote, cantidad_inicial, cantidad_actual,
          fecha_caducidad, costo_unitario, activo
        ) values (
          v_pid, r.lote, r.qty, r.qty, r.cad, r.costo, true
        );
      end if;

      raise notice 'ACTUALIZADO % id %', r.sku_fmx, v_pid;
    end if;
  end loop;
end $$;

-- Stock = suma de lotes de estos SKU
update public.productos p
set stock = coalesce(t.total, p.stock)
from (
  select l.producto_id, sum(l.cantidad_actual)::int as total
  from public.lotes l
  where coalesce(l.activo, true)
  group by l.producto_id
) t
where p.id = t.producto_id
  and (
    p.sku in (
      'FMX-506383','FMX-506385','FMX-307657','FMX-307658',
      'FMX-506389','FMX-506388','FMX-506386',
      'FMX-503319','FMX-503712',
      'FMX-301135','FMX-302174','FMX-301136',
      'FC-22300881','FC-22300775','FC-25100123','FC-25100116','FC-84500515'
    )
    or p.codigo_barras in (
      '7506022300881','7506022300775','7506022300690','7506022314741',
      '7506022300829','7506022300751','7506022300843',
      '7501125100123','7501125100116','7506484500515','7506484500607'
    )
  );

commit;

select
  p.sku, p.nombre, p.codigo_barras, p.costo, p.precio, p.stock,
  l.numero_lote, l.fecha_caducidad, l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true)
where p.sku like 'FMX-50638%'
   or p.sku in (
     'FMX-307657','FMX-307658','FMX-506389','FMX-506388','FMX-506386',
     'FMX-503319','FMX-503712','FMX-301135','FMX-302174','FMX-301136',
     'FC-22300881','FC-22300775','FC-25100123','FC-25100116'
   )
   or p.codigo_barras in (
     '7506022300881','7506022300775','7506022300690','7506022314741',
     '7506022300829','7506022300751','7506022300843'
   )
order by p.nombre;
