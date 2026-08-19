-- ============================================================================
-- Equilibrio 440393 · QUI096 / QUI127 / ULT224
--
-- El archivo digital de venta (VICTOR HUGO AGUILAR ZARCO.xlsx) es la fuente
-- de nombres y códigos. El ticket OCR recortó las descripciones y, peor,
-- colgó QUI127 (anticonceptivo C/28, lote 26D006, costo 24.03) en EQ-ULT230
-- (Levonorgestrel 1.5 mg de urgencia) porque el matcher usó la primera
-- palabra "LEVONORGES".
--
-- QUI096 (C/21, 22.72) y QUI127 (C/28, 24.03) NO son el mismo SKU: mismo
-- activo y dosis, distinta presentación (ciclo 21 vs blister 28).
-- ============================================================================

begin;

-- 1) Completar ficha C/21 (el costo 22.72 ya coincidía con el Excel)
update public.productos
   set nombre = 'Levonorgestrel / Etinilestradiol 0.15/0.03 mg C/21',
       marca = coalesce(nullif(marca, ''), 'Quifa'),
       presentacion = 'Caja con 21 tabletas',
       principio_activo = 'Levonorgestrel / Etinilestradiol',
       denominacion_generica = coalesce(nullif(denominacion_generica, ''),
                                        'Levonorgestrel, Etinilestradiol'),
       concentracion = '0.15 mg / 0.03 mg',
       forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
       descripcion = 'Ticket Equilibrio 440393 · QUI096 · Levonorgestrel / Etinilestradiol 0.15/0.03 mg C/21 · EAN 7501644707506'
 where sku = 'EQ-QUI096';

-- 2) Completar ficha Telmisartán HCTZ (nombre recortado HIDROCLO)
update public.productos
   set nombre = 'Telmisartán / Hidroclorotiazida 80/12.5 mg C/14',
       marca = coalesce(nullif(marca, ''), 'Ultra'),
       presentacion = 'Caja con 14 tabletas',
       principio_activo = 'Telmisartán / Hidroclorotiazida',
       denominacion_generica = coalesce(nullif(denominacion_generica, ''),
                                        'Telmisartán, Hidroclorotiazida'),
       concentracion = '80 mg / 12.5 mg',
       forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
       descripcion = 'Ticket Equilibrio 440393 · ULT224 · Telmisartán / Hidroclorotiazida 80/12.5 mg C/14 · EAN 7502216803244'
 where sku = 'EQ-ULT224';

-- 3) Alta C/28 + mover el lote que quedó en el anticonceptivo de urgencia
do $$
declare
  v_pid bigint;
  v_lote bigint;
  v_ult bigint;
begin
  select id into v_ult from public.productos where sku = 'EQ-ULT230' limit 1;

  select id into v_pid from public.productos where sku = 'EQ-QUI127' limit 1;

  if v_pid is null then
    insert into public.productos (
      nombre, sku, categoria, tipo, descripcion,
      costo, precio, stock, stock_minimo, activo, requiere_receta,
      marca, presentacion, principio_activo, denominacion_generica,
      concentracion, forma_farmaceutica
    ) values (
      'Levonorgestrel / Etinilestradiol 0.15/0.03 mg C/28',
      'EQ-QUI127',
      'Medicamentos',
      'generico',
      'Ticket Equilibrio 440393 · QUI127 · Levonorgestrel / Etinilestradiol 0.15/0.03 mg C/28 · alta 2026-08-18 (el lote 26D006 había quedado en EQ-ULT230)',
      24.03,
      39,
      0,
      1,
      true,
      false,
      'Quifa',
      'Caja con 28 tabletas',
      'Levonorgestrel / Etinilestradiol',
      'Levonorgestrel, Etinilestradiol',
      '0.15 mg / 0.03 mg',
      'Tableta'
    )
    returning id into v_pid;
  else
    update public.productos
       set nombre = 'Levonorgestrel / Etinilestradiol 0.15/0.03 mg C/28',
           marca = coalesce(nullif(marca, ''), 'Quifa'),
           presentacion = 'Caja con 28 tabletas',
           principio_activo = 'Levonorgestrel / Etinilestradiol',
           denominacion_generica = coalesce(nullif(denominacion_generica, ''),
                                            'Levonorgestrel, Etinilestradiol'),
           concentracion = '0.15 mg / 0.03 mg',
           forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tableta'),
           costo = 24.03,
           precio = case when coalesce(precio, 0) = 0 then 39 else precio end
     where id = v_pid;
  end if;

  -- Lote 26D006: costo 24.03, cad 2028-03-31. Vive en ULT230 por el matcher.
  select id into v_lote
    from public.lotes
   where numero_lote = '26D006'
     and costo_unitario = 24.03
     and (
       producto_id = v_ult
       or producto_id = v_pid
     )
   order by case when producto_id = v_pid then 0 else 1 end
   limit 1;

  if v_lote is not null then
    update public.lotes
       set producto_id = v_pid
     where id = v_lote
       and producto_id is distinct from v_pid;
  elsif not exists (
    select 1 from public.lotes
     where producto_id = v_pid and numero_lote = '26D006'
  ) then
    insert into public.lotes (
      producto_id, numero_lote, fecha_caducidad,
      cantidad_inicial, cantidad_actual, costo_unitario, activo
    ) values (
      v_pid, '26D006', '2028-03-31'::date, 1, 1, 24.03, true
    );
  end if;

  raise notice 'EQ-QUI127 id % · lote 26D006 movido desde EQ-ULT230', v_pid;
end $$;

commit;

select p.sku, p.nombre, p.costo, p.precio, p.stock,
       l.numero_lote, l.fecha_caducidad, l.cantidad_actual, l.costo_unitario
  from public.productos p
  left join public.lotes l
    on l.producto_id = p.id and coalesce(l.activo, true)
 where p.sku in ('EQ-QUI096', 'EQ-QUI127', 'EQ-ULT230', 'EQ-ULT224')
 order by p.sku, l.numero_lote;
