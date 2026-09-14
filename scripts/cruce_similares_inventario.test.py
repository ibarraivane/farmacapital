#!/usr/bin/env python3
"""Pruebas del cruce Similares vs inventario (sin red)."""
from pathlib import Path
import importlib.util
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "cruce", ROOT / "scripts" / "cruce_similares_inventario.py"
)
cruce = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cruce)


class ActivosYClase(unittest.TestCase):
    def test_activos_ibuprofeno(self):
        ings = cruce.activos_sim("IBUPROFENO 400 MG 10 TABLETAS")
        self.assertIn("ibuprofeno", ings)

    def test_agua_de_mar_no_es_principio(self):
        ings = cruce.activos_sim("AGUA DE MAR 100ML SPRAY STERIMAR")
        self.assertNotIn("agua", ings)
        self.assertEqual(ings, [])

    def test_calcetin_diabetes_no_es_clase_a(self):
        clase, *_ = cruce.clase_y_stock({
            "descripcion": "CALCETIN PARA DIABETICO COLOR AZUL UNISEX 1 PAR",
            "marca": "",
            "forma": "",
            "jerarquia": "Diabetes",
            "linea": "Diabetes",
            "precio": 61,
        })
        self.assertEqual(clase, "C")

    def test_curacion_excel_linea(self):
        clase, *_ = cruce.clase_y_stock({
            "descripcion": "GASA ESTERIL 10X10 10 PIEZAS",
            "marca": "",
            "forma": "",
            "jerarquia": "MATERIAL DE CURACION",
            "linea": "CURACION Y MEDICION",
            "precio": 25,
        })
        self.assertEqual(clase, "CUR")

    def test_desodorante_no_es_curacion(self):
        clase, *_ = cruce.clase_y_stock({
            "descripcion": "DESODORANTE ANTITRANSPIRANTE GEL CABALLERO GILLETTE 82 GR",
            "marca": "",
            "forma": "gel",
            "jerarquia": "Higiene, curación y diagnóstico",
            "linea": "Higiene",
            "precio": 85,
        })
        self.assertEqual(clase, "C")

    def test_ibuprofeno_si_es_clase_a(self):
        clase, *_ = cruce.clase_y_stock({
            "descripcion": "IBUPROFENO 400 MG 10 TABLETAS",
            "marca": "",
            "forma": "tableta",
            "jerarquia": "Medicamentos",
            "linea": "Analgésicos",
            "precio": 18,
        })
        self.assertEqual(clase, "A")


class CruceFalsosPositivos(unittest.TestCase):
    def test_agua_mar_no_cubre_oxigenada(self):
        sim = [cruce.vtex_a_fila({
            "productName": "AGUA DE MAR 100ML SPRAY STERIMAR",
            "productReference": "4195",
            "brand": "PICK UP",
            "categories": ["/Aparato respiratorio/Gripa y tos/"],
            "items": [{"name": "STERIMAR", "sellers": [{"commertialOffer": {"Price": 219}}]}],
            "link": "",
        })]
        productos = [{
            "sku": "FC-83351381",
            "nombre": "Agua oxigenada Protec",
            "principio_activo": "",
            "marca": "Dermocleen",
            "presentacion": "120 mL",
            "forma_farmaceutica": "",
            "concentracion": "",
            "stock": 4,
        }]
        huecos, _rellenar, ok = cruce.cruzar(sim, productos)
        self.assertEqual(ok, [])
        self.assertEqual(len(huecos), 1)

    def test_tempra_vago_no_cubre_otra_presentacion(self):
        sim = [cruce.vtex_a_fila({
            "productName": "PARACETAMOL 80MG 30 TABLETAS MASTICABLES TEMPRA",
            "productReference": "3839",
            "brand": "PICK UP",
            "categories": ["/Medicamentos/Analgésicos/"],
            "items": [{"name": "TEMPRA 80", "sellers": [{"commertialOffer": {"Price": 103}}]}],
            "link": "",
        })]
        productos = [{
            "sku": "FC-58792792",
            "nombre": "Tempra",
            "principio_activo": "",
            "marca": "Tempra",
            "presentacion": "",
            "forma_farmaceutica": "",
            "concentracion": "",
            "stock": 1,
        }]
        huecos, rellenar, ok = cruce.cruzar(sim, productos)
        self.assertEqual(ok + rellenar, [])
        self.assertEqual(len(huecos), 1)

    def test_nombre_corto_sin_dosis_no_cubre(self):
        sim = [cruce.vtex_a_fila({
            "productName": "ACIDO ACETILSALICILICO 500 MG 20 TABLETAS",
            "productReference": "7",
            "brand": "PICK UP",
            "categories": ["/Medicamentos/Analgésicos/"],
            "items": [{"name": "ASA 500", "sellers": [{"commertialOffer": {"Price": 15}}]}],
            "link": "",
        })]
        productos = [{
            "sku": "FC-7D1D9857",
            "nombre": "Acetilsalicilico",
            "principio_activo": "",
            "marca": "Acido",
            "presentacion": "",
            "forma_farmaceutica": "",
            "concentracion": "",
            "stock": 5,
        }]
        huecos, rellenar, ok = cruce.cruzar(sim, productos)
        self.assertEqual(ok + rellenar, [])
        self.assertEqual(len(huecos), 1)

    def test_mismo_generico_cubre(self):
        sim = [cruce.vtex_a_fila({
            "productName": "IBUPROFENO 400 MG 10 TABLETAS",
            "productReference": "100",
            "brand": "PICK UP",
            "categories": ["/Medicamentos/Analgésicos/"],
            "items": [{"name": "IBU 400", "sellers": [{"commertialOffer": {"Price": 18}}]}],
            "link": "",
        })]
        productos = [{
            "sku": "FC-IBU400",
            "nombre": "Ibuprofeno 400 mg C/10 AMSA",
            "principio_activo": "Ibuprofeno",
            "marca": "AMSA",
            "presentacion": "10 tabletas",
            "forma_farmaceutica": "tableta",
            "concentracion": "400 mg",
            "stock": 8,
        }]
        huecos, rellenar, ok = cruce.cruzar(sim, productos)
        self.assertEqual(huecos, [])
        self.assertEqual(len(ok) + len(rellenar), 1)


if __name__ == "__main__":
    unittest.main()
