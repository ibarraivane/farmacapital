import {
  validarContenidoMonografia,
  validarResultadoEnriquecimiento,
  payloadSeguroParaAgente,
} from "./validarContenido";

const contenidoOk = {
  resumen: "Inhibe la bomba de protones.",
  para_que_sirve: "Úlcera y reflujo.",
  como_se_usa: ["La dosis y la duración las indica tu médico."],
  no_usar_si: ["Alergia al omeprazol"],
  consulta_si: ["Embarazo"],
  interacciones: "Puede cambiar el efecto de otros medicamentos.",
  efectos: ["Dolor de cabeza"],
  alarma: "Suspende y busca atención si hay sibilancias.",
  conservacion: ["A menos de 30 °C"],
  requiere_receta_habitual: false,
};

test("valida el JSON de monografía §4", () => {
  expect(validarContenidoMonografia(contenidoOk).ok).toBe(true);
  expect(validarContenidoMonografia({ resumen: 1 }).ok).toBe(false);
});

test("cada sección con valor necesita fuente", () => {
  const malo = validarResultadoEnriquecimiento({
    tipo_ficha: "medicamento",
    monografia: { clave: "omeprazol", via: "oral", contenido: contenidoOk },
    producto: { resumen: "Cápsulas de 20 mg" },
    fuentes: [],
    faltantes: [],
  });
  expect(malo.ok).toBe(false);
  expect(malo.errores.join(" ")).toMatch(/sin fuente/);

  const bueno = validarResultadoEnriquecimiento({
    tipo_ficha: "medicamento",
    monografia: { clave: "omeprazol", via: "oral", contenido: contenidoOk },
    producto: { resumen: "Cápsulas de 20 mg" },
    fuentes: [{
      url: "https://laboratorio.example/ipp",
      tipo: "instructivo",
      titulo: "IPP",
      consultado: "2026-09-21",
      campos: ["resumen", "para_que_sirve", "como_se_usa", "no_usar_si", "consulta_si", "interacciones", "efectos", "alarma", "conservacion"],
    }],
    faltantes: [],
  });
  expect(bueno.ok).toBe(true);
});

test("el payload del agente no lleva costo ni proveedor", () => {
  const p = payloadSeguroParaAgente({
    id: 9,
    nombre: "Omeprazol",
    marca: "Ultra",
    codigo_barras: "7501",
    costo: 12.5,
    proveedor: "Nadro",
    precio: 40,
  });
  expect(p.nombre).toBe("Omeprazol");
  expect(JSON.stringify(p)).not.toMatch(/costo|proveedor|precio/i);
});
