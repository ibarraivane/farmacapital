import React from "react";
import { C_LIGHT } from "./constants";

export const ThemeContext = React.createContext(C_LIGHT);
export const useTheme = () => React.useContext(ThemeContext);
