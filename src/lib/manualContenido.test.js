import { buscarManual, hayrol, temasParaUsuario, TEMAS, GLOSARIO } from "./manualContenido";

describe("manualContenido", () => {
  test("vendedor no ve reabasto ni costos", () => {
    const u = { rol: "vendedor" };
    const temas = temasParaUsuario(u, (_user, id) => ["midia", "pos", "dev", "agenda", "inv", "caja", "pwa", "ayuda"].includes(id));
    const ids = temas.map((t) => t.id);
    expect(ids).toContain("recibir");
    expect(ids).toContain("catalogo");
    expect(ids).not.toContain("reabasto");
    expect(ids).not.toContain("lotes");
    expect(ids).not.toContain("dashboard");
    expect(ids).toContain("midia");
  });

  test("doctora solo clínica", () => {
    const u = { rol: "doctora" };
    const temas = temasParaUsuario(u, (_user, id) => ["cons_dr", "exp_dr", "ayuda"].includes(id));
    const ids = temas.map((t) => t.id);
    expect(ids).toContain("agenda-doctora");
    expect(ids).toContain("expedientes");
    expect(ids).not.toContain("recibir");
    expect(ids).not.toContain("pos");
  });

  test("admin ve Recibir y Reabasto, no Mi Día", () => {
    const u = { rol: "admin" };
    const temas = temasParaUsuario(u, () => true);
    const ids = temas.map((t) => t.id);
    expect(ids).toContain("recibir");
    expect(ids).toContain("reabasto");
    expect(ids).not.toContain("midia");
    expect(ids).not.toContain("agenda-doctora");
  });

  test("buscador encuentra MMAA y Recibir", () => {
    const temas = TEMAS.filter((t) => t.id === "recibir");
    const r = buscarManual("caducidad 0629", temas, GLOSARIO);
    expect(r.glosario.some((g) => g.id === "mmaa")).toBe(true);
    expect(r.temas.some((t) => t.id === "recibir")).toBe(true);
  });

  test("hayrol respeta exclusividad", () => {
    expect(hayrol(["vendedor"], "admin")).toBe(false);
    expect(hayrol(["admin", "gerente"], "vendedor")).toBe(false);
    expect(hayrol(undefined, "vendedor")).toBe(true);
  });
});
