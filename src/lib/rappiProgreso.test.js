import { parseProgresoBackfill } from "./rappiPrecios";

test("el porcentaje es done/total con un decimal", () => {
  expect(parseProgresoBackfill({ running: true, done: 0, total: 674 }).pct).toBe(0);
  expect(parseProgresoBackfill({ running: true, done: 337, total: 674 }).pct).toBe(50);
  expect(parseProgresoBackfill({ running: false, done: 674, total: 674 }).pct).toBe(100);
  expect(parseProgresoBackfill('{"running":true,"done":1,"total":674}').pct).toBe(0.1);
  expect(parseProgresoBackfill(null)).toBeNull();
});
