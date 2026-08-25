#!/usr/bin/env python3
"""Tests de la cascada A/B/C y matches_confirmados — sin red."""

from __future__ import annotations

import csv
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from lib.pricing.match import (  # noqa: E402
    ProductoCatalogo,
    ProductoProveedor,
    cargar_confirmados,
    enriquecer_catalogo,
    enriquecer_proveedor,
    matchear_fuente,
)


MARCAS = ["Asepxia", "Pantene", "Saba"]


def _cat(**kw) -> ProductoCatalogo:
    base = dict(sku="FC-1", nombre="Jabon Asepxia Bicarbon", marca="Asepxia", presentacion="100 G")
    base.update(kw)
    return enriquecer_catalogo([ProductoCatalogo(**base)], MARCAS)[0]


def _prov(**kw) -> ProductoProveedor:
    base = dict(
        fuente="MayoreoTotal",
        id_producto_proveedor="X1",
        producto_raw="Jabón Asepxia Bicarbonato de Sodio 100 g",
        marca="Asepxia",
        precio_unitario=18.0,
    )
    base.update(kw)
    return enriquecer_proveedor([ProductoProveedor(**base)], MARCAS)[0]


class TestCascada(unittest.TestCase):
    def test_nivel_a_marca_tamano_tipo(self):
        cat = _cat()
        p = _prov()
        m = matchear_fuente([cat], [p], "MayoreoTotal", {})[0]
        self.assertEqual(m.nivel, "A")
        self.assertEqual(m.proveedor.id_producto_proveedor, "X1")

    def test_nivel_b_misma_marca_nombre(self):
        cat = _cat(presentacion="100 G")
        # mismo jabón, tamaño distinto → no A; nombre muy parecido → B
        p = _prov(
            id_producto_proveedor="X2",
            producto_raw="Jabón Asepxia Bicarbonato de Sodio 150 g",
        )
        m = matchear_fuente([cat], [p], "MayoreoTotal", {})[0]
        self.assertEqual(m.nivel, "B")
        self.assertGreaterEqual(m.score, 85)

    def test_nivel_c_sin_marca_no_automatch(self):
        cat = _cat()
        p = _prov(
            marca="",
            producto_raw="Barra de limpieza facial carbonato 100 g marca genérica",
            id_producto_proveedor="Z9",
        )
        # quitar marca_norm a propósito
        p.marca_norm = ""
        m = matchear_fuente([cat], [p], "MayoreoTotal", {})[0]
        self.assertEqual(m.nivel, "C")
        self.assertIsNone(m.proveedor)
        self.assertTrue(m.candidatos)

    def test_confirmado_se_respeta(self):
        cat = _cat()
        p = _prov(id_producto_proveedor="MANUAL-77", producto_raw="otra cosa 50 ml")
        conf = {("FC-1", "MayoreoTotal"): "MANUAL-77"}
        m = matchear_fuente([cat], [p], "MayoreoTotal", conf)[0]
        self.assertEqual(m.nivel, "confirmado")
        self.assertEqual(m.proveedor.id_producto_proveedor, "MANUAL-77")

    def test_cargar_confirmados_csv(self):
        with tempfile.TemporaryDirectory() as td:
            path = Path(td) / "m.csv"
            with path.open("w", encoding="utf-8", newline="") as fh:
                w = csv.DictWriter(fh, fieldnames=["sku", "fuente", "id_producto_proveedor"])
                w.writeheader()
                w.writerow({"sku": "FC-9", "fuente": "Scorpion", "id_producto_proveedor": "5427"})
            d = cargar_confirmados(path)
            self.assertEqual(d[("FC-9", "Scorpion")], "5427")


if __name__ == "__main__":
    unittest.main()
