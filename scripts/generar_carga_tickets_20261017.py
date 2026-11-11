#!/usr/bin/env python3
"""Tickets 17-oct-2026 (fotos) → cola Recibir.

3 pedidos:
  Citymark Caja 1/75116 · Farmalive 14702 · Cityfarma S332558

Nombres de mostrador desde ficha (no el código del ticket).
Sin caducidad inventada (MMAA de la caja). Sin lote en estos tickets.
Citymark: el P.U. impreso ya trae IVA (la suma de renglones = total).
Farmalive: costo = P.U. neto después del 2% del renglón.
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
    sql_str,
    write_carga_sql,
)
from generar_recepcion_borrador import write_ticket_csv  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "sql"
GEN_DIR = ROOT / "sql" / "generated"


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
    # Citymark. Ya en catálogo: no pisar nombre ni foto.
    "7502253600486": p(
        "7502253600486",
        sku="FC-00E8A9C7",
        nombre="Fotosun UV 100 FPS 50+",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Protector solar",
        forma="Crema",
        marca="Fotosun",
        laboratorio="Daclaf",
        presentacion="Tubo 125 mL",
        concentracion="FPS 50+",
        ya=True,
        foto_file="fotosun-uv100-fps50-125ml-7502253600486.jpg",
    ),
    "7501056340117": p(
        "7501056340117",
        sku="FC-56340117",
        nombre="Sedal Liso Perfecto",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Crema para peinar",
        marca="Sedal",
        laboratorio="Unilever",
        presentacion="Tubo 300 mL",
        ya=True,
        # No usar sedal-liso-perfecto-acond-300ml.jpg: esa foto es el acondicionador.
    ),
    # Farmalive
    "7501080911178": p(
        "7501080911178",
        sku="FC-08091178",
        nombre="Sterimar Cobre",
        tipo="marca",
        categoria="Respiratorio",
        subcategoria="Cuidado nasal",
        forma="Spray",
        marca="Sterimar",
        laboratorio="Church & Dwight",
        presentacion="Spray 100 mL",
        principio="Agua de mar con cobre",
        ya=False,
        foto_file="sterimar-cobre-100ml-7501080911178.jpg",
    ),
    "7501065008473": p(
        "7501065008473",
        sku="FC-5008473",
        nombre="Theraflu TD limón",
        tipo="marca",
        categoria="Respiratorio",
        subcategoria="Antigripal",
        forma="Granulado",
        marca="Theraflu",
        laboratorio="Haleon",
        presentacion="Caja con 10 sobres",
        principio="Paracetamol / feniramina / fenilefrina",
        concentracion="650/20/10 mg",
        ya=True,
        foto_file="theraflu-td-limon-10-sobres-7501065008473.jpg",
    ),
    # Cityfarma. Grupo IV (072M97 SSA IV) → receta.
    "7501070615277": p(
        "7501070615277",
        sku="FC-07061527",
        nombre="Daflon 500 mg",
        tipo="marca",
        categoria="Cardiovascular",
        subcategoria="Flebotónico",
        forma="Tableta",
        marca="Daflon",
        laboratorio="Sanfer",
        presentacion="Caja con 20 tabletas",
        principio="Diosmina / hesperidina",
        concentracion="450/50 mg",
        receta=True,
        ya=False,
        foto_file="daflon-500mg-c20-7501070615277.jpg",
    ),
}


def row(ean: str, snap: str, qty: int, pu: float, lote: str | None = None) -> dict:
    prod = PRODUCTOS[ean]
    sub = round(qty * pu, 2)
    return {
        "ean": ean,
        "sku": prod["sku"],
        "snap": snap,
        "nombre": prod["nombre"],
        "qty": qty,
        "pu": pu,
        "sub": sub,
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


TICKETS = [
    {
        "key": "citymark_75116",
        "folio": "75116",
        "proveedor": "Citymark",
        "proveedor_ilike": "citymark",
        "fecha": "2026-10-17",
        "total": 491.64,
        "notas": (
            "Ticket Citymark Caja 1/75116 · Bodega F-42 Ejidos del Moral · "
            "17-oct-2026 11:40 · efectivo · cola Recibir, stock al confirmar pistola y MMAA"
        ),
        "tmp": "_fc_cm_75116",
        "header": (
            "Citymark · Bodega F-42 · Caja 1/75116 · 2026-10-17 11:40:56 · PUBLICO EN GENERAL\n"
            "-- Ticket. Subtotal $423.83 + IVA $67.81 = total $491.64.\n"
            "-- El P.U. impreso ya incluye IVA (246.88 + 244.76 = 491.64).\n"
            "-- Costo = P.U. pagado a 2 decimales: Sedal 48.952 → 48.95 "
            "(5 x 48.95 = 244.75). El centavo queda en el total del ticket.\n"
            "-- Fotosun UV 100 FPS 50+ tubo 125 mL (Daclaf). Sedal Liso Perfecto crema para peinar 300 mL.\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7502253600486", "BLOQ FOTOSUN UV 100 50+ FPS 125ML", 2, 123.44),
            row("7501056340117", "CRA SEDAL LISO PERFECT 300ML", 5, 48.95),
        ],
    },
    {
        "key": "farmalive_14702",
        "folio": "14702",
        "proveedor": "Farmalive",
        "proveedor_ilike": "farmalive",
        "fecha": "2026-10-17",
        "total": 723.44,
        "notas": (
            "Ticket Farmalive 14702 · Club Iztapalapa 1 · 17-oct-2026 12:31 · "
            "cliente FARMACAPITAL · descuento 2% en ambos renglones · tarjeta débito · "
            "cola Recibir, stock al confirmar pistola y MMAA"
        ),
        "tmp": "_fc_fl_14702",
        "header": (
            "Farmalive · ticket 14702 · 2026-10-17 12:31 · Club Iztapalapa 1\n"
            "-- Cliente FARMACAPITAL. 2 renglones / 4 unidades.\n"
            "-- Papel: subtotal $738.20 − descuento $14.76 = $723.44 (tarjeta débito).\n"
            "-- Costo = P.U. neto del renglón (2%): Sterimar 199.92 · Theraflu TD 161.80.\n"
            "-- Theraflu verde = TD limón resfriado severo (paracetamol/feniramina/fenilefrina 650/20/10 mg).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7501080911178", "STERIMAR SPRAY COBRE 100 ML | CHURCH & DWIGHTND", 2, 199.92),
            row("7501065008473", "THERAFLE VERDE SOB C/10 | HALEON", 2, 161.80),
        ],
    },
    {
        "key": "cityfarma_s332558",
        "folio": "S332558",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "cityfarma",
        "fecha": "2026-10-17",
        "total": 430.00,
        "notas": (
            "Ticket Cityfarma S332558 · 17-oct-2026 12:39 · efectivo pagado $430.00 · "
            "cola Recibir, stock al confirmar pistola y MMAA"
        ),
        "tmp": "_fc_cf_s332558",
        "header": (
            "Cityfarma Iztapalapa · orden S332558 · 2026-10-17 12:39:42\n"
            "-- Vendedor David Maldonado. Cliente Luis Angel Palillero Ventura.\n"
            "-- IVA 0%. Efectivo $430.00. Pagado; pendiente $0.\n"
            "-- DAFLON 500M C 20 TAB → Daflon 500 mg (diosmina/hesperidina 450/50 mg, Sanfer).\n"
            "-- Registro 072M97 SSA IV: requiere receta. Sin lote ni caducidad. No inventar 0000."
        ),
        "rows": [
            row("7501070615277", "DAFLON 500M C 20 TAB", 1, 430.00),
        ],
    },
]


def main() -> None:
    GEN_DIR.mkdir(parents=True, exist_ok=True)
    paths: list[Path] = []
    for t in TICKETS:
        for r in t["rows"]:
            r["sub"] = round(r["qty"] * r["pu"], 2)
            r["precio"] = ceil_pvp(r["pu"], r["tipo"])

        suma = round(sum(r["sub"] for r in t["rows"]), 2)
        pzas = sum(r["qty"] for r in t["rows"])
        # 2 centavos: Citymark trae P.U. a 3 decimales (Sedal 48.952 → 48.95).
        if abs(suma - t["total"]) > 0.02:
            raise SystemExit(
                f"{t['folio']}: suma renglones {suma} ≠ total ticket {t['total']}"
            )
        csv_path = GEN_DIR / f"ticket_{t['key']}.csv"
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
        paths.append(sql_path)
        print(f"{t['folio']}: {report(t['rows'], t['total'])}")
        print(f"  → {csv_path.relative_to(ROOT)}")
        print(f"  → {sql_path.name} · {pzas} pzas · ${t['total']:.2f}")

    todos = OUT_DIR / "patch_carga_tickets_20261017_TODOS.sql"
    parts = [
        "-- ═══════════════════════════════════════════════════════════════",
        "-- TICKETS 17-OCT-2026 · PEGAR EN SUPABASE (uno por uno o todo)",
        "-- Ver LEERME_tickets_20261017.md",
        "-- ═══════════════════════════════════════════════════════════════",
        "",
    ]
    for path in paths:
        parts.append("\n-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        parts.append(f"-- INICIO: {path.name}")
        parts.append("-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        parts.append(path.read_text(encoding="utf-8").rstrip() + "\n")
    todos.write_text("\n".join(parts), encoding="utf-8")

    leerme = OUT_DIR / "LEERME_tickets_20261017.md"
    leerme.write_text(
        """# Tickets Recibir · 17-oct-2026

