import {
  coincidenciaIntencionMostrador,
  etiquetaIntencionMostrador,
  intencionesParaConsulta,
} from "./intencionMostrador";
import { tiendaCatalogSearchSuggestions, tiendaProductMatchesBusqueda, tiendaSearchRelevanceRank } from "./fuzzySearch";

const producto = (overrides) => ({ id: Math.random(), activo: true, ...overrides });

describe("lenguaje controlado de mostrador", () => {
  const dimenhidrinato = producto({ nombre: "Vomisin 50 mg", marca: "Vomisin", principio_activo: "Dimenhidrinato" });
  const paracetamol = producto({ nombre: "Tempra 500 mg", marca: "Tempra", principio_activo: "Paracetamol", subcategoria: "Analgésico" });
  const muscular = producto({ nombre: "Robax Gold", principio_activo: "Metocarbamol / Ibuprofeno", subcategoria: "Relajante muscular" });
  const mucolitico = producto({ nombre: "Ambroxol jarabe", principio_activo: "Ambroxol", subcategoria: "Expectorante" });
  const antitusivo = producto({ nombre: "Dextrometorfano jarabe", principio_activo: "Dextrometorfano", subcategoria: "Antitusivo" });

  test("mareo encuentra un SKU real por dimenhidrinato y tolera un typo", () => {
    expect(tiendaProductMatchesBusqueda(dimenhidrinato, "mareo")).toBe(true);
    expect(tiendaProductMatchesBusqueda(dimenhidrinato, "marreo")).toBe(true);
    expect(etiquetaIntencionMostrador("mareo")).toBe("mareo o náusea por movimiento");
  });

  test("no usa una descripción que menciona mareo como efecto adverso", () => {
    const ajeno = producto({ nombre: "Producto ajeno", principio_activo: "Otro", descripcion: "Puede causar mareo" });
    expect(tiendaProductMatchesBusqueda(ajeno, "mareo")).toBe(false);
    expect(coincidenciaIntencionMostrador(ajeno, "mareo")).toBeNull();
  });

  test("dolor de espalda privilegia el contexto muscular", () => {
    expect(tiendaProductMatchesBusqueda(muscular, "dolor espalda")).toBe(true);
    expect(tiendaProductMatchesBusqueda(paracetamol, "dolor espalda")).toBe(false);
  });

  test("dolor de cabeza encuentra paracetamol y exige los espacios", () => {
    expect(tiendaProductMatchesBusqueda(paracetamol, "dolor de cabeza")).toBe(true);
    expect(tiendaProductMatchesBusqueda(paracetamol, "dolordecabeza")).toBe(false);
    expect(etiquetaIntencionMostrador("dolor de cabeza")).toBe("dolor de cabeza");
  });

  test("deshidratado abre hidratación oral", () => {
    const suero = producto({ nombre: "Electrolit 625 mL", subcategoria: "Electrolitos" });
    expect(tiendaProductMatchesBusqueda(suero, "deshidratado")).toBe(true);
    expect(etiquetaIntencionMostrador("deshidratado")).toBe("hidratación oral");
  });

  test("distingue tos con flema de tos seca", () => {
    expect(tiendaProductMatchesBusqueda(mucolitico, "tos con flema")).toBe(true);
    expect(tiendaProductMatchesBusqueda(antitusivo, "tos con flema")).toBe(false);
    expect(tiendaProductMatchesBusqueda(antitusivo, "tos seca")).toBe(true);
    expect(tiendaProductMatchesBusqueda(mucolitico, "tos seca")).toBe(false);
  });

  test("una marca escrita directamente conserva prioridad sobre intención", () => {
    expect(tiendaSearchRelevanceRank(paracetamol, "Tempra")).toBeLessThan(
      tiendaSearchRelevanceRank(dimenhidrinato, "mareo")
    );
  });

  test("las sugerencias del buscador también incluyen relaciones controladas", () => {
    const suggestions = tiendaCatalogSearchSuggestions([paracetamol, dimenhidrinato], "mareo");
    expect(suggestions.map((item) => item.nombre)).toEqual(["Vomisin 50 mg"]);
  });

  test("no activa intención con texto corto, numérico o desconocido", () => {
    expect(intencionesParaConsulta("do")).toEqual([]);
    expect(intencionesParaConsulta("7501234567890")).toEqual([]);
    expect(intencionesParaConsulta("cualquier cosa rara")).toEqual([]);
  });
});
