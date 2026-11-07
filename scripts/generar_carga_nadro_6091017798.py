#!/usr/bin/env python3
"""Factura Nadro folio 6091017798 (11-oct-2026, 8 renglones) → catálogo + cola Recibir.

Foto CFDI: assets/factura_nadro_6091017798.jpg (workspace).
EAN oficiales iNadro intelligent-search (2026-10-12).
Crostox: UPC-A 12 dígitos en portal → se guardan con 0 delante (13)
igual que EQ-MAI163 ya en catálogo (0785120755466).
Sin lote ni MMAA: salen de la caja al escanear.
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_carga_tickets_20260915 import (  # noqa: E402
    ceil_pvp,
    foto_url,
    sku_de,
    write_carga_sql,
)
from generar_recepcion_borrador import report, write_ticket_csv  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
GEN_DIR = ROOT / "sql" / "generated"

FOLIO = "6091017798"
FECHA = "2026-10-11"
TOTAL_TICKET = 877.98  # CFDI total (subtotal 867.28 + IVA Hypafix 10.70)


def row(
    ean: str,
    *,
    snap: str,
    qty: int,
    pu: float,
    nombre: str,
    tipo: str,
    categoria: str,
    subcategoria: str | None,
    forma: str | None,
    marca: str | None,
    laboratorio: str | None,
    presentacion: str | None,
    principio: str | None,
    concentracion: str | None,
    receta: bool,
    ya: bool,
    sku: str | None = None,
    foto_file: str | None = None,
    match: str | None = None,
) -> dict:
    sku_f = sku or sku_de(ean)
    return {
        "ean": ean,
        "sku": sku_f,
        "snap": snap,
        "qty": qty,
        "pu": pu,
        "sub": round(qty * pu, 2),
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
        "precio": ceil_pvp(pu, tipo),
        "foto": foto_url(foto_file) if foto_file else None,
        "foto_file": f"catalogo-propia/{foto_file}" if foto_file else None,
        "lote": None,
        "match": match or ("catalogo" if ya else "alta_nueva"),
    }


ROWS = [
    row(
        "7503008344785",
        snap="IBUPROFENO 400 MG 10 CAPS LGEN",
        qty=3,
        pu=14.66,
        sku="EQ-PGE033",
        nombre="Gelubrín ibuprofeno 400 mg",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Analgésico",
        forma="Cápsulas",
        marca="Gelubrín",
        laboratorio="Progela",
        presentacion="C/10 cápsulas",
        principio="Ibuprofeno",
        concentracion="400 mg",
        receta=False,
        ya=True,
        foto_file="gelubrin-ibuprofeno-400mg-c10-7503008344785.jpg",
    ),
    row(
        "4042809591446",
        snap="LEUKOPLAST HYPAFIX 10 CM X 2 M",
        qty=1,
        pu=66.86,
        nombre="Leukoplast Hypafix",
        tipo="marca",
        categoria="Botiquín",
        subcategoria="Material de curación",
        forma="Cinta adhesiva",
        marca="Leukoplast",
        laboratorio="Essity",
        presentacion="Rollo 10 cm × 2 m",
        principio=None,
        concentracion=None,
        receta=False,
        ya=False,
        foto_file="leukoplast-hypafix-10cmx2m-4042809591446.jpg",
    ),
    row(
        "0785120755459",
        snap="ROSUVASTATINA 10MG 30 TAB LGEN",
        qty=1,
        pu=56.28,
        nombre="Crostox rosuvastatina 10 mg",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Cardiovascular",
        forma="Tabletas",
        marca="Crostox",
        laboratorio="Sanfer / Mavi",
        presentacion="C/30 tabletas",
        principio="Rosuvastatina",
        concentracion="10 mg",
        receta=True,
        ya=False,
        foto_file="crostox-rosuvastatina-10mg-c30-0785120755459.jpg",
    ),
    row(
        "0785120755466",
        snap="ROSUVASTATINA 20MG 30 TAB LGEN",
        qty=2,
        pu=76.52,
        sku="EQ-MAI163",
        nombre="Crostox rosuvastatina 20 mg",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Cardiovascular",
        forma="Tabletas",
        marca="Crostox",
        laboratorio="Sanfer / Mavi",
        presentacion="C/30 tabletas",
        principio="Rosuvastatina",
        concentracion="20 mg",
        receta=True,
        ya=True,
        foto_file="crostox-rosuvastatina-20mg-c30-0785120755466.jpg",
    ),
    row(
        "7501088505454",
        snap="SYNALAR-S 0.025% CRA 20 G 0645",
        qty=1,
        pu=174.13,
        nombre="Synalar-S 0.025%",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Dermatología",
        forma="Crema",
        marca="Synalar",
        laboratorio="Productos Farmacéuticos",
        presentacion="Tubo 20 g",
        principio="Acetónido de fluocinolona",
        concentracion="0.025%",
        receta=True,
        ya=False,
        foto_file="synalar-s-crema-0.025-20g-7501088505454.jpg",
    ),
    row(
        "7501349029736",
        snap="TELMIS/HDRO 80/12.5MG 28TAB LGEN",
        qty=2,
        pu=77.41,
        nombre="Telmisartán / Hidroclorotiazida 80/12.5 mg",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Cardiovascular",
        forma="Tabletas",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="C/28 tabletas",
        principio="Telmisartán / Hidroclorotiazida",
        concentracion="80/12.5 mg",
        receta=True,
        ya=False,
        foto_file="telmisartan-hidro-80-12.5-c28-7501349029736.jpg",
    ),
    row(
        "7501349025844",
        snap="TELMISARTAN 40 MG 28 TAB LGEN",
        qty=2,
        pu=34.00,
        sku="FC-49025844",
        nombre="Telmisartán 40 mg",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Cardiovascular",
        forma="Tabletas",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="C/28 tabletas",
        principio="Telmisartán",
        concentracion="40 mg",
        receta=True,
        ya=True,
        foto_file="telmisartan-40mg-c28-7501349025844.jpg",
    ),
    row(
        "5415062392317",
        snap="TERRAMICINA OFT UNG 10G",
        qty=1,
        pu=150.20,
        nombre="Terramicina oftálmica",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Oftalmología",
        forma="Ungüento",
        marca="Terramicina",
        laboratorio="Pfizer",
        presentacion="Tubo 10 g",
        principio="Oxitetraciclina / Polimixina B",
        concentracion=None,
        receta=True,
        ya=False,
        foto_file="terramicina-oft-ung-10g-5415062392317.jpg",
    ),
]


def patch_crostox_ean_lookup(sql_text: str) -> str:
    """Pistola puede mandar UPC-A 12 dígitos sin el 0 inicial del catálogo."""
    old = """left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;"""
    new = """left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku),
    case
      when t.ean like '0%' and length(t.ean) = 13
        then public.fc_buscar_producto_escaneo(substr(t.ean, 2))
      else null
    end,
    case
      when t.ean in ('0785120755459', '0785120755466')
        then public.fc_buscar_producto_escaneo(substr(t.ean, 2))
      else null
    end
  ) as pid
) v on true
order by t.linea;"""
    if old not in sql_text:
        raise SystemExit("No se pudo parchear lookup Crostox en el SQL generado")
    return sql_text.replace(old, new, 1)


def write_readme(path: Path) -> None:
    path.write_text(
        f"""# Nadro folio {FOLIO} · {FECHA} · ${TOTAL_TICKET:.2f}

