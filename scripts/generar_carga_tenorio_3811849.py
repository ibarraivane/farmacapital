#!/usr/bin/env python3
"""Factura Farmacéuticos Tenorio folio 3811849 (15-oct-2026) → cola Recibir.

Nombres de mostrador desde la ficha, no el código del ticket.
Lote de fábrica sí. Caducidad null: el MMAA se pide de la caja.
Medicamentos: costo = importe / cantidad (IVA 0).
Colonia y agua oxigenada: el importe es neto y el ticket les carga 16%.
Ese IVA va dentro del costo unitario para que la suma de renglones sea el total.
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

# El EAN de la caja Aktyzar C/14 está hoy en el omeprazol LGEN.
# La ficha de Aktyzar es EQ-SOF066 y no trae código. Sin este arreglo
# la pistola recibe el genérico.
AKTYZAR_EAN = "7502274792207"
LGEN_SKU = "FC-16792555"
LGEN_EAN = "7502216792555"
AKTYZAR_SKU = "EQ-SOF066"


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
    "780083148577": p(
        "780083148577",
        sku="EQ-COL213",
        nombre="Ampigrin PFC jarabe infantil 60 mL",
        tipo="marca",
        categoria="Antibiótico",
        forma="Jarabe",
        marca="Collins",
        laboratorio="Collins",
        presentacion="Frasco 60 mL",
        concentracion="3 g / 0.50 g / 0.02 g / 60 mL",
        receta=True,
        ya=True,
    ),
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
    ),
    "7506494600472": p(
        "7506494600472",
        nombre="Aba-Pen 20/400 mg",
        tipo="marca",
        categoria="Antiinflamatorio",
        subcategoria="Antiespasmódico",
        forma="Tabletas",
        marca="Aba-Pen",
        laboratorio="Schoen",
        presentacion="Caja con 10 tabletas",
        principio="Hioscina / ibuprofeno",
        concentracion="20/400 mg",
        # Registro 333M2025 SSA, sin fracción IV en la ficha. Venta de mostrador.
        receta=False,
        foto_file="aba-pen-20-400mg-c10-7506494600472.jpg",
    ),
    "7501022104262": p(
        "7501022104262",
        nombre="Ricitos de Oro manzanilla",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bebé",
        forma="Colonia",
        marca="Ricitos de Oro",
        laboratorio="Grisi",
        presentacion="Frasco 100 mL",
        foto_file="ricitos-de-oro-manzanilla-100ml-7501022104262.jpg",
    ),
    "759684315275": p(
        "759684315275",
        nombre="Agua oxigenada Jaloma",
        tipo="marca",
        categoria="Botiquín",
        forma="Solución",
        marca="Jaloma",
        presentacion="Atomizador 224 mL",
        principio="Peróxido de hidrógeno",
        concentracion="3% (10 volúmenes)",
        foto_file="jaloma-agua-oxigenada-atomizador-224ml-759684315275.jpg",
    ),
    "7501349027343": p(
        "7501349027343",
        sku="FC-49027343",
        nombre="Amsafast orlistat 120 mg",
        tipo="marca",
        categoria="Gastro",
        subcategoria="Obesidad",
        forma="Cápsulas",
        marca="Amsafast",
        laboratorio="AMSA",
        presentacion="Caja con 21 cápsulas",
        principio="Orlistat",
        concentracion="120 mg",
        receta=True,
        ya=True,
    ),
    "7501349020436": p(
        "7501349020436",
        sku="FC-49020436",
        nombre="Gabapentina 300 mg",
        tipo="generico",
        categoria="Medicamentos",
        forma="Cápsulas",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 15 cápsulas",
        principio="Gabapentina",
        concentracion="300 mg",
        receta=True,
        ya=True,
    ),
    "7501384541620": p(
        "7501384541620",
        sku="FC-84541620",
        nombre="Gabapentina 400 mg",
        tipo="generico",
        categoria="Medicamentos",
        forma="Cápsulas",
        marca="Psicofarma",
        laboratorio="Psicofarma",
        presentacion="Caja con 15 cápsulas",
        principio="Gabapentina",
        concentracion="400 mg",
        receta=True,
        ya=True,
    ),
    AKTYZAR_EAN: p(
        AKTYZAR_EAN,
        sku=AKTYZAR_SKU,
        nombre="Aktyzar omeprazol 20 mg",
        tipo="marca",
        categoria="Gastro",
        forma="Cápsulas",
        marca="Aktyzar",
        laboratorio="Solfran",
        presentacion="Caja con 14 cápsulas",
        principio="Omeprazol",
        concentracion="20 mg",
        ya=True,
    ),
    "7502227426715": p(
        "7502227426715",
        nombre="Algidol 600 mg",
        tipo="marca",
        categoria="Analgésico",
        forma="Cápsulas",
        marca="Algidol",
        laboratorio="Gelpharma",
        presentacion="Caja con 10 cápsulas",
        principio="Ibuprofeno",
        concentracion="600 mg",
        # Grupo IV (343M2014 SSA). El de 400 mg es otro SKU y no pide receta.
        receta=True,
        foto_file="algidol-600mg-c10-7502227426715.jpg",
    ),
    "7501471888393": p(
        "7501471888393",
        sku="EQ-TEC0550",
        nombre="Tiarotec 5 mg",
        tipo="marca",
        categoria="Medicamentos",
        forma="Tabletas",
        marca="Tiarotec",
        laboratorio="Tecnofarma",
        presentacion="Caja con 20 tabletas",
        principio="Tiamazol",
        concentracion="5 mg",
        receta=True,
        ya=True,
        foto_file="tiarotec-5mg-c20-7501471888393.jpg",
    ),
    "7502001167278": p(
        "7502001167278",
        nombre="Sinmison's 2 mg",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Urología",
        forma="Tabletas",
        marca="Sinmison's",
        laboratorio="Química Son's",
        presentacion="Caja con 14 tabletas",
        principio="Tolterodina",
        concentracion="2 mg",
        receta=True,
        foto_file="sinmison-2mg-c14-7502001167278.jpg",
    ),
    "7502001167308": p(
        "7502001167308",
        nombre="Sinmison's 2 mg",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Urología",
        forma="Tabletas",
        marca="Sinmison's",
        laboratorio="Química Son's",
        presentacion="Caja con 28 tabletas",
        principio="Tolterodina",
        concentracion="2 mg",
        receta=True,
        foto_file="sinmison-2mg-c28-7502001167308.jpg",
    ),
    "7501349021112": p(
        "7501349021112",
        nombre="Levetiracetam 500 mg",
        tipo="generico",
        categoria="Medicamentos",
        forma="Tabletas",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 60 tabletas",
        principio="Levetiracetam",
        concentracion="500 mg",
        # 168M2013 SSA IV.
        receta=True,
        foto_file="levetiracetam-amsa-500mg-c60-7501349021112.jpg",
    ),
    "7506353200287": p(
        "7506353200287",
        nombre="Endoestat 10 g/100 mL",
        tipo="marca",
        categoria="Medicamentos",
        forma="Solución",
        marca="Endoestat",
        laboratorio="Nucitec",
        presentacion="Frasco 300 mL",
        principio="Levetiracetam",
        concentracion="10 g/100 mL",
        # Caja: 222M2018 SSA IV. No es la tableta de 500 mg.
        receta=True,
        foto_file="endoestat-10g-100ml-300ml-7506353200287.jpg",
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


# Costos unitarios. Higiene: 35.35 y 17.73 ya traen el 16% y cierran el total.
TICKET = {
    "key": "tenorio_3811849",
    "folio": "3811849",
    "proveedor": "Farmaceuticos Tenorio",
    "proveedor_ilike": "tenorio",
    "fecha": "2026-10-15",
    "total": 1393.88,
    "notas": (
        "Factura Farmaceuticos Tenorio folio 3811849 · 15-oct-2026 22:58 · "
        "cliente 20077 Palillero Ventura · ref 2134457 · ruta Puebla · 1 caja · "
        "cola Recibir, stock al confirmar pistola y MMAA"
    ),
    "tmp": "_fc_tn_3811849",
    "header": (
        "Farmaceuticos Tenorio · folio 3811849 · 2026-10-15 22:58\n"
        "-- Cliente 20077 Palillero Ventura Luis Angel. Ref 2134457. Ruta Puebla. 1 caja.\n"
        "-- Subtotal 1376.79 + IVA 17.09 = 1393.88. El IVA solo cae en colonia y agua oxigenada.\n"
        "-- Esas dos llevan el 16% dentro del costo (35.35 y 17.73) para que los renglones sumen el total.\n"
        "-- Lote de la factura. Caducidad null: MMAA de la caja. No inventar 0000.\n"
        "-- Aktyzar: se mueve el EAN 7502274792207 del LGEN FC-16792555 a EQ-SOF066\n"
        "-- y se devuelve 7502216792555 al LGEN, si esas fichas siguen así."
    ),
    "rows": [
        row("780083148577", "AMPIGRIN PFC INF JBE", 2, 24.69, "26141865"),
        row("7503027446279", "GELUBRIN 600MG CAP C/10", 5, 20.12, "U0590"),
        row("7506494600472", "ABA-PEN 20/400MG TAB C/10", 2, 34.56, "162066"),
        row("7501022104262", "AGUA DE COLONIA RICITOS DE ORO 100ML", 2, 35.35, "4262"),
        row("759684315275", "AGUA OXIGENADA ATOMIZADOR 224ML", 3, 17.73, "0171561"),
        row("7501349027343", "AMSAFAST 120MG CAP C/21", 3, 83.14, "U26Y166"),
        row("7501349020436", "GABAPENTINA 300MG CAP C/15", 2, 22.88, "U26Y406"),
        row("7501384541620", "GABAPENTINA 400MG CAP C/15", 2, 49.92, "6080726"),
        row(AKTYZAR_EAN, "AKTYZAR 20MG CAP C/14", 5, 7.90, "61992"),
        row("7502227426715", "ALGIDOL 600MG CAP C/10", 4, 23.21, "260994"),
        row("7501471888393", "TIAROTEC 5MG TAB C/20", 2, 37.25, "441133"),
        row("7502001167278", "SINMISON'S 2MG TAB C/14", 2, 16.32, "26030903"),
        row("7502001167308", "SINMISON'S 2MG TAB C/28", 2, 35.02, "26030903"),
        row("7501349021112", "LEVETIRACETAM 500MG TAB C/60", 1, 97.51, "U26Y100"),
        row("7506353200287", "ENDOESTAT 10GR/100ML SOLUC 300ML", 1, 248.84, "J692036"),
    ],
}

BARCODE_FIX = f"""
-- Aktyzar C/14: el EAN de la caja está en el LGEN. La ficha buena es EQ-SOF066.
update public.productos
set codigo_barras = '{LGEN_EAN}'
where sku = '{LGEN_SKU}'
  and codigo_barras = '{AKTYZAR_EAN}'
  and exists (select 1 from public.productos where sku = '{AKTYZAR_SKU}')
  and not exists (
    select 1 from public.productos
    where codigo_barras = '{LGEN_EAN}' and sku <> '{LGEN_SKU}'
  );

