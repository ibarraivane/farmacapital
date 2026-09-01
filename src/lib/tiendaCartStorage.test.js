import {
  cartStorageKey,
  mergeCartLines,
  loadStoredCart,
  saveStoredCart,
} from "./tiendaCartStorage";

describe("tiendaCartStorage", () => {
  beforeEach(() => {
    localStorage.clear();
  });

  test("clave distinta para cuenta e invitado", () => {
    expect(cartStorageKey(null)).toBe("farmacapital_cart_guest");
    expect(cartStorageKey({ id: 42 })).toBe("farmacapital_cart_42");
  });

  test("guarda y recupera el carrito de la cuenta", () => {
    saveStoredCart({ id: 7 }, [{ id: 11, qty: 2, nombre: "Paracetamol 500", precio: 20 }]);
    const loaded = loadStoredCart({ id: 7 });
    expect(loaded).toHaveLength(1);
    expect(loaded[0].id).toBe(11);
    expect(loaded[0].qty).toBe(2);
    expect(loadStoredCart(null)).toEqual([]);
  });

  test("al entrar a la cuenta junta el carrito de invitado", () => {
    const guest = [{ id: 1, qty: 1, nombre: "A", precio: 10, stock: 8 }];
    const mine = [{ id: 1, qty: 2, nombre: "A", precio: 10, stock: 8 }, { id: 2, qty: 1, nombre: "B", precio: 5, stock: 3 }];
    const merged = mergeCartLines(mine, guest);
    expect(merged.find((x) => x.id === 1).qty).toBe(3);
    expect(merged.find((x) => x.id === 2).qty).toBe(1);
  });
});
