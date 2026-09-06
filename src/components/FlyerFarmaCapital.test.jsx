import { render, screen } from "@testing-library/react";
import { FlyerCard, FlyerCruz, FlyerLogo } from "./FlyerFarmaCapital";

test("el isotipo oficial es el PNG de marca, no un SVG inventado", () => {
  const { container } = render(<FlyerCruz size={88} />);
  const img = container.querySelector("img");
  expect(img).toBeTruthy();
  expect(img.getAttribute("src")).toMatch(/farmacapital-icon-light\.png/);
  expect(container.querySelector("svg")).toBeNull();
});

test("el flyer usa el lockup oficial en claro", () => {
  const { container } = render(<FlyerLogo />);
  const img = container.querySelector("img");
  expect(img.getAttribute("src")).toMatch(/farmacapital-logo-full-light\.png/);
  expect(Number(img.getAttribute("width"))).toBeGreaterThan(200);
  expect(Number(img.getAttribute("height"))).toBeGreaterThan(50);
  expect(screen.getByAltText("FarmaCapital")).toBeTruthy();
});

test("la tarjeta dice FarmaCapital y usa el isotipo oficial", () => {
  const { container } = render(<FlyerCard qrUrl="https://www.farmacapital.mx/" />);
  const card = container.querySelector("[data-flyer-card]");
  const title = container.querySelector("h1");
  expect(title?.textContent).toBe("FarmaCapital");
  expect(card.style.overflow).toBe("visible");
  expect(Number.parseFloat(title.style.lineHeight)).toBeGreaterThanOrEqual(1.2);
  const imgs = [...container.querySelectorAll("img")];
  expect(imgs.some((img) => /farmacapital-icon-light\.png/.test(img.getAttribute("src") || ""))).toBe(true);
});
