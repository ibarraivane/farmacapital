import { render } from "@testing-library/react";
import { FlyerCard, FlyerCruz } from "./FlyerFarmaCapital";

test("la cruz del flyer es el isotipo oficial en claro", () => {
  const { container } = render(<FlyerCruz size={88} />);
  const img = container.querySelector("img");
  expect(img).toBeTruthy();
  expect(img.getAttribute("src")).toMatch(/farmacapital-icon-light\.png/);
  expect(container.querySelector("svg")).toBeNull();
});

test("la tarjeta usa esa misma cruz oficial", () => {
  const { container } = render(<FlyerCard qrUrl="https://www.farmacapital.mx/" />);
  const imgs = [...container.querySelectorAll("img")];
  expect(imgs.some((img) => /farmacapital-icon-light\.png/.test(img.getAttribute("src") || ""))).toBe(true);
});
