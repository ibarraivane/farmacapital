#!/usr/bin/env python3
"""Farmalive · ticket 12127 · Club Iztapalapa 1 · 28-sep-2026.

Ticket térmico Club de Precios · 109 renglones / 238 pzas · TOTAL $11,696.80.
Costo = P.U. neto (después de Descto). Sin lote ni MMAA.
Suerox: ticket trunca a 12 dígitos → EAN canónico del catálogo (650…1 / 650…2).
"""
from __future__ import annotations

import csv
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _data_farmalive_12127_productos import PRODUCTOS, TICKET_ROWS
from generar_carga_tickets_20260915 import report, sku_de, write_carga_sql

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "sql"
GEN_DIR = ROOT / "sql" / "generated"
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"
FOTO_DIR = ROOT / "public" / "catalogo-propia"

FOLIO = "12127"
PROVEEDOR = "Farmalive"
FECHA = "2026-09-28"
TOTAL = 11696.80

# EAN ya vistos en historial / tickets previos (solo costo; no pisa PVP).
KNOWN_YA = {
    "020800600330",
    "056100024798",
    "5000174305449",
    "6502400323252",
    "6502400721541",
    "6502400744481",
    "7500435169035",
    "7500435179980",
    "7501008491966",
    "7501008494226",
    "7501019006623",
    "7501019006647",
    "7501019036590",
    "7501019050664",
    "7501033960499",
    "7501048623006",
    "7501056342227",
    "7501056342258",
    "7501059233072",
    "7501059282117",
    "7501070600556",
    "7501070600730",
    "7501125116810",
    "7501289511414",
    "7501289511421",
    "7501385491146",
    "7501537103422",
    "7501537163266",
    "7501537182960",
    "7501573900115",
    "7501573900375",
    "7501573900535",
    "7501836003621",
    "7501943471900",
    "7502001166066",
    "7502250343065",
    "7502250343072",
    "7502250343102",
    "7503003406785",
    "7506376000260",
    "7506376000277",
    "7506386100158",
    "7891051037878",
    "78924338",
    "78924345",
    "78926523",
}

# Fotos locales → nombre de archivo en catalogo-propia/
FOTO_POR_EAN = {
    "6502400368802": "silka-medic-spray-150ml-6502400368802.jpg",
    "6758730020570": "sukrol-hombre-30-tab-6758730020570.jpg",
    "6758730020716": "sukrol-mujer-30-tab-6758730020716.jpg",
    "7500435162241": "head-shoulders-2en1-650ml-7500435162241.jpg",
    "7500435179980": "oral-b-enjuague-100-250ml.jpg",
    "7501008491041": "lotrimin-power-spray-150ml-7501008491041.jpg",
    "7501033958717": "ensure-advance-vainilla-237ml-7501033958717.jpg",
    "7501033960499": "ensure-advance-suplemento-l-quido-237-ml-7501033960499.jpg",
    "7501033962530": "ensure-advance-cafe-237ml-7501033962530.jpg",
    "7501058799685": "sico-mutual-climax-3-7501058799685.jpg",
    "7501059225350": "nido-kinder-800g-7501059225350.jpg",
    "7501080911178": "sterimar-cobre-100ml-7501080911178.jpg",
    "7501080911185": "sterimar-alergias-100ml-7501080911185.jpg",
    "7501080912274": "sterimar-bebe-50ml-7501080912274.jpg",
    "7501080954212": "sterimar-infantil-50ml-7501080954212.jpg",
    "7501943444966": "kleenbebe-suavelastic-jumbo-40-7501943444966.jpg",
    "7501943447615": "kleenbebe-suavelastic-extra-jumbo-40-7501943447615.jpg",
    "7501943498815": "kleenbebe-suavelastic-recien-nacido-40-7501943498815.jpg",
    "7502250340255": "vitacilina-bebe-110g-7502250340255.jpg",
    "7502250340521": "vitacilina-unguento-32g-7502250340521.jpg",
    "7502250343065": "vitacilina-unguento-16g.jpg",
    "7502250343072": "vitacilina-unguento-28g.jpg",
    "7502276040566": "lotrimin-uno-crema-20g-7502276040566.jpg",
    "7803510003409": "ciruelax-forte-24-tab-7803510003409.jpg",
    "7891051037878": "oral-b-enjuague-complet-250ml.jpg",
    "78924345": "rexona-women-bamboo-roll-on-50-ml-78924345.jpg",
}


