import { clasificarTipoFicha } from "./tipoFicha";

test("medicamento con sustancia", () => {
  const r = clasificarTipoFicha({
    nombre: "Omeprazol 20 mg",
    principio_activo: "Omeprazol",
    categoria: "Gastro",
  });
  expect(r.tipo_ficha).toBe("medicamento");
  expect(r.clave_monografia).toBe("omeprazol");
  expect(r.revisar_clasificacion).toBe(false);
});

test("sin sustancia pide revisión", () => {
  const r = clasificarTipoFicha({
    nombre: "Producto suelto",
    principio_activo: "",
    categoria: "Otro",
  });
  expect(r.revisar_clasificacion).toBe(true);
});

test("dermo y suplemento", () => {
  expect(clasificarTipoFicha({
    nombre: "CeraVe hidratante",
    marca: "CeraVe",
    categoria: "Cuidado personal",
  }).tipo_ficha).toBe("dermocosmetico");
  expect(clasificarTipoFicha({
    nombre: "Birdman proteína",
    categoria: "Suplemento",
  }).tipo_ficha).toBe("suplemento");
});

test("material y equipo", () => {
  expect(clasificarTipoFicha({
    nombre: "Gasa estéril",
    categoria: "Botiquín",
  }).tipo_ficha).toBe("material");
  expect(clasificarTipoFicha({
    nombre: "Oxímetro de pulso",
    categoria: "Dispositivo médico",
  }).tipo_ficha).toBe("equipo_medico");
});
