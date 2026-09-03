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

  test("Reabasto explica surtido por principio activo", () => {
    const t = TEMAS.find((x) => x.id === "reabasto");
    const blob = [t.resumen, ...(t.pasos || []), ...(t.dudas || []).flatMap((d) => [d.q, d.a])].join(" ");
    expect(blob).toMatch(/principio activo/i);
    expect(blob).toMatch(/Pasmodil/);
    expect(blob).toMatch(/Busconet/);
    expect(blob).toMatch(/Por marca/);
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

  test("vendedor ve Recibir aunque el permiso venga de Inventario", () => {
    const u = { rol: "vendedor" };
    const temas = temasParaUsuario(u, (_user, id) => ["midia", "pos", "inv", "caja", "ayuda"].includes(id));
    expect(temas.some((t) => t.id === "recibir")).toBe(true);
    expect(temas.find((t) => t.id === "recibir")?.moduloId).toBe("recibir");
  });

  test("Recibir explica PDF, lista, cierre y dos pantallas", () => {
    const t = TEMAS.find((x) => x.id === "recibir");
    const blob = [t.resumen, ...(t.pasos || []), ...(t.dudas || []).flatMap((d) => [d.q, d.a])].join(" ");
    expect(blob).toMatch(/PDF/i);
    expect(blob).toMatch(/lista|tarjeta/i);
    expect(blob).toMatch(/Nuevo ticket/);
    expect(blob).toMatch(/Farmalive/);
    expect(blob).toMatch(/Cityfarma/);
    expect(blob).toMatch(/Levic/);
    expect(blob).toMatch(/apaga/);
    expect(blob).toMatch(/← Tickets/);
    expect(blob).toMatch(/Inventario/);
    expect(blob).toMatch(/Pistola aquí/);
  });

  test("Mi Día y Catálogo cubren tickets y Activos", () => {
    const midia = TEMAS.find((x) => x.id === "midia");
    const cat = TEMAS.find((x) => x.id === "catalogo");
    expect(midia.pasos.join(" ")).toMatch(/Tickets/);
    expect(cat.pasos.join(" ")).toMatch(/Activos/);
    expect(cat.pasos.join(" ")).toMatch(/Recibir cajas/);
    expect(cat.pasos.join(" ")).toMatch(/pvp|POS|pos/i);
    expect(cat.dudas.some((d) => /precios/i.test(d.q))).toBe(true);
  });

  test("hayrol respeta exclusividad", () => {
    expect(hayrol(["vendedor"], "admin")).toBe(false);
    expect(hayrol(["admin", "gerente"], "vendedor")).toBe(false);
    expect(hayrol(undefined, "vendedor")).toBe(true);
  });

  test("vendedor ve recargas; doctora no", () => {
    const vend = temasParaUsuario({ rol: "vendedor" }, (_u, id) => ["pos", "caja", "ayuda"].includes(id));
    const doc = temasParaUsuario({ rol: "doctora" }, (_u, id) => ["cons_dr", "exp_dr", "ayuda"].includes(id));
    expect(vend.some((t) => t.id === "recargas")).toBe(true);
    expect(doc.some((t) => t.id === "recargas")).toBe(false);
  });

  test("Recargas explica Point, 1% y que no va al cajón", () => {
    const t = TEMAS.find((x) => x.id === "recargas");
    const blob = [t.resumen, ...(t.pasos || []), ...(t.dudas || []).flatMap((d) => [d.q, d.a])].join(" ");
    expect(blob).toMatch(/Point/i);
    expect(blob).toMatch(/1%/);
    expect(blob).toMatch(/saldo/i);
    expect(blob).toMatch(/efectivo/i);
    expect(blob).toMatch(/Telcel/i);
    expect(blob).toMatch(/cajón|cajon/i);
    expect(blob).toMatch(/recargo en 0/);
    const r = buscarManual("telcel compensacion", [t], GLOSARIO);
    expect(r.temas.some((x) => x.id === "recargas")).toBe(true);
    expect(r.glosario.some((g) => g.id === "compensacion-mp" || g.id === "recarga")).toBe(true);
  });
});
