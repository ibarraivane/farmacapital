import { useEffect, useState } from "react";
import { getMenuByRole } from "../../../core/navigation/getMenuByRole";

export default function Sidebar({ user }) {
  const [menu, setMenu] = useState([]);

  useEffect(() => {
    const role = user?.rol || user?.role;
    setMenu(getMenuByRole(role));
  }, [user]);

  return (
    <div>
      {menu.map((item) => (
        <a key={item.path} href={item.path}>
          {item.label}
        </a>
      ))}
    </div>
  );
}
