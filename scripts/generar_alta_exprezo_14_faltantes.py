#!/usr/bin/env python3
"""Alta catálogo: 14 renglones Exprezo 1279718 que Recibir marcó sin registrar.

11 con EAN público. 3 packs sin código (no inventar barra): se crean y
se enlazan por nombre para que dejen el aviso rojo; se tocan a mano.
Stock 0. Sin lote ni MMAA.
"""
from __future__ import annotations

import math
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "sql" / "patch_alta_catalogo_exprezo_14_20260831.sql"


def precio(costo: float, tipo: str) -> int:
    margen = 25 if tipo == "marca" else 60
    return math.ceil(costo / (1 - margen / 100))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


# ean, nombre POS, costo, tipo, categoria, receta
CON_EAN = [
    ("7506306246652", "Jabón Dove blanco 90 g", 18.63, "marca", "Cuidado personal", False),
    ("650240013805", "Alliviax desinflamatorio 550 mg 10 tabletas", 100.50, "marca", "Medicamentos", False),
    ("7506205809248", "Enfagrow Premium etapa 3 lata 800 g", 306.00, "marca", "Bebés", False),
    ("7501058651129", "Gerber Junior pouch frutas mixtas 95 g", 12.79, "marca", "Bebés", False),
    ("0608875005092", "Heinz pouch papilla manzana 113 g", 14.40, "marca", "Bebés", False),
    ("7506475102520", "Gerber Etapa 2 comida casera res 100 g", 10.68, "marca", "Bebés", False),
    ("7506475102537", "Gerber Etapa 2 comida casera pollo 100 g", 10.68, "marca", "Bebés", False),
    ("7506475102476", "Gerber Etapa 2 durazno 100 g", 10.68, "marca", "Bebés", False),
    ("7506475102452", "Gerber Etapa 2 pera 100 g", 10.68, "marca", "Bebés", False),
    ("7506475102469", "Gerber Etapa 2 mango 100 g", 10.68, "marca", "Bebés", False),
    ("7506475102421", "Gerber Etapa 2 manzana 100 g", 10.68, "marca", "Bebés", False),
]

# sku, nombre POS, nombre_snapshot ticket, costo
PACKS = [
    ("FC-EXP-PALM8", "Jabón Palmolive Neutro Balance 100 g 8 pack",
     "Jabón Palmolive Naturals Neutro Balance 100 g 8 Pack", 114.40),
    ("FC-EXP-HS24", "Tira Head & Shoulders 24 sobres 10 ml",
     "Tira Shampoo Head & Shoulders 24 sachets 10 ml", 51.21),
    ("FC-EXP-OPT48", "Pack 48 sobres Palmolive Optims 10 ml",
     "Pack 48 sobres Shampoo Palmolive Optims 10 ml", 75.30),
]


