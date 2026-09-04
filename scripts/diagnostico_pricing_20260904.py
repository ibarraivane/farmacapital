#!/usr/bin/env python3
"""Diagnóstico de precios / barcodes / molécula — solo lectura.

Lee CSV locales del repo. No toca Supabase ni aplica cambios.

  python3 scripts/diagnostico_pricing_20260904.py

Salida: pricing/reportes/diagnostico_20260904/
"""
from __future__ import annotations

import csv
import math
import re
import unicodedata
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "pricing" / "reportes" / "diagnostico_20260904"
CATALOG = ROOT / "sql" / "preview_catalogo_campos_y_precios.csv"
PENDIENTES = ROOT / "sql" / "pendientes_codigo_barras.csv"
LEVIC = ROOT / "pricing" / "importados" / "import_levic_portal_20260818.csv"
EQUILIBRIO = ROOT / "sql" / "generated" / "ticket_equilibrio_440393.csv"
SIMILARES = ROOT / "pricing" / "reportes" / "similares_match_2026-09-03.csv"
FAHORRO = ROOT / "pricing" / "importados" / "import_fahorro_listo.csv"
TICKETS_DIR = ROOT / "sql" / "generated"

# --- umbrales ( auditable ) -------------------------------------------------
MARKUP_BIN_GENERICO = (0.55, 0.65)
MARKUP_BIN_MARCA = (0.28, 0.45)
PA_SUCIO_TOKENS = (
    "antitranspirante",
    "desodorante",
    "surfactantes",
    "formula capilar",
    "latex",
    "látex",
    "electrolitos",
    "suero oral",
    "higiene",
    "cuidado personal",
)
GS1_MX = "750"
GS1_INTERNO_FARMA = "650"  # no es prefijo de país asignado
DISPERSION_ALERTA_PCT = 25.0

TICKET_FILES = (
    "ticket_nadro_1658128647824.csv",
    "ticket_nadro_20260901.csv",
    "ticket_levic_9012078353.csv",
    "ticket_levic_9012161695.csv",
    "ticket_levic_9012148211.csv",
    "ticket_levic_1020554215.csv",
    "ticket_farmalive_9861.csv",
    "ticket_farmalive_11590.csv",
    "ticket_cityfarma_6315912.csv",
    "ticket_bodega_f42_77827.csv",
    "ticket_surtidor_112558.csv",
    "ticket_exprezo_1279718.csv",
)


def fold(s: str) -> str:
    t = unicodedata.normalize("NFD", str(s or ""))
    t = "".join(c for c in t if unicodedata.category(c) != "Mn")
    t = t.lower()
    t = re.sub(r"[^a-z0-9]+", " ", t)
    return re.sub(r"\s+", " ", t).strip()


def digits(s: str) -> str:
    return re.sub(r"\D", "", str(s or ""))


def ean13_check(d12: str) -> int:
    total = sum(int(d) * (1 if i % 2 == 0 else 3) for i, d in enumerate(d12))
    return (10 - (total % 10)) % 10


def valid_ean13(code: str) -> bool:
    d = digits(code)
    return len(d) == 13 and d[:12].isdigit() and int(d[12]) == ean13_check(d[:12])


def clasificar_ean(code: str) -> dict:
    d = digits(code)
    out = {
        "ean": d,
        "longitud": len(d),
        "checksum_ok": False,
        "prefijo": d[:3] if len(d) >= 3 else "",
        "clase": "vacio",
        "nota": "",
    }
    if not d:
        return out
    if len(d) == 14:
        out["clase"] = "gtin14_caja"
        out["nota"] = "GTIN-14 de caja; el POS escanea EAN-13/UPC"
        out["checksum_ok"] = False
        return out
    if len(d) == 8:
        out["clase"] = "ean8_o_interno"
        out["nota"] = "8 dígitos: EAN-8 real o código interno recortado"
        return out
    if len(d) != 13:
        out["clase"] = "longitud_rara"
        out["nota"] = f"{len(d)} dígitos; se espera EAN-13"
        return out
    out["checksum_ok"] = valid_ean13(d)
    pref = d[:3]
    if pref == GS1_INTERNO_FARMA:
        out["clase"] = "prefijo_650_interno"
        out["nota"] = "Prefijo 650 no es GS1 país (México=750). Interno Farmalive/Genomma."
        return out
    if not out["checksum_ok"]:
        out["clase"] = "checksum_invalido"
        out["nota"] = "Dígito verificador GS1 no cuadra"
        return out
    if pref == GS1_MX:
        out["clase"] = "gs1_mx"
        out["nota"] = "EAN-13 México"
        return out
    out["clase"] = "gs1_otro_pais"
    out["nota"] = f"EAN-13 válido, prefijo {pref} (no 750)"
    return out


