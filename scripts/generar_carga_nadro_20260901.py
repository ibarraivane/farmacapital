#!/usr/bin/env python3
"""Pedido Nadro 01-09-26 (13 renglones) → catálogo + cola Recibir.

EAN oficiales de iNadro intelligent-search (2026-09-02).
Los 2 jabones líquidos Grisi vienen a 11 dígitos en el portal; se guardan
como UPC-A de 12 (0 + iNadro) para que la pistola dispare (EAN-8/12/13/14).
Sin lote ni MMAA: salen de la caja al escanear.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_recepcion_sql, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_nadro_20260901.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_nadro_20260901.sql"
OUT_ALTA = ROOT / "sql" / "patch_alta_catalogo_nadro_20260901.sql"

FOLIO = "20260901"
PROVEEDOR = "Nadro"
FECHA = "2026-09-01"
TOTAL_TICKET = 848.05


def precio(costo: float, tipo: str) -> int:
    margen = 25 if tipo == "marca" else 60
    return math.ceil(costo / (1 - margen / 100))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


# nombre ticket, qty, subtotal, ean pistola, sku, match, nombre POS, tipo, cat, receta, ya_catalogo
RAW = [
    ("PARCHES ALFA MED ADH 2TAM BCO C", 1, 53.15, "7503014279552", "", "nadro",
     "Parches adhesivos Alfa Med 2 tamaños blanco", "marca", "Botiquín", False, False),
    ("RUMOQUIN N.F. 30 TAB LGEN", 1, 46.94, "7506494600038", "", "nadro",
     "Rumoquin NF 30 tabletas LGEN", "generico", "Medicamentos", False, False),
    ("SH ACOND PANT RIZOS DEF2EN1 100ML", 2, 35.12, "7506309873701", "", "nadro",
     "Pantene Rizos Definidos 2en1 100 ml", "marca", "Cuidado personal", False, False),
    ("ACOND DOVE DERMA CARE H-ALIV400MLN", 1, 56.91, "7506306256026", "", "nadro",
     "Dove Derma Care Hidratación + Alivio acondicionador 400 ml", "marca", "Cuidado personal", False, False),
    ("ACOND SEDAL LISO PERFECTO 300 ML", 1, 38.48, "7506306223134", "", "nadro",
     "Sedal Liso Perfecto acondicionador 300 ml", "marca", "Cuidado personal", False, False),
    ("JBN GRISI CONCHA NACAR 125G", 1, 22.92, "7501022150818", "", "nadro",
     "Jabón Grisi Concha Nácar 125 g", "marca", "Cuidado personal", False, False),
    ("JBN DOVE EXFOLIAC DIARIA135G", 1, 28.00, "7501056371159", "FC-56371159", "catalogo",
     "Jabón Dove Exfoliación diaria 135 g", "marca", "Cuidado personal", False, True),
    ("JBN LIQ ESCUDO BLANCO NEUT 225ML", 1, 28.27, "7501943489165", "FC-43489165", "catalogo",
     "Jabón líquido Escudo blanco neutro 225 ml", "marca", "Cuidado personal", False, True),
    ("JBN GRISI LECHE DE BURRA 125G", 1, 22.96, "7501022150092", "FC-22150092", "catalogo",
     "Jabón Grisi Leche de Burra 125 g", "marca", "Cuidado personal", False, True),
    ("JBN LIQ GRISI CONCHA NACAR 450ML", 1, 55.31, "037836051227", "", "nadro",
     "Jabón líquido Grisi Concha Nácar 450 ml", "marca", "Cuidado personal", False, False),
    ("JBN GRISI NEUTRO 100G", 2, 32.48, "7501022105191", "", "nadro",
     "Jabón Grisi Neutro 100 g", "marca", "Cuidado personal", False, False),
    ("JBN LIQ GRISI NEUTRO 450ML", 1, 55.31, "037836050282", "", "nadro",
     "Jabón líquido Grisi Neutro 450 ml", "marca", "Cuidado personal", False, False),
    ("BLOQ ANTHE UVAIR 50+ FLU INV 40ML", 1, 372.20, "3337875917810", "", "nadro",
     "Anthelios UV Air fluido invisible 50+ 40 ml", "marca", "Cuidado personal", False, False),
]


def rows():
    out = []
    for nombre, qty, sub, ean, sku, match, *_rest in RAW:
        out.append({
            "nombre": nombre,
            "qty": qty,
            "sub": sub,
            "pu": round(sub / qty, 2),
            "ean": ean,
            "sku": sku or sku_de(ean),
            "match": match,
        })
    return out


def altas():
    out = []
    for nombre, qty, sub, ean, sku, match, pos, tipo, cat, receta, ya in RAW:
        pu = round(sub / qty, 2)
        out.append({
            "ean": ean,
            "sku": sku or sku_de(ean),
            "nombre": pos,
            "costo": pu,
            "precio": precio(pu, tipo),
            "tipo": tipo,
            "categoria": cat,
            "receta": receta,
            "ya": ya,
            "snap": nombre,
        })
    return out


def write_alta_sql(path: Path, items: list) -> None:
    values = []
    for i, r in enumerate(items):
        costo = f"{r['costo']:.2f}::numeric" if i == 0 else f"{r['costo']:.2f}"
        values.append(
            "        ({ean}, {sku}, {nombre}, {costo}, {precio}, {tipo}, {cat}, {receta}, {ya})".format(
                ean=sql_str(r["ean"]),
                sku=sql_str(r["sku"]),
                nombre=sql_str(r["nombre"]),
                costo=costo,
                precio=r["precio"],
                tipo=sql_str(r["tipo"]),
                cat=sql_str(r["categoria"]),
                receta="true" if r["receta"] else "false",
                ya="true" if r["ya"] else "false",
            )
        )

    eans = [sql_str(r["ean"]) for r in items]
    body = f"""-- Pedido Nadro {FOLIO} ({FECHA}) — altas + costo de los 13 EAN.
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
{chr(10).join(v + ("," if i < len(values) - 1 else "") for i, v in enumerate(values))}
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
        'Alta Nadro {FOLIO} · {FECHA} · listo para pistola',
        r.costo, r.precio, 0, 1, true, r.receta
      )
      returning id into v_pid;
      v_creados := v_creados + 1;
    end if;
  end loop;

  raise notice 'Nadro {FOLIO} altas: creados=% ya_estaban=% costos_act=%',
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
{chr(10).join("  " + e + ("," if i < len(eans) - 1 else "") for i, e in enumerate(eans))}
)
order by p.nombre;
"""
    path.write_text(body, encoding="utf-8")


def write_unified_sql(path: Path, ticket_rows: list, items: list) -> None:
    """Una sola pasta: altas + cola Recibir. No suma stock."""
    alta_vals = []
    for i, r in enumerate(items):
        costo = f"{r['costo']:.2f}::numeric" if i == 0 else f"{r['costo']:.2f}"
        alta_vals.append(
            "        ({ean}, {sku}, {nombre}, {costo}, {precio}, {tipo}, {cat}, {receta})".format(
                ean=sql_str(r["ean"]),
                sku=sql_str(r["sku"]),
                nombre=sql_str(r["nombre"]),
                costo=costo,
                precio=r["precio"],
                tipo=sql_str(r["tipo"]),
                cat=sql_str(r["categoria"]),
                receta="true" if r["receta"] else "false",
            )
        )

    recv_vals = []
    for i, row in enumerate(ticket_rows):
        costo = f"{row['pu']:.2f}::numeric" if i == 0 else f"{row['pu']:.2f}"
        recv_vals.append(
            f"        ({sql_str(row['ean'])}, {sql_str(row['nombre'])}, {int(row['qty'])}, {costo}, {sql_str(row['sku'])})"
        )

    eans = [sql_str(r["ean"]) for r in items]
    body = f"""-- Pedido Nadro {FOLIO} ({FECHA}) — altas + cola Recibir, una sola pasta.
