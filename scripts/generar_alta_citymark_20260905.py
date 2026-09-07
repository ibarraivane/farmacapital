#!/usr/bin/env python3
"""City Mark 20260905: altas de catálogo + relink Recibir + stock huérfano.

Las 71 «sin registrar» del ticket. Nombres de mostrador (marca + producto),
no el código interno. Stock 0; piezas al escanear + MMAA.
No borra renglones ya escaneados.
"""
from __future__ import annotations

import csv
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "sql" / "generated" / "ticket_citymark_20260905.csv"
OBF = ROOT / "sql" / "generated" / "citymark_obf_lookup.json"
OUT_SQL = ROOT / "sql" / "patch_alta_catalogo_citymark_20260905.sql"
OUT_NOMBRES = ROOT / "sql" / "patch_nombres_mostrador_citymark_20260905.sql"

FOLIO = "20260905"
PROVEEDOR = "City Mark"
FECHA = "2026-09-05"
TOTAL = 5007.41

# ean → (nombre mostrador, marca, presentacion, subcat, forma)
FICHA = {
    "7891010245160": ("Neutrogena agua micelar 200 ml", "Neutrogena", "200 ml", "Facial", "Solución"),
    "761318132592": ("Revlon peines Salon Carbon 2 pzas", "Revlon", "2 pzas", "Cabello", "Peine"),
    "761318128335": ("Revlon cepillo paleta RV2833LA", "Revlon", "1 pza", "Cabello", "Cepillo"),
    "761318020639": ("Revlon cepillo acolchado goma RV2063LA", "Revlon", "1 pza", "Cabello", "Cepillo"),
    "7502221187575": ("Brut Deep Blue 48 h spray 150 ml", "Brut", "150 ml", "Desodorante", "Spray"),
    "7506306215511": ("Savile sábila y naranja spray 150 ml", "Savile", "150 ml", "Desodorante", "Spray"),
    "7506306215528": ("Savile bicarbonato y limón spray 150 ml", "Savile", "150 ml", "Desodorante", "Spray"),
    "7506306209763": ("Savile manzanilla spray 150 ml", "Savile", "150 ml", "Desodorante", "Spray"),
    "75065102": ("Savile manzanilla stick 45 g", "Savile", "45 g", "Desodorante", "Stick"),
    "75068639": ("Savile bicarbonato y limón stick 45 g", "Savile", "45 g", "Desodorante", "Stick"),
    "75068622": ("Savile bicarbonato y limón roll-on 45 ml", "Savile", "45 ml", "Desodorante", "Roll-on"),
    "75064891": ("Savile agua de rosas roll-on 45 ml", "Savile", "45 ml", "Desodorante", "Roll-on"),
    "7501082736021": ("Nuvel Aclara woman spray 150 ml", "Nuvel", "150 ml", "Desodorante", "Spray"),
    "7506309864839": ("Gillette Endurance Cool spray 150 ml", "Gillette", "150 ml", "Desodorante", "Spray"),
    "7501027286000": ("Obao Ocean roll-on 65 g", "Obao", "65 g", "Desodorante", "Roll-on"),
    "7506309864822": ("Gillette Endurance Arctic Ice spray 150 ml", "Gillette", "150 ml", "Desodorante", "Spray"),
    "7501027286017": ("Obao Clásico roll-on 65 g", "Obao", "65 g", "Desodorante", "Roll-on"),
    "7501082731071": ("Nuvel Tropical woman spray 170 ml", "Nuvel", "170 ml", "Desodorante", "Spray"),
    "7506306251847": ("Axe Black Remix spray 210 ml", "Axe", "210 ml", "Desodorante", "Spray"),
    "7509546029139": ("Speed Stick 24/7 Cool Night stick 85 g", "Speed Stick", "85 g", "Desodorante", "Stick"),
    "7500435141796": ("Old Spice Mariner Professional spray 150 ml", "Old Spice", "150 ml", "Desodorante", "Spray"),
    "7509552906158": ("Obao Fresquísima roll-on 65 g", "Obao", "65 g", "Desodorante", "Roll-on"),
    "7509552844825": ("Obao Naturals Coco roll-on 65 g", "Obao", "65 g", "Desodorante", "Roll-on"),
    "7509546071275": ("Lady Speed Stick Powder Fresh spray 60 g", "Lady Speed Stick", "60 g", "Desodorante", "Spray"),
    "78924338": ("Rexona Woman Powder roll-on 53 g", "Rexona", "53 g", "Desodorante", "Roll-on"),
    "7506306226852": ("Axe Anarchy for Her spray 150 ml", "Axe", "150 ml", "Desodorante", "Spray"),
    "7500435129367": ("Secret pH Balanced stick gel 45 g", "Secret", "45 g", "Desodorante", "Stick"),
    "7506306209862": ("Axe Anarchy Fresh Love for Her spray 150 ml", "Axe", "150 ml", "Desodorante", "Spray"),
    "7791293025919": ("Axe Excite seco spray 152 ml", "Axe", "152 ml", "Desodorante", "Spray"),
    "7509546057545": ("Lady Speed Stick Pro 5en1 stick 45 g", "Lady Speed Stick", "45 g", "Desodorante", "Stick"),
    "7509546015514": ("Lady Speed Stick Derma Defense Fresh 45 g", "Lady Speed Stick", "45 g", "Desodorante", "Stick"),
    "7506306209855": ("Axe Anarchy Floral 48 h spray 150 ml", "Axe", "150 ml", "Desodorante", "Spray"),
    "7509546029153": ("Lady Speed Stick Floral Fresh gel 65 g", "Lady Speed Stick", "65 g", "Desodorante", "Gel"),
    "78924345": ("Rexona Woman Bamboo roll-on 50 ml", "Rexona", "50 ml", "Desodorante", "Roll-on"),
    "7509546060477": ("Lady Speed Stick Powder Fresh roll-on 50 ml", "Lady Speed Stick", "50 ml", "Desodorante", "Roll-on"),
    "7506339349146": ("Old Spice Wolfthorn spray 150 ml", "Old Spice", "150 ml", "Desodorante", "Spray"),
    "7501027250612": ("Obao para ella roll-on 65 g", "Obao", "65 g", "Desodorante", "Roll-on"),
    "7501082790481": ("Nuvel toallitas desmaquillantes hidratantes C/25", "Nuvel", "25 pzas", "Facial", "Toallitas"),
    "7502221012303": ("Claris toallitas desmaquillantes aloe C/40", "Claris", "40 pzas", "Facial", "Toallitas"),
    "7509546029825": ("Neutro Balance roll-on 65 ml", "Neutro Balance", "65 ml", "Desodorante", "Roll-on"),
    "7501022107201": ("Conse shampoo antiolores para perro 500 ml", "Conse", "500 ml", "Mascotas", "Shampoo"),
    "7509546007083": ("Colgate Total 12 Clean Mint 50 ml", "Colgate", "50 ml", "Higiene bucal", "Pasta dental"),
    "037836007279": ("Conse Guau Aloe Vera shampoo para perro 400 ml", "Conse", "400 ml", "Mascotas", "Shampoo"),
    "037836084508": ("Grisi Agrade avena shampoo para perro 400 ml", "Grisi", "400 ml", "Mascotas", "Shampoo"),
    "759684900204": ("Jaloma agua de rosas tónico facial 250 ml", "Jaloma", "250 ml", "Facial", "Tónico"),
    "7509546651743": ("Stefano Triumph desodorante 159 ml", "Stefano", "159 ml", "Desodorante", "Spray"),
    "7501056330378": ("Pond's Bio-Hydra Dual loción limpiadora 200 ml", "Pond's", "200 ml", "Facial", "Loción"),
    "759684900259": ("Jaloma agua de arroz spray 250 ml", "Jaloma", "250 ml", "Facial", "Spray"),
    "814266022627": ("Honey Keeper Kids lavanda 3en1 414 ml", "Honey Keeper", "414 ml", "Infantil", "Shampoo"),
    "7509546694702": ("Stefano Next Level spray 150 ml", "Stefano", "150 ml", "Desodorante", "Spray"),
    "7509546073774": ("Stefano Spaz spray 113 g", "Stefano", "113 g", "Desodorante", "Spray"),
    "7509546078434": ("Stefano Alpine Men spray 113 g", "Stefano", "113 g", "Desodorante", "Spray"),
    "7506267917516": ("Honey Keeper Kids avena crema 414 ml", "Honey Keeper", "414 ml", "Infantil", "Crema"),
    "7509546655055": ("Caprice Volume Control mousse 200 g", "Caprice", "200 g", "Cabello", "Mousse"),
    "3600542478359": ("Garnier SkinActive jelly carbón agua micelar 400 ml", "Garnier", "400 ml", "Facial", "Solución"),
    "7501035911024": ("Colgate Max Fresh Pepper 125 ml", "Colgate", "125 ml", "Higiene bucal", "Pasta dental"),
    "7509546068909": ("Colgate Triple Acción extra blanco 50 ml", "Colgate", "50 ml", "Higiene bucal", "Pasta dental"),
    "7506425629442": ("Escudo solución antiséptica para manos spray 200 ml", "Escudo", "200 ml", "Higiene", "Spray"),
    "7702018913954": ("Gillette Clear Wave 3× roll-on 60 g", "Gillette", "60 g", "Desodorante", "Roll-on"),
    "7500435168991": ("Herbal Essences Extra Control mousse 200 g", "Herbal Essences", "200 g", "Cabello", "Mousse"),
    "7509546698137": ("Colgate Luminous White Coco Brillante 66 ml", "Colgate", "66 ml", "Higiene bucal", "Pasta dental"),
    "78926523": ("Rexona Woman Antibacterial Emotional roll-on 50 g", "Rexona", "50 g", "Desodorante", "Roll-on"),
    "7509546674018": ("Colgate Luminous White Carbón 66 ml", "Colgate", "66 ml", "Higiene bucal", "Pasta dental"),
    "7509546000350": ("Colgate Triple Acción 150 ml", "Colgate", "150 ml", "Higiene bucal", "Pasta dental"),
    "7509546654997": ("Caprice Final Touch mousse 200 g", "Caprice", "200 g", "Cabello", "Mousse"),
    "814266022610": ("Honey Keeper Kids miel shampoo 414 ml", "Honey Keeper", "414 ml", "Infantil", "Shampoo"),
    "7500435169035": ("Herbal Essences Rizos mousse 200 g", "Herbal Essences", "200 g", "Cabello", "Mousse"),
    "7891024028827": ("Colgate Total 12 Clean enjuague 60 ml", "Colgate", "60 ml", "Higiene bucal", "Enjuague"),
    "3616303440534": ("Adidas Control spray 150 ml", "Adidas", "150 ml", "Desodorante", "Spray"),
    "7506267923654": ("Honey Keeper gel manzanilla y miel 200 ml", "Honey Keeper", "200 ml", "Cabello", "Gel"),
    "7896015592837": ("Sensodyne Gentle Care extra suave 3 pzas", "Sensodyne", "3 pzas", "Higiene bucal", "Cepillo"),
    "3616303441173": ("Adidas Dynamic Pulse spray 150 ml", "Adidas", "150 ml", "Desodorante", "Spray"),
    "759684900280": ("Jaloma agua de rosas spray 130 ml", "Jaloma", "130 ml", "Facial", "Spray"),
    "7891024027363": ("Colgate Plax Ice Infinity enjuague 60 ml", "Colgate", "60 ml", "Higiene bucal", "Enjuague"),
    "3616303842550": ("Adidas Fresh Endurance spray 150 ml", "Adidas", "150 ml", "Desodorante", "Spray"),
    "3616303441302": ("Adidas Team Force spray 150 ml", "Adidas", "150 ml", "Desodorante", "Spray"),
    "3616303842420": ("Adidas Power Booster spray 150 ml", "Adidas", "150 ml", "Desodorante", "Spray"),
    "7891024183182": ("Colgate hilo dental encerado 25 m", "Colgate", "25 m", "Higiene bucal", "Hilo dental"),
    "070942302463": ("GUM Go-Betweens microfino C/6", "GUM", "6 pzas", "Higiene bucal", "Cepillo interdental"),
    "759684313295": ("Jaloma atomizador Mertodol blanco 60 ml", "Jaloma", "60 ml", "Botiquín", "Atomizador"),
    "75075996": ("Rexona Happy Morning 48 h roll-on 50 ml", "Rexona", "50 ml", "Desodorante", "Roll-on"),
    "7509552780956": ("Obao Men Tato Rebel roll-on 65 g", "Obao", "65 g", "Desodorante", "Roll-on"),
    "070942303460": ("GUM Trav-Ler interdental 0.8 mm", "GUM", "1 pza", "Higiene bucal", "Cepillo interdental"),
    "7501033204920": ("Speed Stick Xtreme Night crema 30 g", "Speed Stick", "30 g", "Desodorante", "Crema"),
}

