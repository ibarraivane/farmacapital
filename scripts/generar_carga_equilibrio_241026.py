#!/usr/bin/env python3
"""Ticket Equilibrio POS · foto 24-oct-2026 → catálogo + cola Recibir.

Cliente 307513 LUIS ANGEL PALILLERO VENTURA.
Foto térmica sin encabezado de folio → folio provisional 241026 (ddmmyy).
10 renglones / 27 pzas / SubTotal $1,126.53 (IVA $0).
Costo = P.U. neto del papel. Lote de fábrica sí. Caducidad NO (MMAA de la caja).
Fichas Levic / mayoreo / retailer — no el código truncado del ticket.
ULT284/ULT285: ticket no trae mg; mapeo por costo mayoreo Ultra
  50/500 (EAN …90896) y 50/850 (EAN …90490).
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_carga_tickets_20260915 import (  # noqa: E402
    ceil_pvp,
    foto_url,
    write_carga_sql,
)
from generar_recepcion_borrador import report  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OUT_CSV = ROOT / "sql" / "generated" / "ticket_equilibrio_241026.csv"
OUT_MD = ROOT / "sql" / "LEERME_equilibrio_241026.md"

FOLIO = "241026"
PROVEEDOR = "Equilibrio"
FECHA = "2026-10-24"
TOTAL = 1126.53


def row(
    *,
    ean: str,
    codigo: str,
    snap: str,
    nombre: str,
    qty: int,
    pu: float,
    lote: str,
    tipo: str = "generico",
    categoria: str = "Medicamentos",
    subcategoria: str | None = None,
    forma: str | None = None,
    marca: str | None = None,
    laboratorio: str | None = None,
    presentacion: str | None = None,
    principio: str | None = None,
    concentracion: str | None = None,
    receta: bool = True,
    ya: bool = False,
    sku: str | None = None,
    foto_file: str | None = None,
) -> dict:
    precio = ceil_pvp(pu, tipo)
    return {
        "ean": ean,
        "sku": sku or f"EQ-{codigo}",
        "nombre": nombre,
        "snap": snap,
        "qty": qty,
        "pu": pu,
        "sub": round(pu * qty, 2),
        "precio": precio,
        "tipo": tipo,
        "categoria": categoria,
        "subcategoria": subcategoria,
        "forma": forma,
        "marca": marca,
        "laboratorio": laboratorio,
        "presentacion": presentacion,
        "principio": principio,
        "concentracion": concentracion,
        "receta": receta,
        "ya": ya,
        "foto": foto_url(foto_file) if foto_file else None,
        "foto_file": f"catalogo-propia/{foto_file}" if foto_file else None,
        "lote": lote,
        "match": "ya" if ya else "alta",
    }


# Fichas de mostrador (no el código del ticket).
ROWS = [
    row(
        ean="7502223112445",
        codigo="QUM052",
        snap="QUM052 QUIMIKAN 1 SOL C/ APLI 10 ML 200MG/ 1 ML",
        nombre="Quimikan benzocaína 200 mg/mL",
        qty=2,
        pu=71.10,
        lote="26FS34",
        forma="Solución bucal",
        marca="Quimikan",
        laboratorio="Quimpharma",
        presentacion="Frasco 10 mL con aplicador",
        principio="Benzocaína",
        concentracion="200 mg/mL",
        receta=False,
        ya=True,
    ),
    row(
        ean="7502216790896",
        codigo="ULT284",
        snap="ULT284 VILDAGLIPTINA METFORMINA 30COMP",
        nombre="Vildagliptina/metformina 50/500 mg",
        qty=1,
        pu=158.27,
        lote="6GM172A",
        subcategoria="Diabetes",
        forma="Comprimido",
        marca="Ultra",
        laboratorio="Ultra",
        presentacion="Caja con 30 comprimidos",
        principio="Vildagliptina / metformina",
        concentracion="50/500 mg",
        ya=False,
    ),
    row(
        ean="7501349020139",
        codigo="AMS495",
        snap="AMS495 FLUCONAZOL 10 CAP 100 MG",
        nombre="Fluconazol 100 mg",
        qty=3,
        pu=19.18,
        lote="U26A296",
        sku="FC-LV-AMS495",
        forma="Cápsula",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 10 cápsulas",
        principio="Fluconazol",
        concentracion="100 mg",
        ya=True,
    ),
    row(
        ean="7502209858190",
        codigo="AVT202",
        snap="AVT202 CIDORIX 14 TAB 75 MG",
        nombre="Cidorix clopidogrel 75 mg",
        qty=4,
        pu=22.51,
        lote="SD26119",
        subcategoria="Cardiovascular",
        forma="Tableta",
        marca="Cidorix",
        laboratorio="Avitus",
        presentacion="Caja con 14 tabletas",
        principio="Clopidogrel",
        concentracion="75 mg",
        ya=False,
    ),
    row(
        ean="7501349022126",
        codigo="AMS404",
        snap="AMS404 METAMIZOL SODICO 3 AMP 1G/2ML",
        nombre="Metamizol sódico 1 g/2 ml",
        qty=5,
        pu=20.06,
        lote="B26E508",
        subcategoria="Dolor",
        forma="Solución inyectable",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 3 ampolletas de 2 ml",
        principio="Metamizol sódico",
        concentracion="1 g/2 ml",
        ya=False,
    ),
    row(
        ean="7502001165328",
        codigo="SON237",
        snap="SON237 EXPICIN 20 CAPS 500 MG",
        nombre="Expicin ampicilina 500 mg",
        qty=3,
        pu=31.52,
        lote="B2608303",
        subcategoria="Antibiótico",
        forma="Cápsula",
        marca="Expicin",
        laboratorio="Son's",
        presentacion="Caja con 20 cápsulas",
        principio="Ampicilina",
        concentracion="500 mg",
        ya=True,
    ),
    row(
        ean="7502009745614",
        codigo="MAV260",
        snap="MAV260 CEFALVER 12 TAB 1 G",
        nombre="Cefalver cefalexina 1 g",
        qty=3,
        pu=62.49,
        lote="260969",
        sku="FC-492D652F",
        subcategoria="Antibiótico",
        forma="Tableta",
        marca="Cefalver",
        laboratorio="Maver",
        presentacion="Caja con 12 tabletas",
        principio="Cefalexina",
        concentracion="1 g",
        ya=True,
    ),
    row(
        ean="7502209858183",
        codigo="AVT203",
        snap="AVT203 CIDORIX 28 TAB 75 MG",
        nombre="Cidorix clopidogrel 75 mg",
        qty=4,
        pu=18.77,
        lote="SD25083",
        subcategoria="Cardiovascular",
        forma="Tableta",
        marca="Cidorix",
        laboratorio="Avitus",
        presentacion="Caja con 28 tabletas",
        principio="Clopidogrel",
        concentracion="75 mg",
        ya=True,
    ),
    row(
        ean="7502216790490",
        codigo="ULT285",
        snap="ULT285 VILDAGLIPTINA METFORMINA 30 COMP",
        nombre="Vildagliptina/metformina 50/850 mg",
        qty=1,
        pu=172.28,
        lote="6GM021A",
        subcategoria="Diabetes",
        forma="Comprimido",
        marca="Ultra",
        laboratorio="Ultra",
        presentacion="Caja con 30 comprimidos",
        principio="Vildagliptina / metformina",
        concentracion="50/850 mg",
        ya=False,
    ),
    row(
        ean="7500831405888",
        codigo="COL083",
        snap="COL083 PLUS GEL 50 TAB 200/200/20 MG",
        nombre="Plusgel antiácido 200/200/20 mg",
        qty=1,
        pu=48.79,
        lote="26142071",
        sku="FC-31405888",
        categoria="Medicamentos",
        subcategoria="Antiácido",
        forma="Tableta masticable",
        marca="Plusgel",
        laboratorio="Collins",
        presentacion="Frasco con 50 tabletas masticables",
        principio="Hidróxido de aluminio / hidróxido de magnesio / dimeticona",
        concentracion="200/200/20 mg",
        receta=False,
        ya=True,
    ),
]


def main() -> None:
    import csv

    piezas = sum(r["qty"] for r in ROWS)
    sub = round(sum(r["sub"] for r in ROWS), 2)
    assert piezas == 27, piezas
    assert abs(sub - TOTAL) < 0.02, (sub, TOTAL)
    for r in ROWS:
        assert abs(r["pu"] * r["qty"] - r["sub"]) < 0.03, r
        assert not r["nombre"].isupper(), r["nombre"]
        assert len(r["ean"]) >= 12, r["ean"]
        assert r["lote"], r

    altas = sum(1 for r in ROWS if not r["ya"])
    ticket = {
        "key": "equilibrio_241026",
        "header": (
            f"Equilibrio · ticket {FOLIO} · {FECHA} · cliente 307513 Palillero · "
            f"foto sin folio de factura · Total ${TOTAL:,.2f} · "
            f"{len(ROWS)} renglones / {piezas} pzas. "
            "Claves EQF → EAN ficha/Levic/mayoreo. Lote de fábrica sí. "
            "Caducidad NO: MMAA de la caja. 0000 inválido."
        ),
        "tmp": "_fc_eq_241026",
        "folio": FOLIO,
        "proveedor": PROVEEDOR,
        "proveedor_ilike": "equilibrio",
        "fecha": FECHA,
        "total": TOTAL,
        "notas": (
            f"Ticket Equilibrio folio {FOLIO} (foto sin encabezado; cliente 307513 Luis Angel) · "
            f"24-oct-2026 · {piezas} pzas · ${TOTAL:,.2f} · lote de fábrica en renglón; "
            "MMAA de la caja · cola Recibir"
        ),
        "rows": ROWS,
    }

    sql_path = write_carga_sql(ticket)

    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    with OUT_CSV.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow([
            "linea", "folio", "fecha", "proveedor", "ean",
            "descripcion_ticket", "nombre_mostrador", "cantidad",
            "precio_unitario", "subtotal", "lote", "sku_farmacapital",
            "total_ticket", "match",
        ])
        for i, r in enumerate(ROWS, start=1):
            w.writerow([
                i, FOLIO, FECHA, PROVEEDOR, r["ean"],
                r["snap"], r["nombre"], r["qty"],
                f"{r['pu']:.2f}", f"{r['sub']:.2f}", r["lote"], r["sku"],
                f"{TOTAL:.2f}", r["match"],
            ])

    OUT_MD.write_text(
        f"""# Equilibrio {FOLIO} — Recibir

