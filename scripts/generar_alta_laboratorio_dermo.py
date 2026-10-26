#!/usr/bin/env python3
"""Genera SQL de catálogo dermo a precio de laboratorio (SVR / Alastin / Medik8).

Sustituye la estrategia MePiel / Dermaexpress para estas marcas:
- SVR: stock real + costo de compra + PVP FarmaCapital → anaquel
- Alastin / Medik8: bajo pedido con costo lab y PVP de lista

  python3 scripts/generar_alta_laboratorio_dermo.py
"""
from __future__ import annotations

import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs" / "catalogos"
SQL_DIR = ROOT / "sql" / "alta_laboratorio_dermo_20261025"


def sql_text(v: str | None) -> str:
    if v is None:
        return "null"
    s = str(v).replace("'", "''")
    return f"'{s}'"


def sql_num(v) -> str:
    if v is None or v == "":
        return "null"
    return f"{float(v):.2f}"


def read_csv(path: Path) -> list[dict]:
    with path.open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def write_fuentes() -> None:
    path = ROOT / "sql" / "patch_fuentes_laboratorio_dermo_20261025.sql"
    path.write_text(
        """-- Fuentes de compra a precio directo de laboratorio (dermo).
-- Reemplazan MePiel / Dermaexpress para SVR, Alastin y Medik8.
-- Idempotente.

begin;

insert into public.fuentes_precio (id, nombre, tipo, metodo, notas) values
  ('svr', 'SVR (laboratorio)', 'compra', 'import_archivo',
   'Compra directa SVR. Costo real de factura + PVP FarmaCapital.'),
  ('alastin', 'Alastin (laboratorio)', 'compra', 'import_archivo',
   'Lista Alastin 2026. Costo base c/IVA; descuentos por volumen en notas.'),
  ('medik8', 'Medik8 / Dermatotec', 'compra', 'import_archivo',
   'Lista especialistas Medik8 México 2025 (Dermatotec). Costo = precio especialista c/IVA.')
on conflict (id) do update set
  nombre = excluded.nombre,
  tipo = excluded.tipo,
  metodo = excluded.metodo,
  notas = excluded.notas;

commit;
""",
        encoding="utf-8",
    )