# Ya estaban en catálogo el día del aviso (13). Igual se actualiza costo.
YA = {
    "7501027286017",
    "7509552844825",
    "7506306226852",
    "7506306209862",
    "7791293025919",
    "7501027250612",
    "7502221012303",
    "7501056330378",
    "7509546655055",
    "7509546068909",
    "7500435168991",
    "7500435169035",
    "7509552780956",
}


def sql_str(v) -> str:
    if v is None or v == "":
        return "null"
    return "'" + str(v).replace("'", "''") + "'"


def sku_de(ean: str) -> str:
    d = "".join(c for c in ean if c.isdigit())
    return "FC-" + d[-8:]


def precio(costo: float) -> int:
    return math.ceil(costo * 1.25)


def load_imagenes() -> dict[str, str]:
    if not OBF.exists():
        return {}
    out = {}
    for row in json.loads(OBF.read_text(encoding="utf-8")):
        img = row.get("imagen")
        if row.get("found") and img:
            out[row["ean"]] = img
    return out


def load_ticket() -> list[dict]:
    rows = list(csv.DictReader(SRC.open(encoding="utf-8")))
    assert len(rows) == 84
    out = []
    imgs = load_imagenes()
    for i, r in enumerate(rows, start=1):
        ean = r["ean"]
        if ean not in FICHA:
            raise SystemExit(f"Falta ficha para {ean}")
        nombre, marca, presentacion, subcat, forma = FICHA[ean]
        qty = int(r["cantidad"])
        sub = float(r["subtotal"])
        costo = round(sub / qty, 3)
        cat = "Botiquín" if subcat == "Botiquín" else "Cuidado personal"
        local = f"https://www.farmacapital.mx/catalogo-propia/cm-{ean}.jpg"
        out.append({
            "linea": i,
            "ean": ean,
            "sku": sku_de(ean),
            "nombre": nombre,
            "snap": r["descripcion_ticket"],
            "qty": qty,
            "costo": costo,
            "precio": precio(costo),
            "marca": marca,
            "presentacion": presentacion,
            "categoria": cat,
            "subcategoria": subcat,
            "forma": forma,
            "imagen": local if ean in imgs else None,
            "ya": ean in YA,
        })
    assert abs(sum(x["costo"] * x["qty"] for x in out) - TOTAL) < 0.05
    return out