Cliente **307513** Luis Ángel Palillero Ventura · foto térmica 24-oct-2026.

## Qué correr

1. Pegar **todo** `sql/patch_carga_equilibrio_241026.sql` en Supabase → SQL Editor → Run.
2. En Recibir debe aparecer el botón vivo **Equilibrio · {FOLIO}**.
3. Escanear cada caja → MMAA de la caja (no inventar `0000`) → confirmar.

## Totales

- {len(ROWS)} renglones / **{piezas} pzas** / **${TOTAL:,.2f}**
- Folio **{FOLIO}** provisional (`ddmmyy`): la foto no trae el número de factura. Si el papel dice otro, avisar.
- **{altas} altas** stock 0: ULT284 50/500 · AVT202 Cidorix 14 · AMS404 Metamizol AMSA · ULT285 50/850
- Ya en catálogo: Quimikan · Fluconazol AMS495 · Expicin · Cefalver 1 g · Cidorix 28 · Plusgel

## Mapeo ULT284 / ULT285

El ticket solo dice «VILDAGLIPTINA METFORMINA 30COMP». Concentraciones por ficha Ultra + costo mayoreo:

| Clave | EAN | Concentración | P.U. ticket |
|---|---|---|---|
| ULT284 | 7502216790896 | 50/500 mg | $158.27 |
| ULT285 | 7502216790490 | 50/850 mg | $172.28 |

Si al escanear la caja el beep no pega, mandar foto del código y lo corregimos.

## Pendiente

- **Fotos:** packshot en `catalogo-propia/` para las 4 altas (y Quimikan/Expicin si aún no tienen). SQL de `imagen_url` después del deploy.
- AMS404 es **AMSA** (EAN 7501349022126), distinto del Alpharma ALP0628 ya cargado.
- Lote AVT203 en papel: OCR `SD25083` (misma familia que AVT202 `SD26119`).

## Regenerar

`python3 scripts/generar_carga_equilibrio_241026.py`
""",
        encoding="utf-8",
    )

    print(report(ROWS, TOTAL))
    print(f"SQL → {sql_path}")
    print(f"CSV → {OUT_CSV}")
    print(f"MD  → {OUT_MD}")
    print(f"piezas={piezas} sub={sub} altas={altas}")
    for r in ROWS:
        print(
            f"  {r['ean']}  {r['qty']}×{r['pu']:.2f}  "
            f"{'ya' if r['ya'] else 'ALTA'}  {r['nombre']}  lote={r['lote']}"
        )


if __name__ == "__main__":
    main()
