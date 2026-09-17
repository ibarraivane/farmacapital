import { FARMA_INTEGRAL_SHOP, urlFotoFarmaIntegral } from "./farmaIntegral";

test("la ficha pública del shop arma la URL de packshot", () => {
  expect(FARMA_INTEGRAL_SHOP).toBe("https://farmacia-integral.odoo.com/shop");
  expect(urlFotoFarmaIntegral(21882)).toBe(
    "https://farmacia-integral.odoo.com/web/image/product.template/21882/image_512",
  );
  expect(urlFotoFarmaIntegral("x")).toBeNull();
});
