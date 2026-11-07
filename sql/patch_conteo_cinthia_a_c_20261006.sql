-- Conteo físico Cinthia (WhatsApp + fotos de anaquel vs ficha POS).
-- Letras A–C. Pegar TODO en Supabase → SQL Editor → Run.
--
-- Fuente de verdad: lotes. El trigger sincroniza productos.stock.
-- No inventa caducidad. Idempotente: si la suma de lotes ya es el
-- objetivo, no toca.
--
-- No aplica (ya cuadra o hay duda):
--   EQ-AVT201 Alphalock 0.4 mg — sistema 5; fotos 4 + 1 = 5
--   FC-E6B50AC3 Celecoxib 200 mg — sistema 3 y foto de 3 cajas
--     (el caption dijo «Fisco 2»; no bajamos)
--   FC-347A49C7 Amikacina 100 mg/2 ml — sistema 1; la 2.ª caja de la
--     pila es 500 mg (FC-1FEA2FB7), no otra de 100 mg
--
-- Amikacina 500 mg 1 amp: solo sube a 1 si hoy está en 0.

begin;

create temp table _fc_conteo (
  sku text primary key,
  ean text,
  target int not null check (target >= 0),
  nota text not null,
  solo_si_cero boolean not null default false
) on commit drop;

insert into _fc_conteo (sku, ean, target, nota, solo_si_cero) values
  ('FC-BE76D409', '7501349012004', 8,
   'Amcef IM ceftriaxona 1 g/3.5 ml · sistema 9 → físico 8', false),
  ('FC-D210172A', '7501349022874', 2,
   'Ampicilina AMSA 1 g/5 ml · sistema 3 → físico 2', false),
  ('FC-08496701', '7501008496701', 2,
   'Aspirina efervescente C/12 · sistema 1 → físico 2', false),
  ('FC-070839',   '650240070839',  2,
   'Alliviax garganta C/6 · sistema 1 → físico 2', false),
  ('EQ-AMS147',   '7501349014190', 8,
   'Ácido alendrónico AMSA 10 mg C/30 · sistema 7 → físico 8', false),
  ('EQ-AMS458',   null,            3,
   'Ácido alendrónico AMSA 70 mg C/4 · sistema 4 → físico 3', false),
  ('FL-8509810',  '7501088509810', 2,
   'Antiflu-Des pediátrico 30 ml · sistema 1 → físico 2', false),
  ('FC-1FEA2FB7', '7501349021440', 1,
   'Amikacina AMSA 500 mg/2 ml 1 amp · caja vista en el conteo del 100 mg; solo si stock 0',
   true),
  ('FC-369D1689', '7502009746253', 2,
   'Beneventol cefixima 400 mg C/6 · sistema 1 → físico 2', false),
  ('FC-447B30F9', '7501349023987', 1,
   'Budesonida AMSA 0.250 mg/2 ml · sistema 2 → físico 1', false),
  ('EQ-WER038',   '7502240450018', 5,
   'Charyn 3 azitromicina 500 mg C/3 · sistema 6 → físico 5', false);

do $$
declare
  r record;
  v_pid bigint;
  v_sum int;
  v_delta int;
  v_restante int;
  v_lid bigint;
  v_qty int;
  v_take int;
  v_costo numeric;
begin
  for r in
    select * from _fc_conteo order by sku
  loop
    select p.id, p.costo
      into v_pid, v_costo
      from public.productos p
     where p.sku = r.sku
        or (r.ean is not null and p.codigo_barras = r.ean)
     order by case when p.sku = r.sku then 0 else 1 end
     limit 1
     for update;

    if v_pid is null then
      raise exception 'No está % (%)', r.sku, r.nota;
    end if;

    select coalesce(sum(l.cantidad_actual), 0)
      into v_sum
      from public.lotes l
     where l.producto_id = v_pid
       and coalesce(l.activo, true);

    if r.solo_si_cero and v_sum > 0 then
      raise notice 'SKIP %: ya hay % en lotes (no forzar a %)', r.sku, v_sum, r.target;
      continue;
    end if;

    if v_sum = r.target then
      raise notice 'OK %: ya son %', r.sku, r.target;
      continue;
    end if;

    v_delta := r.target - v_sum;

    if v_delta < 0 then
      v_restante := -v_delta;
      while v_restante > 0 loop
        select l.id, coalesce(l.cantidad_actual, 0)
          into v_lid, v_qty
          from public.lotes l
         where l.producto_id = v_pid
           and coalesce(l.activo, true)
           and coalesce(l.cantidad_actual, 0) > 0
         order by l.fecha_caducidad asc nulls last, l.id asc
         limit 1
         for update;

        if v_lid is null then
          raise exception '%: faltan % para bajar a % (lotes vacíos)', r.sku, v_restante, r.target;
        end if;

        v_take := least(v_qty, v_restante);
        update public.lotes
           set cantidad_actual = cantidad_actual - v_take,
               activo = case
                 when cantidad_actual - v_take <= 0 then false
                 else activo
               end
         where id = v_lid;
        v_restante := v_restante - v_take;
      end loop;
    else
      select l.id
        into v_lid
        from public.lotes l
       where l.producto_id = v_pid
         and coalesce(l.activo, true)
       order by coalesce(l.cantidad_actual, 0) desc,
                l.fecha_caducidad desc nulls last,
                l.id desc
       limit 1
       for update;

      if v_lid is null then
        insert into public.lotes (
          producto_id, numero_lote, cantidad_inicial, cantidad_actual,
          fecha_caducidad, costo_unitario, activo
        ) values (
          v_pid, 'INV-CONTEO-20261006', v_delta, v_delta,
          null, v_costo, true
        );
      else
        update public.lotes
           set cantidad_actual = cantidad_actual + v_delta,
               activo = true,
               cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), cantidad_actual + v_delta)
         where id = v_lid;
      end if;
    end if;

    insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
    values (
      v_pid,
      'ajuste',
      r.target,
      'Conteo Cinthia 6-oct-2026: ' || r.nota || '. Lotes ' || v_sum || ' → ' || r.target || '.'
    );
  end loop;
end $$;

select p.sku, p.nombre, p.presentacion, p.concentracion, p.stock,
       c.target, c.nota,
       l.id as lote_id, l.numero_lote, l.cantidad_actual, l.fecha_caducidad, l.activo
  from _fc_conteo c
  join public.productos p
    on p.sku = c.sku
    or (c.ean is not null and p.codigo_barras = c.ean)
  left join public.lotes l on l.producto_id = p.id
 order by p.sku, l.activo desc nulls last, l.id;

commit;
