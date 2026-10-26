#!/usr/bin/env python3
"""Factura Levic A 9012545305 (CFDI 26-oct-2026) → CSV Recibir + SQL.

Hoja 1 de 2 del CFDI (TOT 59 pzas). Costo = Precio neto.
IVA $94.39 = Cintapore $20.07 + Microdacyn $74.32.
Lote de fábrica sí viene en la factura (se anota en el ticket).
Caducidad del papel NO se escribe en SQL: MMAA sale de la caja. 0000 inválido.

Nombres de mostrador (no el código interno del PDF). EAN desde portal Levic /
Sufarmed / Farmahome / Prixz / cargas previos cuando la ficha lo publica.
BEA215 (Diclofenaco beadvance 20 tab): sin EAN público; TODO leer de la caja.
"""
from __future__ import annotations

import csv
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, sql_str

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_levic_9012545305.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_levic_9012545305.sql"
OUT_MD = ROOT / "sql" / "LEERME_levic_9012545305.md"

FOLIO = "9012545305"
PROVEEDOR = "Levic"
FECHA = "2026-10-26"
SUBTOTAL_CFDI = 1750.53
IVA_CFDI = 94.39  # Cintapore 20.07 + Microdacyn 74.32
TOTAL_TICKET = 1844.92
UUID = "B57229E5-7DBB-4B9F-A23E-B1D28E33B872"  # OCR foto; confirmar en PDF/timbre


def ceil_pvp(costo: float, factor: float = 1.6) -> float:
    return float(math.ceil(costo * factor - 1e-9))


def ceil_pvp_tipo(costo: float, tipo: str) -> float:
    factor = 1.25 if tipo == "marca" else 1.6
    return ceil_pvp(costo, factor)


