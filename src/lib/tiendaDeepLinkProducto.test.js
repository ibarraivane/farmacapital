import { resolverFichaDeepLink } from "./tiendaDeepLinkProducto";

const omeprazol = { id: 2, nombre: "Omeprazol 20 mg" };

test("usa el producto de la lista si el id coincide", () => {
  expect(resolverFichaDeepLink({
    productId: "2",
    productos: [omeprazol],
  })).toEqual({ status: "ready", prod: omeprazol });
});

test("mientras carga no manda al catálogo", () => {
  expect(resolverFichaDeepLink({
    productId: "2",
    productos: [],
    loading: true,
  })).toEqual({ status: "loading", prod: null });
});

test("id inexistente tras cargar es aviso, no catálogo", () => {
  expect(resolverFichaDeepLink({
    productId: "999999999",
    productos: [omeprazol],
    loading: false,
  })).toEqual({ status: "missing", prod: null });
});

test("sin id y sin sesión guardada es aviso", () => {
  expect(resolverFichaDeepLink({
    productId: "",
    productos: [omeprazol],
  })).toEqual({ status: "missing", prod: null });
});

test("sesión guardada del mismo id gana mientras llega el catálogo", () => {
  expect(resolverFichaDeepLink({
    productId: "2",
    productos: [],
    loading: true,
    saved: omeprazol,
  })).toEqual({ status: "ready", prod: omeprazol });
});