Factura CFDI (foto `sql/generated/factura_nadro_6091017798.jpg`) · UUID E11D25BA-… · subtotal ~$867.28 + IVA Hypafix $10.70 = **$877.98**.
Suma de renglones a costo unitario: $867.31 (3 centavos de redondeo vs subtotal impreso).

## Veredicto

| EAN | Ticket | SKU | Acción |
|---|---|---|---|
| `7503008344785` | Ibuprofeno 400 mg C/10 ×3 | `EQ-PGE033` | Solo costo (Gelubrín) |
| `4042809591446` | Leukoplast Hypafix 10 cm × 2 m ×1 | `FC-09591446` | **Alta nueva** |
| `0785120755459` | Rosuvastatina 10 mg C/30 ×1 | `FC-20755459` | **Alta nueva** (Crostox) |
| `0785120755466` | Rosuvastatina 20 mg C/30 ×2 | `EQ-MAI163` | Solo costo (Crostox) |
| `7501088505454` | Synalar-S 0.025% crema 20 g ×1 | `FC-88505454` | **Alta nueva** |
| `7501349029736` | Telmisartán/HCTZ 80/12.5 C/28 ×2 | `FC-49029736` | **Alta nueva** |
| `7501349025844` | Telmisartán 40 mg C/28 ×2 | `FC-49025844` | Solo costo |
| `5415062392317` | Terramicina oft. ungüento 10 g ×1 | `FC-62392317` | **Alta nueva** |

Fichas desde iNadro (no el código del ticket). Marca real: Gelubrín / Leukoplast / Crostox / Synalar / AMSA / Terramicina — no LGEN ni casa Nadro.

## Qué pegar en Supabase

1. `sql/patch_carga_nadro_6091017798.sql` — altas + cola Recibir borrador.
2. Tras deploy Vercel: `sql/patch_fotos_nadro_6091017798.sql`.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja. No inventar `0000`.

