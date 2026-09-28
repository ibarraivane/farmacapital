import { esRpcStaffAusente, filasProductosStaff } from "./productosStaff";

describe("productosStaff", () => {
  it("reconoce que el RPC todavía no está en la base", () => {
    expect(esRpcStaffAusente({ code: "PGRST202", message: "Could not find the function public.empleado_listar_productos_staff" })).toBe(true);
    expect(esRpcStaffAusente({ code: "42883", message: "function public.empleado_listar_productos_staff(uuid) does not exist" })).toBe(true);
    expect(esRpcStaffAusente({ message: "Sesión inválida" })).toBe(false);
    expect(esRpcStaffAusente(null)).toBe(false);
  });

  it("normaliza el jsonb del RPC", () => {
    expect(filasProductosStaff([{ id: 1 }])).toEqual([{ id: 1 }]);
    expect(filasProductosStaff('[{"id":2}]')).toEqual([{ id: 2 }]);
    expect(filasProductosStaff({ productos: [{ id: 3 }] })).toEqual([{ id: 3 }]);
    expect(filasProductosStaff(null)).toEqual([]);
  });
});
