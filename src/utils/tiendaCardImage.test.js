import {
  CATALOGO_PAGE_SIZE,
  PRODUCTOS_CACHE_KEY,
  TIENDA_CARD_THUMB_PX,
  clearStaleProductosCache,
  esUrlImagenCompetencia,
  instalarRespaldoMiniaturas,
  rutaMiniatura,
  tiendaCardImageUrl,
  urlImagenPublicaTienda,
  urlOriginalDeMiniatura,
} from "./tiendaCardImage";

const SUPA = "https://qyabhoftqfmqwpqcsdrb.supabase.co";

describe("urlImagenPublicaTienda / competencia", () => {
  test("bloquea CDN de Del Ahorro (logo rosa A / media)", () => {
    expect(esUrlImagenCompetencia("https://production-media.fahorro.com/media/catalog/product/3/7/3701129802069.jpg")).toBe(true);
    expect(esUrlImagenCompetencia("https://www.fahorro.com/media/catalog/product/x.jpg")).toBe(true);
    expect(urlImagenPublicaTienda("https://www.fahorro.com/media/catalog/product/x.jpg")).toBe("");
    expect(tiendaCardImageUrl("https://production-media.fahorro.com/media/catalog/product/x.jpg")).toBe("");
  });

  test("deja pasar packshots propios y Nadro", () => {
    const propia = "https://www.farmacapital.mx/catalogo-propia/bioderma-atoderm-intensive-baume-200ml-3701129802069.jpg";
    expect(esUrlImagenCompetencia(propia)).toBe(false);
    expect(urlImagenPublicaTienda(propia)).toBe(propia);
    const nadro = "https://nadro.vtexassets.com/arquivos/ids/123/foto.jpg";
    expect(urlImagenPublicaTienda(nadro)).toBe(nadro);
  });
});

describe("tiendaCardImageUrl", () => {
  test("vacío y basura", () => {
    expect(tiendaCardImageUrl("")).toBe("");
    expect(tiendaCardImageUrl(null)).toBe("");
    expect(tiendaCardImageUrl("  ")).toBe("");
    expect(tiendaCardImageUrl("not a url")).toBe("not a url");
  });

  test("no toca hosts ajenos ni data/blob/gif/svg", () => {
    const nadro = "https://nadro.vtexassets.com/arquivos/ids/123/foto.jpg";
    expect(tiendaCardImageUrl(nadro)).toBe(nadro);
    expect(tiendaCardImageUrl("data:image/png;base64,aaa")).toBe("data:image/png;base64,aaa");
    expect(tiendaCardImageUrl("blob:https://www.farmacapital.mx/abc")).toBe("blob:https://www.farmacapital.mx/abc");
    const gif = `${SUPA}/storage/v1/object/public/productos/1/anim.gif`;
    expect(tiendaCardImageUrl(gif)).toBe(gif);
    const svg = `${SUPA}/storage/v1/object/public/productos/1/icon.svg?v=1`;
    expect(tiendaCardImageUrl(svg)).toBe(svg);
  });

  test("object/public → render/image con width", () => {
    const src = `${SUPA}/storage/v1/object/public/productos/99/desktop.jpg`;
    const out = tiendaCardImageUrl(src);
    expect(out).toContain("/storage/v1/render/image/public/productos/99/desktop.jpg");
    expect(out).toContain(`width=${TIENDA_CARD_THUMB_PX}`);
    expect(out).toContain("resize=contain");
    expect(out).not.toContain("/object/public/");
  });

  test("conserva query de cache-bust y no duplica render", () => {
    const src = `${SUPA}/storage/v1/object/public/productos/rappi/7501/1.webp?v=99`;
    const out = new URL(tiendaCardImageUrl(src, 200));
    expect(out.searchParams.get("v")).toBe("99");
    expect(out.searchParams.get("width")).toBe("200");
    const already = `${SUPA}/storage/v1/render/image/public/productos/99/desktop.jpg?width=800`;
    const again = new URL(tiendaCardImageUrl(already));
    expect(again.pathname).toBe("/storage/v1/render/image/public/productos/99/desktop.jpg");
    expect(again.searchParams.get("width")).toBe(String(TIENDA_CARD_THUMB_PX));
  });
});

describe("clearStaleProductosCache", () => {
  test("borra solo la clave vieja del catálogo", () => {
    const store = {
      data: { [PRODUCTOS_CACHE_KEY]: "[{}]", other: "1" },
      getItem(k) { return Object.prototype.hasOwnProperty.call(this.data, k) ? this.data[k] : null; },
      removeItem(k) { delete this.data[k]; },
    };
    expect(CATALOGO_PAGE_SIZE).toBe(36);
    expect(clearStaleProductosCache(store)).toBe(true);
    expect(store.data[PRODUCTOS_CACHE_KEY]).toBeUndefined();
    expect(store.data.other).toBe("1");
    expect(clearStaleProductosCache(store)).toBe(false);
  });
});