def write_svr(rows: list[dict]) -> None:
    parts = [
        """-- ============================================================================
-- FARMACAPITAL — SVR stock a precio de laboratorio (oct-2026)
-- costo  = precio de compra (factura)
-- precio = SOLO los PVP públicos que dio el dueño (catálogo FarmaCapital)
-- Pasa a anaquel (bajo_pedido = false) con lote S/L si aún no hay piezas.
-- Regenerar: python3 scripts/generar_alta_laboratorio_dermo.py
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

create temporary table _fc_svr_lab (
  ean text primary key,
  sku text not null,
  nombre text not null,
  presentacion text,
  forma text,
  cantidad integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  imagen_url text
) on commit drop;

insert into _fc_svr_lab (ean, sku, nombre, presentacion, forma, cantidad, costo, precio, imagen_url) values
"""
    ]
    tuples = []
    for r in rows:
        tuples.append(
            f"  ({sql_text(r['ean'])}, {sql_text(r['sku'])}, {sql_text(r['nombre'])}, "
            f"{sql_text(r['presentacion'])}, {sql_text(r['forma_farmaceutica'])}, "
            f"{int(r['cantidad'])}, {sql_num(r['costo'])}, {sql_num(r['precio'])}, "
            f"{sql_text(r.get('imagen_url') or '')})"
        )
    parts.append(",\n".join(tuples) + ";\n")
    parts.append(
        """
do $$
declare
  r record;
  v_pid bigint;
  v_lid bigint;
  v_sku text;
begin
  for r in select * from _fc_svr_lab loop
    v_sku := r.sku;
    select p.id into v_pid
      from public.productos p
     where p.codigo_barras = r.ean
     order by p.id
     limit 1;

    if v_pid is null then
      if exists (
        select 1 from public.productos p
         where p.sku = v_sku
           and coalesce(p.codigo_barras, '') <> r.ean
      ) then
        v_sku := 'FC-ND-' || right(r.ean, 8);
      end if;

      select f.producto_id, f.lote_id into v_pid, v_lid
        from public.create_producto_with_lote(
          jsonb_build_object(
            'nombre', r.nombre,
            'sku', v_sku,
            'codigo_barras', r.ean,
            'categoria', 'Cuidado personal',
            'tipo', 'marca',
            'descripcion', 'SVR · compra directa laboratorio · FarmaCapital oct-2026',
            'costo', r.costo,
            'precio', r.precio,
            'stock_minimo', 2,
            'activo', true,
            'requiere_receta', false
          ),
          r.cantidad,
          'S/L',
          null::date,
          r.costo,
          null::bigint
        ) f;
    else
      declare
        v_stock integer;
        v_faltan integer;
      begin
        select coalesce(sum(l.cantidad_actual), 0) into v_stock
          from public.lotes l
         where l.producto_id = v_pid
           and coalesce(l.activo, true);
        v_faltan := r.cantidad - v_stock;
        if v_faltan > 0 then
          select f.lote_id into v_lid
            from public.receive_merchandise_lote(
              v_pid, v_faltan, 'S/L', null::date, r.costo, 'SVR laboratorio', null::bigint
            ) f;
        end if;
      end;
    end if;

    update public.productos set
      nombre = r.nombre,
      marca = 'SVR',
      laboratorio = 'SVR',
      presentacion = r.presentacion,
      forma_farmaceutica = r.forma,
      subcategoria = 'Dermatología',
      categoria = 'Cuidado personal',
      tipo = 'marca',
      requiere_receta = false,
      codigo_barras = r.ean,
      costo = r.costo,
      precio = r.precio,
      stock_minimo = greatest(coalesce(stock_minimo, 0), 2),
      activo = true,
      bajo_pedido = false,
      imagen_url = coalesce(nullif(btrim(r.imagen_url), ''), nullif(btrim(imagen_url), ''))
     where id = v_pid;

    -- Referencia de compra laboratorio (hoy)
    delete from public.producto_precios_referencia
     where producto_id = v_pid
       and fuente = 'svr'
       and origen = 'import_csv'
       and fecha = current_date;

    insert into public.producto_precios_referencia
      (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
    values (
      v_pid, 'svr', 'compra', r.costo, r.ean, 'import_csv',
      'SVR laboratorio · stock FarmaCapital · PVP ' || r.precio::text
    );
  end loop;
end $$;

commit;

select
  p.sku, p.codigo_barras as ean, p.nombre, p.costo, p.precio,
  round((p.precio - p.costo) / nullif(p.precio, 0) * 100, 1) as margen_pct,
  p.stock, p.bajo_pedido, p.activo
from public.productos p
join _fc_svr_lab t on t.ean = p.codigo_barras
order by p.nombre;
"""
    )
    # note: temp table dropped after commit — fix the final select
    sql = "".join(parts).replace(
        """select
  p.sku, p.codigo_barras as ean, p.nombre, p.costo, p.precio,
  round((p.precio - p.costo) / nullif(p.precio, 0) * 100, 1) as margen_pct,
  p.stock, p.bajo_pedido, p.activo
from public.productos p
join _fc_svr_lab t on t.ean = p.codigo_barras
order by p.nombre;
""",
        """select
  p.sku, p.codigo_barras as ean, p.nombre, p.costo, p.precio,
  round((p.precio - p.costo) / nullif(p.precio, 0) * 100, 1) as margen_pct,
  p.stock, p.bajo_pedido, p.activo
from public.productos p
where p.codigo_barras in (
  '3662361002450','3662361000364','3662361002597','3662361003167','3662361004300',
  '3662361003792','3662361001897','3662361003402','3662361000937','3662361000401'
)
order by p.nombre;
""",
    )
    (SQL_DIR / "01_svr_stock.sql").write_text(sql, encoding="utf-8")