# match=True → ya había EAN/SKU en portal o inventario local.
ROWS = [
    {
        "clave": "ALP0598",
        "ean": "7503004908721",
        "nombre": "Acetónido de fluocinolona Alpharma crema 0.01%",
        "desc_ticket": "ACETONIDO DE FLUOCINOLONA CMA 40/01/100G",
        "qty": 5,
        "pu": 19.79,
        "sub": 98.95,
        "lote": "2605164",
        "caducidad": "2028-05-30",
        "sku": "FC-1BF03D35",
        "match": True,
        "categoria": "Medicamentos",
        "tipo": "generico",
        "marca": "Alpharma",
        "presentacion": "Tubo 40 g",
        "principio": "Acetónido de fluocinolona",
        "concentracion": "0.01%",
        "forma": "Crema",
        "receta": True,
        "stock_minimo": 2,
        "imagen": None,
    },
    {
        "clave": "ALP0673",
        "ean": "7502226294476",
        "nombre": "Acetónido de fluocinolona Alpharma crema 0.01%",
        "desc_ticket": "ACETONIDO DE FLUOCINOLONA CMA 20/01/100G",
        "qty": 5,
        "pu": 11.46,
        "sub": 57.30,
        "lote": "2609272",
        "caducidad": "2028-08-30",
        "sku": "EQ-ALP0673",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "generico",
        "marca": "Alpharma",
        "presentacion": "Tubo 20 g",
        "principio": "Acetónido de fluocinolona",
        "concentracion": "0.01%",
        "forma": "Crema",
        "receta": True,
        "stock_minimo": 2,
        "imagen": "https://www.farmacapital.mx/catalogo-propia/acetonido-fluocinolona-alpharma-20g-7502226294476.jpg",
    },
    {
        "clave": "BEA215",
        # Sin EAN público confirmado (Curitek/Sufarmed/Prixz). TODO de la caja.
        "ean": "",
        "nombre": "Diclofenaco beadvance 100 mg",
        "desc_ticket": "DICLOFENACO 20 TAB 100 MG",
        "qty": 5,
        "pu": 7.67,
        "sub": 38.35,
        "lote": "SMM2088",
        "caducidad": "2027-12-30",
        "sku": "EQ-BEA215",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "generico",
        "marca": "beadvance",
        "presentacion": "Caja con 20 tabletas de liberación prolongada",
        "principio": "Diclofenaco",
        "concentracion": "100 mg",
        "forma": "Tabletas",
        "receta": True,
        "stock_minimo": 2,
        "imagen": "https://www.farmacapital.mx/catalogo-propia/diclofenaco-beadvance-100mg-20-tabs.jpg",
    },
    {
        "clave": "BIO149",
        "ean": "7501573906407",
        "nombre": "Lozamir-V clotrimazol crema 2%",
        "desc_ticket": "LOZAMIR V C/3 APLICS 1 CMA 2% 20G",
        "qty": 5,
        "pu": 22.52,
        "sub": 112.60,
        "lote": "CE2607",
        "caducidad": "2028-05-30",
        "sku": "FC-73906407",
        "match": True,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Biomep",
        "presentacion": "Tubo 20 g con 3 aplicadores",
        "principio": "Clotrimazol",
        "concentracion": "2%",
        "forma": "Crema",
        "receta": True,
        "stock_minimo": 2,
        "imagen": None,
    },
    {
        "clave": "BIO213",
        "ean": "7501573909859",
        "nombre": "Sarox omeprazol 20 mg",
        "desc_ticket": "SAROX 28 CAPS 20 MG",
        "qty": 5,
        "pu": 15.00,
        "sub": 75.00,
        "lote": "SG2653",
        "caducidad": "2028-07-30",
        "sku": "FC-73909859",
        "match": True,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Biomep",
        "presentacion": "Caja con 28 cápsulas",
        "principio": "Omeprazol",
        "concentracion": "20 mg",
        "forma": "Cápsulas",
        "receta": True,
        "stock_minimo": 2,
        "imagen": None,
    },
    {
        "clave": "BRU053",
        "ean": "7501537102845",
        "nombre": "Nediclon diclofenaco 100 mg",
        "desc_ticket": "NEDICLON 20 GRAG 100 MG",
        "qty": 20,
        "pu": 8.84,
        "sub": 176.80,
        "lote": "807352",
        "caducidad": "2028-08-18",
        "sku": "EQ-BRU053",
        "match": True,
        "categoria": "Medicamentos",
        "tipo": "generico",
        "marca": "Bruluart",
        "presentacion": "Caja con 20 grageas de liberación prolongada",
        "principio": "Diclofenaco",
        "concentracion": "100 mg",
        "forma": "Grageas",
        "receta": True,
        "stock_minimo": 4,
        "imagen": None,
    },
    {
        "clave": "BRU070",
        "ean": "7501537102067",
        "nombre": "Soltrim trimetoprima/sulfametoxazol 40/200",
        "desc_ticket": "SOLTRIM 1 SUSP 40/200/5/120 ML",
        "qty": 2,
        "pu": 28.00,
        "sub": 56.00,
        "lote": "2605486",
        "caducidad": "2028-05-22",
        "sku": "EQ-BRU070",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Bruluart",
        "presentacion": "Frasco suspensión 120 mL",
        "principio": "Trimetoprima / Sulfametoxazol",
        "concentracion": "40 mg / 200 mg / 5 mL",
        "forma": "Suspensión",
        "receta": True,
        "stock_minimo": 2,
        "imagen": "https://www.farmacapital.mx/catalogo-propia/soltrim-suspension-40-200-120ml-bruluart-7501537102067.jpg",
    },
    {
        "clave": "CHI029",
        "ean": "7501088545658",
        "nombre": "Mydocalm-A paracetamol/tolperisona 300/50 mg",
        "desc_ticket": "MYDOCALM A 30 CAPS 300 MG/50 MG",
        "qty": 1,
        "pu": 363.75,
        "sub": 363.75,
        "lote": "BFC021",
        "caducidad": "2029-02-28",
        "sku": "EQ-CHI029",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Chinoin",
        "presentacion": "Caja con 30 cápsulas",
        "principio": "Paracetamol / Tolperisona",
        "concentracion": "300 mg / 50 mg",
        "forma": "Cápsulas",
        "receta": True,
        "stock_minimo": 1,
        "imagen": "https://www.farmacapital.mx/catalogo-propia/mydocalm-a-paracetamol-tolperisona-300-50-30-caps-7501088545658.jpg",
    },
    {
        "clave": "COD106",
        "ean": "7506484500034",
        "nombre": "Cintapore micropore piel",
        "desc_ticket": "CINTAPORE PIEL 12 PZAS 2.5 CM X 5 M",
        "qty": 1,
        "pu": 125.43,
        "sub": 125.43,
        "lote": "2804022",
        "caducidad": "2031-04-15",
        "sku": "FC-84500034",
        "match": True,
        "categoria": "Botiquín",
        "tipo": "marca",
        "marca": "Codifarma",
        "presentacion": "Caja con 12 rollos 2.5 cm × 5 m",
        "principio": None,
        "concentracion": None,
        "forma": "Cinta",
        "receta": False,
        "stock_minimo": 1,
        "imagen": "https://www.farmacapital.mx/catalogo-propia/cintapore-piel-2.5x5.jpg",
    },
    {
        "clave": "FAC0059",
        "ean": "7502006920021",
        "nombre": "Motilaxil-T picosulfato de sodio 5 mg",
        "desc_ticket": "MOTILAXIL 20 TAB 5 MG",
        "qty": 5,
        "pu": 17.95,
        "sub": 89.75,
        "lote": "ITG265092",
        "caducidad": "2028-06-30",
        "sku": "FC-06920021",
        "match": True,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Fármacos Continentales",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Picosulfato de sodio",
        "concentracion": "5 mg",
        "forma": "Tabletas",
        "receta": False,
        "stock_minimo": 2,
        "imagen": None,
    },
    {
        "clave": "RAM092",
        "ean": "7502227874417",
        "nombre": "Raamcedo aceclofenaco 100 mg",
        "desc_ticket": "RAAMCEDO 10 TAB 100 MG",
        "qty": 2,
        "pu": 46.04,
        "sub": 92.08,
        "lote": "RMD033",
        "caducidad": "2028-04-30",
        "sku": "EQ-RAM092",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Raam",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Aceclofenaco",
        "concentracion": "100 mg",
        "forma": "Tabletas",
        "receta": True,
        "stock_minimo": 2,
        "imagen": "https://www.farmacapital.mx/catalogo-propia/raamcedo-aceclofenaco-100mg-10-raam-7502227874417.jpg",
    },
    {
        "clave": "SFE159",
        "ean": "7503006698316",
        "nombre": "Microdacyn 60 solución antiséptica 120 ml",
        "desc_ticket": "MICRODACYN 1 SOL 120 ML",
        "qty": 3,
        "pu": 154.84,
        "sub": 464.52,
        "lote": "209GD984",
        "caducidad": "2028-06-30",
        "sku": "FC-06698316",
        "match": True,
        "categoria": "Botiquín",
        "tipo": "marca",
        "marca": "Microdacyn",
        "presentacion": "Frasco spray 120 mL",
        "principio": "Ácido hipocloroso",
        "concentracion": None,
        "forma": "Solución",
        "receta": False,
        "stock_minimo": 2,
        "imagen": "https://www.farmacapital.mx/catalogo-propia/microdacyn-60-solucion-120ml.jpg",
    },
]


