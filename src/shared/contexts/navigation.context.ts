import { createContext } from "@lit/context";
import type { NavItem } from "../interfaces/navigation.interface";

export const NavigationContext = createContext<NavItem[]>("navContext");