def write_alastin(rows: list[dict]) -> None:
    parts = [
        """-- ============================================================================
-- FARMACAPITAL — Alastin precio laboratorio 2026 (bajo pedido / listo para ordenar)
-- costo  = precio al médico (lista con IVA, sin descuento volumen)
-- precio = precio al público sugerido de la lista (por ahora)
-- Regenerar: python3 scripts/generar_alta_laboratorio_dermo.py
-- ============================================================================

begin;

create temporary table _fc_alastin_lab (
  ean text,
  sku text not null,
  nombre text not null,
  presentacion text,
  forma text,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  imagen_url text,
  cabina boolean not null default false,
  costo_sin_iva numeric(12,2)
) on commit drop;

insert into _fc_alastin_lab
  (ean, sku, nombre, presentacion, forma, costo, precio, imagen_url, cabina, costo_sin_iva) values
"""
    ]
    tuples = []
    for r in rows:
        ean = (r.get("ean") or "").strip()
        tuples.append(
            f"  ({sql_text(ean) if ean else 'null'}, {sql_text(r['sku'])}, {sql_text(r['nombre'])}, "
            f"{sql_text(r['presentacion'])}, {sql_text(r['forma_farmaceutica'])}, "
            f"{sql_num(r['costo'])}, {sql_num(r['precio'])}, {sql_text(r.get('imagen_url') or '')}, "
            f"{'true' if r.get('cabina') in ('1', 'true', True) else 'false'}, "
            f"{sql_num(r.get('costo_sin_iva'))})"
        )
    parts.append(",\n".join(tuples) + ";\n")
    parts.append(
        """
-- Altas nuevas
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, forma_farmaceutica, subcategoria,
  imagen_url, bajo_pedido
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then t.sku || '-LAB'
    else t.sku
  end,
  t.ean,
  'Cuidado personal',
  'marca',
  'Alastin laboratorio 2026 · costo = precio médico c/IVA · precio = PVP lista',
  t.costo,
  t.precio,
  0,
  1,
  true,
  false,
  'Alastin',
  'Alastin',
  t.presentacion,
  t.forma,
  'Dermatología',
  nullif(t.imagen_url, ''),
  true
from _fc_alastin_lab t
where not exists (
  select 1 from public.productos p
  where (t.ean is not null and p.codigo_barras = t.ean)
     or (t.ean is null and p.sku = t.sku)
);

-- Actualiza existentes (incluye los que vinieron de Dermaexpress/MePiel)
update public.productos p
   set costo = t.costo,
       precio = t.precio,
       bajo_pedido = case when coalesce(p.stock, 0) > 0 then false else true end,
       activo = true,
       marca = 'Alastin',
       laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'Alastin'),
       presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
       forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), t.forma),
       subcategoria = 'Dermatología',
       categoria = 'Cuidado personal',
       imagen_url = coalesce(nullif(btrim(p.imagen_url), ''), nullif(t.imagen_url, '')),
       nombre = case
         when p.nombre ilike '%alastin%' then p.nombre
         else t.nombre
       end
  from _fc_alastin_lab t
 where (t.ean is not null and p.codigo_barras = t.ean)
    or (t.ean is null and p.sku = t.sku);

delete from public.producto_precios_referencia r
 using public.productos p, _fc_alastin_lab t
 where r.producto_id = p.id
   and r.fuente = 'alastin'
   and r.origen = 'import_csv'
   and r.fecha = current_date
   and (
     (t.ean is not null and p.codigo_barras = t.ean)
     or (t.ean is null and p.sku = t.sku)
   );

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select p.id, 'alastin', 'compra', t.costo, coalesce(t.ean, t.sku), 'import_csv',
       'Alastin 2026 · precio médico c/IVA'
         || coalesce(' · sin IVA ' || t.costo_sin_iva::text, '')
         || ' · PVP público ' || t.precio::text
         || case when t.cabina then ' · cabina' else '' end
         || ' · descuentos volumen: 15%@30k / 20%@60k / 25%@80k / 30%@140k / 35%@200k (sobre sin IVA)'
  from _fc_alastin_lab t
  join public.productos p
    on (t.ean is not null and p.codigo_barras = t.ean)
    or (t.ean is null and p.sku = t.sku);

commit;

select p.sku, p.codigo_barras, p.nombre, p.costo, p.precio, p.bajo_pedido, p.stock
from public.productos p
where p.marca ilike 'alastin'
order by p.nombre;
"""
    )
    (SQL_DIR / "02_alastin_lab.sql").write_text("".join(parts), encoding="utf-8")


