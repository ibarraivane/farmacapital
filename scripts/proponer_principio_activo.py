#!/usr/bin/env python3
"""
Propone el principio activo de los productos que no lo tienen registrado.

Sin `principio_activo` no hay contra qué verificar un precio de referencia: una marca
comercial como "Zukedib" no se parece a nada en el catálogo de la competencia. Este
script usa los matches de un archivo externo como *hipótesis* de cuál es el genérico
(Zukedib → glimepirida) y las saca a un CSV para que una persona las confirme.

No escribe nada en la base: genera un CSV para revisar y, con las filas confirmadas,
el SQL para aplicarlas.

Uso:
  # 1) generar la lista para revisar (combina todas las fuentes disponibles)
  python3 scripts/proponer_principio_activo.py --generar --excel --externo archivo.csv

  # 2) marcar la columna `confirmado` con x/si en el CSV y generar el SQL
  python3 scripts/proponer_principio_activo.py --sql --revisado pricing/reportes/propuestas_pa_<fecha>.csv
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

_spec_x = importlib.util.spec_from_file_location("sync_excel", Path(__file__).with_name("sync_precios_excel_farmacias.py"))
excel_mod = importlib.util.module_from_spec(_spec_x)
_spec_x.loader.exec_module(excel_mod)

EXCEL_DEFAULT = ROOT / "pricing" / "fuentes" / "articulos_farmacias.xlsx"

RE_SCORE = re.compile(r"\(Score:\s*(\d+)%\)")

CONFIRMACIONES = {"x", "s", "si", "sí", "y", "yes", "1", "true", "ok"}


def limpiar_candidato(notas: str) -> str | None:
    if not notas or not RE_SCORE.search(notas):
        return None
    nombre = RE_SCORE.sub("", notas).strip()
    return re.sub(r"\.\.$", "", nombre).strip(" .-") or None


def formatear_concentracion(c: str) -> str:
    """El verificador homologa todo a mg; para leerlo se revierte ('20000mg' → '20 g')."""
    m = re.fullmatch(r"(\d+(?:\.\d+)?)(mg|mcg|ml|ui|%)", c)
    if not m:
        return c
    valor, unidad = float(m.group(1)), m.group(2)
    if unidad == "mg" and valor >= 1000:
        return f"{valor / 1000:g} g"
    return f"{valor:g} {unidad}"


RE_PARENTESIS = re.compile(r"\(([^)]{4,80})\)")

# Paréntesis que describen al público o el empaque, no al contenido:
# "Desodorante Axe Intense 48H (Hombre)" no aporta principio activo.
PARENTESIS_NO_PA = {
    "hombre", "mujer", "men", "women", "woman", "unisex", "dama", "caballero",
    "adulto", "adultos", "infantil", "infantiles", "nino", "ninos", "nina", "ninas",
    "bebe", "bebes", "familiar", "junior", "senior", "pediatrico", "pediatrica",
    "grande", "chico", "mediano", "nuevo", "nueva", "original", "clasico", "clasica",
}


def pa_desde_nombre_propio(nombre: str) -> str | None:
    """
    Muchos productos ya declaran su genérico en el propio nombre:
    'Infamid (Metamizol + Dexametasona)' o 'Cina (Ciprofloxacino)'.
    Es una fuente más confiable que cualquier match externo y no necesita revisión.
    """
    for contenido in RE_PARENTESIS.findall(nombre or ""):
        ings = sync.ingredientes(contenido)
        if not ings:
            continue
        # Descarta paréntesis que describen presentación ("(Inyectable)") o público ("(Hombre)")
        if all(sync.extraer_forma(i) or i in PARENTESIS_NO_PA for i in ings):
            continue
        ings = [i for i in ings if i not in PARENTESIS_NO_PA]
        if not ings:
            continue
        return " + ".join(i.capitalize() for i in ings)
    return None


def proponer_pa(candidato: str) -> str:
    """'ESCITALOPRAM 10MG 14TAB' → 'Escitalopram 10 mg'."""
    ingredientes = sync.ingredientes(candidato) or sync.tokens_utiles(candidato)
    ingredientes = [i for i in ingredientes if not re.fullmatch(r"\d+\w*", i)]
    concs = sorted(sync.extraer_concentraciones(candidato))
    base = " / ".join(i.capitalize() for i in ingredientes[:4])
    if concs:
        base = f"{base} {formatear_concentracion(concs[0])}".strip()
    return base


def generar(externo: Path | None, excel: Path | None) -> Path:
    env = sync.cargar_env()
    url, key = env.get("REACT_APP_SUPABASE_URL", ""), env.get("REACT_APP_SUPABASE_ANON_KEY", "")
    if not url or not key:
        sys.exit("Faltan credenciales Supabase en .env")

    productos = sync.fetch_productos(url, key)
    faltantes = {
        p["sku"]: p for p in productos
        if p.get("sku") and not sync.ingredientes(p.get("principio_activo") or "")
    }

    propuestas: list[dict] = []

    # Fuente 1: el propio nombre del producto. No requiere archivo externo ni revisión
    # caso por caso, y gana sobre cualquier propuesta externa que lo contradiga.
    desde_nombre: set[str] = set()
    for sku, p in faltantes.items():
        pa = pa_desde_nombre_propio(p.get("nombre") or "")
        if not pa:
            continue
        desde_nombre.add(sku)
        propuestas.append({
            "confirmado": "x",
            "sku": sku,
            "nombre_fc": p.get("nombre"),
            "marca_fc": p.get("marca"),
            "principio_activo_propuesto": pa,
            "candidato_externo": "(del propio nombre del producto)",
            "precio_externo": "",
            "etiqueta_externa": "nombre_propio",
        })

    # Fuente 2: el Excel de artículos, que trae marca comercial junto al genérico.
    # Es más confiable que un match textual porque la equivalencia viene en el dato.
    desde_excel: set[str] = set()
    if excel and excel.exists():
        catalogo = excel_mod.cargar_excel(excel)
        por_marca: dict[str, dict] = {}
        for c in catalogo:
            por_marca.setdefault(c["marca_norm"], c)
        for sku, p in faltantes.items():
            if sku in desde_nombre:
                continue
            marca = sync.normalizar(p.get("marca") or "")
            cand = por_marca.get(marca) if marca else None
            if not cand:
                continue
            desde_excel.add(sku)
            propuestas.append({
                "confirmado": "",
                "sku": sku,
                "nombre_fc": p.get("nombre"),
                "marca_fc": p.get("marca"),
                "principio_activo_propuesto": cand["descripcion"],
                "candidato_externo": f"Excel · marca {cand['marca']}",
                "precio_externo": cand["precio"],
                "etiqueta_externa": "excel_marca",
            })

    # Fuente 3: matches del archivo externo, para los que no se resolvieron antes
    resueltos = desde_nombre | desde_excel
    filas = list(csv.DictReader(externo.open(encoding="utf-8"))) if externo else []
    descartadas_dudosas = 0
    for f in filas:
        if (f.get("sku") or "").strip() in resueltos:
            continue
        sku = (f.get("sku") or "").strip()
        p = faltantes.get(sku)
        if not p:
            continue
        # La propia fuente marca este bucket como estimación por categoría; en la
        # práctica produce disparates (algodón → amlodipino) que ensucian la revisión.
        if (f.get("confianza_match") or "").strip().lower() == "dudoso":
            descartadas_dudosas += 1
            continue
        candidato = limpiar_candidato(f.get("notas") or "")
        if not candidato:
            continue
        pa = proponer_pa(candidato)
        if not pa:
            continue
        propuestas.append({
            "confirmado": "",
            "sku": sku,
            "nombre_fc": p.get("nombre"),
            "marca_fc": p.get("marca"),
            "principio_activo_propuesto": pa,
            "candidato_externo": candidato,
            "precio_externo": f.get("precio"),
            "etiqueta_externa": f.get("confianza_match"),
        })

    orden = {"nombre_propio": 0, "excel_marca": 1, "alta": 2, "media": 3}
    propuestas.sort(key=lambda x: (orden.get(x["etiqueta_externa"], 9), (x["nombre_fc"] or "").lower()))
    REPORTE_DIR.mkdir(parents=True, exist_ok=True)
    destino = REPORTE_DIR / f"propuestas_pa_{date.today().isoformat()}.csv"
    with destino.open("w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(propuestas[0].keys()) if propuestas else
                           ["confirmado", "sku", "nombre_fc", "marca_fc",
                            "principio_activo_propuesto", "candidato_externo",
                            "precio_externo", "etiqueta_externa"])
        w.writeheader()
        w.writerows(propuestas)

    print(f"Productos sin principio activo utilizable: {len(faltantes)}")
    print(f"  resueltos por su propio nombre         : {len(desde_nombre)}  (ya vienen confirmados)")
    print(f"  propuestos por marca del Excel         : {len(desde_excel)}")
    print(f"  propuestas del archivo externo         : {len(propuestas) - len(desde_nombre) - len(desde_excel)}")
    print(f"  omitidas por venir marcadas 'dudoso'   : {descartadas_dudosas}")
    print(f"  sin propuesta, captura manual          : {len(faltantes) - len({p['sku'] for p in propuestas})}")
    print(f"\nCSV para revisar: {destino}")
    print("Las de `nombre_propio` ya vienen con 'x'. Revisa las de `alta`/`media`,")
    print("marca con 'x' las correctas, corrige el texto si hace falta, y corre --sql.")
    return destino


def generar_sql(revisado: Path) -> Path:
    filas = [
        r for r in csv.DictReader(revisado.open(encoding="utf-8"))
        if (r.get("confirmado") or "").strip().lower() in CONFIRMACIONES
    ]
    if not filas:
        sys.exit("Ninguna fila tiene la columna `confirmado` marcada.")

    def q(s: str) -> str:
        return "'" + str(s).replace("'", "''") + "'"

    SQL_DIR.mkdir(parents=True, exist_ok=True)
    destino = SQL_DIR / f"completar_principio_activo_{date.today().isoformat()}.sql"
    lineas = [
        "-- Completa `principio_activo` en productos que no lo tenían registrado.",
        f"-- Generado por scripts/proponer_principio_activo.py desde {revisado.name}",
        "-- Solo incluye las filas confirmadas manualmente.",
        "-- Sin este campo no se puede verificar ningún precio de referencia contra la competencia.",
        "",
        "BEGIN;",
        "",
    ]
    for r in filas:
        pa = (r.get("principio_activo_propuesto") or "").strip()
        if not pa:
            continue
        lineas.append(
            "UPDATE public.productos SET principio_activo = "
            f"{q(pa)} WHERE sku = {q(r['sku'])} AND coalesce(btrim(principio_activo), '') = '';"
        )
    lineas += ["", f"-- Filas confirmadas: {len(filas)}", "", "COMMIT;", ""]
    destino.write_text("\n".join(lineas), encoding="utf-8")
    print(f"Confirmadas: {len(filas)}")
    print(f"SQL: {destino}")
    return destino


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--generar", action="store_true")
    ap.add_argument("--externo", help="CSV externo con matches (sku,precio,confianza_match,notas)")
    ap.add_argument("--excel", nargs="?", const=str(EXCEL_DEFAULT),
                    help="Excel de artículos de farmacia (marca comercial + genérico)")
    ap.add_argument("--sql", action="store_true")
    ap.add_argument("--revisado", help="CSV de propuestas ya revisado")
    args = ap.parse_args()

    if args.generar:
        if not args.externo and not args.excel:
            sys.exit("--generar requiere --externo y/o --excel")
        generar(
            Path(args.externo).expanduser() if args.externo else None,
            Path(args.excel).expanduser() if args.excel else None,
        )
    elif args.sql:
        if not args.revisado:
            sys.exit("--sql requiere --revisado")
        generar_sql(Path(args.revisado).expanduser())
    else:
        ap.print_help()


if __name__ == "__main__":
    main()
