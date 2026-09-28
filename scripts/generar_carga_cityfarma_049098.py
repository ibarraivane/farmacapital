#!/usr/bin/env python3
"""Cityfarma Iztapalapa · factura INV/2026/09/2057 · folio 049098 (28-sep-2026).

CFDI Yalesa / City Farma · receptor Palillero · tarjeta.
16 renglones / 34 pzas · subtotal $6,431.19 + IVA $133.85 = TOTAL $6,565.04.
Costo = Precio U de la factura (antes de IVA). Sin lote ni MMAA.
"""
from __future__ import annotations

import csv
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_carga_tickets_20260915 import report, sku_de, sql_str, write_carga_sql

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "sql"
GEN_DIR = ROOT / "sql" / "generated"
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"

FOLIO = "049098"
PROVEEDOR = "Cityfarma Iztapalapa"
FECHA = "2026-09-28"
TOTAL = 6565.04


def ceil_pvp(costo: float, tipo: str) -> int:
    factor = 1.25 if tipo == "marca" else 1.6
    return int(math.ceil(costo * factor))


def foto(name: str | None) -> tuple[str | None, str | None]:
    if not name:
        return None, None
    path = ROOT / "public" / "catalogo-propia" / name
    if not path.exists() or path.stat().st_size < 4000:
        return None, None
    return f"{FOTO_BASE}/{name}", f"catalogo-propia/{name}"


def p(
    ean: str,
    *,
    nombre: str,
    tipo: str = "marca",
    categoria: str = "Medicamentos",
    subcategoria: str | None = None,
    forma: str | None = None,
    marca: str | None = None,
    laboratorio: str | None = None,
    presentacion: str | None = None,
    principio: str | None = None,
    concentracion: str | None = None,
    receta: bool = False,
    ya: bool = False,
    sku: str | None = None,
    foto_name: str | None = None,
) -> dict:
    url, rel = foto(foto_name)
    return {
        "sku": sku or sku_de(ean),
        "nombre": nombre,
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
        "foto": url,
        "foto_file": rel,
    }