def write_ticket_csv() -> None:
    OUT_TICKET.parent.mkdir(parents=True, exist_ok=True)
    with OUT_TICKET.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow([
            "linea", "folio", "fecha", "proveedor", "ean", "clave_levic",
            "descripcion_ticket", "cantidad", "precio_unitario", "subtotal",
            "lote", "caducidad", "sku_farmacapital", "total_ticket", "match",
        ])
        for i, r in enumerate(ROWS, start=1):
            w.writerow([
                i, FOLIO, FECHA, PROVEEDOR, r["ean"], r["clave"],
                r["desc_ticket"], r["qty"], f"{r['pu']:.2f}", f"{r['sub']:.2f}",
                r["lote"], r["caducidad"], r["sku"], f"{TOTAL_TICKET:.2f}",
                "recibir" if r["match"] else "alta",
            ])


def write_md() -> None:
    altas = [r for r in ROWS if not r["match"]]
    lines = [
        f"# Ticket Levic · A {FOLIO}",
        "",
        f"**Fecha CFDI:** {FECHA} (America/Mexico_City) · Hoja 1 de 2 · TOT {sum(r['qty'] for r in ROWS)} pzas",
        f"**Total:** ${TOTAL_TICKET:.2f} (subtotal ${SUBTOTAL_CFDI:.2f} + IVA ${IVA_CFDI:.2f})",
        f"**IVA:** Cintapore $20.07 + Microdacyn $74.32 · PUE efectivo",
        f"**Folio fiscal (OCR foto):** `{UUID}` — confirmar en PDF/timbre",
        f"**Receptor:** LUIS ANGEL PALILLERO VENTURA",
        "",
        "## Renglones",
        "",
        "| # | Clave | Ticket | Cant | Neto | EAN | SKU | Match |",
        "|---|-------|--------|------|------|-----|-----|-------|",
    ]
    for i, r in enumerate(ROWS, start=1):
        ean = r["ean"] or "*(TODO caja)*"
        lines.append(
            f"| {i} | `{r['clave']}` | `{r['desc_ticket']}` | {r['qty']} | "
            f"${r['pu']:.2f} | `{ean}` | `{r['sku']}` | "
            f"{'recibir' if r['match'] else 'alta'} |"
        )
    lines += [
        "",
        "## Cómo aplicar",
        "",
        f"1. Pegar `sql/patch_carga_levic_9012545305.sql` en Supabase → SQL Editor → Run.",
        "2. Recibir → pistola → MMAA de la caja. No poner `0000`.",
        "3. **BEA215** (Diclofenaco beadvance): al escanear la caja, anotar EAN y "
        "correr un patch `UPDATE productos SET codigo_barras = … WHERE sku = 'EQ-BEA215'`.",
        "4. Packshots de altas ya están en `public/catalogo-propia/` "
        "(imagen_url apunta a farmacapital.mx; aplica **después** del deploy).",
        "",
        "## Altas nuevas",
        "",
    ]
    for r in altas:
        foto = "foto ok" if r.get("imagen") else "foto pendiente"
        lines.append(
            f"- `{r['sku']}` · {r['nombre']} · {r['presentacion']} · "
            f"EAN `{r['ean'] or 'pendiente'}` · {foto}"
        )
    lines += [
        "",
        "## Archivos",
        "",
        f"- `sql/generated/ticket_levic_{FOLIO}.csv`",
        f"- `sql/patch_carga_levic_{FOLIO}.sql`",
        f"- `scripts/generar_carga_levic_{FOLIO}.py`",
        "",
    ]
    OUT_MD.write_text("\n".join(lines), encoding="utf-8")