def write_sql(rows: list[dict]) -> None:
    lines = [
        "-- City Mark 20260905 — 71 altas que faltaron + relink Recibir + stock huérfano.",
        "-- Nombres de mostrador (marca + producto), no el código del ticket.",
        "-- Stock 0 en el alta. Piezas al escanear + MMAA. No inventar 0000.",
        "-- NO borra renglones ya escaneados (se conserva MMAA/lote).",
        "-- SIN bloques dollar-quote. Pegar TODO en Supabase → SQL Editor → Run.",
        "",
        "begin;",
        "",
        "create temp table _fc_cm20260905 (",
        "  linea integer primary key,",
        "  ean text not null,",
        "  sku text not null,",
        "  nombre text not null,",
        "  snap text not null,",
        "  qty integer not null,",
        "  costo numeric(12,3) not null,",
        "  precio numeric(12,2) not null,",
        "  marca text,",
        "  presentacion text,",
        "  categoria text not null,",
        "  subcategoria text,",
        "  forma text,",
        "  imagen text",
        ") on commit drop;",
        "",
        "insert into _fc_cm20260905 (",
        "  linea, ean, sku, nombre, snap, qty, costo, precio,",
        "  marca, presentacion, categoria, subcategoria, forma, imagen",
        ") values",
    ]
    vals = []
    for r in rows:
        vals.append(
            "  ({linea}, {ean}, {sku}, {nombre}, {snap}, {qty}, {costo:.3f}, {precio},"
            " {marca}, {pres}, {cat}, {sub}, {forma}, {img})".format(
                linea=r["linea"],
                ean=sql_str(r["ean"]),
                sku=sql_str(r["sku"]),
                nombre=sql_str(r["nombre"]),
                snap=sql_str(r["snap"]),
                qty=r["qty"],
                costo=r["costo"],
                precio=r["precio"],
                marca=sql_str(r["marca"]),
                pres=sql_str(r["presentacion"]),
                cat=sql_str(r["categoria"]),
                sub=sql_str(r["subcategoria"]),
                forma=sql_str(r["forma"]),
                img=sql_str(r["imagen"]),
            )
        )
    lines.append(",\n".join(vals) + ";")
    lines += [
        "",
        "insert into public.productos (",
        "  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,",
        "  costo, precio, stock, stock_minimo, activo, requiere_receta,",
        "  marca, presentacion, forma_farmaceutica, imagen_url, imagen_mobile_url",
        ")",
        "select",
        "  t.nombre,",
        "  case",
        "    when exists (",
        "      select 1 from public.productos p",
        "      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean",
        "    ) then 'FC-CM-' || right(t.ean, 8)",
        "    else t.sku",
        "  end,",
        "  t.ean,",
        "  t.categoria,",
        "  t.subcategoria,",
        "  'marca',",
        "  'Alta City Mark 20260905 · 2026-09-05 · listo para pistola',",
        "  t.costo,",
        "  t.precio,",
        "  0,",
        "  1,",
        "  true,",
        "  false,",
        "  t.marca,",
        "  t.presentacion,",
        "  t.forma,",
        "  t.imagen,",
        "  t.imagen",
        "from _fc_cm20260905 t",
        "where public.fc_buscar_producto_escaneo(t.ean) is null;",
        "",
        "update public.productos p",
        "set",
        "  costo = t.costo,",
        "  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end",
        "from _fc_cm20260905 t",
        "where p.id = public.fc_buscar_producto_escaneo(t.ean)",
        "  and (",
        "    p.costo is distinct from t.costo",
        "    or coalesce(p.precio, 0) <= 0",
        "  );",
        "",
        "update public.productos p",
        "set",
        "  nombre = case",
        "    when upper(btrim(p.nombre)) = upper(btrim(t.snap)) then t.nombre",
        "    else p.nombre",
        "  end,",
        "  marca = coalesce(nullif(trim(t.marca), ''), nullif(trim(p.marca), '')),",
        "  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),",
        "  categoria = case",
        "    when coalesce(nullif(trim(p.categoria), ''), 'Otro') in ('Otro', '') then t.categoria",
        "    else p.categoria",
        "  end,",
        "  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),",
        "  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),",
        "  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),",
        "  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),",
        "  proveedor = coalesce(nullif(trim(p.proveedor), ''), 'City Mark')",
        "from _fc_cm20260905 t",
        "where p.id = public.fc_buscar_producto_escaneo(t.ean);",
        "",
        "-- Enlaza renglones de este folio. No toca confirmado / MMAA / lote.",
        "update public.recepcion_items i",
        "set",
        "  producto_id = public.fc_buscar_producto_escaneo(i.codigo_escaneado),",
        "  pendiente_alta = false",
        "from public.recepciones r",
        "where i.recepcion_id = r.id",
        f"  and r.folio = '{FOLIO}'",
        "  and coalesce(r.proveedor, '') ilike '%city mark%'",
        "  and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null",
        "  and (i.pendiente_alta or i.producto_id is null);",
        "",
        "select",
        "  count(*) filter (where public.fc_buscar_producto_escaneo(t.ean) is null) as siguen_sin_alta,",
        "  count(*) as lineas_ticket",
        "from _fc_cm20260905 t;",
        "",
        "commit;",
        "",
        "-- Stock de renglones ya verdes con MMAA y sin lote (si el RPC está).",
        "select",
        "  case",
        "    when exists (",
        "      select 1 from pg_proc p",
        "      join pg_namespace n on n.oid = p.pronamespace",
        "      where n.nspname = 'public' and p.proname = 'recepcion_reparar_stock_huerfanos'",
        "    ) then public.recepcion_reparar_stock_huerfanos(null)",
        "    else jsonb_build_object('skipped', 'falta patch_recepcion_verde_sin_stock_20260903')",
        "  end as reparacion_stock;",
        "",
        "select",
        "  r.id as recepcion_id,",
        "  r.estado,",
        "  count(i.*) as renglones,",
        "  count(*) filter (where i.pendiente_alta) as pendiente_alta,",
        "  count(*) filter (where i.confirmado and i.lote_id is not null) as con_stock,",
        "  count(*) filter (where i.confirmado and i.lote_id is null) as verde_sin_lote",
        "from public.recepciones r",
        "left join public.recepcion_items i on i.recepcion_id = r.id",
        f"where r.folio = '{FOLIO}' and coalesce(r.proveedor, '') ilike '%city mark%'",
        "group by r.id, r.estado",
        "order by r.id desc;",
        "",
        "select",
        "  i.codigo_escaneado as ean,",
        "  left(coalesce(p.nombre, i.nombre_snapshot), 52) as nombre,",
        "  i.cantidad,",
        "  i.pendiente_alta,",
        "  i.confirmado,",
        "  i.lote_id is not null as en_anaquel,",
        "  p.stock",
        "from public.recepcion_items i",
        "join public.recepciones r on r.id = i.recepcion_id",
        "left join public.productos p on p.id = i.producto_id",
        f"where r.folio = '{FOLIO}' and coalesce(r.proveedor, '') ilike '%city mark%'",
        "order by i.pendiente_alta desc, i.id;",
        "",
    ]
    OUT_SQL.write_text("\n".join(lines), encoding="utf-8")
    altas = sum(1 for r in rows if not r["ya"])
    print(f"wrote {OUT_SQL} lineas={len(rows)} altas_esperadas={altas} ya={len(rows)-altas}")


