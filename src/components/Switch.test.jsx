import { fireEvent, render, screen } from "@testing-library/react";
import { Switch } from "./Switch";

test("Switch: click llama onChange(!checked) y no muta su propio estado", () => {
  const onChange = jest.fn();
  render(<Switch checked={false} onChange={onChange} label="Incluir canceladas" />);
  fireEvent.click(screen.getByText("Incluir canceladas"));
  expect(onChange).toHaveBeenCalledWith(true);
  expect(onChange).toHaveBeenCalledTimes(1);
  expect(screen.getByRole("switch")).not.toBeChecked();
});

test("Switch: el input es focusable y responde a Space", () => {
  const onChange = jest.fn();
  render(<Switch checked={false} onChange={onChange} label="Solo con excepción" id="sw-space" />);
  const input = screen.getByRole("switch");
  input.focus();
  expect(input).toHaveFocus();
  fireEvent.keyDown(input, { key: " " });
  expect(onChange).toHaveBeenCalledWith(true);
});