Fotos Citymark + Farmalive + Cityfarma. Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Citymark 75116 | `patch_carga_citymark_75116.sql` | 7 | $491.64 |
| Farmalive 14702 | `patch_carga_farmalive_14702.sql` | 4 | $723.44 |
| Cityfarma S332558 | `patch_carga_cityfarma_s332558.sql` | 1 | $430.00 |

## Todo-en-uno

`patch_carga_tickets_20261017_TODOS.sql`

## Notas

- Citymark (Bodega F-42, Caja 1): P.U. con IVA. Sedal queda en $48.95 (el ticket trae $48.952).
- Farmalive: costo = neto del renglón (2%). Cliente FARMACAPITAL. Tarjeta débito.
- Cityfarma: efectivo pagado, pendiente $0. Daflon es alta nueva y pide receta.
- Altas nuevas con foto: Sterimar Cobre y Daflon 500 mg. Fotosun y Theraflu TD solo llenan foto si el catálogo la tiene vacía.
- Sedal Liso Perfecto ya está. No se usa `sedal-liso-perfecto-acond-300ml.jpg` (esa foto es el acondicionador).
- Sin lote ni caducidad: MMAA de la caja al escanear.
- Regenerar: `python3 scripts/generar_carga_tickets_20261017.py`
""",
        encoding="utf-8",
    )
    print(f"\nTODOS → {todos.name} ({todos.stat().st_size} bytes)")
    print(f"LEERME → {leerme.name}")


if __name__ == "__main__":
    main()
