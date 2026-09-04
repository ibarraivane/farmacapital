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

  test("bloqueador abre protección solar aunque el nombre sea Fotosun", () => {
    const fotosun = producto({ nombre: "Fotosun UV100", marca: "Fotosun", categoria: "Cuidado personal" });
    expect(tiendaProductMatchesBusqueda(fotosun, "bloqueador")).toBe(true);
    expect(etiquetaIntencionMostrador("bloqueador")).toBe("protección solar");
    expect(etiquetaIntencionMostrador("bloqueador solar")).toBe("protección solar");
  });

  test("el código de ticket Nadro sigue saliendo con bloqueador", () => {
    const ticket = producto({
      nombre: "BLOQ ANTHE UVAIR 50+ FLU INV 40ML",
      marca: "FRABEL 2",
      subcategoria: "Protector solar",
    });
    expect(tiendaProductMatchesBusqueda(ticket, "bloqueador")).toBe(true);
    expect(coincidenciaIntencionMostrador(ticket, "bloqueador")?.id).toBe("proteccion-solar");
  });

  test("pegamento dental abre adhesivo para dentadura y no se mezcla con dolor dental", () => {
    const corega = producto({
      nombre: "Corega Ultra Sin Sabor 40 g",
      marca: "Corega",
      subcategoria: "Protesis dental / adhesivo",
    });
    const ibuprofeno = producto({
      nombre: "Ibuprofeno 400 mg",
      principio_activo: "Ibuprofeno",
      subcategoria: "Analgésico",
    });
    expect(tiendaProductMatchesBusqueda(corega, "pegamento dental")).toBe(true);
    expect(etiquetaIntencionMostrador("pegamento dental")).toBe("adhesivo para dentadura");
    expect(etiquetaIntencionMostrador("adhesivo para dentadura")).toBe("adhesivo para dentadura");
    expect(coincidenciaIntencionMostrador(ibuprofeno, "pegamento dental")).toBeNull();
    expect(tiendaProductMatchesBusqueda(ibuprofeno, "dolor dental")).toBe(true);
    expect(etiquetaIntencionMostrador("dolor dental")).toBe("dolor dental");
    expect(coincidenciaIntencionMostrador(corega, "dolor dental")).toBeNull();
  });

  test("no activa intención con texto corto, numérico o desconocido", () => {
    expect(intencionesParaConsulta("do")).toEqual([]);
    expect(intencionesParaConsulta("7501234567890")).toEqual([]);
    expect(intencionesParaConsulta("cualquier cosa rara")).toEqual([]);
  });
});
