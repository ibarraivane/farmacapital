-- Pedido Nadro 20260901 (2026-09-01) — altas + costo de los 13 EAN.
-- 10 altas (stock 0). 3 ya estaban: solo se actualiza costo, no el PVP.
-- Sin lote ni caducidad (MMAA de la caja). Idempotente.
-- Pegar en Supabase → SQL Editor → Run. Luego el de Recibir, o usa patch_carga_nadro_20260901.sql.

begin;

do $$
declare
  r record;
  v_pid bigint;
  v_sku text;
  v_creados int := 0;
  v_existian int := 0;
  v_costos int := 0;
begin
  for r in
    select * from (values
        ('7503014279552', 'FC-14279552', 'Parches adhesivos Alfa Med 2 tamaños blanco', 53.15::numeric, 71, 'marca', 'Botiquín', false, false),
        ('7506494600038', 'FC-94600038', 'Rumoquin NF 30 tabletas LGEN', 46.94, 118, 'generico', 'Medicamentos', false, false),
        ('7506309873701', 'FC-09873701', 'Pantene Rizos Definidos 2en1 100 ml', 17.56, 24, 'marca', 'Cuidado personal', false, false),
        ('7506306256026', 'FC-06256026', 'Dove Derma Care Hidratación + Alivio acondicionador 400 ml', 56.91, 76, 'marca', 'Cuidado personal', false, false),
        ('7506306223134', 'FC-06223134', 'Sedal Liso Perfecto acondicionador 300 ml', 38.48, 52, 'marca', 'Cuidado personal', false, false),
        ('7501022150818', 'FC-22150818', 'Jabón Grisi Concha Nácar 125 g', 22.92, 31, 'marca', 'Cuidado personal', false, false),
        ('7501056371159', 'FC-56371159', 'Jabón Dove Exfoliación diaria 135 g', 28.00, 38, 'marca', 'Cuidado personal', false, true),
        ('7501943489165', 'FC-43489165', 'Jabón líquido Escudo blanco neutro 225 ml', 28.27, 38, 'marca', 'Cuidado personal', false, true),
        ('7501022150092', 'FC-22150092', 'Jabón Grisi Leche de Burra 125 g', 22.96, 31, 'marca', 'Cuidado personal', false, true),
        ('037836051227', 'FC-36051227', 'Jabón líquido Grisi Concha Nácar 450 ml', 55.31, 74, 'marca', 'Cuidado personal', false, false),
        ('7501022105191', 'FC-22105191', 'Jabón Grisi Neutro 100 g', 16.24, 22, 'marca', 'Cuidado personal', false, false),
        ('037836050282', 'FC-36050282', 'Jabón líquido Grisi Neutro 450 ml', 55.31, 74, 'marca', 'Cuidado personal', false, false),
        ('3337875917810', 'FC-75917810', 'Anthelios UV Air fluido invisible 50+ 40 ml', 372.20, 497, 'marca', 'Cuidado personal', false, false)
    ) as t(ean, sku, nombre, costo, precio, tipo, categoria, receta, ya)
  loop
    v_pid := public.fc_buscar_producto_escaneo(r.ean);
    if v_pid is not null then
      v_existian := v_existian + 1;
      update public.productos
      set costo = r.costo, updated_at = now()
      where id = v_pid and (costo is distinct from r.costo);
      if found then
        v_costos := v_costos + 1;
      end if;
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
        costo, precio, stock, stock_minimo, activo, requiere_receta
      ) values (
        r.nombre, v_sku, r.ean, r.categoria, r.tipo,
        'Alta Nadro 20260901 · 2026-09-01 · listo para pistola',
        r.costo, r.precio, 0, 1, true, r.receta
      )
      returning id into v_pid;
      v_creados := v_creados + 1;
    end if;
  end loop;

  raise notice 'Nadro 20260901 altas: creados=% ya_estaban=% costos_act=%',
    v_creados, v_existian, v_costos;
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
  '7503014279552',
  '7506494600038',
  '7506309873701',
  '7506306256026',
  '7506306223134',
  '7501022150818',
  '7501056371159',
  '7501943489165',
  '7501022150092',
  '037836051227',
  '7501022105191',
  '037836050282',
  '3337875917810'
)
order by p.nombre;
