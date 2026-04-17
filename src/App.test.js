import { render, screen } from "@testing-library/react";
import App from "./App";

test("renders FARMAX loader", () => {
  window.history.pushState({}, "", "/");
  render(<App />);
  const title = screen.getByText(/farmax/i);
  expect(title).toBeInTheDocument();
});

test("admin route renders without blank screen", () => {
  window.history.pushState({}, "", "/admin");
  const { container } = render(<App />);
  expect(container.firstChild).not.toBeNull();
});