CSV: `sql/generated/ticket_nadro_6091017798.csv`.
""",
        encoding="utf-8",
    )


def write_fotos_sql(path: Path) -> None:
    fotos = [
        ("7503008344785", ["EQ-PGE033"], "gelubrin-ibuprofeno-400mg-c10-7503008344785.jpg"),
        ("4042809591446", ["FC-09591446", "FC-ND-09591446"], "leukoplast-hypafix-10cmx2m-4042809591446.jpg"),
        ("0785120755459", ["FC-20755459", "FC-ND-20755459"], "crostox-rosuvastatina-10mg-c30-0785120755459.jpg"),
        ("0785120755466", ["EQ-MAI163"], "crostox-rosuvastatina-20mg-c30-0785120755466.jpg"),
        ("7501088505454", ["FC-88505454", "FC-ND-88505454"], "synalar-s-crema-0.025-20g-7501088505454.jpg"),
        ("7501349029736", ["FC-49029736", "FC-ND-49029736"], "telmisartan-hidro-80-12.5-c28-7501349029736.jpg"),
        ("7501349025844", ["FC-49025844"], "telmisartan-40mg-c28-7501349025844.jpg"),
        ("5415062392317", ["FC-62392317", "FC-ND-62392317"], "terramicina-oft-ung-10g-5415062392317.jpg"),
    ]
    lines = [
        f"-- Fotos catalogo-propia · Nadro {FOLIO} · corrida DESPUÉS del deploy de Vercel.",
        "-- Packshots desde iNadro (no placeholder genérico).",
        "-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.",
        "",
        "begin;",
        "",
    ]
    for ean, skus, fname in fotos:
        url = f"https://www.farmacapital.mx/catalogo-propia/{fname}"
        sku_list = ", ".join(f"'{s}'" for s in skus)
        lines += [
            "update public.productos",
            f"set imagen_url = '{url}',",
            f"    imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), '{url}')",
            f"where (codigo_barras = '{ean}' or sku in ({sku_list})",
            f"       or (codigo_barras = substr('{ean}', 2) and '{ean}' like '0%' and length('{ean}') = 13))",
            "  and (",
            "    imagen_url is null",
            "    or btrim(imagen_url) = ''",
            f"    or imagen_url not like '%catalogo-propia/{fname.split('.')[0][:28]}%'",
            "  );",
            "",
            "insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)",
            "select p.id,",
            f"       '{url}',",
            f"       'catalogo-propia/{fname}',",
            "       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,",
            "       not exists (",
            "         select 1 from public.producto_imagenes i",
            "         where i.producto_id = p.id and coalesce(i.es_principal, false)",
            "       ),",
            "       'propia'",
            "from public.productos p",
            f"where (p.codigo_barras = '{ean}' or p.sku in ({sku_list})",
            f"       or (p.codigo_barras = substr('{ean}', 2) and '{ean}' like '0%' and length('{ean}') = 13))",
            "  and not exists (",
            "    select 1 from public.producto_imagenes i",
            "    where i.producto_id = p.id",
            f"      and (i.url = '{url}' or i.storage_path = 'catalogo-propia/{fname}')",
            "  );",
            "",
        ]
    lines += ["commit;", ""]
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    GEN_DIR.mkdir(parents=True, exist_ok=True)
    assert sku_de("0785120755459") == "FC-20755459"
    assert sku_de("4042809591446") == "FC-09591446"
    assert sku_de("7501088505454") == "FC-88505454"
    assert sku_de("7501349029736") == "FC-49029736"
    assert sku_de("5415062392317") == "FC-62392317"

    ticket = {
        "key": "nadro_6091017798",
        "tmp": "_fc_nd6091017798",
        "folio": FOLIO,
        "fecha": FECHA,
        "proveedor": "Nadro",
        "proveedor_ilike": "nadro",
        "total": TOTAL_TICKET,
        "header": (
            f"Pedido Nadro folio {FOLIO} ({FECHA}) — altas + cola Recibir. "
            f"CFDI total ${TOTAL_TICKET:.2f} · EAN iNadro"
        ),
        "notas": (
            f"Pedido Nadro {FOLIO} · CFDI {FECHA} · EAN iNadro · "
            "cola Recibir; stock al confirmar pistola"
        ),
        "rows": ROWS,
    }

    csv_path = GEN_DIR / f"ticket_nadro_{FOLIO}.csv"
    write_ticket_csv(
        csv_path,
        folio=FOLIO,
        fecha=FECHA,
        proveedor="Nadro",
        total=TOTAL_TICKET,
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
            for r in ROWS
        ],
    )

    sql_path = write_carga_sql(ticket)
    sql_path.write_text(patch_crostox_ean_lookup(sql_path.read_text(encoding="utf-8")), encoding="utf-8")

    write_readme(ROOT / "sql" / f"LEERME_nadro_{FOLIO}.md")
    write_fotos_sql(ROOT / "sql" / f"patch_fotos_nadro_{FOLIO}.sql")

    print(f"{FOLIO}: {report(ROWS, TOTAL_TICKET)}")
    print(f"  → {csv_path.relative_to(ROOT)}")
    print(f"  → {sql_path.relative_to(ROOT)}")
    print(f"  → sql/LEERME_nadro_{FOLIO}.md")
    print(f"  → sql/patch_fotos_nadro_{FOLIO}.sql")
    print("Suma renglones (sin IVA):", round(sum(r["sub"] for r in ROWS), 2))


if __name__ == "__main__":
    main()
