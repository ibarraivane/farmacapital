-- FarmaCapital — reseñas propias de producto (23-sep-2026)
-- Pegar en Supabase → SQL Editor → Run.
--
-- No se importan reseñas de Amazon ni de otros sitios: no hay API pública
-- para republicarlas, bajarlas viola esos términos, el texto es de quien lo
-- escribió y el proyecto no monta testimonios ajenos. Aquí solo entran
-- reseñas de un pedido ya entregado (estado completado).
--
-- Toda reseña nace pendiente. El público solo lee las aprobadas.
-- La lista blanca vive también en src/lib/resenasProductoCore.cjs.
-- Receta y medicamento controlado bloquean aunque la categoría esté permitida.
-- Una categoría nueva queda fuera hasta agregarla a mano en los dos lados.

begin;

alter table public.pedidos
  add column if not exists resena_token uuid,
  add column if not exists resena_pedida_at timestamptz;

create unique index if not exists pedidos_resena_token_uidx
  on public.pedidos (resena_token)
  where resena_token is not null;

create table if not exists public.resenas (
  id bigint generated always as identity primary key,
  producto_id bigint not null references public.productos (id),
  pedido_id bigint not null references public.pedidos (id),
  cliente_id bigint references public.clientes (id),
  estrellas smallint not null check (estrellas between 1 and 5),
  comentario text,
  estado text not null default 'pendiente'
    check (estado in ('pendiente', 'aprobada', 'rechazada')),
  created_at timestamptz not null default now(),
  moderada_at timestamptz,
  moderada_por bigint references public.usuarios (id),
  constraint resenas_comentario_len check (comentario is null or char_length(comentario) <= 800),
  constraint resenas_pedido_producto_uidx unique (pedido_id, producto_id)
);

create index if not exists resenas_producto_estado_idx
  on public.resenas (producto_id, estado);
create index if not exists resenas_estado_created_idx
  on public.resenas (estado, created_at desc);

comment on table public.resenas is
  'Reseñas propias del cliente, de un pedido entregado. Nacen pendientes. No vienen de otros sitios.';

alter table public.resenas enable row level security;
alter table public.resenas force row level security;

drop policy if exists resenas_select_aprobadas on public.resenas;
create policy resenas_select_aprobadas
  on public.resenas
  for select
  to anon, authenticated
  using (estado = 'aprobada');

revoke insert, update, delete on public.resenas from anon, authenticated, public;
grant select on public.resenas to anon, authenticated;

-- ── Categoría (misma idea que categoriaVitrina + lista blanca) ──

create or replace function public.fc_norm_cat_resena(raw text)
returns text
language sql
immutable
as $$
  select trim(both from regexp_replace(
    translate(lower(coalesce(raw, '')),
      'áéíóúüñàèìòùäëïöâêîôû',
      'aeiouunaeiouaeioaeiou'),
    '\s+', ' ', 'g'));
$$;

create or replace function public.fc_categoria_canon_resena(raw text)
returns text
language plpgsql
immutable
as $$
declare
  n text := public.fc_norm_cat_resena(raw);
begin
  if n = '' then
    return '';
  end if;
  if n in ('digestivo', 'gastro') then return 'Gastro'; end if;
  if n in ('botiquin', 'curacion', 'material de curacion', 'hospitalario') then return 'Botiquín'; end if;
  if n = 'suplementos' then return 'Suplemento'; end if;
  if n in ('bebes', 'bebe') then return 'Higiene'; end if;
  if n in ('general', 'producto', 'productos') then return 'Otro'; end if;
  if n in ('antibiotico', 'antibioticos') then return 'Antibiótico'; end if;
  if n in ('analgesico', 'analgesicos') then return 'Analgésico'; end if;
  if n = 'hipertension' then return 'Hipertensión'; end if;
  if n in ('hidratacion', 'hidratacion / electrolitos', 'electrolitos') then return 'Hidratación'; end if;
  if n in ('dispositivo medico', 'dispositivo') then return 'Dispositivo médico'; end if;
  if n = 'cuidado personal' then return 'Cuidado personal'; end if;
  if n = 'analgesico' then return 'Analgésico'; end if;
  if n = 'antiinflamatorio' then return 'Antiinflamatorio'; end if;
  if n = 'diabetes' then return 'Diabetes'; end if;
  if n = 'alergia' then return 'Alergia'; end if;
  if n = 'vitaminas' then return 'Vitaminas'; end if;
  if n = 'suplemento' then return 'Suplemento'; end if;
  if n = 'herbolario' then return 'Herbolario'; end if;
  if n = 'cardiovascular' then return 'Cardiovascular'; end if;
  if n = 'hormonales' then return 'Hormonales'; end if;
  if n = 'respiratorio' then return 'Respiratorio'; end if;
  if n = 'higiene' then return 'Higiene'; end if;
  if n = 'bebidas' then return 'Bebidas'; end if;
  if n = 'basicos' then return 'Básicos'; end if;
  if n = 'abarrotes' then return 'Abarrotes'; end if;
  if n = 'minisuper' then return 'Minisuper'; end if;
  if n = 'otro' then return 'Otro'; end if;
  return btrim(raw);
