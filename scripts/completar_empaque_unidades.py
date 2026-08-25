#!/usr/bin/env python3
"""
Estructura el empaque de cada producto a partir del texto de `presentacion`.

Sin piezas por empaque no se puede comparar un precio contra la competencia: una caja
de 80 aspirinas contra un paquete de 20 da una brecha de +450% que en realidad es de
+38% por tableta. `presentacion` ya trae el dato en 98% del catálogo, pero como texto
libre ("C/80 tabletas 500 mg"); esto lo pasa a las columnas que ya existen.

Distingue dos maneras de medir, porque no se comparan igual:
  · formas sólidas (tabletas, cápsulas, sobres, ampolletas) → precio por pieza
  · formas líquidas o cremas (jarabe 120 mL, pomada 30 g)    → precio por mL o por gramo

No escribe en la base (la llave anon no tiene UPDATE sobre productos): genera el SQL
para Supabase y un CSV con los casos que necesitan ojo humano.

Uso:
  python3 scripts/completar_empaque_unidades.py
  python3 scripts/completar_empaque_unidades.py --incluir-revisables
"""
from __future__ import annotations

import argparse
import csv
import importlib.util
import re
import sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPORTE_DIR = ROOT / "pricing" / "reportes"
SQL_DIR = ROOT / "sql" / "pricing" / "generated"

_spec = importlib.util.spec_from_file_location("sync_similares", Path(__file__).with_name("sync_precios_similares.py"))
sync = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(sync)

import requests  # noqa: E402

# Formas que se cuentan por pieza
SOLIDAS = {
    "tableta", "capsula", "pastilla", "sobre", "supositorio", "ovulo",
    "parche", "globulo", "paleta", "inyectable",
}
# Formas cuyo contenido se mide en volumen o peso
CONTINUAS = {
    "jarabe", "suspension", "solucion", "gotas", "crema", "unguento", "gel",
    "locion", "spray", "emulsion", "jalea", "polvo", "rollon", "barra",
}

# "5 CM x 5 M", "12 X 18 CM": son medidas físicas, no piezas por caja
RE_DIMENSION = re.compile(r"\d+\s*(?:cm|mm|m|pulg|in)\b", re.IGNORECASE)
# "C/20", "C/ 20"
RE_EXPLICITO = re.compile(r"c/\s*(\d+)", re.IGNORECASE)
RE_VOLUMEN = re.compile(r"(\d+(?:[.,]\d+)?)\s*(ml|l|lt|litro|litros)\b", re.IGNORECASE)
RE_PESO = re.compile(r"(\d+(?:[.,]\d+)?)\s*(g|gr|gramos|kg|mg)\b", re.IGNORECASE)


def a_float(s: str) -> float | None:
    try:
        return float(str(s).replace(",", "."))
    except (TypeError, ValueError):
        return None


def forma_de(p: dict) -> str | None:
    return (
        sync.extraer_forma(p.get("forma_farmaceutica") or "")
        or sync.extraer_forma(p.get("presentacion") or "")
        or sync.extraer_forma(p.get("nombre") or "")
    )


def contenido_continuo(texto: str) -> tuple[float, str] | None:
    """Volumen o peso total del envase: ('120', 'ml') o ('30', 'g')."""
    mv = RE_VOLUMEN.search(texto)
    if mv:
        valor, unidad = a_float(mv.group(1)), mv.group(2).lower()
        if valor:
            if unidad in ("l", "lt", "litro", "litros"):
                valor, unidad = valor * 1000, "ml"
            return valor, "ml"
    mp = RE_PESO.search(texto)
    if mp:
        valor, unidad = a_float(mp.group(1)), mp.group(2).lower()
        if valor and unidad != "mg":  # mg es concentración, no contenido del envase
            if unidad == "kg":
                valor, unidad = valor * 1000, "g"
            return valor, "g"
    return None


