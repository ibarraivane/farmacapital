#!/usr/bin/env python3
import importlib.util
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "dups", ROOT / "scripts" / "duplicados_sin_barcode.py"
)
dups = importlib.util.module_from_spec(spec)
spec.loader.exec_module(dups)


class ParesCurados(unittest.TestCase):
    def test_sin_sku_pobre_repetido(self):
        pobres = [r[0] for r in dups.DUPLICADOS]
        self.assertEqual(len(pobres), len(set(pobres)))

    def test_unico_pasar_stock_es_cintapore(self):
        pasar = [r for r in dups.DUPLICADOS if r[6] == 0]
        self.assertEqual([r[0] for r in pasar], ["FMX-301136"])

    def test_lo_bruquin_es_el_sku_guion_1(self):
        self.assertTrue(any(r[0] == "EQ-BRL072-1" and r[3] == "EQ-BRL072" for r in dups.DUPLICADOS))

    def test_gentamicina_comprimidos_no_se_desactiva(self):
        self.assertFalse(any(r[0] == "FC-63975795" for r in dups.DUPLICADOS))
        self.assertTrue(any(r[0] == "FC-63975795" for r in dups.UNICOS_SIN_EAN))

    def test_mercurio_arnica_no_va_en_el_sql(self):
        self.assertFalse(any(r[0] == "FC-89F00320" for r in dups.DUPLICADOS))

    def test_sql_exige_ean_del_bueno(self):
        sql = dups.escribir_sql.__doc__ or ""
        from io import StringIO
        import tempfile
        from pathlib import Path
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "x.sql"
            dups.escribir_sql(p)
            txt = p.read_text()
        self.assertIn("ean_del_bueno_no_cuadra", txt)
        self.assertIn("listo_para_desactivar", txt)
        self.assertNotIn("FC-89F00320", txt)
        self.assertIn("EQ-BRL072-1", txt)
        self.assertGreaterEqual(len(dups.COMPRAR), 7)


if __name__ == "__main__":
    unittest.main()
