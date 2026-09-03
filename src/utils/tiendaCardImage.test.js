import {
  CATALOGO_PAGE_SIZE,
  PRODUCTOS_CACHE_KEY,
  TIENDA_CARD_THUMB_PX,
  clearStaleProductosCache,
  tiendaCardImageUrl,
} from "./tiendaCardImage";

const SUPA = "https://qyabhoftqfmqwpqcsdrb.supabase.co";

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