def ceil_pvp(costo: float, tipo: str) -> int:
    factor = 1.25 if tipo == "marca" else 1.6
    return int(math.ceil(costo * factor))


def foto(ean: str, foto_file: str | None) -> tuple[str | None, str | None]:
    name = FOTO_POR_EAN.get(ean) or foto_file
    if not name:
        return None, None
    path = FOTO_DIR / name
    if not path.exists() or path.stat().st_size < 4000:
        return None, None
    return f"{FOTO_BASE}/{name}", f"catalogo-propia/{name}"


def row(ean: str, snap: str, qty: int, pu: float) -> dict:
    meta = dict(PRODUCTOS[ean])
    # Preferir señal de catálogo histórico sobre el default del data module.
    if ean in KNOWN_YA:
        meta["ya"] = True
    url, rel = foto(ean, meta.get("foto_file"))
    sub = round(qty * pu, 2)
    return {
        "ean": ean,
        "sku": meta.get("sku") or sku_de(ean),
        "snap": snap,
        "nombre": meta["nombre"],
        "qty": qty,
        "pu": pu,
        "sub": sub,
        "lote": None,
        "tipo": meta["tipo"],
        "categoria": meta["categoria"],
        "subcategoria": meta.get("subcategoria"),
        "forma": meta.get("forma"),
        "marca": meta.get("marca"),
        "laboratorio": meta.get("laboratorio"),
        "presentacion": meta.get("presentacion"),
        "principio": meta.get("principio"),
        "concentracion": meta.get("concentracion"),
        "receta": bool(meta.get("receta")),
        "ya": bool(meta["ya"]),
        "foto": url,
        "foto_file": rel,
        "precio": ceil_pvp(pu, meta["tipo"]),
        "match": "ya" if meta["ya"] else "alta",
    }


ROWS = [row(ean, snap, qty, pu) for ean, snap, qty, pu in TICKET_ROWS]


