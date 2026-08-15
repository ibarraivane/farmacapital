-- Tribedoce — productos faltantes y corrección barcode 50000 Amp
-- Grageas C/30: 7501537164713 → FC-37164713 (alta manual, sin ticket)
-- Compuesto Amp C/3: 7501537163266 → FC-37163266 (ticket FL-080826, qty 2, $54.10 c/u)
-- 50000 Amp C/5: FC-71829601 barcode corregido a 7501537182960

begin;

update public.productos p
set codigo_barras = '7501537182960'
where p.sku = 'FC-71829601' and p.activo = true
  and coalesce(p.codigo_barras, '') <> '7501537182960'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501537182960' and o.id <> p.id
  );

update public.productos set
  nombre = 'Tribedoce 50000 UI Amp C/5',
  marca = 'Bruluart',
  presentacion = 'Amp C/5',
  principio_activo = 'Hidroxocobalamina + Tiamina + Piridoxina',
  concentracion = '50000 UI / 100 mg / 50 mg',
  forma_farmaceutica = 'AMPOLLETA',
  categoria = 'Medicamentos',
  tipo = 'MEDICAMENTO'
where sku = 'FC-71829601' and activo = true;

-- Tribedoce Compuesto grageas C/30
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (
    select 1 from public.productos
    where codigo_barras = '7501537164713' or sku = 'FC-37164713'
  ) then
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Tribedoce Compuesto grageas C/30',
      'sku', 'FC-37164713',
      'codigo_barras', '7501537164713',
      'categoria', 'Medicamentos',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Tribedoce Compuesto grageas C/30 — EAN 7501537164713',
      'costo', 0,
      'precio', 0,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', true
    ),
    0,
    'MAN-FC-37164713',
    NULL::date,
    0,
    null::bigint,
    null::text
  ) f;

  update public.productos set
    marca = 'Bruluart',
    presentacion = 'C/30 grageas',
    principio_activo = 'Diclofenaco + Complejo B (Tiamina, Piridoxina, Cianocobalamina)',
    concentracion = '50/50/1/50 mg',
    forma_farmaceutica = 'GRAGEAS'
  where id = v_pid;
end $$;

-- Tribedoce Compuesto Amp C/3 (ticket FarmaLive)
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (
    select 1 from public.productos
    where codigo_barras = '7501537163266' or sku = 'FC-37163266'
  ) then
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Tribedoce Compuesto Amp C/3',
      'sku', 'FC-37163266',
      'codigo_barras', '7501537163266',
      'categoria', 'Medicamentos',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Tribedoce Compuesto Amp C/3 — Ticket FL-080826 (COMPUESTO 4266C/3)',
      'costo', 54.10,
      'precio', 73.04,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', true
    ),
    2,
    'TK-FL-080826-TRIB-C3',
    NULL::date,
    54.10,
    null::bigint,
    null::text
  ) f;

  update public.productos set
    marca = 'Bruluart',
    presentacion = 'Amp C/3',
    principio_activo = 'Diclofenaco + Complejo B (Tiamina, Piridoxina, Cianocobalamina)',
    concentracion = '75/5/100 mg',
    forma_farmaceutica = 'SOLUCION INYECTABLE'
  where id = v_pid;
end $$;

commit;

select sku, nombre, codigo_barras, presentacion, costo, precio
from public.productos
where sku in ('FC-37164713', 'FC-37163266', 'FC-71829601', 'FC-88947797')
  and activo = true
order by sku;