-- Folio de trabajo {FOLIO} (PDF NADRO 01-09-26; si tienes el folio iNadro, avísame).
-- 10 altas stock 0. 3 ya estaban: solo costo. Ticket en borrador.
-- No suma stock: pistola + MMAA de la caja. No inventar 0000.
-- Idempotente. Pegar en Supabase → SQL Editor → Run.
-- No lo vuelvas a pegar después de escanear: borra el avance de la pistola.

begin;

do $$
declare
  r record;
  v_pid bigint;
  v_sku text;
  v_id bigint;
  v_creados int := 0;
  v_existian int := 0;
begin
  for r in
    select * from (values
{chr(10).join(v + ("," if i < len(alta_vals) - 1 else "") for i, v in enumerate(alta_vals))}
    ) as t(ean, sku, nombre, costo, precio, tipo, categoria, receta)
  loop
    v_pid := public.fc_buscar_producto_escaneo(r.ean);
    if v_pid is not null then
      v_existian := v_existian + 1;
      update public.productos
      set costo = r.costo, updated_at = now()
      where id = v_pid and (costo is distinct from r.costo);
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
        'Alta Nadro {FOLIO} · {FECHA} · listo para pistola',
        r.costo, r.precio, 0, 1, true, r.receta
      );
      v_creados := v_creados + 1;
    end if;
  end loop;

  select id into v_id
  from public.recepciones
  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%nadro%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Nadro {FOLIO} ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values ({sql_str(PROVEEDOR)}, {sql_str(FOLIO)}, {sql_str(FECHA)}, {TOTAL_TICKET:.2f}, 'borrador',
              {sql_str(f"Pedido Nadro {FOLIO} · PDF 01-09-26 · EAN iNadro · cola Recibir; stock al confirmar pistola")})
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
      set total_ticket = {TOTAL_TICKET:.2f}, fecha = {sql_str(FECHA)}, proveedor = {sql_str(PROVEEDOR)}, updated_at = now()
      where id = v_id;
    end if;

    for r in
      select * from (values
{chr(10).join(v + ("," if i < len(recv_vals) - 1 else "") for i, v in enumerate(recv_vals))}
      ) as t(ean, nombre, qty, costo, sku)
    loop
      v_pid := null;
      if r.ean is not null and btrim(r.ean) <> '' then
        v_pid := public.fc_buscar_producto_escaneo(r.ean);
      end if;
      if v_pid is null and r.sku is not null then
        v_pid := public.fc_buscar_producto_escaneo(r.sku);
      end if;

      insert into public.recepcion_items (
        recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
        cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
        origen, confirmado, lote_distinto, lote_id
      ) values (
        v_id, v_pid, nullif(btrim(r.ean), ''), r.nombre, r.qty, null, null, r.costo,
        (v_pid is null), 'pdf', false,
        (v_pid is not null and exists (
          select 1 from public.lotes l
          where l.producto_id = v_pid and coalesce(l.activo, true)
            and coalesce(l.cantidad_actual, 0) > 0
        )),
        null
      );
    end loop;

    raise notice 'Nadro {FOLIO}: altas=% ya=% recepcion id=% — escanear caja por caja',
      v_creados, v_existian, v_id;
  end if;