def main() -> None:
    assert len(CON_EAN) == 11
    assert len(PACKS) == 3
    skus = [sku_de(e) for e, *_ in CON_EAN] + [s for s, *_ in PACKS]
    assert len(skus) == len(set(skus)), skus

    ean_vals = []
    for i, (ean, nombre, costo, tipo, cat, receta) in enumerate(CON_EAN):
        costo_sql = f"{costo:.2f}::numeric" if i == 0 else f"{costo:.2f}"
        ean_vals.append(
            "        ({ean}, {sku}, {nombre}, {costo}, {precio}, {tipo}, {cat}, {receta})".format(
                ean=sql_str(ean),
                sku=sql_str(sku_de(ean)),
                nombre=sql_str(nombre),
                costo=costo_sql,
                precio=precio(costo, tipo),
                tipo=sql_str(tipo),
                cat=sql_str(cat),
                receta="true" if receta else "false",
            )
        )

    pack_vals = []
    for i, (sku, nombre, snap, costo) in enumerate(PACKS):
        costo_sql = f"{costo:.2f}::numeric" if i == 0 else f"{costo:.2f}"
        pack_vals.append(
            "        ({sku}, {nombre}, {snap}, {costo}, {precio})".format(
                sku=sql_str(sku),
                nombre=sql_str(nombre),
                snap=sql_str(snap),
                costo=costo_sql,
                precio=precio(costo, "marca"),
            )
        )

    ean_list = ",\n".join(f"  {sql_str(e)}" for e, *_ in CON_EAN)
    sku_list = ",\n".join(f"  {sql_str(s)}" for s, *_ in PACKS)

    body = f"""-- 14 renglones Exprezo 1279718 que Recibir marcó sin catálogo.
-- 11 con EAN. 3 packs sin barra (no se inventa código): se tocan a mano.
-- Stock 0. Sin lote ni caducidad. Idempotente. Supabase → SQL Editor → Run.
-- No vuelvas a pegar patch_recepcion_exprezo_*: borra lo ya escaneado.

begin;

do $$
declare
  r record;
  v_pid bigint;
  v_sku text;
  v_creados int := 0;
  v_existian int := 0;
  v_enlazados int := 0;
  n int;
begin
  for r in
    select * from (values
{chr(10).join(v + ("," if i < len(ean_vals) - 1 else "") for i, v in enumerate(ean_vals))}
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
        v_sku := 'FC-EX-' || right(r.ean, 8);
      end if;
      insert into public.productos (
        nombre, sku, codigo_barras, categoria, tipo, descripcion,
        costo, precio, stock, stock_minimo, activo, requiere_receta
      ) values (
        r.nombre, v_sku, r.ean, r.categoria, r.tipo,
        'Alta Exprezo 1279718 · 2026-08-31 · listo para pistola',
        r.costo, r.precio, 0, 1, true, r.receta
      )
      returning id into v_pid;
      v_creados := v_creados + 1;
    end if;
  end loop;

  for r in
    select * from (values
{chr(10).join(v + ("," if i < len(pack_vals) - 1 else "") for i, v in enumerate(pack_vals))}
    ) as t(sku, nombre, snap, costo, precio)
  loop
    select id into v_pid from public.productos where sku = r.sku limit 1;
    if v_pid is not null then
      v_existian := v_existian + 1;
    else
      insert into public.productos (
        nombre, sku, codigo_barras, categoria, tipo, descripcion,
        costo, precio, stock, stock_minimo, activo, requiere_receta
      ) values (
        r.nombre, r.sku, null, 'Cuidado personal', 'marca',
        'Alta Exprezo 1279718 · pack sin EAN de caja · tocar renglón',
        r.costo, r.precio, 0, 1, true, false
      )
      returning id into v_pid;
      v_creados := v_creados + 1;
    end if;

    update public.recepcion_items i
    set producto_id = v_pid, pendiente_alta = false
    from public.recepciones rec
    where i.recepcion_id = rec.id
      and rec.folio = '1279718'
      and coalesce(rec.proveedor, '') ilike '%exprezo%'
      and i.pendiente_alta
      and i.producto_id is null
      and coalesce(nullif(btrim(i.codigo_escaneado), ''), '') = ''
      and i.nombre_snapshot = r.snap;
    get diagnostics n = row_count;
    v_enlazados := v_enlazados + n;
  end loop;

  update public.recepcion_items i
  set
    producto_id = public.fc_buscar_producto_escaneo(i.codigo_escaneado),
    pendiente_alta = false
  where i.pendiente_alta
    and i.producto_id is null
    and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null;
  get diagnostics n = row_count;
  v_enlazados := v_enlazados + n;

  raise notice 'Exprezo 14: creados=% ya_estaban=% renglones_enlazados=%',
    v_creados, v_existian, v_enlazados;
end
$$;

commit;

select sku, codigo_barras as ean, left(nombre, 52) as nombre, costo, precio, stock
from public.productos
where codigo_barras in (
{ean_list}
)
   or sku in (
{sku_list}
)
order by nombre;
"""
    OUT.write_text(body, encoding="utf-8")
    print(f"sql  {OUT}")
    print(f"con_ean {len(CON_EAN)} packs {len(PACKS)}")


if __name__ == "__main__":
    main()