update public.productos
set codigo_barras = '{AKTYZAR_EAN}'
where sku = '{AKTYZAR_SKU}'
  and coalesce(nullif(trim(codigo_barras), ''), '') = ''
  and not exists (
    select 1 from public.productos
    where codigo_barras = '{AKTYZAR_EAN}' and sku <> '{AKTYZAR_SKU}'
  );
"""


def main() -> None:
    GEN_DIR.mkdir(parents=True, exist_ok=True)
    t = TICKET
    for r in t["rows"]:
        r["sub"] = round(r["qty"] * r["pu"], 2)
        r["precio"] = ceil_pvp(r["pu"], r["tipo"])
    suma = round(sum(r["sub"] for r in t["rows"]), 2)
    if suma != t["total"]:
        raise SystemExit(f"suma renglones {suma} ≠ total {t['total']}")
    if ";" in t["notas"] or ";" in t["header"]:
        raise SystemExit("el ticket no puede llevar punto y coma en notas ni comentarios")

    csv_path = GEN_DIR / "ticket_tenorio_3811849.csv"
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
    text = sql_path.read_text(encoding="utf-8")
    needle = "begin;\n"
    if needle not in text:
        raise SystemExit("no encontré begin para el arreglo del EAN")
    text = text.replace(needle, "begin;\n" + BARCODE_FIX, 1)
    sql_path.write_text(text, encoding="utf-8")
    print(f"{t['folio']}: {report(t['rows'], t['total'])}")
    print(f"  → {csv_path.relative_to(ROOT)}")
    print(f"  → {sql_path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