describe("miniaturas pregeneradas", () => {
  const ON = { miniaturas: true };

  test("apagado por defecto: misma URL de /render/image que antes", () => {
    const src = `${SUPA}/storage/v1/object/public/productos/99/desktop.jpg`;
    expect(tiendaCardImageUrl(src)).toBe(tiendaCardImageUrl(src, TIENDA_CARD_THUMB_PX, { miniaturas: false }));
    expect(tiendaCardImageUrl(src)).toContain("/render/image/");
  });

  test("encendido: apunta a la miniatura, sin /render/image", () => {
    const src = `${SUPA}/storage/v1/object/public/productos/rappi/7501/1.webp?v=99`;
    const out = new URL(tiendaCardImageUrl(src, 480, ON));
    expect(out.pathname).toBe("/storage/v1/object/public/productos/_miniaturas/480/rappi/7501/1.webp.webp");
    expect(out.searchParams.get("v")).toBe("99");
    expect(out.searchParams.get("width")).toBeNull();
    expect(out.toString()).not.toContain("/render/");
  });

  test("encendido: el ancho pedido no cambia la miniatura (carrito 128)", () => {
    const src = `${SUPA}/storage/v1/object/public/productos/7/desktop.jpg`;
    expect(tiendaCardImageUrl(src, 128, ON)).toBe(tiendaCardImageUrl(src, 480, ON));
  });

  test("encendido: URL ya guardada como /render/image vuelve a objeto", () => {
    const src = `${SUPA}/storage/v1/render/image/public/productos/7/desktop.jpg?width=800&resize=contain&v=3`;
    const out = new URL(tiendaCardImageUrl(src, 480, ON));
    expect(out.pathname).toBe("/storage/v1/object/public/productos/_miniaturas/480/7/desktop.jpg.webp");
    expect([...out.searchParams.keys()]).toEqual(["v"]);
  });

  test("encendido: otros buckets y extensiones raras van a la original, nunca a render", () => {
    const banner = `${SUPA}/storage/v1/object/public/banners/hero.jpg`;
    expect(tiendaCardImageUrl(banner, 480, ON)).toBe(banner);
    const raro = `${SUPA}/storage/v1/object/public/productos/7/foto`;
    expect(tiendaCardImageUrl(raro, 480, ON)).toBe(raro);
    const renderBanner = `${SUPA}/storage/v1/render/image/public/banners/hero.jpg?width=480`;
    expect(tiendaCardImageUrl(renderBanner, 480, ON)).toBe(banner);
  });

  test("encendido: no toca hosts ajenos, gif/svg, ni duplica miniatura", () => {
    const nadro = "https://nadro.vtexassets.com/arquivos/ids/123/foto.jpg";
    expect(tiendaCardImageUrl(nadro, 480, ON)).toBe(nadro);
    const gif = `${SUPA}/storage/v1/object/public/productos/1/anim.gif`;
    expect(tiendaCardImageUrl(gif, 480, ON)).toBe(gif);
    const mini = `${SUPA}/storage/v1/object/public/productos/_miniaturas/480/7/desktop.jpg.webp`;
    expect(tiendaCardImageUrl(mini, 480, ON)).toBe(mini);
    expect(tiendaCardImageUrl("https://production-media.fahorro.com/x.jpg", 480, ON)).toBe("");
  });

  test("nombres con espacios y acentos ida y vuelta", () => {
    const src = `${SUPA}/storage/v1/object/public/productos/fc%20cr%C3%A9ma/1.png?v=5`;
    const mini = tiendaCardImageUrl(src, 480, ON);
    expect(mini).toBe(`${SUPA}/storage/v1/object/public/productos/_miniaturas/480/fc%20cr%C3%A9ma/1.png.webp?v=5`);
    expect(urlOriginalDeMiniatura(mini)).toBe(src);
  });

  test("rutaMiniatura coincide con el job", () => {
    const { rutaMiniatura: rutaJob } = require("../../api/_lib/miniaturasJob");
    ["rappi/7501/1.webp", "7/desktop.jpg", "fc-1-1200x1200-1.webp", "a b/c.png"].forEach((n) => {
      expect(rutaMiniatura(n)).toBe(rutaJob(n));
    });
    expect(rutaMiniatura("_miniaturas/480/x.jpg.webp")).toBe("");
    expect(rutaMiniatura("_auditoria/rev.json")).toBe("");
  });

  test("urlOriginalDeMiniatura ignora lo que no es miniatura", () => {
    expect(urlOriginalDeMiniatura(`${SUPA}/storage/v1/object/public/productos/7/desktop.jpg`)).toBe("");
    expect(urlOriginalDeMiniatura("")).toBe("");
    expect(urlOriginalDeMiniatura("basura")).toBe("");
  });
});

describe("instalarRespaldoMiniaturas", () => {
  const React = require("react");
  const { render, fireEvent } = require("@testing-library/react");

  test("si la miniatura falla, la <img> carga la original y el onError del componente no corre", () => {
    const win = window;
    delete win.__fcRespaldoMiniaturas;
    expect(instalarRespaldoMiniaturas(win)).toBe(true);
    expect(instalarRespaldoMiniaturas(win)).toBe(false);

    const original = `${SUPA}/storage/v1/object/public/productos/7/desktop.jpg?v=1`;
    const mini = tiendaCardImageUrl(original, 480, { miniaturas: true });
    const onError = jest.fn();
    const { container } = render(React.createElement("img", { src: mini, alt: "", onError }));
    const img = container.querySelector("img");

    fireEvent.error(img);
    expect(img.getAttribute("src")).toBe(original);
    expect(onError).not.toHaveBeenCalled();

    // Si también falla la original, el componente decide (foto siguiente / rota).
    fireEvent.error(img);
    expect(onError).toHaveBeenCalledTimes(1);
  });

  test("errores de imágenes normales llegan intactos al componente", () => {
    const onError = jest.fn();
    const { container } = render(
      React.createElement("img", { src: `${SUPA}/storage/v1/object/public/productos/9/x.jpg`, alt: "", onError })
    );
    fireEvent.error(container.querySelector("img"));
    expect(onError).toHaveBeenCalledTimes(1);
  });
});