def write_medik8(rows: list[dict]) -> None:
    # chunk inserts for editor size
    staging = """-- ============================================================================
-- FARMACAPITAL — Medik8 / Dermatotec lista especialistas 2025
-- costo  = precio venta al médico / especialistas c/IVA
-- precio = RRP / precio al público c/IVA (por ahora)
-- Bajo pedido. Sin EAN en la lista → match por SKU estable.
-- Regenerar: python3 scripts/generar_alta_laboratorio_dermo.py
-- Orden: 03_staging → 03a_filas_* → 03b_aplicar
-- ============================================================================

begin;

create table if not exists public._fc_medik8_stg (
  sku text primary key,
  nombre text not null,
  nombre_lista text,
  descripcion text,
  presentacion text,
  gama text,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null
);

truncate public._fc_medik8_stg;

commit;
"""
    old_stg = SQL_DIR / "00_staging_medik8.sql"
    if old_stg.exists():
        old_stg.unlink()
    (SQL_DIR / "03_staging_medik8.sql").write_text(staging, encoding="utf-8")

    chunk_size = 25
    for i in range(0, len(rows), chunk_size):
        chunk = rows[i : i + chunk_size]
        n = i // chunk_size
        body = [
            f"-- Medik8 filas bloque {n:02d}\nbegin;\n",
            "insert into public._fc_medik8_stg "
            "(sku, nombre, nombre_lista, descripcion, presentacion, gama, costo, precio) values\n",
        ]
        tuples = []
        for r in chunk:
            tuples.append(
                f"  ({sql_text(r['sku'])}, {sql_text(r['nombre'])}, {sql_text(r['nombre_lista'])}, "
                f"{sql_text(r.get('descripcion') or '')}, {sql_text(r.get('presentacion') or '')}, "
                f"{sql_text(r.get('gama') or '')}, {sql_num(r['costo'])}, {sql_num(r['precio_rrp'])})"
            )
        body.append(",\n".join(tuples) + "\non conflict (sku) do update set\n")
        body.append(
            "  nombre = excluded.nombre,\n"
            "  nombre_lista = excluded.nombre_lista,\n"
            "  descripcion = excluded.descripcion,\n"
            "  presentacion = excluded.presentacion,\n"
            "  gama = excluded.gama,\n"
            "  costo = excluded.costo,\n"
            "  precio = excluded.precio;\ncommit;\n"
        )
        (SQL_DIR / f"03a_filas_{n:02d}.sql").write_text("".join(body), encoding="utf-8")

    aplicar = """-- Aplica staging Medik8 → productos + referencias
begin;

do $$
begin
  if to_regclass('public._fc_medik8_stg') is null then
    raise exception 'Falta _fc_medik8_stg. Corre 03_staging_medik8.sql y las filas 03a.';
  end if;
end $$;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, subcategoria, bajo_pedido
)
select
  t.nombre,
  t.sku,
  null,
  'Cuidado personal',
  'marca',
  coalesce(nullif(t.descripcion, ''), 'Medik8 · Dermatotec especialistas 2025')
    || coalesce(' · ' || nullif(t.gama, ''), ''),
  t.costo,
  t.precio,
  0,
  1,
  true,
  false,
  'Medik8',
  'Dermatotec',
  t.presentacion,
  'Dermatología',
  true
from public._fc_medik8_stg t
where not exists (
  select 1 from public.productos p where p.sku = t.sku
);

update public.productos p
   set costo = t.costo,
       precio = t.precio,
       bajo_pedido = case when coalesce(p.stock, 0) > 0 then false else true end,
       activo = true,
       marca = 'Medik8',
       laboratorio = 'Dermatotec',
       presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
       subcategoria = 'Dermatología',
       categoria = 'Cuidado personal',
       descripcion = coalesce(nullif(btrim(p.descripcion), ''), t.descripcion)
  from public._fc_medik8_stg t
 where p.sku = t.sku;

delete from public.producto_precios_referencia r
 using public.productos p, public._fc_medik8_stg t
 where r.producto_id = p.id
   and p.sku = t.sku
   and r.fuente = 'medik8'
   and r.origen = 'import_csv'
   and r.fecha = current_date;

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select p.id, 'medik8', 'compra', t.costo, t.sku, 'import_csv',
       'Medik8 · precio médico/especialistas · PVP público RRP ' || t.precio::text
         || coalesce(' · ' || nullif(t.gama, ''), '')
  from public._fc_medik8_stg t
  join public.productos p on p.sku = t.sku;

drop table if exists public._fc_medik8_stg;

commit;

select count(*) as medik8_productos
from public.productos
where marca ilike 'medik8';
"""
    (SQL_DIR / "03b_aplicar_medik8.sql").write_text(aplicar, encoding="utf-8")