end;
$$;

create or replace function public.fc_texto_categoria_resena(
  p_nombre text, p_marca text, p_forma text, p_principio text, p_presentacion text, p_sub text
) returns text
language sql
immutable
as $$
  select btrim(regexp_replace(regexp_replace(
    public.fc_norm_cat_resena(concat_ws(' ', p_nombre, p_marca, p_forma, p_principio, p_presentacion, p_sub)),
    '[^a-z0-9+/. -]', ' ', 'g'), '\s+', ' ', 'g'));
$$;

create or replace function public.fc_inferir_categoria_resena(p_texto text)
returns text
language plpgsql
immutable
as $$
declare
  v_cat text;
begin
  if p_texto is null or btrim(p_texto) = '' then
    return '';
  end if;
  select r.cat into v_cat
    from (values
      (1,  '\y(electrolit|electrolid|pedialyte|suerox|oralit|voldratol|suero oral|electrolitos)\y', 'Hidratación'),
      (2,  '\y(solucion cs|cloruro de sodio 0\.?9|nacl 0\.?9|hartmann|solucion fisiologica)\y', 'Hidratación'),
      (3,  '\y(gasa|venda|jeringa|algodon|tegaderm|curita|micropore|tela adhesiva|cubrebocas|guante esteril|tensolastic|material de curacion|agua oxigenada|agua destilada)\y', 'Botiquín'),
      (4,  '\y(alcohol etilico|alcohol 70|isodine|yodo|termometro|gotero|cateter|perilla n\d)\y', 'Botiquín'),
      (5,  '\y(omron|glucometro|tensiometro|oximetro|accu-?chek|softclix|monitor de presion)\y', 'Dispositivo médico'),
      (6,  '\y(amoxicilina|ampicilina|azitromicina|ciprofloxacino|levofloxacino|cefalexina|cefaclor|ceftriaxona|claritromicina|doxiciclina|clindamicina|dicloxacilina|penicilina|amikacina|nitrofurantoina|trimetoprima|sulfametoxazol|cefuroxima|cefixima)\y', 'Antibiótico'),
      (7,  '\y(clamoxin|cefalver|cefaroxil|gimalxina|valclan)\y', 'Antibiótico'),
      (8,  '\y(antiflu|desenfriol|next|contac|theraflu|syncol|agrifen|tabcin)\y', 'Respiratorio'),
      (9,  '\y(alka-?seltzer|alka seltzer|sal de uvas)\y', 'Gastro'),
      (10, '\y(ibuprofeno|naproxeno|diclofenaco|nimesulida|piroxicam|celecoxib|ketoprofeno|acemetacina|meloxicam|indometacina|flanax|advil|motrin)\y', 'Antiinflamatorio'),
      (11, '\y(paracetamol|acetaminofen|metamizol|neomelubrina|ketorolaco|tramadol|tempra|tylenol|cafiaspirina)\y', 'Analgésico'),
      (12, '\y(acido acetilsalicilico|acetilsalicilico|aspirina)\y', 'Analgésico'),
      (13, '\y(omeprazol|pantoprazol|esomeprazol|lansoprazol|ranitidina|famotidina|sucralfato|bismuto|estomaquil|loperamida|butilhioscina|butilescopolamina|metoclopramida|ondansetron|dimenhidrinato|buscapina|gaviscon)\y', 'Gastro'),
      (14, '\y(metformina|glibenclamida|insulina|sitagliptina|empagliflozina|dapagliflozina|linagliptina|gliclazida)\y', 'Diabetes'),
      (15, '\y(losartan|enalapril|amlodipino|telmisartan|valsartan|captopril|nifedipino|hidroclorotiazida|metoprolol|atenolol|bisoprolol|irbesartan|candesartan)\y', 'Hipertensión'),
      (16, '\y(atorvastatina|simvastatina|rosuvastatina|pravastatina|clopidogrel|rivaroxaban|warfarina|acenocumarol)\y', 'Cardiovascular'),
      (17, '\y(loratadina|cetirizina|levocetirizina|desloratadina|fexofenadina|clorfenamina|clarityne|claritin|allegra|zyrtec)\y', 'Alergia'),
      (18, '\y(ambroxol|dextrometorfano|bromhexina|guaifenesina|oxolamina|salbutamol|budesonida|montelukast|afrin|broncolin|nasalub|histiacil|bisolvon|antigripal)\y', 'Respiratorio'),
      (19, '\y(levonorgestrel|etinilestradiol|levotiroxina|desogestrel|drospirenona|anticonceptivo)\y', 'Hormonales'),
      (20, '\y(vitamina c|vitamina d|vitamina a|vitamina e|complejo b|acido folico|centrum|aderogyl|redoxon|neurobion|multivitamin)\y', 'Vitaminas'),
      (21, '\y(ensure|pediasure|glucerna|omega 3|proteina whey|suplemento nutricional)\y', 'Suplemento'),
      (22, '\y(ajolotius|arnica|homeopatico|producto homeopatico|producto natural)\y', 'Herbolario'),
      (23, '\y(shampoo|acondicionador|crema dental|pasta dental|enjuague bucal|desodorante|antitranspirante|jabon|protector solar|bloqueador|cerave|crema corporal)\y', 'Higiene'),
      (24, '\y(pantene|sedal|caprice|savile|listerine|colgate|sensodyne|rexona|dove|huggies|toallas humedas)\y', 'Higiene')
    ) as r(ord, pat, cat)
   where p_texto ~ r.pat
   order by r.ord
   limit 1;
  return coalesce(v_cat, '');
