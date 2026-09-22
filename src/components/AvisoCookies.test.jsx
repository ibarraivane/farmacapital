import { fireEvent, render, screen } from "@testing-library/react";
import AvisoCookies from "./AvisoCookies";
import { COOKIE_CONSENT_KEY } from "../lib/cookieConsent";

beforeEach(() => {
  localStorage.removeItem(COOKIE_CONSENT_KEY);
});

test("al entrar sin decisión muestra el aviso y el enlace al aviso de privacidad", () => {
  render(<AvisoCookies />);
  expect(screen.getByRole("dialog", { name: "Aviso de cookies" })).toBeInTheDocument();
  expect(screen.getByRole("link", { name: "Aviso de privacidad" })).toHaveAttribute("href", "/privacidad");
});

test("aceptar lo guarda y ya no lo muestra", () => {
  render(<AvisoCookies />);
  fireEvent.click(screen.getByRole("button", { name: "Aceptar" }));
  expect(localStorage.getItem(COOKIE_CONSENT_KEY)).toBe("aceptadas");
  expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
});

test("solo necesarias también cierra el aviso", () => {
  render(<AvisoCookies />);
  fireEvent.click(screen.getByRole("button", { name: "Solo necesarias" }));
  expect(localStorage.getItem(COOKIE_CONSENT_KEY)).toBe("rechazadas");
  expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
});

test("si ya aceptó, no aparece al volver", () => {
  localStorage.setItem(COOKIE_CONSENT_KEY, "aceptadas");
  render(<AvisoCookies />);
  expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
});
