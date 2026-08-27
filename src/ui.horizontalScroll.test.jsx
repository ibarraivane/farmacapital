import { render } from "@testing-library/react";
import { HorizontalScrollSync } from "./ui";

describe("HorizontalScrollSync", () => {
  test("sin bodyMaxHeight solo se desliza de lado", () => {
    const { container } = render(
      <HorizontalScrollSync>
        <table><tbody><tr><td>x</td></tr></tbody></table>
      </HorizontalScrollSync>,
    );
    const scroller = container.querySelector("[data-fc-table-scroll='x']");
    expect(scroller).toBeTruthy();
    expect(scroller.style.overflowY).toBe("hidden");
  });

  test("con bodyMaxHeight el encabezado puede quedarse fijo al bajar", () => {
    const { container } = render(
      <HorizontalScrollSync bodyMaxHeight="400px">
        <table><tbody><tr><td>x</td></tr></tbody></table>
      </HorizontalScrollSync>,
    );
    const scroller = container.querySelector("[data-fc-table-scroll='xy']");
    expect(scroller).toBeTruthy();
    expect(scroller.style.maxHeight).toBe("400px");
    expect(scroller.style.overflowY).toBe("auto");
  });
});