end;
$$;

create or replace function public.producto_acepta_resena(
  p_nombre text,
  p_marca text,
  p_forma text,
  p_principio text,
  p_presentacion text,
  p_sub text,
  p_categoria text,
  p_requiere_receta boolean,
  p_controlado boolean,
  p_grupo_controlado text
) returns boolean
language plpgsql
immutable
as $$
declare
  v_texto text;
  v_cat text;
  v_key text;
begin
  if coalesce(p_requiere_receta, false) then
    return false;
  end if;
  if coalesce(p_controlado, false) then
    return false;
  end if;
  if btrim(coalesce(p_grupo_controlado, '')) <> '' then
    return false;
  end if;
  v_texto := public.fc_texto_categoria_resena(p_nombre, p_marca, p_forma, p_principio, p_presentacion, p_sub);
  v_cat := nullif(public.fc_inferir_categoria_resena(v_texto), '');
  if v_cat is null then
    v_cat := nullif(public.fc_categoria_canon_resena(p_categoria), '');
  end if;
  if v_cat is null then
    v_cat := 'Otro';
  end if;
  v_key := public.fc_norm_cat_resena(v_cat);
  return v_key = any (array[
    'cuidado personal', 'dermocosmetico', 'dermocosmetica', 'dermocosmeticos',
    'higiene', 'bebes', 'bebe', 'suplemento', 'suplementos', 'vitaminas',
    'herbolario', 'botiquin', 'curacion', 'dispositivo medico', 'dispositivos'
  ]);
end;
$$;

revoke all on function public.producto_acepta_resena(text, text, text, text, text, text, text, boolean, boolean, text)
  from public, anon, authenticated;