def fnum(v) -> float | None:
    if v is None or str(v).strip() == "":
        return None
    try:
        n = float(str(v).replace(",", "").strip())
    except ValueError:
        return None
    return n if math.isfinite(n) else None


def markup_implicito(costo, precio) -> float | None:
    c, p = fnum(costo), fnum(precio)
    if c is None or p is None or c <= 0:
        return None
    return (p / c) - 1.0


def margen_sobre_venta(costo, precio) -> float | None:
    c, p = fnum(costo), fnum(precio)
    if c is None or p is None or p <= 0:
        return None
    return (p - c) / p


def boolish(v) -> bool:
    return str(v or "").strip().lower() in {"true", "1", "t", "yes", "si", "sí"}


def classify_markup_rule(p: dict) -> tuple[float, str]:
    """Espejo de classifyProductoMargen en src/lib/preciosReferencia.js."""
    cat_l = (p.get("categoria") or "").lower()
    nombre = (p.get("nombre") or "").lower()
    tipo = (p.get("tipo") or "").lower()
    forma = (p.get("forma_farmaceutica") or "").lower()
    costo = fnum(p.get("costo")) or 0.0
    pa = (p.get("principio_activo") or "").strip()
    rx = boolish(p.get("requiere_receta"))

    if costo <= 0:
        return 0.0, "sin_costo"
    if costo < 2:
        return 0.35, "sin_clasificar"

    if "hidrat" in cat_l or cat_l == "bebidas" or re.search(
        r"electrolit|pedialyte|suero oral|oralit", nombre
    ):
        return 0.30, "categoria"
    if "beb" in cat_l or re.search(r"pañal|huggies|nan |enfamil", nombre):
        return 0.30, "categoria"
    if cat_l in {"abarrotes", "minisuper"}:
        return 0.40, "categoria"
    if cat_l in {"suplemento", "vitaminas"} or "vitamina" in nombre:
        return 0.45, "categoria"
    if "botiqu" in cat_l or re.search(r"venda|gasa|jeringa|algodon|guante", nombre):
        return 0.50, "categoria"
    if cat_l in {"higiene", "cuidado personal"}:
        return 0.40, "categoria"
    if re.search(r"tensiometro|glucometro|nebulizador|termometro|oximetro", nombre):
        return (0.30 if costo >= 300 else 0.50), "disp_med"

    med_form = bool(
        re.search(
            r"tableta|capsula|cápsula|jarabe|suspension|solucion|inyect|comprim|gragea",
            forma,
        )
    )
    if tipo in {"generico", "genérico"} and pa and med_form:
        return 0.60, "med_generico"
    if tipo == "marca" and rx:
        return 0.25, "med_patente"
    if tipo == "marca" and med_form and not rx:
        return 0.35, "med_otc_marca"
    return 0.35, "sin_clasificar"


def price_floor(costo: float, markup: float) -> float | None:
    if costo <= 0:
        return None
    min_profit = 5 if costo < 20 else (8 if costo < 50 else 0)
    base = costo * (1 + markup)
    return math.ceil(max(base, costo + min_profit))


def percentile(xs: list[float], p: float) -> float | None:
    if not xs:
        return None
    ys = sorted(xs)
    if len(ys) == 1:
        return ys[0]
    k = (len(ys) - 1) * p
    f = math.floor(k)
    c = math.ceil(k)
    if f == c:
        return ys[int(k)]
    return ys[f] * (c - k) + ys[c] * (k - f)


