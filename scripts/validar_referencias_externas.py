#!/usr/bin/env python3
"""
Valida un listado externo de precios de referencia contra nuestro catálogo.

Sirve para aprovechar el trabajo de matching de una fuente externa (por ejemplo un
CSV generado contra el catálogo de Similares) sin confiar en su etiqueta de confianza:
se toma el nombre del producto candidato que trae el archivo y se vuelve a evaluar con
el mismo verificador de scripts/sync_precios_similares.py (principios activos,
concentración, cantidad por caja y forma farmacéutica).

Formato esperado del CSV: sku, precio, fuente, confianza_match, notas
donde `notas` contiene el nombre del producto de la fuente. Las filas cuyo `notas`
no traiga un `(Score: N%)` se descartan: no son un match contra la fuente sino una
estimación que repite nuestro propio nombre y se auto-validaría.

Uso:
  python3 scripts/validar_referencias_externas.py --csv archivo.csv --dry-run
  python3 scripts/validar_referencias_externas.py --csv archivo.csv --apply
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

# Reutilizamos el verificador ya probado en lugar de duplicar la lógica de scoring
_spec = importlib.util.spec_from_file_location("sync_similares", Path(__file__).with_name("sync_precios_similares.py"))
sync = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(sync)

import requests  # noqa: E402  (después de cargar el módulo hermano)

RE_SCORE = re.compile(r"\(Score:\s*(\d+)%\)")


def limpiar_candidato(notas: str) -> tuple[str | None, int | None]:
    """
    'CEFOTAXIMA 1GR SOL INY.. (Score: 100%)' → ('CEFOTAXIMA 1GR SOL INY', 100)
    Devuelve (None, None) si la fila no es un match real contra la fuente.
    """
    if not notas:
        return None, None
    m = RE_SCORE.search(notas)
    if not m:
        return None, None
    nombre = RE_SCORE.sub("", notas).strip()
    nombre = re.sub(r"\.\.$", "", nombre).strip(" .-")
    return (nombre or None), int(m.group(1))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv", required=True, help="CSV externo (sku,precio,fuente,confianza_match,notas)")
    ap.add_argument("--fuente", default="similares", help="id en fuentes_precio (default: similares)")
    ap.add_argument("--umbral", type=int, default=sync.UMBRAL_DEFAULT)
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    ruta = Path(args.csv).expanduser()
    if not ruta.exists():
        sys.exit(f"No existe {ruta}")

    env = sync.cargar_env()
    url = env.get("REACT_APP_SUPABASE_URL", "")
    key = env.get("REACT_APP_SUPABASE_ANON_KEY", "")
    if not url or not key:
        sys.exit("Faltan credenciales Supabase en .env")

    productos = sync.fetch_productos(url, key)
    por_sku = {p["sku"]: p for p in productos if p.get("sku")}

    # No repetir productos que ya tienen referencia verificada de esta fuente
    headers = {"apikey": key, "Authorization": f"Bearer {key}"}
    r = requests.get(
        f"{url}/rest/v1/producto_precios_referencia_actual",
        headers=headers,
        params={"select": "producto_id,confianza", "fuente": f"eq.{args.fuente}"},
        timeout=60,
    )
    r.raise_for_status()
    ya_cubiertos = {x["producto_id"] for x in r.json() if (x.get("confianza") or 0) >= args.umbral}

    filas = list(csv.DictReader(ruta.open(encoding="utf-8")))
    aceptados: list[dict] = []
    motivos: dict[str, int] = {}

    def contar(m: str) -> None:
        motivos[m] = motivos.get(m, 0) + 1

    for f in filas:
        sku = (f.get("sku") or "").strip()
        p = por_sku.get(sku)
        if not p:
            contar("SKU no existe en el catálogo")
            continue
        if p["id"] in ya_cubiertos:
            contar("ya tiene referencia verificada")
            continue

        candidato, score_externo = limpiar_candidato(f.get("notas") or "")
        if not candidato:
            contar("estimación sin match real contra la fuente")
            continue

        try:
            precio = float(f.get("precio") or 0)
        except ValueError:
            contar("precio ilegible")
            continue

        confianza, razones = sync.evaluar_candidato(p, candidato)
        if confianza < args.umbral:
            contar(f"no pasa verificación (<{args.umbral})")
            continue

        costo = p.get("costo")
        costo = float(costo) if costo not in (None, "") else None
        motivo_precio = sync.validar_precio(precio, costo)
        if motivo_precio:
            contar(f"guardarrail de precio: {motivo_precio.split()[0]}")
            continue

        aceptados.append({
            "producto_id": p["id"],
            "sku": sku,
            "nombre": p.get("nombre"),
            "precio": precio,
            "confianza": confianza,
            "nombre_fuente": candidato,
            "razones": "; ".join(razones),
            "score_externo": score_externo,
            "etiqueta_externa": f.get("confianza_match"),
        })

    print(f"Filas en el archivo: {len(filas)}")
    print(f"Aceptadas tras verificar: {len(aceptados)}")
    for m, n in sorted(motivos.items(), key=lambda t: -t[1]):
        print(f"  descartadas · {n:4d}  {m}")

    etiquetas: dict[str, int] = {}
    for a in aceptados:
        etiquetas[a["etiqueta_externa"]] = etiquetas.get(a["etiqueta_externa"], 0) + 1
    if etiquetas:
        print("Etiqueta original de las aceptadas:", dict(sorted(etiquetas.items())))

    REPORTE_DIR.mkdir(parents=True, exist_ok=True)
    salida = REPORTE_DIR / f"validacion_externa_{ruta.stem}_{date.today().isoformat()}.csv"
    with salida.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["sku", "nombre", "precio", "confianza_verificada", "etiqueta_externa",
                    "score_externo", "nombre_fuente", "razones"])
        for a in sorted(aceptados, key=lambda x: -x["confianza"]):
            w.writerow([a["sku"], a["nombre"], a["precio"], a["confianza"], a["etiqueta_externa"],
                        a["score_externo"], a["nombre_fuente"], a["razones"]])
    print(f"CSV: {salida}")

    if not args.apply or args.dry_run:
        if not args.dry_run:
            print("Usa --apply para guardar en Supabase")
        return
    if not aceptados:
        print("Nada que insertar.")
        return

    fecha = date.today().isoformat()
    wh = {**headers, "Content-Type": "application/json", "Prefer": "return=representation"}
    imp = requests.post(
        f"{url}/rest/v1/importaciones_referencia",
        headers=wh,
        json={
            "fuente": args.fuente,
            "tipo": "venta",
            "fecha_lista": fecha,
            "archivo": ruta.name,
            "filas_ok": len(aceptados),
            "notas": f"validar_referencias_externas.py (verificado, umbral {args.umbral})",
        },
        timeout=60,
    )
    imp.raise_for_status()
    import_id = imp.json()[0]["id"]

    payload = [
        {
            "producto_id": a["producto_id"],
            "fuente": args.fuente,
            "tipo": "venta",
            "precio": round(a["precio"], 2),
            "fecha": fecha,
            "nombre_fuente": a["nombre_fuente"],
            "confianza": a["confianza"],
            "origen": "import_csv",
            "import_id": import_id,
            "notas": f"externo:{ruta.name} | {a['razones']}"[:500],
        }
        for a in aceptados
    ]
    for i in range(0, len(payload), 100):
        r = requests.post(
            f"{url}/rest/v1/producto_precios_referencia",
            headers=wh,
            json=payload[i: i + 100],
            timeout=120,
        )
        r.raise_for_status()
    print(f"Guardadas {len(payload)} referencias (import_id={import_id}).")


if __name__ == "__main__":
    main()
