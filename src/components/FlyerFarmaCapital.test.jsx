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

test("la tarjeta lleva el logo oficial, no un FarmaCapital tipográfico", () => {
  const { container } = render(<FlyerCard qrUrl="https://www.farmacapital.mx/" />);
  const imgs = [...container.querySelectorAll("img")];
  expect(imgs.some((img) => /farmacapital-logo-full-light\.png/.test(img.getAttribute("src") || ""))).toBe(true);
  expect(container.querySelector("h1")).toBeNull();
});