def read_csv(path: Path) -> list[dict]:
    if not path.exists():
        return []
    with path.open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def write_csv(path: Path, rows: list[dict], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        w.writeheader()
        for row in rows:
            w.writerow({k: row.get(k, "") for k in fieldnames})


def pa_sucio(pa: str) -> bool:
    n = fold(pa)
    if not n:
        return False
    return any(tok in n for tok in PA_SUCIO_TOKENS)


def load_tickets_ean() -> list[dict]:
    rows = []
    for name in TICKET_FILES:
        path = TICKETS_DIR / name
        if not path.exists():
            continue
        fuente = name.replace("ticket_", "").replace(".csv", "")
        for i, r in enumerate(read_csv(path), start=1):
            ean = digits(r.get("ean") or r.get("codigo_barras") or "")
            if not ean:
                continue
            rows.append(
                {
                    "fuente": fuente,
                    "ean": ean,
                    "descripcion": (
                        r.get("descripcion")
                        or r.get("descripcion_ticket")
                        or r.get("nombre")
                        or ""
                    ),
                    "laboratorio": r.get("laboratorio") or "",
                    "sku_ticket": r.get("sku_farmacapital") or r.get("sku") or "",
                    "linea": r.get("linea") or str(i),
                }
            )
    return rows


def load_levic_por_clave() -> dict[str, dict]:
    out = {}
    for r in read_csv(LEVIC):
        clave = str(r.get("sku_externo") or "").strip().upper()
        ean = digits(r.get("ean_levic") or r.get("ean_fc") or "")
        if not clave or not ean:
            continue
        out[clave] = {
            "ean": ean,
            "nombre_levic": r.get("nombre") or r.get("nombre_fuente") or "",
            "sku_fc": r.get("sku") or "",
            "precio_levic": r.get("precio") or "",
        }
    return out


def load_equilibrio() -> list[dict]:
    rows = []
    for i, r in enumerate(read_csv(EQUILIBRIO), start=1):
        rows.append(
            {
                "linea": i,
                "codigo_prov": str(r.get("codigo_prov") or "").strip().upper(),
                "descripcion": r.get("descripcion") or "",
                "lote": str(r.get("lote") or "").strip().upper(),
                "costo": r.get("costo_unitario") or "",
            }
        )
    return rows


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    catalogo = read_csv(CATALOG)
    pendientes = read_csv(PENDIENTES)
    levic = load_levic_por_clave()
    equilibrio = load_equilibrio()
    tickets_ean = load_tickets_ean()
    similares = {r.get("sku"): r for r in read_csv(SIMILARES) if r.get("sku")}
    fahorro = {r.get("sku"): r for r in read_csv(FAHORRO) if r.get("sku")}

    eq_por_lote = {}
    for r in equilibrio:
        if r["lote"] and r["lote"] not in eq_por_lote:
            eq_por_lote[r["lote"]] = r
    eq_por_linea = {r["linea"]: r for r in equilibrio}
    eq_por_fold = {}
    for r in equilibrio:
        k = fold(r["descripcion"])
        if k and k not in eq_por_fold:
            eq_por_fold[k] = r

    ean_a_ticket = defaultdict(list)
    for t in tickets_ean:
        ean_a_ticket[t["ean"]].append(t)
    sku_ticket_ean = {}
    for t in tickets_ean:
        sku = str(t.get("sku_ticket") or "").strip()
        if sku and t["ean"] and sku not in sku_ticket_ean:
            sku_ticket_ean[sku] = t

    farmalive_lab = {}
    for t in tickets_ean:
        if "farmalive" in t["fuente"] and t["ean"] and t.get("laboratorio"):
            farmalive_lab[t["ean"]] = t["laboratorio"]

    # --- catálogo -----------------------------------------------------------
    markups = []
    ean_skus = defaultdict(list)
    item_rows = []
    barcode_audit = []
    pa_counter = Counter()
    sin_barcode = []

    for p in catalogo:
        sku = p.get("sku") or ""
        ean_raw = p.get("codigo_barras") or ""
        ean_info = clasificar_ean(ean_raw)
        costo = fnum(p.get("costo"))
        precio = fnum(p.get("precio"))
        mk = markup_implicito(costo, precio)
        mg = margen_sobre_venta(costo, precio)
        if mk is not None:
            markups.append(mk)
        rule_mk, rule_code = classify_markup_rule(p)
        piso = price_floor(costo or 0, rule_mk) if costo else None
        pa = (p.get("principio_activo") or "").strip()
        if pa:
            pa_counter[fold(pa)] += 1
        if ean_info["ean"]:
            ean_skus[ean_info["ean"]].append(sku)
        else:
            sin_barcode.append(p)

        sim = similares.get(sku) or {}
        fah = fahorro.get(sku) or {}
        ref_sim = fnum(sim.get("precio_similares"))
        ref_fah = fnum(fah.get("precio") or fah.get("precio_del_ahorro"))
        refs = [x for x in (ref_sim, ref_fah) if x and x > 0]
        ref_min = min(refs) if refs else None
        sugerido = math.ceil(ref_min * 0.98) if ref_min else None
        piso_gt_mercado = (
            piso is not None and sugerido is not None and piso > sugerido
        )

        lab_inferido = farmalive_lab.get(ean_info["ean"], "")
        item_rows.append(
            {
                "sku": sku,
                "nombre": p.get("nombre") or "",
                "tipo": p.get("tipo") or "",
                "categoria": p.get("categoria") or "",
                "marca": p.get("marca") or "",
                "laboratorio_inferido": lab_inferido,
                "principio_activo": pa,
                "pa_sucio": "si" if pa_sucio(pa) else "",
                "concentracion": p.get("concentracion") or "",
                "forma_farmaceutica": p.get("forma_farmaceutica") or "",
                "presentacion": p.get("presentacion") or "",
                "costo": f"{costo:.2f}" if costo is not None else "",
                "precio": f"{precio:.2f}" if precio is not None else "",
                "markup_implicito_pct": f"{mk * 100:.1f}" if mk is not None else "",
                "margen_sobre_venta_pct": f"{mg * 100:.1f}" if mg is not None else "",
                "regla_markup": rule_code,
                "regla_markup_pct": f"{rule_mk * 100:.0f}",
                "piso": piso if piso is not None else "",
                "ean": ean_info["ean"],
                "ean_clase": ean_info["clase"],
                "ean_nota": ean_info["nota"],
                "precio_similares": ref_sim if ref_sim is not None else "",
                "precio_fahorro": ref_fah if ref_fah is not None else "",
                "ref_min": ref_min if ref_min is not None else "",
                "sugerido_min_menos_2": sugerido if sugerido is not None else "",
                "piso_gt_mercado": "si" if piso_gt_mercado else "",
                "stock": p.get("stock") or "",
            }
        )
        if ean_info["ean"] and ean_info["clase"] not in {"gs1_mx", "gs1_otro_pais"}:
            barcode_audit.append(
                {
                    "sku": sku,
                    "nombre": p.get("nombre") or "",
                    **ean_info,
                }
            )

    dupes = []
    for ean, skus in sorted(ean_skus.items()):
        if len(skus) > 1:
            for sku in skus:
                p = next((x for x in catalogo if x.get("sku") == sku), {})
                dupes.append(
                    {
                        "ean": ean,
                        "n_skus": len(skus),
                        "sku": sku,
                        "nombre": p.get("nombre") or "",
                    }
                )

    # --- cruce 148 sin barcode ----------------------------------------------
    pend_por_sku = {r.get("sku"): r for r in pendientes}
    candidatos = []
    for p in sin_barcode:
        sku = p.get("sku") or ""
        pend = pend_por_sku.get(sku, {})
        ticket = pend.get("ticket") or ""
        linea = int(pend.get("linea") or 0) or None
        lote = str(pend.get("lote") or "").strip().upper()
        nombre_ticket = pend.get("nombre") or p.get("nombre") or ""

        eq = None
        via = ""
        if lote and lote in eq_por_lote:
            eq = eq_por_lote[lote]
            via = "lote_equilibrio"
        elif ticket == "440393" and linea and linea in eq_por_linea:
            eq = eq_por_linea[linea]
            via = "linea_equilibrio"
        else:
            k = fold(nombre_ticket)
            if k in eq_por_fold:
                eq = eq_por_fold[k]
                via = "nombre_fold_equilibrio"

        clave = (eq or {}).get("codigo_prov") or ""
        lev = levic.get(clave) if clave else None
        ean_levic = (lev or {}).get("ean") or ""
        ean_ticket_sku = (sku_ticket_ean.get(sku) or {}).get("ean") or ""

        aceptable = ""
        confirmado_por = ""
        if ean_ticket_sku:
            aceptable = "candidato_ean_ticket"
            confirmado_por = sku_ticket_ean[sku]["fuente"]
        elif ean_levic and via in {"lote_equilibrio", "linea_equilibrio"}:
            aceptable = "candidato_clave_levic"
            confirmado_por = f"equilibrio.{via}+levic.{clave}"
        elif ean_levic and via == "nombre_fold_equilibrio":
            aceptable = "revisar_nombre"
            confirmado_por = f"fold+levic.{clave}"

        # no aplicar: columna aceptado vacía a propósito
        candidatos.append(
            {
                "sku": sku,
                "nombre": p.get("nombre") or "",
                "ticket": ticket,
                "linea_ticket": linea or "",
                "lote": lote,
                "nombre_ticket": nombre_ticket,
                "clave_equilibrio": clave,
                "via_match": via,
                "ean_propuesto": ean_ticket_sku or ean_levic,
                "nombre_levic": (lev or {}).get("nombre_levic") or "",
                "precio_levic": (lev or {}).get("precio_levic") or "",
                "aceptable": aceptable,
                "confirmado_por": confirmado_por,
                "aceptado": "",  # vacío a propósito — no aplicar en lote
                "aviso": (
                    "NO aplicar en lote. Solo clave/EAN exacto. "
                    "Revisar a mano si via=nombre_fold."
                    if aceptable
                    else "Sin clave/EAN exacto en tickets ni portal Levic"
                ),
            }
        )

    # --- grupos molécula ----------------------------------------------------
    grupos = defaultdict(list)
    for row in item_rows:
        pa = fold(row["principio_activo"])
        if not pa or row["pa_sucio"] == "si":
            continue
        conc = fold(row["concentracion"])
        forma = fold(row["forma_farmaceutica"])
        if not conc and not forma:
            continue
        key = f"{pa}|{conc}|{forma}"
        grupos[key].append(row)

    grupos_out = []
    for key, members in sorted(grupos.items(), key=lambda kv: -len(kv[1])):
        if len(members) < 2:
            continue
        precios = [fnum(m["precio"]) for m in members if fnum(m["precio"])]
        if len(precios) < 2:
            continue
        mn, mx = min(precios), max(precios)
        disp = ((mx - mn) / mn * 100.0) if mn > 0 else 0.0
        pa, conc, forma = key.split("|")
        grupos_out.append(
            {
                "principio_activo": pa,
                "concentracion": conc,
                "forma": forma,
                "n_skus": len(members),
                "skus": " | ".join(m["sku"] for m in members),
                "nombres": " | ".join(m["nombre"] for m in members),
                "marcas": " | ".join(sorted({m["marca"] for m in members if m["marca"]})),
                "precio_min": f"{mn:.2f}",
                "precio_max": f"{mx:.2f}",
                "dispersion_precio_pct": f"{disp:.1f}",
                "alerta": "si" if disp >= DISPERSION_ALERTA_PCT else "",
            }
        )

    # --- writes -------------------------------------------------------------
    write_csv(
        OUT / "01_item_por_item.csv",
        item_rows,
        [
            "sku",
            "nombre",
            "tipo",
            "categoria",
            "marca",
            "laboratorio_inferido",
            "principio_activo",
            "pa_sucio",
            "concentracion",
            "forma_farmaceutica",
            "presentacion",
            "costo",
            "precio",
            "markup_implicito_pct",
            "margen_sobre_venta_pct",
            "regla_markup",
            "regla_markup_pct",
            "piso",
            "ean",
            "ean_clase",
            "ean_nota",
            "precio_similares",
            "precio_fahorro",
            "ref_min",
            "sugerido_min_menos_2",
            "piso_gt_mercado",
            "stock",
        ],
    )
    write_csv(
        OUT / "02_barcodes_calidad.csv",
        barcode_audit,
        ["sku", "nombre", "ean", "longitud", "checksum_ok", "prefijo", "clase", "nota"],
    )
    write_csv(
        OUT / "03_barcodes_duplicados.csv",
        dupes,
        ["ean", "n_skus", "sku", "nombre"],
    )
    write_csv(
        OUT / "04_cruce_tickets_ean.csv",
        tickets_ean,
        ["fuente", "ean", "descripcion", "laboratorio", "sku_ticket", "linea"],
    )
    write_csv(
        OUT / "05_grupos_molecula.csv",
        grupos_out,
        [
            "principio_activo",
            "concentracion",
            "forma",
            "n_skus",
            "skus",
            "nombres",
            "marcas",
            "precio_min",
            "precio_max",
            "dispersion_precio_pct",
            "alerta",
        ],
    )
    write_csv(
        OUT / "06_barcodes_candidatos.csv",
        candidatos,
        [
            "sku",
            "nombre",
            "ticket",
            "linea_ticket",
            "lote",
            "nombre_ticket",
            "clave_equilibrio",
            "via_match",
            "ean_propuesto",
            "nombre_levic",
            "precio_levic",
            "aceptable",
            "confirmado_por",
            "aceptado",
            "aviso",
        ],
    )

    n = len(catalogo)
    n_ean = sum(1 for p in catalogo if digits(p.get("codigo_barras") or ""))
    n_sin = n - n_ean
    clases = Counter(r["ean_clase"] for r in item_rows)
    cand_ok = sum(
        1
        for c in candidatos
        if c["aceptable"] in {"candidato_ean_ticket", "candidato_clave_levic"}
    )
    cand_rev = sum(1 for c in candidatos if c["aceptable"] == "revisar_nombre")
    p25 = percentile(markups, 0.25)
    p50 = percentile(markups, 0.50)
    p75 = percentile(markups, 0.75)
    p95 = percentile(markups, 0.95)
    bin_30 = sum(1 for m in markups if 0.28 <= m <= 0.45)
    bin_60 = sum(1 for m in markups if 0.55 <= m <= 0.65)
    n_conc = sum(1 for p in catalogo if str(p.get("concentracion") or "").strip())
    n_pa = sum(1 for p in catalogo if str(p.get("principio_activo") or "").strip())
    n_pa_sucio = sum(1 for r in item_rows if r["pa_sucio"] == "si")
    n_con_ref = sum(1 for r in item_rows if r["ref_min"] != "")
    n_piso_gt = sum(1 for r in item_rows if r["piso_gt_mercado"] == "si")
    n_650 = clases.get("prefijo_650_interno", 0)
    n_chk = clases.get("checksum_invalido", 0)
    n_gtin14 = clases.get("gtin14_caja", 0)
    n_dupe_ean = len({d["ean"] for d in dupes})
    n_dupe_sku = len(dupes)

    resumen = f"""diagnostico_pricing_20260904
catalogo={CATALOG.name}  n={n}
con_ean={n_ean} ({n_ean/n*100:.1f}%)  sin_ean={n_sin} ({n_sin/n*100:.1f}%)

markup implicito (precio/costo - 1)
  p25={p25*100:.1f}%  p50={p50*100:.1f}%  p75={p75*100:.1f}%  p95={p95*100:.1f}%
  bin 28-45% (marca-ish) = {bin_30}
  bin 55-65% (generico-ish) = {bin_60}

ean_clase
  gs1_mx={clases.get("gs1_mx", 0)}
  gs1_otro_pais={clases.get("gs1_otro_pais", 0)}
  prefijo_650_interno={n_650}
  checksum_invalido={n_chk}
  gtin14_caja={n_gtin14}
  longitud_rara={clases.get("longitud_rara", 0)}
  ean8_o_interno={clases.get("ean8_o_interno", 0)}
  vacio={clases.get("vacio", 0)}
duplicados: {n_dupe_ean} EAN distintos / {n_dupe_sku} SKUs

campos
  con_principio_activo={n_pa}  pa_sucio={n_pa_sucio}  con_concentracion={n_conc} ({n_conc/n*100:.1f}%)
grupos molecula (>=2 SKUs, PA limpio) = {len(grupos_out)}
  con dispersion>={DISPERSION_ALERTA_PCT:.0f}% = {sum(1 for g in grupos_out if g["alerta"]=="si")}

refs venta locales (Similares sept-3 + Del Ahorro import)
  skus_con_alguna_ref={n_con_ref}
  piso > sugerido (min-2%) = {n_piso_gt}

candidatos barcode (NO aplicar en lote)
  clave/EAN exacto = {cand_ok}
  solo fold nombre = {cand_rev}  (revisar a mano)
  sin match = {n_sin - cand_ok - cand_rev}

tickets con EAN cargados = {len(tickets_ean)} lineas
claves Levic portal = {len(levic)}
lineas Equilibrio = {len(equilibrio)}

NO se escribio nada en Supabase.
Regenerar: python3 scripts/diagnostico_pricing_20260904.py
"""
    # --- diagnóstico accionable + SQL (EAN exactos / duplicados) ----------
    ean_ocupado = {}
    for p in catalogo:
        e = digits(p.get("codigo_barras") or "")
        if e:
            ean_ocupado.setdefault(e, []).append(p.get("sku") or "")

    cand_por_sku = {c["sku"]: c for c in candidatos}

    def percentil_py(xs, p=0.4):
        ys = sorted(x for x in xs if x and x > 0)
        if not ys:
            return None
        if len(ys) == 1:
            return ys[0]
        k = (len(ys) - 1) * p
        lo, hi = math.floor(k), math.ceil(k)
        if lo == hi:
            return ys[lo]
        return ys[lo] * (hi - k) + ys[hi] * (k - lo)

    diag = []
    sql_ean = []
    for row in item_rows:
        sku = row["sku"]
        cand = cand_por_sku.get(sku, {})
        ean_prop = digits(cand.get("ean_propuesto") or "")
        aceptable = cand.get("aceptable") or ""
        ocupado_por = [s for s in ean_ocupado.get(ean_prop, []) if s and s != sku]
        clase_prop = clasificar_ean(ean_prop)["clase"] if ean_prop else ""

        accion_ean = "ok"
        if not row["ean"]:
            if aceptable in {"candidato_ean_ticket", "candidato_clave_levic"} and ean_prop:
                if ocupado_por:
                    accion_ean = "ean_propuesto_ya_usado"
                elif clase_prop == "prefijo_650_interno":
                    accion_ean = "revisar_650"
                elif clase_prop in {"gs1_mx", "gs1_otro_pais"}:
                    accion_ean = "asignar_ean"
                else:
                    accion_ean = "revisar_ean"
            else:
                accion_ean = "capturar_al_recibir"
        elif row["ean_clase"] == "prefijo_650_interno":
            accion_ean = "marcar_interno_650"
        elif row["ean_clase"] == "checksum_invalido":
            accion_ean = "corregir_checksum"
        elif row["ean_clase"] == "gtin14_caja":
            accion_ean = "usar_ean13_unidad"
        elif row["ean"] in {d["ean"] for d in dupes}:
            accion_ean = "fusionar_duplicado"

        refs = []
        if fnum(row["precio_similares"]):
            refs.append(fnum(row["precio_similares"]))
        if fnum(row["precio_fahorro"]):
            refs.append(fnum(row["precio_fahorro"]))
        ancla = percentil_py(refs, 0.4) if refs else None
        costo = fnum(row["costo"])
        piso = fnum(row["piso"])
        precio = fnum(row["precio"])
        techo = math.ceil(ancla) if ancla else None
        sugerido_nuevo = None
        alerta_precio = ""
        if ancla:
            sugerido_nuevo = math.ceil(ancla)
            if piso and sugerido_nuevo < piso:
                sugerido_nuevo = int(piso)
                if techo and piso > techo:
                    alerta_precio = "piso_gt_techo"
        accion_precio = "sin_ref_mercado"
        if sugerido_nuevo and precio:
            if alerta_precio == "piso_gt_techo":
                accion_precio = "revisar_compra"
            elif sugerido_nuevo - precio >= 2:
                accion_precio = "subir"
            elif precio - sugerido_nuevo >= 2:
                accion_precio = "bajar"
            else:
                accion_precio = "mantener"

        accion_datos = []
        if row["pa_sucio"] == "si":
            accion_datos.append("limpiar_pa")
        if not str(row["concentracion"]).strip() and row["principio_activo"]:
            accion_datos.append("llenar_concentracion")
        if not row["laboratorio_inferido"]:
            accion_datos.append("capturar_laboratorio")

        if accion_ean == "asignar_ean" and ean_prop:
            sql_ean.append((sku, ean_prop, cand.get("confirmado_por") or "", cand.get("nombre") or row["nombre"]))

        diag.append({
            **row,
            "ean_propuesto": ean_prop,
            "accion_ean": accion_ean,
            "sugerido_nuevo": sugerido_nuevo if sugerido_nuevo is not None else "",
            "alerta_precio": alerta_precio,
            "accion_precio": accion_precio,
            "accion_datos": "|".join(accion_datos),
            "accion_principal": (
                "revisar_compra" if accion_precio == "revisar_compra"
                else accion_ean if accion_ean not in {"ok", "marcar_interno_650"}
                else accion_precio if accion_precio != "sin_ref_mercado"
                else (accion_datos[0] if accion_datos else "ok")
            ),
        })

    write_csv(
        OUT / "07_diagnostico_sku.csv",
        diag,
        list(item_rows[0].keys()) + [
            "ean_propuesto", "accion_ean", "sugerido_nuevo", "alerta_precio",
            "accion_precio", "accion_datos", "accion_principal",
        ] if item_rows else [],
    )

    # SQL EAN exactos
    sql_path = ROOT / "sql" / "patch_barcodes_exactos_20260904.sql"
    lines = [
        "-- EAN exactos: clave Equilibrio→Levic o EAN de ticket.",
        "-- Solo WHERE codigo_barras IS NULL. No pisa códigos existentes.",
        "-- Generado por scripts/diagnostico_pricing_20260904.py",
        "begin;",
        "",
    ]
    for sku, ean, via, nombre in sql_ean:
        nom = nombre.replace("'", "''")
        via_s = via.replace("'", "''")
        lines.append(
            f"-- {nom} · {via_s}\n"
            f"update public.productos\n"
            f"   set codigo_barras = '{ean}'\n"
            f" where sku = '{sku}'\n"
            f"   and (codigo_barras is null or btrim(codigo_barras) = '')\n"
            f"   and not exists (\n"
            f"     select 1 from public.productos x\n"
            f"      where x.codigo_barras = '{ean}' and x.sku <> '{sku}'\n"
            f"   );"
        )
    lines += ["", "commit;", ""]
    sql_path.write_text("\n".join(lines), encoding="utf-8")

    # SQL duplicados: deja el SKU con más stock / nombre más largo
    dupe_sql = ROOT / "sql" / "patch_barcodes_duplicados_20260904.sql"
    dlines = [
        "-- Libera EAN duplicados: se queda el SKU con más stock (empate: nombre más largo).",
        "begin;",
        "",
    ]
    by_ean = defaultdict(list)
    for p in catalogo:
        e = digits(p.get("codigo_barras") or "")
        if e:
            by_ean[e].append(p)
    n_lib = 0
    for ean, ps in sorted(by_ean.items()):
        if len(ps) < 2:
            continue
        ps_sorted = sorted(
            ps,
            key=lambda x: (-(fnum(x.get("stock")) or 0), -len(x.get("nombre") or "")),
        )
        keep = ps_sorted[0].get("sku")
        for extra in ps_sorted[1:]:
            sku = extra.get("sku")
            n_lib += 1
            dlines.append(
                f"-- {ean} se queda en {keep}; libera {sku} ({extra.get('nombre') or ''})\n"
                f"update public.productos set codigo_barras = null where sku = '{sku}' and codigo_barras = '{ean}';"
            )
    dlines += ["", "commit;", ""]
    dupe_sql.write_text("\n".join(dlines), encoding="utf-8")

    lab_pares = []
    seen_ean = set()
    for t in tickets_ean:
        if not (t.get("laboratorio") and t.get("ean") and "farmalive" in t["fuente"]):
            continue
        ean = digits(t["ean"])
        if not ean or ean in seen_ean:
            continue
        seen_ean.add(ean)
        lab = str(t["laboratorio"]).replace("'", "''")
        lab_pares.append((ean, lab))
    vals = ",\n".join(f"      ('{ean}', '{lab}')" for ean, lab in lab_pares)
    lab_sql = ROOT / "sql" / "patch_laboratorio_columna_20260904.sql"
    lab_sql.write_text(
        """-- Columna laboratorio (distinta de marca) + backfill FarmaLive.
-- Un bloque: crea la columna si falta y llena en un solo update.
-- FarmaLive a veces manda EAN sin dígito (650240010712 vs 6502400107128).

do $$
begin
  if not exists (
    select 1
      from information_schema.columns
     where table_schema = 'public'
       and table_name = 'productos'
       and column_name = 'laboratorio'
  ) then
    alter table public.productos add column laboratorio text;
  end if;

  update public.productos p
     set laboratorio = v.lab
    from (values
"""
        + vals
        + """
    ) as v(ean, lab)
   where (p.laboratorio is null or btrim(p.laboratorio) = '')
     and (
       regexp_replace(coalesce(p.codigo_barras, ''), '\\D', '', 'g') = v.ean
       or regexp_replace(coalesce(p.codigo_barras, ''), '\\D', '', 'g') like v.ean || '_'
     );
end $$;

comment on column public.productos.laboratorio is
  'Laboratorio fabricante (FarmaLive). Distinto de marca de mostrador.';

select count(*) filter (where laboratorio is not null and btrim(laboratorio) <> '') as con_lab
from public.productos;
""",
        encoding="utf-8",
    )

    counts = Counter(d["accion_principal"] for d in diag)
    md = ["# Diagnóstico SKU por SKU — 2026-09-04", "", "Fuente: `07_diagnostico_sku.csv` (626 filas).", "", "## Acciones", ""]
    md.append("| accion_principal | SKUs |")
    md.append("|---|---|")
    for k, v in counts.most_common():
        md.append(f"| `{k}` | {v} |")
    md += [
        "",
        f"SQL EAN a aplicar (revisar): `{sql_path.name}` · {len(sql_ean)} updates.",
        f"SQL duplicados: `{dupe_sql.name}` · {n_lib} liberaciones.",
        "SQL laboratorio: `patch_laboratorio_columna_20260904.sql`.",
        "",
        "No se escribió en Supabase. Corre los SQL en el Editor cuando los aceptes.",
    ]
    (OUT / "07_resumen_acciones.md").write_text("\n".join(md), encoding="utf-8")

    resumen += (
        f"\nacciones principales: {dict(counts)}\n"
        f"sql_ean_updates={len(sql_ean)}  sql_dupes_libera={n_lib}\n"
    )
    (OUT / "00_resumen.txt").write_text(resumen, encoding="utf-8")
    print(resumen)


if __name__ == "__main__":
    main()

