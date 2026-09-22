import { mapearFichaTienda } from "./mapearFichaTienda";

const producto = {
  nombre: "Omeprazol 20 mg",
  descripcion: "Texto corto de respaldo",
  principio_activo: "Omeprazol",
  concentracion: "20 mg",
  forma_farmaceutica: "Cápsula",
  presentacion: "30 cápsulas",
  marca: "Ultra",
  requiere_receta: false,
  codigo_barras: "750123",
};

test("sin ficha publicada degrada a ficha técnica", () => {
  const ui = mapearFichaTienda({
    producto,
    ficha: { estado: "borrador", contenido: { resumen: "NO PUBLICAR", chips: ["oculto"] } },
    monografia: { estado: "borrador", contenido: { para_que_sirve: "NO" } },
  });
  expect(ui.publicada).toBe(false);
  expect(ui.clinica).toBeNull();
  expect(ui.chips).toEqual([]);
  expect(ui.resumen).toBe("Texto corto de respaldo");
  expect(ui.mostrarSoloTecnica).toBe(true);
  expect(ui.fichaTecnica.map((r) => r.k)).toContain("Sustancia activa");
  expect(ui.fichaTecnica.map((r) => r.k)).not.toContain("Código de barras");
  expect(ui.fichaTecnica.some((r) => r.v === "750123")).toBe(false);
});

test("ficha de cliente expande C/12 y no muestra el EAN", () => {
  const ui = mapearFichaTienda({
    producto: {
      nombre: "Aspirina Eferv",
      descripcion: "Aspirina Eferv 7501008496701",
      principio_activo: "Acidoacetilsalicilico",
      forma_farmaceutica: "TABLETAS",
      presentacion: "C/12",
      marca: "Aspirina",
      requiere_receta: false,
      codigo_barras: "7501008496701",
    },
  });
  expect(ui.resumen).toBe("");
  expect(ui.fichaTecnica.find((r) => r.k === "Forma farmacéutica").v).toBe("Tabletas");
  expect(ui.fichaTecnica.find((r) => r.k === "Presentación").v).toBe("Caja con 12");
  expect(ui.fichaTecnica.map((r) => r.k)).not.toContain("Código de barras");
  expect(ui.fichaTecnica.some((r) => String(r.v).includes("7501008496701"))).toBe(false);
});

test("con ficha y monografía publicadas arma acordeones", () => {
  const ui = mapearFichaTienda({
    producto,
    ficha: {
      estado: "publicado",
      tipo_ficha: "medicamento",
      contenido: { resumen: "Resumen de ficha", chips: ["1 cápsula al día"] },
      registro_sanitario: "123M2020",
    },
    monografia: {
      estado: "publicado",
      contenido: {
        resumen: "De la sustancia",
        para_que_sirve: "Reflujo",
        como_se_usa: ["En ayunas"],
        no_usar_si: ["Alergia"],
        consulta_si: [],
        interacciones: "Consulta la lista.",
        efectos: ["Dolor de cabeza"],
        alarma: "Busca atención.",
        conservacion: ["Lugar seco"],
      },
    },
  });
  expect(ui.publicada).toBe(true);
  expect(ui.resumen).toBe("Resumen de ficha");
  expect(ui.chips).toEqual(["1 cápsula al día"]);
  expect(ui.clinica.para_que_sirve).toBe("Reflujo");
  expect(ui.fichaTecnica.find((r) => r.k === "Registro sanitario").v).toBe("123M2020");
  expect(ui.mostrarSoloTecnica).toBe(false);
});

test("dermo usa fabricante y no clínica", () => {
  const ui = mapearFichaTienda({
    producto: { ...producto, principio_activo: "" },
    ficha: {
      estado: "publicado",
      tipo_ficha: "dermocosmetico",
      contenido: {
        resumen: "Crema",
        fabricante: { descripcion: "Hidrata", modo_de_uso: ["Aplica"] },
      },
    },
  });
  expect(ui.clinica).toBeNull();
  expect(ui.fabricante.descripcion).toBe("Hidrata");
});
