import { politicaProducto, validarCarritoPolitica, textosPolitica, TIPO } from "./politicaMedicamentos";

describe("politicaMedicamentos", () => {

  const amoxi = { nombre: "Amoxicilina 500", categoria: "Antibiótico" };
  const tramadol = { nombre: "Tramadol", categoria: "Analgésico", controlado: true };
  const rx = { nombre: "Losartán", categoria: "Cardiovascular", requiere_receta: true };
  const libre = { nombre: "Paracetamol", categoria: "Analgésico" };

  it("controlado nunca se vende en línea, sin importar switches", () => {
    const p = politicaProducto(tramadol, { canal: "habilitado", envioAntibioticos: true });
    expect(p.tipo).toBe(TIPO.CONTROLADO);
    expect(p.ventaEnLinea).toBe(false);
  });

  it("antibiótico siempre requiere receta, el switch solo cambia el canal", () => {
    for (const canal of ["habilitado", "suspendido"]) {
      expect(politicaProducto(amoxi, { canal, envioAntibioticos: false }).requiereReceta).toBe(true);
    }
    expect(politicaProducto(amoxi, { canal: "habilitado", envioAntibioticos: false }).ventaEnLinea).toBe(true);
    expect(politicaProducto(amoxi, { canal: "suspendido", envioAntibioticos: true }).ventaEnLinea).toBe(false);
    expect(politicaProducto(amoxi, { canal: "suspendido", envioAntibioticos: true }).envioDomicilio).toBe(false);
  });

  it("antibiótico a domicilio solo si ambos switches lo permiten", () => {
    expect(politicaProducto(amoxi, { canal: "habilitado", envioAntibioticos: false }).envioDomicilio).toBe(false);
    expect(politicaProducto(amoxi, { canal: "habilitado", envioAntibioticos: true }).envioDomicilio).toBe(true);
  });

  it("antibiótico escrito sin acento también se reconoce", () => {
    expect(politicaProducto({ categoria: "antibioticos" }, { canal: "habilitado" }).tipo).toBe(TIPO.ANTIBIOTICO);
  });

  it("carrito: antibiótico bloquea envío con default, no bloquea recoger", () => {
    const opts = { canal: "habilitado", envioAntibioticos: false };
    expect(validarCarritoPolitica([amoxi, libre], "envio", opts).ok).toBe(false);
    expect(validarCarritoPolitica([amoxi, libre], "cdmx", opts).ok).toBe(false);
    expect(validarCarritoPolitica([amoxi, libre], "recoger", opts).ok).toBe(true);
    expect(validarCarritoPolitica([amoxi, libre], "pickup", opts).ok).toBe(true);
    expect(validarCarritoPolitica([{ prod: amoxi }], "recoger", opts).requiereReceta).toBe(true);
  });

  it("carrito: controlado bloquea incluso al recoger", () => {
    const r = validarCarritoPolitica([tramadol], "recoger", { canal: "habilitado" });
    expect(r.ok).toBe(false);
    expect(r.bloqueados.length).toBe(1);
  });

  it("Rx general y libre no cambian respecto a hoy", () => {
    expect(validarCarritoPolitica([rx, libre], "envio", { canal: "habilitado" }).ok).toBe(true);
  });

  it("los textos nunca dicen que la receta de antibióticos es opcional", () => {
    for (const canal of ["habilitado", "suspendido"]) {
      for (const envioAntibioticos of [true, false]) {
        const t = textosPolitica({ canal, envioAntibioticos });
        const todo = Object.values(t).join(" ").toLowerCase();
        expect(todo).not.toContain("no es obligatoria");
        expect(t.faqReceta).toContain("receta");
      }
    }
  });
});