end $$;

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
"""
    path.write_text(body, encoding="utf-8")


if __name__ == "__main__":
    r = rows()
    a = altas()
    skus = [x["sku"] for x in a]
    assert len(skus) == len(set(skus)), skus
    assert len(RAW) == 13, len(RAW)
    suma = sum(x["sub"] for x in r)
    assert abs(suma - TOTAL_TICKET) < 0.02, (suma, TOTAL_TICKET)

    write_ticket_csv(OUT_TICKET, folio=FOLIO, fecha=FECHA, proveedor=PROVEEDOR, total=TOTAL_TICKET, rows=r)
    write_recepcion_sql(
        ROOT / "sql" / "patch_recepcion_nadro_20260901_corroborar.sql",
        folio=FOLIO,
        proveedor=PROVEEDOR,
        proveedor_ilike="nadro",
        fecha=FECHA,
        total=TOTAL_TICKET,
        notas=f"Pedido Nadro {FOLIO} · PDF 01-09-26 · EAN iNadro · cola Recibir; stock al confirmar pistola",
        rows=r,
    )
    write_alta_sql(OUT_ALTA, a)
    write_unified_sql(OUT_SQL, r, a)
    print(f"csv   {OUT_TICKET}")
    print(f"sql   {OUT_SQL}")
    print(f"alta  {OUT_ALTA}")
    print(report(r, TOTAL_TICKET))
    print("altas", sum(1 for x in a if not x["ya"]), "ya_catalogo", sum(1 for x in a if x["ya"]))