def analizar(p: dict) -> dict:
    """Devuelve la propuesta de empaque con su nivel de certeza y el motivo."""
    presentacion = str(p.get("presentacion") or "")
    nombre = str(p.get("nombre") or "")
    texto = f"{nombre} {presentacion}"
    forma = forma_de(p)

    res = {
        "sku": p.get("sku"),
        "nombre": nombre,
        "presentacion": presentacion,
        "forma": forma or "",
        "piezas": None,
        "medida": "",
        "contenido": None,
        "certeza": "",
        "motivo": "",
    }

    if RE_DIMENSION.search(presentacion):
        res["motivo"] = "la presentacion son medidas fisicas, no piezas"
        res["certeza"] = "revisar"
        return res

    explicito = RE_EXPLICITO.search(texto)
    detectado = sync.extraer_cantidad(texto)

    # ── Formas sólidas: la unidad de comparación es la pieza
    if forma in SOLIDAS:
        piezas = a_float(explicito.group(1)) if explicito else (detectado or None)
        if piezas:
            res.update(piezas=int(piezas), medida="pieza",
                       certeza="alta" if explicito else "media",
                       motivo="C/N explicito" if explicito else "cantidad inferida del texto")
        else:
            res.update(certeza="revisar", motivo=f"forma solida ({forma}) sin cantidad legible")
        return res

    # ── Formas continuas: la unidad es el mL o el gramo
    if forma in CONTINUAS:
        cont = contenido_continuo(texto)
        piezas = a_float(explicito.group(1)) if explicito else None
        if cont:
            res.update(piezas=int(piezas) if piezas else 1, medida=cont[1], contenido=cont[0],
                       certeza="alta", motivo=f"contenido {cont[0]:g} {cont[1]}")
        elif piezas:
            res.update(piezas=int(piezas), medida="pieza", certeza="media",
                       motivo="C/N explicito sin contenido declarado")
        else:
            res.update(certeza="revisar", motivo=f"forma continua ({forma}) sin contenido legible")
        return res

    # ── Sin forma reconocida: aun así la presentación suele traer el dato
    # ("190 mL", "30 g", "3 pzs"), que es lo único que hace falta para comparar.
    if explicito:
        res.update(piezas=int(a_float(explicito.group(1))), medida="pieza", certeza="media",
                   motivo="C/N explicito pero sin forma farmaceutica")
        return res

    cont = contenido_continuo(texto)
    if cont and not detectado:
        res.update(piezas=1, medida=cont[1], contenido=cont[0], certeza="alta",
                   motivo=f"contenido {cont[0]:g} {cont[1]} (sin forma declarada)")
    elif detectado:
        res.update(piezas=detectado, medida="pieza", certeza="media",
                   motivo="cantidad inferida sin forma farmaceutica")
    else:
        res.update(certeza="revisar", motivo="sin forma ni cantidad legible")
    return res


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--incluir-revisables", action="store_true",
                    help="Mete también en el SQL los casos de certeza media")
    args = ap.parse_args()

    env = sync.cargar_env()
    url, key = env.get("REACT_APP_SUPABASE_URL", ""), env.get("REACT_APP_SUPABASE_ANON_KEY", "")
    if not url or not key:
        sys.exit("Faltan credenciales Supabase en .env")

    headers = {"apikey": key, "Authorization": f"Bearer {key}"}
    productos: list[dict] = []
    off = 0
    while True:
        r = requests.get(
            f"{url}/rest/v1/productos",
            headers={**headers, "Range": f"{off}-{off + 499}"},
            params={
                "select": "id,sku,nombre,presentacion,concentracion,unidades_por_caja,"
                          "forma_farmaceutica,precio,costo",
                "activo": "eq.true",
            },
            timeout=60,
        )
        r.raise_for_status()
        lote = r.json()
        productos.extend(lote)
        if len(lote) < 500:
            break
        off += 500

    altas: list[dict] = []
    medias: list[dict] = []
    revisar: list[dict] = []
    discrepancias: list[dict] = []

    for p in productos:
        a = analizar(p)
        actual = p.get("unidades_por_caja")
        actual = int(actual) if actual not in (None, "", 0) else None

        if actual and a["piezas"] and actual != a["piezas"]:
            discrepancias.append({**a, "unidades_por_caja_actual": actual})
            continue
        if actual:
            continue  # ya está poblado y no contradice

        if a["certeza"] == "alta":
            altas.append(a)
        elif a["certeza"] == "media":
            medias.append(a)
        else:
            revisar.append(a)

    total = len(productos)
    print(f"Productos activos: {total}")
    print(f"  ya tenían el dato y es consistente : {total - len(altas) - len(medias) - len(revisar) - len(discrepancias)}")
    print(f"  propuesta de certeza alta          : {len(altas)}")
    print(f"  propuesta de certeza media         : {len(medias)}")
    print(f"  requieren revisión manual          : {len(revisar)}")
    print(f"  contradicen el dato ya guardado    : {len(discrepancias)}")

    hoy = date.today().isoformat()
    REPORTE_DIR.mkdir(parents=True, exist_ok=True)
    SQL_DIR.mkdir(parents=True, exist_ok=True)

    ruta_csv = REPORTE_DIR / f"empaque_a_revisar_{hoy}.csv"
    with ruta_csv.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["bloque", "sku", "nombre", "presentacion", "forma",
                    "piezas_propuestas", "medida", "contenido", "motivo", "dato_actual"])
        for bloque, grupo in (("discrepancia", discrepancias), ("revisar", revisar), ("media", medias)):
            for a in grupo:
                w.writerow([bloque, a["sku"], a["nombre"], a["presentacion"], a["forma"],
                            a["piezas"], a["medida"], a["contenido"], a["motivo"],
                            a.get("unidades_por_caja_actual", "")])
    print(f"\nCSV de revisión: {ruta_csv}")

    aplicar = altas + (medias if args.incluir_revisables else [])

    def q(s) -> str:
        return "'" + str(s).replace("'", "''") + "'"

    ruta_sql = SQL_DIR / f"completar_empaque_unidades_{hoy}.sql"
    lineas = [
        "-- Estructura el empaque en `unidades_por_caja` a partir del texto de `presentacion`.",
        "-- Generado por scripts/completar_empaque_unidades.py",
        "--",
        "-- Para qué sirve: sin piezas por empaque, comparar nuestro precio contra la",
        "-- competencia da brechas falsas (una caja de 80 aspirinas contra un paquete de 20",
        "-- se ve como +450% cuando por tableta es +38%).",
        "--",
        f"-- Incluye {len(aplicar)} productos"
        + (" (certeza alta y media)" if args.incluir_revisables else " (solo certeza alta)"),
        "-- El WHERE evita sobrescribir un dato ya capturado a mano.",
        "",
        "BEGIN;",
        "",
    ]
    for a in sorted(aplicar, key=lambda x: x["sku"] or ""):
        if not a["piezas"]:
            continue
        detalle = f"{a['piezas']} x {a['medida']}"
        if a["contenido"]:
            detalle = f"{a['piezas']} envase(s) de {a['contenido']:g} {a['medida']}"
        lineas.append(
            f"UPDATE public.productos SET unidades_por_caja = {a['piezas']} "
            f"WHERE sku = {q(a['sku'])} AND coalesce(unidades_por_caja, 0) = 0;  -- {detalle}"
        )

    if discrepancias:
        lineas += [
            "",
            "-- ── Correcciones ──",
            "-- Aquí el dato guardado contradice a la propia presentación del producto.",
            "-- Estos UPDATE sí sobrescriben: revísalos antes de correrlos.",
            "",
        ]
        for a in sorted(discrepancias, key=lambda x: x["sku"] or ""):
            if not a["piezas"]:
                continue
            lineas.append(
                f"UPDATE public.productos SET unidades_por_caja = {a['piezas']} "
                f"WHERE sku = {q(a['sku'])};"
                f"  -- '{a['presentacion']}' dice {a['piezas']}, estaba en {a['unidades_por_caja_actual']}"
            )

    lineas += ["", "COMMIT;", ""]
    ruta_sql.write_text("\n".join(lineas), encoding="utf-8")
    print(f"SQL ({len(aplicar)} productos): {ruta_sql}")


if __name__ == "__main__":
    main()
