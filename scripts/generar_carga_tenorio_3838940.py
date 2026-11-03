#!/usr/bin/env python3
"""Factura Farmacéuticos Tenorio folio 3838940 (02-nov-2026) → cola Recibir.

Foto del ticket. Costos = importe / cantidad (IVA 0).
Nombres de mostrador desde ficha (no el código del papel).
Lote de la factura. Caducidad null: MMAA de la caja.
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_carga_tickets_20260915 import (  # noqa: E402
    ceil_pvp,
    foto_url,
    report,
    sku_de,
    write_carga_sql,
)
from generar_recepcion_borrador import write_ticket_csv  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "sql"
GEN_DIR = ROOT / "sql" / "generated"
OUT_LEERME = OUT_DIR / "LEERME_tenorio_3838940.md"


def p(
    ean: str,
    *,
    nombre: str,
    tipo: str = "generico",
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
    foto_file: str | None = None,
) -> dict:
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
        "foto": foto_url(foto_file) if foto_file else None,
        "foto_file": f"catalogo-propia/{foto_file}" if foto_file else None,
    }


PRODUCTOS: dict[str, dict] = {
    # Ya en catálogo (FC-5C8C9C11). Mismo EAN en Tenorio 3811849.
    "7503027446279": p(
        "7503027446279",
        sku="FC-5C8C9C11",
        nombre="Gelubrin 600 mg",
        tipo="generico",
        categoria="Antiinflamatorio",
        forma="Cápsulas",
        marca="Gelubrin",
        laboratorio="Progela",
        presentacion="Caja con 10 cápsulas",
        principio="Ibuprofeno",
        concentracion="600 mg",
        ya=True,
        foto_file="gelubrin-600-7503027446279.jpg",
    ),
    # Raypid (Rayere) — ficha Vitau / BuscaMed EAN exacto.
    "7502003386547": p(
        "7502003386547",
        nombre="Raypid 600 mg",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Lípidos",
        forma="Tabletas",
        marca="Raypid",
        laboratorio="Rayere",
        presentacion="Caja con 14 tabletas",
        principio="Gemfibrozilo",
        concentracion="600 mg",
        receta=True,
        foto_file="raypid-600-c14-7502003386547.jpg",
    ),
    # Doxon (Maver) C/10 — sufarmed EAN 7502009746222.
    "7502009746222": p(
        "7502009746222",
        nombre="Doxon 25 mg",
        tipo="generico",
        categoria="Analgésico",
        forma="Tabletas",
        marca="Doxon",
        laboratorio="Maver",
        presentacion="Caja con 10 tabletas",
        principio="Dexketoprofeno",
        concentracion="25 mg",
        # 513M2016 SSA IV.
        receta=True,
        foto_file="doxon-25mg-c10-7502009746222.jpg",
    ),
    # Doxon (Maver) C/20 — mismo principio, otra presentación.
    "7502009748844": p(
        "7502009748844",
        nombre="Doxon 25 mg",
        tipo="generico",
        categoria="Analgésico",
        forma="Tabletas",
        marca="Doxon",
        laboratorio="Maver",
        presentacion="Caja con 20 tabletas",
        principio="Dexketoprofeno",
        concentracion="25 mg",
        receta=True,
        # Foto C/20 pendiente: no reusar packshot C/10.
    ),
    # Sobres 25 mg/10 ml — EAN válido; marca no confirmada en ficha pública.
    "7503045798336": p(
        "7503045798336",
        nombre="Dexketoprofeno 25 mg/10 ml",
        tipo="generico",
        categoria="Analgésico",
        forma="Solución",
        marca=None,
        laboratorio=None,
        presentacion="Sobres",
        principio="Dexketoprofeno",
        concentracion="25 mg/10 ml",
        receta=True,
        # Foto pendiente.
    ),
    # Aliren (Siegfried Rhein) — ficha PLM / BuscaMed EAN 7501300420541.
    "7501300420541": p(
        "7501300420541",
        nombre="Aliren 50/3/300 mg",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Respiratorio",
        forma="Cápsulas",
        marca="Aliren",
        laboratorio="Siegfried Rhein",
        presentacion="Caja con 24 cápsulas",
        principio="Amantadina / clorfenamina / paracetamol",
        concentracion="50/3/300 mg",
        # OTC antigripal (Fahorro/YZA: sin receta).
        receta=False,
        foto_file="aliren-50-3-300-c24-7501300420541.jpg",
    ),
}


def row(ean: str, snap: str, qty: int, pu: float, lote: str) -> dict:
    prod = PRODUCTOS[ean]
    return {
        "ean": ean,
        "sku": prod["sku"],
        "snap": snap,
        "nombre": prod["nombre"],
        "qty": qty,
        "pu": pu,
        "sub": round(qty * pu, 2),
        "lote": lote,
        **{
            k: prod[k]
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
        "precio": ceil_pvp(pu, prod["tipo"]),
        "match": "ya" if prod["ya"] else "alta",
    }


TICKET = {
    "key": "tenorio_3838940",
    "folio": "3838940",
    "proveedor": "Farmaceuticos Tenorio",
    "proveedor_ilike": "tenorio",
    "fecha": "2026-11-02",
    "total": 1148.52,
    "notas": (
        "Factura Farmaceuticos Tenorio folio 3838940 · 02-nov-2026 07:43 · "
        "cliente 20077 Palillero Ventura · ref 2150638 · ruta Puebla · 1 caja · "
        "cola Recibir, stock al confirmar pistola y MMAA"
    ),
    "tmp": "_fc_tn_3838940",
    "header": (
        "Farmaceuticos Tenorio · folio 3838940 · 2026-11-02 07:43\n"
        "-- Cliente 20077 Palillero Ventura Luis Angel. Ref 2150638. Ruta Puebla. 1 caja.\n"
        "-- Subtotal 1148.52 + IVA 0.00 = 1148.52. Costo = importe / cantidad.\n"
        "-- Lote de la factura. Caducidad null: MMAA de la caja. No inventar 0000.\n"
        "-- Gelubrin ya existía (FC-5C8C9C11). Altas: Raypid, Doxon C/10 y C/20,\n"
        "-- Dexketoprofeno sobres (marca no confirmada), Aliren."
    ),
    "rows": [
        row("7503027446279", "GELUBRIN 600MG CAP C/10 *PRO*", 30, 18.11, "U0591"),
        row("7502003386547", "GEMFIBROZILO 600MG TAB C/14 *RAY*", 2, 89.19, "26104"),
        row("7502009746222", "DEXKETOPROFENO 25MG TAB C/10 *MVE*", 2, 59.00, "263460"),
        row("7502009748844", "DEXKETOPROFENO 25MG TAB C/20 *MVE*", 1, 113.77, "262635"),
        row("7503045798336", "DEXKETOPROFENO 25MG/10ML SOBRES", 1, 80.96, "266319"),
        row("7501300420541", "ALIREN 50/3/300MG CAP C/24 *SGF*", 1, 114.11, "261358"),
    ],
}


def write_leerme(items: list) -> None:
    lines = [
        "# Tenorio folio 3838940 · 02-nov-2026 · $1,148.52",
        "",
        "Factura Farmacéuticos Tenorio (foto). Cliente **20077** Palillero Ventura. Ref **2150638**.",
        "",
        "## Veredicto",
        "",
        "**Ticket nuevo.** 6 renglones, 37 piezas. Gelubrin ya estaba; el resto es alta.",
        "",
        "| EAN | Ticket | SKU | Nombre mostrador | Qty | Costo |",
        "|---|---|---|---|---|---|",
    ]
    for r in items:
        lines.append(
            f"| `{r['ean']}` | {r['snap']} | `{r['sku']}` | {r['nombre']} | {r['qty']} | ${r['pu']:.2f} |"
        )
    lines += [
        "",
        "### Notas",
        "",
        "1. Costo unitario = importe ÷ cantidad (IVA $0).",
        "2. Lote de la factura. Caducidad **null** → MMAA de la caja. No `0000`.",
        "3. Dexketoprofeno sobres (`7503045798336`): marca no salió en ficha pública; nombre por molécula.",
        "4. Fotos: Gelubrin / Raypid / Doxon C/10 / Aliren en `catalogo-propia/`. Doxon C/20 y sobres: pendientes.",
        "",
        "## Qué pegar en Supabase",
        "",
        "1. `sql/patch_carga_tenorio_3838940.sql` — altas + cola Recibir borrador.",
        "2. Tras deploy Vercel: las URLs `farmacapital.mx/catalogo-propia/…` ya apuntan a las fotos del PR.",
        "",
        "CSV: `sql/generated/ticket_tenorio_3838940.csv`.",
        "",
        "Stock **0** hasta pistola + MMAA.",
        "",
        "Auditoría de tickets recientes: `sql/diag_recepciones_recientes_20261103.sql`.",
        "",
        "Regenerar: `python3 scripts/generar_carga_tenorio_3838940.py`",
        "",
    ]
    OUT_LEERME.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    GEN_DIR.mkdir(parents=True, exist_ok=True)
    t = TICKET
    for r in t["rows"]:
        r["sub"] = round(r["qty"] * r["pu"], 2)
        r["precio"] = ceil_pvp(r["pu"], r["tipo"])
    suma = round(sum(r["sub"] for r in t["rows"]), 2)
    if abs(suma - t["total"]) > 0.02:
        raise SystemExit(f"suma renglones {suma} ≠ total {t['total']}")
    if ";" in t["notas"] or ";" in t["header"]:
        raise SystemExit("el ticket no puede llevar punto y coma en notas ni comentarios")

    csv_path = GEN_DIR / "ticket_tenorio_3838940.csv"
    write_ticket_csv(
        csv_path,
        folio=t["folio"],
        fecha=t["fecha"],
        proveedor=t["proveedor"],
        total=t["total"],
        rows=[
            {
                "ean": r["ean"],
                "nombre": r["snap"],
                "qty": r["qty"],
                "pu": r["pu"],
                "sub": r["sub"],
                "sku": r["sku"],
                "match": r["match"],
            }
            for r in t["rows"]
        ],
    )
    sql_path = write_carga_sql(t)
    write_leerme(t["rows"])
    print(f"{t['folio']}: {report(t['rows'], t['total'])}")
    print(f"  → {csv_path.relative_to(ROOT)}")
    print(f"  → {sql_path.relative_to(ROOT)}")
    print(f"  → {OUT_LEERME.relative_to(ROOT)}")
    for r in t["rows"]:
        print(
            f"  {r['sku']}  {r['ean']}  ×{r['qty']}  ${r['pu']:.2f} → ${r['precio']}  "
            f"{r['nombre']}  ({'ya' if r['ya'] else 'alta'})"
        )


if __name__ == "__main__":
    main()