def write_retire_note() -> None:
    # Corre ANTES de cargar lab. Saca de inventario/vitrina lo de listas web.
    old = SQL_DIR / "09_retirar_mepiel_sin_stock.sql"
    if old.exists():
        old.unlink()
    path = SQL_DIR / "00_retirar_mepiel_dermaexpress.sql"
    path.write_text(
        """-- ============================================================================
-- OBLIGATORIO primero: sacar de inventario/vitrina lo cargado desde
-- listas de páginas (MePiel, Dermaexpress). NO toca anaquel con stock > 0.
-- NO toca Birdman / Ewafra. Las altas de laboratorio (SVR/Alastin/Medik8)
-- que siguen vuelven a activar solo lo pedible al lab.
-- ============================================================================

-- Conteo previo (revisar antes del update)
select
  count(*) filter (
    where coalesce(p.stock, 0) = 0
      and (
        exists (
          select 1 from public.producto_precios_referencia r
           where r.producto_id = p.id
             and r.fuente in ('mepiel', 'dermaexpress')
        )
        or coalesce(p.descripcion, '') ~* 'Bajo pedido ·[[:space:]]*(mepiel|dermaexpress|me[[:space:]]*piel)'
        or coalesce(p.descripcion, '') ~* '(^|[[:space:]])(mepiel|dermaexpress)([[:space:]]|$)'
      )
  ) as a_retirar_sin_stock,
  count(*) filter (
    where coalesce(p.stock, 0) > 0
      and (
        exists (
          select 1 from public.producto_precios_referencia r
           where r.producto_id = p.id
             and r.fuente in ('mepiel', 'dermaexpress')
        )
      )
  ) as con_stock_se_conservan
from public.productos p;

begin;

update public.productos p
   set bajo_pedido = false,
       activo = false
 where coalesce(p.stock, 0) = 0
   and (
     exists (
       select 1 from public.producto_precios_referencia r
        where r.producto_id = p.id
          and r.fuente in ('mepiel', 'dermaexpress')
     )
     or coalesce(p.descripcion, '') ~* 'Bajo pedido ·[[:space:]]*(mepiel|dermaexpress|me[[:space:]]*piel)'
   )
   -- No apagar lo que ya quedó marcado como lab (por si se re-corre)
   and not exists (
     select 1 from public.producto_precios_referencia r
      where r.producto_id = p.id
        and r.fuente in ('svr', 'alastin', 'medik8')
   )
   -- Birdman / Ewafra siguen
   and not exists (
     select 1 from public.producto_precios_referencia r
      where r.producto_id = p.id
        and r.fuente in ('birdman', 'ewafra')
   );

commit;

select
  count(*) filter (where coalesce(bajo_pedido, false) and coalesce(activo, false)) as vitrina_activa,
  count(*) filter (where marca ilike 'alastin' and coalesce(activo, false)) as alastin_activos,
  count(*) filter (where marca ilike 'medik8' and coalesce(activo, false)) as medik8_activos,
  count(*) filter (where marca ilike 'svr' and coalesce(activo, false)) as svr_activos
from public.productos;
""",
        encoding="utf-8",
    )


