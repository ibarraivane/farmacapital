import React from "react";
import { C_LIGHT, C_DARK } from "./constants";

export const ThemeContext = React.createContext({
  C: C_LIGHT,
  darkMode: false,
  setDarkMode: () => {},
});

export function ThemeProvider({ children }) {
  const [darkMode, setDarkMode] = React.useState(() => {
    if (typeof window === "undefined") return false;
    return localStorage.getItem("farmax_dark") === "1";
  });

  React.useEffect(() => {
    if (typeof window === "undefined") return;
    localStorage.setItem("farmax_dark", darkMode ? "1" : "0");
  }, [darkMode]);

  const C = darkMode ? C_DARK : C_LIGHT;
  const value = React.useMemo(() => ({ C, darkMode, setDarkMode }), [C, darkMode]);

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

export const useTheme = () => {
  const ctx = React.useContext(ThemeContext);
  return ctx?.C || C_LIGHT;
};

export const useThemeMode = () => {
  const ctx = React.useContext(ThemeContext);
  return {
    darkMode: ctx?.darkMode ?? false,
    setDarkMode: ctx?.setDarkMode ?? (() => {}),
  };
};