-- ── Alta: solo el dueño del pedido entregado, siempre pendiente ──

create or replace function public.fn_crear_resena(
  p_producto_id bigint,
  p_pedido_id bigint,
  p_estrellas integer,
  p_comentario text default null,
  p_session_token uuid default null,
  p_token_resena uuid default null
) returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_ped public.pedidos%rowtype;
  v_cli bigint;
  v_ok boolean := false;
  v_prod record;
  v_id bigint;
  v_comentario text;
begin
  if p_estrellas is null or p_estrellas < 1 or p_estrellas > 5 then
    return jsonb_build_object('ok', false, 'error', 'estrellas_invalidas');
  end if;
  v_comentario := nullif(btrim(coalesce(p_comentario, '')), '');
  if v_comentario is not null and char_length(v_comentario) > 800 then
    return jsonb_build_object('ok', false, 'error', 'comentario_largo');
  end if;

  select * into v_ped from public.pedidos where id = p_pedido_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'no_autorizado');
  end if;
  if v_ped.estado is distinct from 'completado' then
    return jsonb_build_object('ok', false, 'error', 'pedido_no_entregado');
  end if;

  if p_token_resena is not null and v_ped.resena_token is not null and v_ped.resena_token = p_token_resena then
    v_ok := true;
    v_cli := v_ped.cliente_id;
  elsif p_session_token is not null then
    v_cli := public.fn_validar_token_cliente(p_session_token);
    if v_cli is not null and v_ped.cliente_id = v_cli then
      v_ok := true;
    end if;
  end if;
  if not v_ok then
    return jsonb_build_object('ok', false, 'error', 'no_autorizado');
  end if;

  if not exists (
    select 1 from public.pedido_items i
    where i.pedido_id = p_pedido_id and i.producto_id = p_producto_id
  ) then
    return jsonb_build_object('ok', false, 'error', 'producto_ajeno');
  end if;

  select pr.nombre, pr.marca, pr.forma_farmaceutica, pr.principio_activo,
         pr.presentacion, pr.subcategoria, pr.categoria, pr.requiere_receta,
         pr.controlado, pr.grupo_controlado
    into v_prod
    from public.productos pr
   where pr.id = p_producto_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'producto_ajeno');
  end if;
  if not public.producto_acepta_resena(
    v_prod.nombre, v_prod.marca, v_prod.forma_farmaceutica, v_prod.principio_activo,
    v_prod.presentacion, v_prod.subcategoria, v_prod.categoria,
    v_prod.requiere_receta, v_prod.controlado, v_prod.grupo_controlado
  ) then
    return jsonb_build_object('ok', false, 'error', 'producto_sin_resena');
  end if;

  insert into public.resenas (producto_id, pedido_id, cliente_id, estrellas, comentario, estado)
  values (p_producto_id, p_pedido_id, v_cli, p_estrellas, v_comentario, 'pendiente')
  returning id into v_id;

  return jsonb_build_object('ok', true, 'id', v_id, 'estado', 'pendiente');
exception
  when unique_violation then
    return jsonb_build_object('ok', false, 'error', 'ya_enviada');
end;
$$;

create or replace function public.fn_pedido_para_resena(p_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_ped public.pedidos%rowtype;
  v_items jsonb;
begin
  if p_token is null then
    return jsonb_build_object('ok', false, 'error', 'no_autorizado');
  end if;
  select * into v_ped from public.pedidos where resena_token = p_token;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'no_autorizado');
  end if;
  if v_ped.estado is distinct from 'completado' then
    return jsonb_build_object('ok', false, 'error', 'pedido_no_entregado');
  end if;

  select coalesce(jsonb_agg(row_js order by ord), '[]'::jsonb)
    into v_items
  from (
    select
      jsonb_build_object(
        'producto_id', i.producto_id,
        'nombre', pr.nombre,
        'ya_enviada', exists (
          select 1 from public.resenas r
          where r.pedido_id = v_ped.id and r.producto_id = i.producto_id
        )
      ) as row_js,
      i.id as ord
    from public.pedido_items i
    join public.productos pr on pr.id = i.producto_id
    where i.pedido_id = v_ped.id
      and public.producto_acepta_resena(
        pr.nombre, pr.marca, pr.forma_farmaceutica, pr.principio_activo,
        pr.presentacion, pr.subcategoria, pr.categoria,
        pr.requiere_receta, pr.controlado, pr.grupo_controlado
      )
  ) s;

  return jsonb_build_object('ok', true, 'pedido_id', v_ped.id, 'items', v_items);