def write_leerme(svr_n: int, alastin_n: int, medik8_n: int) -> None:
    (SQL_DIR / "LEERME.md").write_text(
        f"""# Catálogo dermo a precio de laboratorio (25-oct-2026)

**Regla de precios**
- `costo` = precio de venta al médico / especialista (compra)
- `precio` = precio al público de la lista (por ahora)
- **SVR**: solo los PVP que dio el dueño en el catálogo FarmaCapital + costo de su factura

Se **quita del inventario** lo cargado desde listas de páginas (MePiel / Dermaexpress).
Solo se mantienen / cargan estas listas de laboratorio.

| Archivo | Qué hace | Filas |
|---|---|---|
| `../patch_fuentes_laboratorio_dermo_20261025.sql` | Fuentes `svr`, `alastin`, `medik8` | — |
| `00_retirar_mepiel_dermaexpress.sql` | **Obligatorio**: apaga MePiel/Dermaexpress sin stock | — |
| `01_svr_stock.sql` | SVR anaquel: costo factura + PVP FarmaCapital | {svr_n} |
| `02_alastin_lab.sql` | Alastin: costo = c/IVA médico · precio = PVP sugerido | {alastin_n} |
| `03_staging_medik8.sql` + `03a_filas_*.sql` + `03b_aplicar_medik8.sql` | Medik8: costo = especialistas · precio = RRP | {medik8_n} |

## Orden en Supabase

1. `sql/patch_fuentes_laboratorio_dermo_20261025.sql`
2. `00_retirar_mepiel_dermaexpress.sql` ← primero limpia listas web
3. `01_svr_stock.sql`
4. `02_alastin_lab.sql`
5. `03_staging_medik8.sql` → todos los `03a_filas_*` → `03b_aplicar_medik8.sql`

## CSV fuente

- `docs/catalogos/laboratorio_svr_stock_20261025.csv`
- `docs/catalogos/laboratorio_alastin_2026.csv`
- `docs/catalogos/laboratorio_medik8_especialistas_2025.csv`

Cuando lleguen más listas de laboratorio, agrégalas en `docs/catalogos/` y
extiende `scripts/generar_alta_laboratorio_dermo.py`.

## Notas

- **SVR Topialyse Gel Lavant**: margen ~15% (costo $475.70 → PVP $559).
- **Alastin**: costo = precio con IVA de lista (sin descuento volumen). Si compras $30k+ sin IVA, baja el costo al escalón.
- **Medik8**: sin EAN en PDF; al recibir, escanear y pegar `codigo_barras`.
- Birdman / Ewafra no se tocan.
""",
        encoding="utf-8",
    )


def main() -> None:
    SQL_DIR.mkdir(parents=True, exist_ok=True)
    svr = read_csv(DOCS / "laboratorio_svr_stock_20261025.csv")
    alastin = read_csv(DOCS / "laboratorio_alastin_2026.csv")
    medik8 = read_csv(DOCS / "laboratorio_medik8_especialistas_2025.csv")
    write_fuentes()
    write_svr(svr)
    write_alastin(alastin)
    write_medik8(medik8)
    write_retire_note()
    write_leerme(len(svr), len(alastin), len(medik8))
    print(f"OK SVR={len(svr)} Alastin={len(alastin)} Medik8={len(medik8)} → {SQL_DIR}")


if __name__ == "__main__":
    main()