def write_sql() -> None:
    altas = [r for r in ROWS if not r["match"]]
    notas = (
        f"Factura Levic A {FOLIO} · CFDI {UUID} · cola Recibir; "
        "stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja; "
        "TODO EAN BEA215 de la caja (packshot ya en catalogo-propia)"
    )
    lines = [
        f"-- Levic · factura interna A {FOLIO} · CFDI {FECHA}",
        f"-- Folio fiscal {UUID} (OCR foto) · PUE efectivo ${TOTAL_TICKET:.2f}",
        f"-- Receptor LUIS ANGEL PALILLERO VENTURA · {len(ROWS)} renglones · "
        f"{sum(r['qty'] for r in ROWS)} pzas (TOT 59 hoja 1).",
        f"-- Subtotal CFDI ${SUBTOTAL_CFDI:.2f} + IVA ${IVA_CFDI:.2f} "
        f"(Cintapore $20.07 + Microdacyn $74.32) = ${TOTAL_TICKET:.2f}.",
        "-- Costo = Precio neto. Lote = de fábrica (sí viene en la factura).",
        "-- Caducidad del papel NO se escribe aquí: Recibir captura MMAA de la caja.",
        "-- 0000 es inválido.",
        "-- BEA215 sin EAN público: alta por SKU EQ-BEA215; completar codigo_barras al escanear.",
        "--",
        f"-- {len(ROWS) - len(altas)} ya estaban · {len(altas)} altas nuevas.",
        "-- Altas: stock 0. En existentes solo se actualiza costo (no el PVP).",
        "-- Idempotente. Pegar en Supabase SQL Editor (archivo completo).",
        "",
        "begin;",
        "",
        "-- ── 1) Catálogo: altas faltantes + costo de esta factura ──────────",
        "do $$",
        "declare",
        "  r record;",
        "  v_pid bigint;",
        "  n_alta integer := 0;",
        "  n_costo integer := 0;",
        "begin",
        "  for r in",
        "    select * from (values",
    ]
    vals = []
    for i, r in enumerate(ROWS):
        costo = f"{r['pu']:.2f}::numeric" if i == 0 else f"{r['pu']:.2f}"
        precio = f"{ceil_pvp_tipo(r['pu'], r['tipo']):.2f}"
        receta = "true" if r["receta"] else "false"
        alta = "true" if not r["match"] else "false"
        ean_sql = sql_str(r["ean"]) if r["ean"] else "null"
        nota = f"Factura Levic {FOLIO} · clave {r['clave']} · lote {r['lote']}"
        img = sql_str(r["imagen"]) if r.get("imagen") else "null"
        vals.append(
            "      ({ean}, {sku}, {nombre}, {cat}, {tipo}, {costo}, {precio}, {smin}, "
            "{marca}, {pres}, {pa}, {conc}, {forma}, {receta}, {notas}, {img}, {alta})".format(
                ean=ean_sql,
                sku=sql_str(r["sku"]),
                nombre=sql_str(r["nombre"]),
                cat=sql_str(r["categoria"]),
                tipo=sql_str(r["tipo"]),
                costo=costo,
                precio=precio,
                smin=r["stock_minimo"],
                marca=sql_str(r["marca"]),
                pres=sql_str(r["presentacion"]),
                pa=sql_str(r["principio"]) if r["principio"] else "null",
                conc=sql_str(r["concentracion"]) if r["concentracion"] else "null",
                forma=sql_str(r["forma"]) if r.get("forma") else "null",
                receta=receta,
                notas=sql_str(nota),
                img=img,
                alta=alta,
            )
        )
    lines.append(",\n".join(vals))
    lines += [
        "    ) as t(ean, sku, nombre, categoria, tipo, costo, precio, stock_minimo,",
        "           marca, presentacion, principio, concentracion, forma, receta, notas, imagen, es_alta)",
        "  loop",
        "    v_pid := null;",
        "    if r.ean is not null then",
        "      v_pid := public.fc_buscar_producto_escaneo(r.ean);",
        "    end if;",
        "    if v_pid is null then",
        "      v_pid := public.fc_buscar_producto_escaneo(r.sku);",
        "    end if;",
        "",
        "    if v_pid is null then",
        "      select f.producto_id into v_pid",
        "      from public.create_producto_with_lote(",
        "        jsonb_strip_nulls(jsonb_build_object(",
        "          'nombre', r.nombre,",
        "          'sku', r.sku,",
        "          'codigo_barras', r.ean,",
        "          'categoria', r.categoria,",
        "          'tipo', r.tipo,",
        "          'descripcion', r.notas,",
        "          'costo', r.costo,",
        "          'precio', r.precio,",
        "          'stock_minimo', r.stock_minimo,",
        "          'activo', true,",
        "          'requiere_receta', r.receta,",
        "          'imagen_url', r.imagen",
        "        )),",
        "        0, null, null::date, r.costo, null::bigint",
        "      ) f;",
        "      n_alta := n_alta + 1;",
        "    else",
        "      update public.productos set",
        "        costo = r.costo,",
        "        stock_minimo = greatest(coalesce(stock_minimo, 0), r.stock_minimo),",
        "        codigo_barras = case",
        "          when r.ean is not null then coalesce(nullif(codigo_barras, ''), r.ean)",
        "          else codigo_barras",
        "        end,",
        "        imagen_url = coalesce(nullif(btrim(imagen_url), ''), r.imagen)",
        "      where id = v_pid;",
        "      n_costo := n_costo + 1;",
        "    end if;",
        "",
        "    update public.productos set",
        "      marca = coalesce(nullif(marca, ''), r.marca),",
        "      presentacion = coalesce(nullif(presentacion, ''), r.presentacion),",
        "      principio_activo = coalesce(nullif(principio_activo, ''), r.principio),",
        "      concentracion = coalesce(nullif(concentracion, ''), r.concentracion),",
        "      forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), r.forma)",
        "    where id = v_pid;",
        "  end loop;",
        "",
        f"  raise notice 'Levic {FOLIO}: % altas de catálogo, % costos actualizados (stock = Recibir)',",
        "    n_alta, n_costo;",
        "end $$;",
        "",
        "-- ── 2) Cola Recibir (borrador, sin sumar piezas) ──────────────────",
        "do $$",
        "declare",
        "  v_id bigint;",
        "  r record;",
        "  v_pid bigint;",
        "begin",
        "  select id into v_id",
        "  from public.recepciones",
        f"  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%levic%'",
        "  order by id desc",
        "  limit 1;",
        "",
        "  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then",
        f"    raise notice 'Recepcion Levic {FOLIO} ya cerrada (id %)', v_id;",
        "  else",
        "    if v_id is null then",
        "      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)",
        f"      values ({sql_str(PROVEEDOR)}, {sql_str(FOLIO)}, {sql_str(FECHA)}, {TOTAL_TICKET:.2f}, 'borrador',",
        f"              {sql_str(notas)})",
        "      returning id into v_id;",
        "    else",
        "      delete from public.recepcion_items where recepcion_id = v_id;",
        "      update public.recepciones",
        f"      set total_ticket = {TOTAL_TICKET:.2f}, fecha = {sql_str(FECHA)},",
        f"          proveedor = {sql_str(PROVEEDOR)}, notas = {sql_str(notas)}, updated_at = now()",
        "      where id = v_id;",
        "    end if;",
        "",
        "    for r in",
        "      select * from (values",
    ]
    recv = []
    for i, r in enumerate(ROWS):
        costo = f"{r['pu']:.2f}::numeric" if i == 0 else f"{r['pu']:.2f}"
        ean_sql = sql_str(r["ean"]) if r["ean"] else "null"
        recv.append(
            f"        ({ean_sql}, {sql_str(r['nombre'])}, {r['qty']}, {costo}, "
            f"{sql_str(r['sku'])}, {sql_str(r['lote'])})"
        )
    lines.append(",\n".join(recv))
    lines += [
        "      ) as t(ean, nombre, qty, costo, sku, lote)",
        "    loop",
        "      v_pid := null;",
        "      if r.ean is not null then",
        "        v_pid := public.fc_buscar_producto_escaneo(r.ean);",
        "      end if;",
        "      if v_pid is null then",
        "        v_pid := public.fc_buscar_producto_escaneo(r.sku);",
        "      end if;",
        "",
        "      insert into public.recepcion_items (",
        "        recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,",
        "        cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,",
        "        origen, confirmado, lote_distinto, lote_id",
        "      ) values (",
        "        v_id, v_pid, coalesce(r.ean, r.sku), r.nombre, r.qty, null, r.lote, r.costo,",
        "        (v_pid is null), 'pdf', false,",
        "        (v_pid is not null and exists (",
        "          select 1 from public.lotes l",
        "          where l.producto_id = v_pid and coalesce(l.activo, true)",
        "            and coalesce(l.cantidad_actual, 0) > 0",
        "            and l.numero_lote is distinct from r.lote",
        "        )),",
        "        null",
        "      );",
        "    end loop;",
        "",
        f"    raise notice 'Recepcion Levic {FOLIO} lista id=% — escanear caja por caja', v_id;",
        "  end if;",
        "end $$;",
        "",
        "commit;",
        "",
        "select",
        "  i.id,",
        "  i.codigo_escaneado as ean,",
        "  left(i.nombre_snapshot, 48) as nombre,",
        "  i.cantidad,",
        "  i.costo_estimado,",
        "  i.numero_lote,",
        "  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado",
        "from public.recepcion_items i",
        "join public.recepciones r on r.id = i.recepcion_id",
        f"where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%levic%'",
        "order by i.id;",
        "",
    ]
    OUT_SQL.write_text("\n".join(lines), encoding="utf-8")


