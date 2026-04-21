import { useEffect, useState } from "react";
import { buildSalesProjection } from "../../../core/projections/buildProjections";

export function useSalesReport() {
  const [data, setData] = useState(null);

  useEffect(() => {
    buildSalesProjection().then(setData);
  }, []);

  return data;
}