PRODUCTOS = {
    "8429420084520": p(
        "8429420084520",
        sku="FC-20084520",
        nombre="Bexident Post colutorio 250 ml",
        categoria="Cuidado personal",
        subcategoria="Bucal",
        forma="Colutorio",
        marca="Bexident",
        laboratorio="Isdin",
        presentacion="Frasco 250 ml",
        foto_name="isdin-bexident-post-colutorio-250ml-8429420084520.jpg",
    ),
    "8429420084674": p(
        "8429420084674",
        sku="FC-20084674",
        nombre="Bexident Post gel tópico 25 ml",
        categoria="Cuidado personal",
        subcategoria="Bucal",
        forma="Gel",
        marca="Bexident",
        laboratorio="Isdin",
        presentacion="Tubo 25 ml",
        foto_name="isdin-bexident-post-gel-25ml-8429420084674.jpg",
    ),
    "7501385491085": p(
        "7501385491085",
        sku="FC-85491085",
        nombre="Danzen serratiopeptidasa 10 mg C/20",
        marca="Danzen",
        laboratorio="Hormona",
        forma="Tableta",
        presentacion="Caja con 20 tabletas",
        principio="Serratiopeptidasa",
        concentracion="10 mg",
        receta=True,
        ya=True,
    ),
    "7501298223711": p(
        "7501298223711",
        nombre="Dolo Neurobion C/10",
        marca="Neurobion",
        laboratorio="Probiomed",
        forma="Tableta",
        presentacion="Caja con 10 tabletas",
        principio="Diclofenaco / vitaminas B1 B6 B12",
        categoria="Vitaminas",
    ),
    "7501298223728": p(
        "7501298223728",
        nombre="Dolo Neurobion C/5",
        marca="Neurobion",
        laboratorio="Probiomed",
        forma="Tableta",
        presentacion="Caja con 5 tabletas",
        principio="Diclofenaco / vitaminas B1 B6 B12",
        categoria="Vitaminas",
    ),
    "7501008497340": p(
        "7501008497340",
        sku="FC-84973401",
        nombre="Flanax naproxeno 550 mg C/12",
        marca="Flanax",
        laboratorio="Bayer",
        forma="Tableta",
        presentacion="Caja con 12 tabletas",
        principio="Naproxeno",
        concentracion="550 mg",
        ya=True,
    ),
    "7502276040351": p(
        "7502276040351",
        sku="FC-6040351",
        nombre="Lotrimin Uno crema 1% 20 g",
        marca="Lotrimin Uno",
        laboratorio="Bayer",
        forma="Crema",
        presentacion="Tubo 20 g",
        principio="Bifonazol",
        concentracion="1%",
        subcategoria="Dermatología",
        ya=True,
    ),
    "7500435131834": p(
        "7500435131834",
        nombre="Pepto-Bismol masticable C/12",
        marca="Pepto-Bismol",
        laboratorio="P&G",
        forma="Tableta masticable",
        presentacion="Caja con 12 tabletas",
        principio="Subsalicilato de bismuto",
        categoria="Gastro",
        subcategoria="Antidiarreico",
    ),
    "7502240450230": p(
        "7502240450230",
        sku="FC-40450230",
        nombre="Rosel solución infantil 60 ml",
        marca="Rosel",
        laboratorio="Wermar",
        forma="Solución",
        presentacion="Frasco 60 ml",
        principio="Paracetamol / amantadina / clorfenamina",
        concentracion="3 / 0.5 / 0.02 g / 60 ml",
        subcategoria="Respiratorio",
        ya=True,
    ),
    "7501314703227": p(
        "7501314703227",
        nombre="Sies hidrosmina 200 mg C/20",
        marca="Sies",
        laboratorio="Ferrer",
        forma="Cápsula",
        presentacion="Caja con 20 cápsulas",
        principio="Hidrosmina",
        concentracion="200 mg",
        receta=True,
    ),
    "7501080912083": p(
        "7501080912083",
        nombre="Sterimar solución nasal 50 ml",
        marca="Sterimar",
        laboratorio="Sofibel",
        forma="Spray nasal",
        presentacion="Frasco 50 ml",
        subcategoria="Respiratorio",
    ),
    "7501088505430": p(
        "7501088505430",
        nombre="Synalar Simple fluocinolona 0.01% crema 20 g",
        marca="Synalar",
        laboratorio="CHINOIN",
        forma="Crema",
        presentacion="Tubo 20 g",
        principio="Fluocinolona acetónido",
        concentracion="0.01%",
        subcategoria="Dermatología",
        receta=True,
    ),
    "7501088505454": p(
        "7501088505454",
        nombre="Synalar Simple fluocinolona 0.025% crema 20 g",
        marca="Synalar",
        laboratorio="CHINOIN",
        forma="Crema",
        presentacion="Tubo 20 g",
        principio="Fluocinolona acetónido",
        concentracion="0.025%",
        subcategoria="Dermatología",
        receta=True,
    ),
    "7501065026439": p(
        "7501065026439",
        nombre="Tesalon benzonatato 100 mg C/20",
        marca="Tesalon",
        laboratorio="GSK",
        forma="Perla / tableta",
        presentacion="Caja con 20",
        principio="Benzonatato",
        concentracion="100 mg",
        subcategoria="Respiratorio",
    ),
    "3662042003059": p(
        "3662042003059",
        sku="FC-42003059",
        nombre="Thealoz Duo gotas 10 ml",
        marca="Thealoz Duo",
        laboratorio="Théa",
        forma="Gotas oftálmicas",
        presentacion="Frasco 10 ml",
        principio="Trehalosa / hialuronato de sodio",
        concentracion="3% / 0.15%",
        categoria="Oftálmico",
        subcategoria="Sequedad ocular",
        foto_name="thealoz-duo-gotas-10ml-3662042003059.jpg",
        # Misma SKU que Surtidor 136447 (si ya pegaron ese SQL, solo actualiza costo).
    ),
    "7501037925579": p(
        "7501037925579",
        nombre="Trayenta linagliptina 5 mg C/30",
        marca="Trayenta",
        laboratorio="Boehringer Ingelheim",
        forma="Tableta",
        presentacion="Caja con 30 tabletas",
        principio="Linagliptina",
        concentracion="5 mg",
        categoria="Diabetes",
        receta=True,
    ),
}


def row(ean: str, snap: str, qty: int, pu: float) -> dict:
    meta = PRODUCTOS[ean]
    sub = round(qty * pu, 2)
    return {
        "ean": ean,
        "sku": meta["sku"],
        "snap": snap,
        "nombre": meta["nombre"],
        "qty": qty,
        "pu": pu,
        "sub": sub,
        "lote": None,
        **{
            k: meta[k]
            for k in (
                "tipo",
                "categoria",
                "subcategoria",
                "forma",
                "marca",
                "laboratorio",
                "presentacion",
                "principio",
                "concentracion",
                "receta",
                "ya",
                "foto",
                "foto_file",
            )
        },
        "precio": ceil_pvp(pu, meta["tipo"]),
        "match": "ya" if meta["ya"] else "alta",
    }


ROWS = [
    row("8429420084520", "BEXIDENT POST COLUT 250 ML", 1, 359.14),
    row("8429420084674", "BEXIDENT POST GEL TOPICO 25ML", 1, 226.10),
    row("7501385491085", "DANZEN 10MG C20 TABS HORMONA", 1, 388.82),
    row("7501298223711", "DOLO NEUROBION TAB C 10", 3, 158.00),
    row("7501298223728", "DOLO NEUROBION TAB C5", 3, 87.00),
    row("7501008497340", "FLANAX 550 C 12 TABS 162", 2, 176.38),
    row("7502276040351", "LOTRIMIN UNO CRA 1% 20G", 3, 70.24),
    row("7500435131834", "PEPTO BISMOL MAST C12TAB", 2, 48.92),
    row("7502240450230", "ROSEL SOL INF 60ML", 3, 24.71),
    row("7501314703227", "SIES 200MG CAPS C20 HIDROSMINA", 2, 414.80),
    row("7501080912083", "STERIMAR SOLUCION C 50 ML", 2, 125.67),
    row("7501088505430", "SYNALAR SIMPLE 0.01% CRA 20GR", 2, 131.52),
    row("7501088505454", "SYNALAR SIMPLE 0.025% CRA 20GR", 1, 181.36),
    row("7501065026439", "TESALON 100MG C20TABS", 3, 145.37),
    row("3662042003059", "THEALOZ DUO 10ML", 1, 537.23),
    row("7501037925579", "TRAYENTA 5MG T30", 4, 372.00),
]