def write_csv(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(
            [
                "linea",
                "folio",
                "fecha",
                "proveedor",
                "ean",
                "descripcion_ticket",
                "nombre_mostrador",
                "cantidad",
                "precio_unitario",
                "subtotal",
                "lote",
                "caducidad",
                "sku_farmacapital",
                "total_ticket",
                "match",
            ]
        )
        for i, r in enumerate(ROWS, start=1):
            w.writerow(
                [
                    i,
                    FOLIO,
                    FECHA,
                    PROVEEDOR,
                    r["ean"],
                    r["snap"],
                    r["nombre"],
                    r["qty"],
                    f"{r['pu']:.2f}",
                    f"{r['sub']:.2f}",
                    "",
                    "",
                    r["sku"],
                    f"{TOTAL:.2f}",
                    r["match"],
                ]
            )


def write_leerme(path: Path) -> None:
    altas = [r for r in ROWS if not r["ya"]]
    ya = [r for r in ROWS if r["ya"]]
    sin_foto = [r for r in altas if not r["foto"]]
    piezas = sum(r["qty"] for r in ROWS)
    lines = [
        "# Ticket Farmalive 12127 · 28-sep-2026",
        "",
        "Club Iztapalapa 1 · Club de Precios · ticket **12127** · 28/09/2026 16:24.",
        "Pegar `sql/patch_carga_farmalive_12127.sql` en Supabase → SQL Editor → Run.",
        "",
        f"| Artículos | Piezas | Subtotal ticket | Descuento | **Total** |",
        f"|-----------|--------|-----------------|-----------|-----------|",
        f"| 109 | {piezas} | $12,642.62 | −$945.82 | **$11,696.80** |",
        "",
        f"**Altas nuevas ({len(altas)} SKUs):** stock 0 hasta Recibir.",
        "",
        f"**Ya en catálogo ({len(ya)} renglones):** solo costo / ficha vacía; no pisa PVP.",
        "",
        "## Notas",
        "",
        "- Costo = P.U. neto del ticket (después de Descto 2–15%).",
        "- Recargo marca +25% / genérico +60% solo si PVP estaba en 0.",
        "- Sin lote ni caducidad: MMAA de la caja al escanear. No inventar `0000`.",
        "- Suerox: ticket imprime 12 dígitos; SQL usa EAN canónico del catálogo "
        "(`6502400721541`, `6502400744481`, `6502400323252`).",
        "- Rexona roll-on: códigos cortos del catálogo (`78924345`, `78924338`, `78926523`).",
        "- Cloranfenicol Exakta: ticket truncó a `75049638` (se conserva; pistola puede "
        "traer EAN completo de la caja).",
        "- Alliviax C/20 y 1× Sico Mutual vienen a $0.01 (promo ticket).",
        "- Centavos: NIDO Kinder bolsa 8×$29.36 imprime $234.84; suma renglones "
        f"${sum(r['sub'] for r in ROWS):,.2f} vs total ticket $11,696.80 (±$0.17).",
        f"- Altas sin packshot local ({len(sin_foto)}): conseguir foto o SQL de foto "
        "después del deploy. No usar placeholder Fahorro.",
        "- Regenerar: `python3 scripts/generar_carga_farmalive_12127.py`",
        "",
        "## Altas (nombre mostrador)",
        "",
    ]
    for r in sorted({r["ean"]: r for r in altas}.values(), key=lambda x: x["nombre"]):
        flag = "foto" if r["foto"] else "SIN FOTO"
        lines.append(f"- `{r['ean']}` {r['nombre']} · {flag}")
    lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    suma = sum(r["sub"] for r in ROWS)
    piezas = sum(r["qty"] for r in ROWS)
    assert piezas == 238, piezas
    assert len(ROWS) == 109, len(ROWS)
    # Farmalive redondea Descto por línea; total impreso puede diferir unos centavos.
    assert abs(suma - TOTAL) < 0.25, (suma, TOTAL)
    for r in ROWS:
        assert r["ean"] in PRODUCTOS, r["ean"]
        assert r["nombre"] and not r["nombre"].isupper(), r["nombre"]
        assert "C/" not in r["nombre"], r["nombre"]

    ticket = {
        "key": "farmalive_12127",
        "folio": FOLIO,
        "proveedor": PROVEEDOR,
        "proveedor_ilike": "farmalive",
        "fecha": FECHA,
        "total": TOTAL,
        "notas": (
            "Ticket Farmalive 12127 · Club Iztapalapa 1 · 28-sep-2026 16:24 · "
            "Club de Precios · tarjeta · 109 art / 238 pzas · "
            "subtotal $12,642.62 − desc $945.82 = $11,696.80 · "
            "precio neto · Suerox EAN canónico · "
            "cola Recibir; stock al confirmar pistola + MMAA"
        ),
        "tmp": "_fc_fl_12127",
        "header": (
            "Farmalive · ticket 12127 · 2026-09-28 16:24 · Club Iztapalapa 1\n"
            "-- Total $11,696.80 · 109 artículos / 238 unidades.\n"
            "-- Costo = P.U. neto (Descto 2–15%). Ticket trunca Suerox a 12 dígitos.\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": ROWS,
    }

    write_csv(GEN_DIR / "ticket_farmalive_12127.csv")
    sql_path = write_carga_sql(ticket)
    write_leerme(OUT_DIR / "LEERME_ticket_farmalive_12127.md")
    print(report(ROWS, TOTAL))
    print(f"piezas={piezas} suma_renglones={suma:.2f} total_ticket={TOTAL:.2f}")
    print(f"sql={sql_path}")
    altas = sum(1 for r in ROWS if not r["ya"])
    ya = sum(1 for r in ROWS if r["ya"])
    foto_n = sum(1 for r in ROWS if r["foto"] and not r["ya"])
    print(f"altas={altas} ya={ya} altas_con_foto={foto_n}")
    for r in ROWS:
        if r["ya"]:
            continue
        print(
            f"  ALTA {r['ean']}  {r['qty']}×{r['pu']:.2f}  "
            f"{'foto' if r['foto'] else 'SIN FOTO'}  {r['nombre']}"
        )


if __name__ == "__main__":
    main()
