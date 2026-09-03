import { claveSustancia, formaFarmaceuticaClave } from "../utils/equivalentesPos";
import {
  agruparReabastoPorActivo,
  calcStockUrgencia,
  claveGrupoReabasto,
  idParaPedir,
  leyendaCoberturaGrupo,
  representativoParaPedir,
  reabastoFilaMatchesBusqueda,
} from "./reabastoPorActivo";

const C = { red: "#e", redDim: "#ed", amber: "#a", amberDim: "#ad" };

const busconetFa = {
  id: 33,
  nombre: "Busconet 1 Fa 250/20mg/5 Ml",
  sku: "EQ-SON033",
  marca: "Busconet",
  principio_activo: "Bromuro de butil hiocina y metamizol sódico",
  forma_farmaceutica: "",
  presentacion: "",
  stock: 0,
  stock_minimo: 5,
  costo: 33.38,
  activo: true,
};

const pasmodilFa = {
  id: 80,
  nombre: "Pasmodil 1 Fa 250/20 Mg",
  sku: "EQ-COL080",
  marca: "Pasmodil",
  principio_activo: "Hioscina / Metamizol sódico",
  forma_farmaceutica: "Solución inyectable",
  presentacion: "1 frasco ámpula",
  stock: 6,
  stock_minimo: 5,
  costo: 28.5,
  activo: true,
};

const busconetTab = {
  id: 34,
  nombre: "Busconet 10 Tab 250/10 Mg",
  sku: "EQ-SON034",
  marca: "Busconet",
  principio_activo: "Metamizol / Butilhioscina",
  forma_farmaceutica: "Tabletas",
  presentacion: "C/10",
  stock: 0,
  stock_minimo: 5,
  costo: 24.92,
  activo: true,
};

const paracetamol = {
  id: 9,
  nombre: "Tempra 500 mg",
  sku: "FC-TEMPRA",
  marca: "Tempra",
  principio_activo: "Paracetamol",
  forma_farmaceutica: "Tabletas",
  stock: 0,
  stock_minimo: 5,
  activo: true,
};

describe("claveSustancia — Busconet / Pasmodil", () => {
  it("une hiocina, butilhioscina e hioscina con metamizol", () => {
    expect(claveSustancia(busconetFa)).toBe("hioscina+metamizol");
    expect(claveSustancia(pasmodilFa)).toBe(claveSustancia(busconetFa));
    expect(claveSustancia(busconetTab)).toBe(claveSustancia(pasmodilFa));
  });
});

describe("formaFarmaceuticaClave", () => {
  it("lee 1 Fa como inyectable y Tab como tabletas", () => {
    expect(formaFarmaceuticaClave(busconetFa)).toBe("inyectable");
    expect(formaFarmaceuticaClave(pasmodilFa)).toBe("inyectable");
    expect(formaFarmaceuticaClave(busconetTab)).toBe("tabletas");
  });
});

describe("agruparReabastoPorActivo", () => {
  it("no marca agotado el inyectable si Pasmodil cubre a Busconet", () => {
    const filas = agruparReabastoPorActivo([busconetFa, pasmodilFa, busconetTab, paracetamol]);
    const inyectable = filas.find((f) => f.esGrupoActivo && String(f.claveGrupo).includes("inyectable"));
    expect(inyectable).toBeTruthy();
    expect(inyectable.stock).toBe(6);
    expect(inyectable.falta.map((p) => p.id)).toEqual([33]);
    expect(inyectable.cubre.map((p) => p.id)).toEqual([80]);
    expect(calcStockUrgencia(inyectable, C)?.nivel).not.toBe("AGOTADO");
    expect(leyendaCoberturaGrupo(inyectable)).toMatch(/Pasmodil/);
    expect(leyendaCoberturaGrupo(inyectable)).toMatch(/Busconet/);
    expect(representativoParaPedir(inyectable.miembros).id).toBe(80);
    expect(idParaPedir(inyectable)).toBe(80);
  });

  it("no mezcla tabletas con inyectable del mismo activo", () => {
    const filas = agruparReabastoPorActivo([busconetFa, pasmodilFa, busconetTab]);
    const tabs = filas.filter((f) => (f.claveGrupo || "").includes("tabletas") || f.id === 34);
    const inys = filas.filter((f) => (f.claveGrupo || "").includes("inyectable") || f.esGrupoActivo);
    expect(tabs).toHaveLength(1);
    expect(inys.some((f) => f.esGrupoActivo && f.stock === 6)).toBe(true);
    expect(calcStockUrgencia(busconetTab, C).nivel).toBe("AGOTADO");
  });

  it("deja solo un SKU si no hay equivalente", () => {
    const filas = agruparReabastoPorActivo([paracetamol]);
    expect(filas).toHaveLength(1);
    expect(filas[0].esGrupoActivo).toBe(false);
    expect(filas[0].id).toBe(9);
  });

  it("encuentra el grupo buscando la marca que falta", () => {
    const filas = agruparReabastoPorActivo([busconetFa, pasmodilFa]);
    const grupo = filas.find((f) => f.esGrupoActivo);
    expect(reabastoFilaMatchesBusqueda(grupo, "busconet")).toBe(true);
    expect(reabastoFilaMatchesBusqueda(grupo, "pasmodil")).toBe(true);
    expect(reabastoFilaMatchesBusqueda(grupo, "hioscina")).toBe(true);
    expect(reabastoFilaMatchesBusqueda(grupo, "ibuprofeno")).toBe(false);
  });

  it("permite pedir la marca faltante si se elige a mano", () => {
    const filas = agruparReabastoPorActivo([busconetFa, pasmodilFa]);
    const grupo = filas.find((f) => f.esGrupoActivo);
    expect(idParaPedir(grupo, { [grupo.claveGrupo]: 33 })).toBe(33);
  });
});

describe("claveGrupoReabasto", () => {
  it("separa por forma", () => {
    expect(claveGrupoReabasto(busconetFa)).not.toBe(claveGrupoReabasto(busconetTab));
    expect(claveGrupoReabasto(busconetFa)).toBe(claveGrupoReabasto(pasmodilFa));
  });
});
