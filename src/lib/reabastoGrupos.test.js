import {
  agruparFilasReabasto,
  claveGrupoReabasto,
  etiquetaMarca,
  etiquetaPrincipioActivo,
  grupoEstaSeleccionado,
  marcasDelGrupo,
} from "./reabastoGrupos";

const tempra = {
  id: 1,
  nombre: "Tempra 500 mg C/20",
  marca: "Tempra",
  tipo: "marca",
  principio_activo: "Paracetamol",
  stock: 0,
  urgencia: { nivel: "AGOTADO" },
};
const paracetamolGen = {
  id: 2,
  nombre: "Paracetamol 500 mg C/20",
  marca: "Genérico",
  tipo: "generico",
  principio_activo: "Paracetamol",
  stock: 2,
  urgencia: { nivel: "CRÍTICO" },
};
const tylenolOk = {
  id: 3,
  nombre: "Tylenol 500 mg",
  marca: "Tylenol",
  tipo: "marca",
  principio_activo: "Paracetamol",
  stock: 12,
  activo: true,
};
const electrolit = {
  id: 10,
  nombre: "Electrolit fresa",
  marca: "Electrolit",
  stock: 1,
  urgencia: { nivel: "CRÍTICO" },
};
const huggies80 = {
  id: 20,
  nombre: "Toallitas Huggies C/80",
  marca: "Huggies",
  stock: 3,
  urgencia: { nivel: "BAJO" },
};
const huggies40 = {
  id: 21,
  nombre: "Toallitas Huggies C/40",
  marca: "Huggies",
  stock: 4,
  urgencia: { nivel: "BAJO" },
};
const treda = {
  id: 30,
  nombre: "Treda C/20",
  marca: "Treda",
  tipo: "marca",
  principio_activo: "Neomicina + Caolin + Pectina",
  presentacion: "C/20",
  forma_farmaceutica: "Tabletas",
  concentracion: "129/280/30 mg",
  urgencia: { nivel: "AGOTADO" },
};
const nineka = {
  id: 31,
  nombre: "Nineka C/20",
  marca: "Nineka",
  tipo: "generico",
  principio_activo: "Neomicina / Caolín y Pectina",
  presentacion: "C/20",
  forma_farmaceutica: "Tabletas",
  concentracion: "129/280/30 mg",
  urgencia: { nivel: "BAJO" },
};

test("clave de grupo junta el mismo principio activo escrito distinto", () => {
  expect(claveGrupoReabasto(tempra).clave).toBe(claveGrupoReabasto(paracetamolGen).clave);
  expect(claveGrupoReabasto(treda).clave).toBe(claveGrupoReabasto(nineka).clave);
  expect(claveGrupoReabasto({ principio_activo: "Amoxicilina" }).clave)
    .not.toBe(claveGrupoReabasto({ principio_activo: "Amoxicilina / Ácido clavulánico" }).clave);
});

test("etiqueta de marca no trata Genérico como laboratorio", () => {
  expect(etiquetaMarca(tempra)).toBe("Tempra");
  expect(etiquetaMarca(paracetamolGen)).toBe("Genérico");
  expect(etiquetaPrincipioActivo(tempra)).toBe("Paracetamol");
});

test("Tempra y el genérico de paracetamol son el mismo medicamento", () => {
  const grupos = agruparFilasReabasto([electrolit, paracetamolGen, tempra]);
  expect(grupos[0].tipo).toBe("medicamento");
  expect(grupos[0].etiqueta).toBe("Paracetamol");
  expect(grupos[0].subtitulo).toMatch(/Mismo medicamento/);
  expect(grupos[0].productos.map((p) => p.id)).toEqual([1, 2]);
  expect(grupos[0].marcas).toEqual(["Tempra", "Genérico"]);
  expect(grupos[1].etiqueta).toBe("Electrolit");
});

test("Treda y Nineka se agrupan aunque el PA venga con otra grafía", () => {
  const grupos = agruparFilasReabasto([nineka, treda]);
  expect(grupos).toHaveLength(1);
  expect(grupos[0].marcas).toEqual(["Treda", "Nineka"]);
  expect(grupos[0].subtitulo).toBe("Mismo medicamento · 2 marcas");
});

test("sin principio activo agrupa por marca", () => {
  const grupos = agruparFilasReabasto([huggies40, huggies80, electrolit]);
  const huggies = grupos.find((g) => g.tipo === "marca" && g.etiqueta === "Huggies");
  expect(huggies.productos.map((p) => p.id).sort()).toEqual([20, 21]);
  expect(huggies.subtitulo).toBe("Misma marca");
});

test("muestra otras marcas del mismo PA que sí tienen stock", () => {
  const grupos = agruparFilasReabasto([tempra], { catalogo: [tempra, paracetamolGen, tylenolOk] });
  expect(grupos[0].relacionados.map((p) => p.marca)).toEqual(["Genérico", "Tylenol"]);
});

test("no mezcla un PA distinto ni productos sin stock en relacionados", () => {
  const amoxi = { id: 40, nombre: "Amoxil", principio_activo: "Amoxicilina", stock: 8, activo: true };
  const agotado = { ...tylenolOk, id: 41, stock: 0 };
  const grupos = agruparFilasReabasto([tempra], { catalogo: [tempra, amoxi, agotado] });
  expect(grupos[0].relacionados).toEqual([]);
});

test("marcasDelGrupo y selección del grupo", () => {
  expect(marcasDelGrupo([tempra, paracetamolGen, tempra])).toEqual(["Tempra", "Genérico"]);
  expect(grupoEstaSeleccionado({ productos: [tempra, paracetamolGen] }, { 1: 6, 2: 3 })).toBe(true);
  expect(grupoEstaSeleccionado({ productos: [tempra, paracetamolGen] }, { 1: 6 })).toBe(false);
});
