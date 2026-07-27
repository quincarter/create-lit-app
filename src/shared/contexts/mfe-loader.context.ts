import { createContext } from "@lit/context";
import type { MfeLoader } from "../utilities/mfe-loader.utility";

export const MfeLoaderContext = createContext<MfeLoader>("mfeLoaderContext");