if __name__ == "__main__":
    write_ticket_csv()
    write_sql()
    write_md()
    rows_rep = [
        {
            "ean": r["ean"],
            "nombre": r["desc_ticket"],
            "qty": r["qty"],
            "pu": r["pu"],
            "sub": r["sub"],
            "sku": r["sku"],
            "match": "recibir" if r["match"] else "alta",
        }
        for r in ROWS
    ]
    suma = sum(r["sub"] for r in ROWS)
    print(f"csv  {OUT_TICKET}")
    print(f"sql  {OUT_SQL}")
    print(f"md   {OUT_MD}")
    print(report(rows_rep, TOTAL_TICKET))
    print(
        f"productos ${suma:.2f} + IVA ${IVA_CFDI:.2f} = ${suma + IVA_CFDI:.2f} "
        f"(CFDI ${TOTAL_TICKET:.2f})"
    )
    print(f"altas {sum(1 for r in ROWS if not r['match'])}  recibir {sum(1 for r in ROWS if r['match'])}")
    print(f"piezas {sum(r['qty'] for r in ROWS)}")
    assert abs(suma - SUBTOTAL_CFDI) < 0.01, (suma, SUBTOTAL_CFDI)
    assert abs(suma + IVA_CFDI - TOTAL_TICKET) < 0.01
    assert sum(r["qty"] for r in ROWS) == 59
    eans = [r["ean"] for r in ROWS if r["ean"]]
    assert len(eans) == len(set(eans)), eans
