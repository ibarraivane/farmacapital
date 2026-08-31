-- 41 productos del ticket Nadro 1658128647824-01 que Recibir marcó
-- «sin registrar en catálogo». Stock 0. Sin lote ni caducidad (MMAA de la caja).
-- Precio provisional: marca 25% / genérico 60% sobre venta (igual que Recibir).
-- Enlaza renglones pendientes. Idempotente. Pegar en Supabase → SQL Editor → Run.

begin;

do $$
declare
  r record;
  v_pid bigint;
  v_sku text;
  v_creados int := 0;
  v_existian int := 0;
  v_enlazados int := 0;
begin
  for r in
    select * from (values
        ('7501008499412', 'FC-08499412', 'Flanax 660 mg 8 tabletas', 230.00::numeric, 307, 'marca', 'Medicamentos', false),
        ('7501008499092', 'FC-08499092', 'Flanax Nocto 220/25 mg 20 comprimidos', 130.50, 174, 'marca', 'Medicamentos', false),
        ('7501008498866', 'FC-08498866', 'Flanax 550 mg 6 tabletas', 105.00, 140, 'marca', 'Medicamentos', false),
        ('7501070600709', 'FC-70600709', 'Syncol 500/25/15 mg 12 comprimidos', 97.12, 130, 'marca', 'Medicamentos', false),
        ('354312225133', 'FC-12225133', 'Vitacilina ungüento 28 g', 37.57, 51, 'marca', 'Medicamentos', false),
        ('354312225140', 'FC-12225140', 'Vitacilina ungüento 16 g', 25.19, 34, 'marca', 'Medicamentos', false),
        ('7502321440013', 'FC-21440013', 'Buscapina Duo 10/500 mg 10 tabletas', 122.36, 164, 'marca', 'Medicamentos', false),
        ('7501165011649', 'FC-65011649', 'Buscapina 10 mg 24 grageas', 172.04, 230, 'marca', 'Medicamentos', false),
        ('7501349026377', 'FC-49026377', 'Gentamicina 160 mg solución inyectable 2 ml AMSA', 12.71, 32, 'generico', 'Medicamentos', true),
        ('7502216798878', 'FC-16798878', 'Pioglitazona 30 mg 7 tabletas LGEN', 17.76, 45, 'generico', 'Medicamentos', true),
        ('7501019068911', 'FC-19068911', 'Panty protector Saba largo 28', 27.28, 37, 'marca', 'Cuidado personal', false),
        ('7501058715913', 'FC-58715913', 'Picot Plus 9 sobres efervescentes', 46.12, 62, 'marca', 'Medicamentos', false),
        ('7501019039355', 'FC-19039355', 'Parches Saba térmicos 3 pz', 57.41, 77, 'marca', 'Cuidado personal', false),
        ('7501349029613', 'FC-49029613', 'Combedi DX Complejo B / Dexametasona 6 amp AMSA', 55.76, 140, 'generico', 'Medicamentos', true),
        ('4005800631702', 'FC-00631702', 'Eucerin pH5 pomada labial', 85.20, 114, 'marca', 'Cuidado personal', false),
        ('650240053634', 'FC-40053634', 'Alli Triple 50/.25/50/50 mg 6 tabletas', 79.87, 107, 'marca', 'Medicamentos', false),
        ('7501019032424', 'FC-19032424', 'Tampones Saba compactos super', 31.39, 42, 'marca', 'Cuidado personal', false),
        ('7502268541491', 'FC-68541491', 'Electrolife Zero uva 625 ml', 19.36, 26, 'marca', 'Bebidas', false),
        ('75073107', 'FC-75073107', 'Rexona Woman Clinical Classic stick 46 g', 55.68, 75, 'marca', 'Cuidado personal', false),
        ('75073114', 'FC-75073114', 'Rexona Men Clinical Clean stick 46 g', 55.68, 75, 'marca', 'Cuidado personal', false),
        ('7501349013223', 'FC-49013223', 'Deflazacort 30 mg 10 tabletas LGEN', 110.89, 278, 'generico', 'Medicamentos', true),
        ('4005900948670', 'FC-00948670', 'Labello Caring Beauty Red 4.8 g', 79.58, 107, 'marca', 'Cuidado personal', false),
        ('7501054503637', 'FC-54503637', 'Labello Med Protection 4.8 g', 54.87, 74, 'marca', 'Cuidado personal', false),
        ('7501019050473', 'FC-19050473', 'Toalla húmeda Tena adulto EG', 55.00, 74, 'marca', 'Cuidado personal', false),
        ('7502256729917', 'FC-56729917', 'Oxímetro Inhala Care pulso dedo FS10E', 303.80, 406, 'marca', 'Botiquín', false),
        ('3337875784054', 'FC-75784054', 'CeraVe gel limpiador contra imperfecciones 236 ml', 273.91, 366, 'marca', 'Cuidado personal', false),
        ('7501300450227', 'FC-00450227', 'Bactrim 200/40 mg suspensión 100 ml', 188.44, 252, 'marca', 'Medicamentos', true),
        ('7501349028234', 'FC-49028234', 'Omeprazol 40 mg solución inyectable ampolleta LGEN', 29.06, 73, 'generico', 'Medicamentos', true),
        ('7501300450210', 'FC-00450210', 'Bactrim F 800/160 mg 15 tabletas', 331.87, 443, 'marca', 'Medicamentos', true),
        ('7501349022768', 'FC-49022768', 'Cefalotina 1 g solución inyectable FA 5 ml LGEN', 56.28, 141, 'generico', 'Medicamentos', true),
        ('7501125195105', 'FC-25195105', 'Cefuroxima 750 mg FA + ampolleta 5 ml', 42.56, 107, 'generico', 'Medicamentos', true),
        ('7502009740442', 'FC-09740442', 'Klarix Claritromicina 250 mg 10 tabletas', 44.88, 113, 'generico', 'Medicamentos', true),
        ('7502227879597', 'FC-27879597', 'Oxitetraciclina 500 mg 16 cápsulas', 70.00, 175, 'generico', 'Medicamentos', true),
        ('7502227870259', 'FC-27870259', 'Roxidolin Doxiciclina 100 mg 10 cápsulas', 21.15, 53, 'generico', 'Medicamentos', true),
        ('7501493888302', 'FC-93888302', 'Doxiciclina 100 mg 10 cápsulas Ken LGEN', 23.86, 60, 'generico', 'Medicamentos', true),
        ('7506442700643', 'FC-42700643', 'Irbesartán + HCTZ 150/12.5 mg 28 tabletas Camber', 91.86, 230, 'generico', 'Medicamentos', true),
        ('7501349022492', 'FC-49022492', 'Irbesartán 150 mg 28 tabletas LGEN', 92.36, 231, 'generico', 'Medicamentos', true),
        ('7502216804708', 'FC-16804708', 'Irbesartán 150 mg frasco 28 tabletas LGEN', 97.42, 244, 'generico', 'Medicamentos', true),
        ('7506442700629', 'FC-42700629', 'Irbesartán 300 mg 28 tabletas LGEN', 59.66, 150, 'generico', 'Medicamentos', true),
        ('7502216792760', 'FC-16792760', 'Omeprazol 20 mg 30 cápsulas LGEN', 16.13, 41, 'generico', 'Medicamentos', true),
        ('7502216792555', 'FC-16792555', 'Omeprazol 20 mg 14 cápsulas LGEN', 9.50, 24, 'generico', 'Medicamentos', true)
    ) as t(ean, sku, nombre, costo, precio, tipo, categoria, receta)
  loop
    v_pid := public.fc_buscar_producto_escaneo(r.ean);
    if v_pid is not null then
      v_existian := v_existian + 1;
    else
      v_sku := r.sku;
      if exists (
        select 1 from public.productos p
        where p.sku = v_sku
          and coalesce(p.codigo_barras, '') <> r.ean
      ) then
        v_sku := 'FC-ND-' || right(r.ean, 8);
      end if;

      insert into public.productos (
        nombre, sku, codigo_barras, categoria, tipo, descripcion,
        costo, precio, stock, stock_minimo, activo, requiere_receta, proveedor
      ) values (
        r.nombre, v_sku, r.ean, r.categoria, r.tipo,
        'Alta Nadro 1658128647824-01 · 2026-08-31 · listo para pistola',
        r.costo, r.precio, 0, 1, true, r.receta, 'Nadro'
      )
      returning id into v_pid;
      v_creados := v_creados + 1;
    end if;
  end loop;

  update public.recepcion_items i
  set
    producto_id = public.fc_buscar_producto_escaneo(i.codigo_escaneado),
    pendiente_alta = false
  where i.pendiente_alta
    and i.producto_id is null
    and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null;

  get diagnostics v_enlazados = row_count;

  raise notice 'Nadro 41: creados=% ya_estaban=% renglones_enlazados=%',
    v_creados, v_existian, v_enlazados;
end
$$;

commit;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 52) as nombre,
  p.costo,
  p.precio,
  p.stock,
  p.tipo
from public.productos p
where p.codigo_barras in (
  '7501008499412',
  '7501008499092',
  '7501008498866',
  '7501070600709',
  '354312225133',
  '354312225140',
  '7502321440013',
  '7501165011649',
  '7501349026377',
  '7502216798878',
  '7501019068911',
  '7501058715913',
  '7501019039355',
  '7501349029613',
  '4005800631702',
  '650240053634',
  '7501019032424',
  '7502268541491',
  '75073107',
  '75073114',
  '7501349013223',
  '4005900948670',
  '7501054503637',
  '7501019050473',
  '7502256729917',
  '3337875784054',
  '7501300450227',
  '7501349028234',
  '7501300450210',
  '7501349022768',
  '7501125195105',
  '7502009740442',
  '7502227879597',
  '7502227870259',
  '7501493888302',
  '7506442700643',
  '7501349022492',
  '7502216804708',
  '7506442700629',
  '7502216792760',
  '7502216792555'
)
order by p.nombre;