end;
$$;

create or replace function public.fn_mis_resenas(p_session_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli bigint;
begin
  v_cli := public.fn_require_cliente(p_session_token);
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'pedido_id', r.pedido_id,
      'producto_id', r.producto_id,
      'estado', r.estado,
      'estrellas', r.estrellas
    ) order by r.created_at desc)
    from public.resenas r
    where r.cliente_id = v_cli
  ), '[]'::jsonb);
end;
$$;

-- ── Moderación: solo admin o gerente ──

create or replace function public.fn_listar_resenas_moderacion(
  p_session_token uuid,
  p_estado text default 'pendiente'
) returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_estado text := coalesce(nullif(btrim(p_estado), ''), 'pendiente');
begin
  perform public.fn_require_admin(p_session_token);
  if v_estado not in ('pendiente', 'aprobada', 'rechazada') then
    v_estado := 'pendiente';
  end if;
  return coalesce((
    select jsonb_agg(row_js order by ord)
    from (
      select jsonb_build_object(
        'id', r.id,
        'producto_id', r.producto_id,
        'nombre', pr.nombre,
        'marca', pr.marca,
        'categoria', pr.categoria,
        'pedido_id', r.pedido_id,
        'estrellas', r.estrellas,
        'comentario', r.comentario,
        'estado', r.estado,
        'created_at', r.created_at
      ) as row_js,
      r.created_at as ord
      from public.resenas r
      join public.productos pr on pr.id = r.producto_id
      where r.estado = v_estado
      order by r.created_at desc
      limit 200
    ) s
  ), '[]'::jsonb);
end;
$$;

create or replace function public.fn_moderar_resena(
  p_session_token uuid,
  p_resena_id bigint,
  p_estado text
) returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_estado text := btrim(coalesce(p_estado, ''));
  v_id bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);
  if v_estado not in ('aprobada', 'rechazada') then
    return jsonb_build_object('ok', false, 'error', 'estado_invalido');
  end if;
  update public.resenas
     set estado = v_estado,
         moderada_at = now(),
         moderada_por = v_actor
   where id = p_resena_id
   returning id into v_id;
  if v_id is null then
    return jsonb_build_object('ok', false, 'error', 'no_encontrada');
  end if;
  return jsonb_build_object('ok', true, 'id', v_id, 'estado', v_estado);
end;
$$;

revoke all on function public.fn_crear_resena(bigint, bigint, integer, text, uuid, uuid) from public;
revoke all on function public.fn_pedido_para_resena(uuid) from public;
revoke all on function public.fn_mis_resenas(uuid) from public;
revoke all on function public.fn_listar_resenas_moderacion(uuid, text) from public;
revoke all on function public.fn_moderar_resena(uuid, bigint, text) from public;

grant execute on function public.fn_crear_resena(bigint, bigint, integer, text, uuid, uuid) to anon, authenticated;
grant execute on function public.fn_pedido_para_resena(uuid) to anon, authenticated;
grant execute on function public.fn_mis_resenas(uuid) to anon, authenticated;
grant execute on function public.fn_listar_resenas_moderacion(uuid, text) to anon, authenticated;
grant execute on function public.fn_moderar_resena(uuid, bigint, text) to anon, authenticated;

create or replace view public.resenas_resumen
with (security_invoker = true) as
select
  producto_id,
  round(avg(estrellas)::numeric, 1) as promedio,
  count(*)::integer as total
from public.resenas
where estado = 'aprobada'
group by producto_id;

grant select on public.resenas_resumen to anon, authenticated;

comment on view public.resenas_resumen is
  'Promedio de reseñas aprobadas. Si un producto no está aquí, la tienda no pinta estrellas.';

commit;