def write_csv(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow([
            "linea", "folio", "fecha", "proveedor", "ean",
            "descripcion_ticket", "nombre_mostrador", "cantidad",
            "precio_unitario", "subtotal", "lote", "caducidad",
            "sku_farmacapital", "total_ticket", "match",
        ])
        for i, r in enumerate(ROWS, start=1):
            w.writerow([
                i, FOLIO, FECHA, PROVEEDOR, r["ean"],
                r["snap"], r["nombre"], r["qty"],
                f"{r['pu']:.2f}", f"{r['sub']:.2f}",
                "", "",
                r["sku"], f"{TOTAL:.2f}", r["match"],
            ])


def write_leerme(path: Path) -> None:
    altas = [r for r in ROWS if not r["ya"]]
    ya = [r for r in ROWS if r["ya"]]
    lines = [
        "# Ticket Cityfarma 049098 · 28-sep-2026",
        "",
        "Factura CFDI `INV/2026/09/2057` · Folio **049098** · Yalesa / City Farma.",
        "Pegar `sql/patch_carga_cityfarma_049098.sql` en Supabase → SQL Editor → Run.",
        "",
        f"| Piezas | Subtotal | IVA 16% | **Total** |",
        f"|--------|----------|---------|-----------|",
        f"| 34 | $6,431.19 | $133.85 | **$6,565.04** |",
        "",
        f"**Altas nuevas ({len(altas)}):** " + ", ".join(r["nombre"] for r in altas),
        "",
        f"**Ya en catálogo ({len(ya)}):** " + ", ".join(r["nombre"] for r in ya),
        "",
        "## Notas",
        "",
        "- Costo = Precio U de la factura (antes de IVA).",
        "- Recargo marca +25% / genérico +60% solo si PVP estaba en 0.",
        "- Sin lote ni caducidad: MMAA de la caja al escanear. No inventar `0000`.",
        "- Thealoz Duo: misma SKU `FC-42003059` que El Surtidor 136447 (idempotente).",
        "- Bexident: fotos Isdin en `public/catalogo-propia/` (tras deploy).",
        "- Regenerar: `python3 scripts/generar_carga_cityfarma_049098.py`",
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    suma = sum(r["sub"] for r in ROWS)
    piezas = sum(r["qty"] for r in ROWS)
    assert abs(suma - 6431.19) < 0.02, (suma, 6431.19)
    assert piezas == 34, piezas
    for r in ROWS:
        assert abs(r["pu"] * r["qty"] - r["sub"]) < 0.03, r
        assert not r["nombre"].isupper() or len(r["nombre"]) < 8, r["nombre"]

    ticket = {
        "key": "cityfarma_049098",
        "folio": FOLIO,
        "proveedor": PROVEEDOR,
        "proveedor_ilike": "cityfarma",
        "fecha": FECHA,
        "total": TOTAL,
        "notas": (
            "Factura Cityfarma INV/2026/09/2057 · folio 049098 · 28-sep-2026 16:45 · "
            "Yalesa DFY171116BKA · cliente Palillero · tarjeta · "
            "subtotal $6,431.19 + IVA $133.85 = $6,565.04 · "
            "cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_cf_049098",
        "header": (
            "Cityfarma Iztapalapa · factura INV/2026/09/2057 · folio 049098 · 2026-09-28\n"
            "-- CFDI Yalesa (DFY171116BKA). 16 renglones / 34 pzas.\n"
            "-- Subtotal $6,431.19 + IVA 16% $133.85 = TOTAL $6,565.04.\n"
            "-- Costo = Precio U de la factura (antes de IVA).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": ROWS,
    }

    write_csv(GEN_DIR / "ticket_cityfarma_049098.csv")
    sql_path = write_carga_sql(ticket)
    write_leerme(OUT_DIR / "LEERME_ticket_cityfarma_049098.md")
    print(report(ROWS, TOTAL))
    print(f"piezas={piezas} subtotal={suma:.2f} total={TOTAL:.2f}")
    print(f"sql={sql_path}")
    print("altas", sum(1 for r in ROWS if not r["ya"]), "ya", sum(1 for r in ROWS if r["ya"]))
    for r in ROWS:
        print(
            f"  {r['ean']}  {r['qty']}×{r['pu']:.2f}  "
            f"{'ya' if r['ya'] else 'ALTA'}  "
            f"{'foto' if r['foto'] else 'SIN FOTO'}  {r['nombre']}"
        )


if __name__ == "__main__":
    main()