def write_nombres_sql(rows: list[dict]) -> None:
    """Re-runnable: ticket ALL CAPS → nombre de mostrador. No toca stock."""
    lines = [
        "-- City Mark 20260905 — nombres de ticket → mostrador.",
        "-- NO sube stock. El 0 es correcto hasta Recibir (pistola + MMAA).",
        "-- Solo pisa el nombre si sigue siendo el código del PDF (snap).",
        "-- SIN bloques dollar-quote. Pegar TODO en Supabase → SQL Editor → Run.",
        "",
        "begin;",
        "",
        "create temp table _fc_cm_nom (",
        "  ean text primary key,",
        "  nombre text not null,",
        "  snap text not null,",
        "  marca text,",
        "  presentacion text,",
        "  categoria text not null,",
        "  subcategoria text,",
        "  forma text,",
        "  imagen text",
        ") on commit drop;",
        "",
        "insert into _fc_cm_nom (",
        "  ean, nombre, snap, marca, presentacion, categoria, subcategoria, forma, imagen",
        ") values",
    ]
    vals = []
    for r in rows:
        vals.append(
            "  ({ean}, {nombre}, {snap}, {marca}, {pres}, {cat}, {sub}, {forma}, {img})".format(
                ean=sql_str(r["ean"]),
                nombre=sql_str(r["nombre"]),
                snap=sql_str(r["snap"]),
                marca=sql_str(r["marca"]),
                pres=sql_str(r["presentacion"]),
                cat=sql_str(r["categoria"]),
                sub=sql_str(r["subcategoria"]),
                forma=sql_str(r["forma"]),
                img=sql_str(r["imagen"]),
            )
        )
    lines.append(",\n".join(vals) + ";")
    lines += [
        "",
        "update public.productos p",
        "set",
        "  nombre = t.nombre,",
        "  marca = coalesce(nullif(trim(t.marca), ''), nullif(trim(p.marca), '')),",
        "  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),",
        "  categoria = case",
        "    when coalesce(nullif(trim(p.categoria), ''), 'Otro') in ('Otro', '') then t.categoria",
        "    else p.categoria",
        "  end,",
        "  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),",
        "  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),",
        "  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),",
        "  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),",
        "  proveedor = coalesce(nullif(trim(p.proveedor), ''), 'City Mark')",
        "from _fc_cm_nom t",
        "where p.id = public.fc_buscar_producto_escaneo(t.ean)",
        "  and upper(btrim(p.nombre)) = upper(btrim(t.snap));",
        "",
        "select",
        "  count(*) filter (where upper(btrim(p.nombre)) = upper(btrim(t.snap))) as siguen_nombre_ticket,",
        "  count(*) filter (where p.nombre = t.nombre) as ya_mostrador,",
        "  count(*) as lineas",
        "from _fc_cm_nom t",
        "left join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean);",
        "",
        "select p.sku, left(p.nombre, 56) as nombre, p.marca, p.proveedor, p.stock",
        "from _fc_cm_nom t",
        "join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)",
        "order by p.nombre;",
        "",
        "commit;",
        "",
    ]
    OUT_NOMBRES.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {OUT_NOMBRES} lineas={len(rows)}")


if __name__ == "__main__":
    ticket = load_ticket()
    write_sql(ticket)
    write_nombres_sql(ticket)
