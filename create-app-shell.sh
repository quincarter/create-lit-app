#!/usr/bin/env bash

# ==============================================================================
# Lit Element App Shell Architecture Generator
# Scaffolds modular Lit Element applications with optional Routing, Signals,
# Contexts, MFE Loader, Theme Switcher, and Component Showcase Suites.
# ==============================================================================

set -e

# ANSI Color Tokens
BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
CYAN="\033[36m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

log_title() {
  echo -e "\n${BOLD}${CYAN}====================================================${RESET}"
  echo -e "${BOLD}${CYAN}  $1${RESET}"
  echo -e "${BOLD}${CYAN}====================================================${RESET}\n"
}

log_info() {
  echo -e "${BLUE}ℹ${RESET} $1"
}

log_success() {
  echo -e "${GREEN}✔${RESET} $1"
}

log_warn() {
  echo -e "${YELLOW}⚠${RESET} $1"
}

log_error() {
  echo -e "${RED}✖${RESET} $1"
}

# Default Configuration Variables
APP_NAME=""
TEMPLATE="full" # full | blank | custom
ENABLE_ROUTER=true
ENABLE_CONTEXT=true
ENABLE_SIGNALS=true
ENABLE_HEADER=true
ENABLE_THEME_SWITCHER=true
ENABLE_MFE_LOADER=true
ENABLE_TODOS=true
ENABLE_CARDS=true
ENABLE_CHARTS=true
PACKAGE_MANAGER="yarn"
INIT_GIT=true
RUN_INSTALL=false
NON_INTERACTIVE=false

# Helper for CLI Flag Parsing
parse_args() {
  for arg in "$@"; do
    case $arg in
      --name=*)
        APP_NAME="${arg#*=}"
        ;;
      --template=*)
        TEMPLATE="${arg#*=}"
        ;;
      --router) ENABLE_ROUTER=true ;;
      --no-router) ENABLE_ROUTER=false ;;
      --context) ENABLE_CONTEXT=true ;;
      --no-context) ENABLE_CONTEXT=false ;;
      --signals) ENABLE_SIGNALS=true ;;
      --no-signals) ENABLE_SIGNALS=false ;;
      --header) ENABLE_HEADER=true ;;
      --no-header) ENABLE_HEADER=false ;;
      --theme-switcher) ENABLE_THEME_SWITCHER=true ;;
      --no-theme-switcher) ENABLE_THEME_SWITCHER=false ;;
      --mfe-loader) ENABLE_MFE_LOADER=true ;;
      --no-mfe-loader) ENABLE_MFE_LOADER=false ;;
      --todos) ENABLE_TODOS=true; ENABLE_SIGNALS=true ;;
      --no-todos) ENABLE_TODOS=false ;;
      --cards) ENABLE_CARDS=true ;;
      --no-cards) ENABLE_CARDS=false ;;
      --charts) ENABLE_CHARTS=true ;;
      --no-charts) ENABLE_CHARTS=false ;;
      --pm=*) PACKAGE_MANAGER="${arg#*=}" ;;
      --git) INIT_GIT=true ;;
      --no-git) INIT_GIT=false ;;
      --install) RUN_INSTALL=true ;;
      --no-install) RUN_INSTALL=false ;;
      -v|--version)
        echo "@quincarter/create-lit-app v1.0.0"
        exit 0
        ;;
      --help|-h)
        echo -e "\n${BOLD}${CYAN}⚡ Lit Element App Shell Architecture Generator ⚡${RESET}"
        echo -e "${BLUE}Scaffold modular Lit Element applications with signals, context, routing, and UI suites.${RESET}\n"

        echo -e "${BOLD}${YELLOW}USAGE:${RESET}"
        echo -e "  ${GREEN}npx @quincarter/create-lit-app${RESET} [options]\n"

        echo -e "${BOLD}${YELLOW}PROJECT CONFIGURATION:${RESET}"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--name=<name>" "Project directory / package name"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--template=<type>" "Starter template: full | blank | custom (default: full)"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--pm=<yarn|npm>" "Package manager to use (default: yarn)"
        echo ""

        echo -e "${BOLD}${YELLOW}CORE ARCHITECTURE & STATE:${RESET}"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--router | --no-router" "Enable/disable @lit-labs/router (auto-enables @lit/context)"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--context | --no-context" "Enable/disable @lit/context dependency injection"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--signals | --no-signals" "Enable/disable Preact Signals & IndexedDB store"
        echo ""

        echo -e "${BOLD}${YELLOW}UI COMPONENTS & SHOWCASES:${RESET}"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--header | --no-header" "Enable/disable AppShellHeader component"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--theme-switcher | --no-theme-switcher" "Enable/disable Theme Switcher component"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--todos | --no-todos" "Enable/disable Signals Todo List component & view"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--cards | --no-cards" "Enable/disable Generic Card component & view"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--charts | --no-charts" "Enable/disable Chart.js wrapper & view"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--mfe-loader | --no-mfe-loader" "Enable/disable Micro-Frontend (MFE) loader utility"
        echo ""

        echo -e "${BOLD}${YELLOW}WORKFLOW & SETUP:${RESET}"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--git | --no-git" "Initialize Git repository (default: true)"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--install | --no-install" "Run dependency installation step (default: false)"
        printf "  ${CYAN}%-32s${RESET} %s\n" "-y, --yes" "Run non-interactively with current flags"
        printf "  ${CYAN}%-32s${RESET} %s\n" "-v, --version" "Display version number"
        printf "  ${CYAN}%-32s${RESET} %s\n" "-h, --help" "Display this help menu"
        echo ""
        exit 0
        ;;
    esac
  done
}

prompt_user() {
  log_title "Lit Element App Shell Generator"

  if [ -z "$APP_NAME" ]; then
    read -rp "Enter app name (default: my-app-shell): " input_name
    APP_NAME=${input_name:-my-app-shell}
  fi

  echo -e "\nChoose starter template preset:"
  echo "  1) Full App Shell (Header, Navigation, Router, Contexts, Signals, Todos Showcase, Cards, Charts, MFEs)"
  echo "  2) Blank App Shell (Minimal Lit App Host)"
  echo "  3) Custom Selection (Select specific features interactively)"
  read -rp "Selection [1-3] (default: 1): " template_choice

  case $template_choice in
    2)
      TEMPLATE="blank"
      ENABLE_ROUTER=false
      ENABLE_CONTEXT=false
      ENABLE_SIGNALS=false
      ENABLE_HEADER=false
      ENABLE_THEME_SWITCHER=false
      ENABLE_MFE_LOADER=false
      ENABLE_TODOS=false
      ENABLE_CARDS=false
      ENABLE_CHARTS=false
      ;;
    3)
      TEMPLATE="custom"
      read -rp "Enable Routing (@lit-labs/router)? [Y/n]: " ans
      if [[ "$ans" =~ ^[Nn] ]]; then
        ENABLE_ROUTER=false
      else
        ENABLE_ROUTER=true
        ENABLE_CONTEXT=true
        log_info "Lit Context (@lit/context) automatically enabled for Routing."
      fi

      if [ "$ENABLE_ROUTER" = false ]; then
        read -rp "Enable Lit Context (@lit/context)? [Y/n]: " ans
        [[ "$ans" =~ ^[Nn] ]] && ENABLE_CONTEXT=false || ENABLE_CONTEXT=true
      fi

      read -rp "Enable Preact Signals & IndexedDB Stores (@lit-labs/preact-signals)? [Y/n]: " ans
      [[ "$ans" =~ ^[Nn] ]] && ENABLE_SIGNALS=false || ENABLE_SIGNALS=true

      read -rp "Include Signals Showcase (Todo List Component & Store)? [Y/n]: " ans
      if [[ "$ans" =~ ^[Nn] ]]; then
        ENABLE_TODOS=false
      else
        ENABLE_TODOS=true
        ENABLE_SIGNALS=true
      fi

      read -rp "Include Generic Card Component & Examples Page? [Y/n]: " ans
      [[ "$ans" =~ ^[Nn] ]] && ENABLE_CARDS=false || ENABLE_CARDS=true

      read -rp "Include Chart.js Wrapper Component & Examples Page? [Y/n]: " ans
      [[ "$ans" =~ ^[Nn] ]] && ENABLE_CHARTS=false || ENABLE_CHARTS=true

      read -rp "Enable App Shell Header component? [Y/n]: " ans
      [[ "$ans" =~ ^[Nn] ]] && ENABLE_HEADER=false || ENABLE_HEADER=true

      read -rp "Enable Theme Switcher component? [Y/n]: " ans
      [[ "$ans" =~ ^[Nn] ]] && ENABLE_THEME_SWITCHER=false || ENABLE_THEME_SWITCHER=true

      read -rp "Enable Micro-Frontend (MFE) Loader utility? [Y/n]: " ans
      [[ "$ans" =~ ^[Nn] ]] && ENABLE_MFE_LOADER=false || ENABLE_MFE_LOADER=true
      ;;
    *)
      TEMPLATE="full"
      ENABLE_ROUTER=true
      ENABLE_CONTEXT=true
      ENABLE_SIGNALS=true
      ENABLE_HEADER=true
      ENABLE_THEME_SWITCHER=true
      ENABLE_MFE_LOADER=true
      ENABLE_TODOS=true
      ENABLE_CARDS=true
      ENABLE_CHARTS=true
      ;;
  esac

  read -rp "Choose package manager [yarn/npm] (default: yarn): " pm_choice
  PACKAGE_MANAGER=${pm_choice:-yarn}

  read -rp "Initialize Git repository? [Y/n]: " git_ans
  [[ "$git_ans" =~ ^[Nn] ]] && INIT_GIT=false || INIT_GIT=true

  read -rp "Run dependency installation now? [y/N]: " install_ans
  [[ "$install_ans" =~ ^[Yy] ]] && RUN_INSTALL=true || RUN_INSTALL=false
}

parse_args "$@"

if [ "$NON_INTERACTIVE" = false ] && [ -t 0 ]; then
  prompt_user
else
  if [ -z "$APP_NAME" ]; then
    APP_NAME="my-app-shell"
  fi
  if [ "$TEMPLATE" = "blank" ]; then
    ENABLE_ROUTER=false
    ENABLE_CONTEXT=false
    ENABLE_SIGNALS=false
    ENABLE_HEADER=false
    ENABLE_THEME_SWITCHER=false
    ENABLE_MFE_LOADER=false
    ENABLE_TODOS=false
    ENABLE_CARDS=false
    ENABLE_CHARTS=false
  fi
fi

# Mandatory Dependency Rules
if [ "$ENABLE_ROUTER" = true ]; then
  ENABLE_CONTEXT=true
fi
if [ "$ENABLE_TODOS" = true ]; then
  ENABLE_SIGNALS=true
fi

TARGET_DIR="$(pwd)/$APP_NAME"

if [ -d "$TARGET_DIR" ]; then
  log_error "Target directory '$APP_NAME' already exists."
  exit 1
fi

log_info "Creating project directory: $TARGET_DIR"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# ------------------------------------------------------------------------------
# Generate package.json
# ------------------------------------------------------------------------------
log_info "Generating package.json..."

DEPS='"lit": "^3.3.3"'
if [ "$ENABLE_ROUTER" = true ]; then
  DEPS="$DEPS,
    \"@lit-labs/router\": \"^0.1.4\",
    \"urlpattern-polyfill\": \"^10.1.0\""
fi
if [ "$ENABLE_CONTEXT" = true ]; then
  DEPS="$DEPS,
    \"@lit/context\": \"^1.1.6\""
fi
if [ "$ENABLE_SIGNALS" = true ]; then
  DEPS="$DEPS,
    \"@lit-labs/preact-signals\": \"^1.0.3\",
    \"idb\": \"^8.0.3\""
fi
if [ "$ENABLE_CHARTS" = true ]; then
  DEPS="$DEPS,
    \"chart.js\": \"^4.5.1\",
    \"chartjs-adapter-luxon\": \"^1.3.1\",
    \"luxon\": \"^3.7.2\",
    \"@kurkle/color\": \"^0.4.0\""
fi

cat <<EOF > package.json
{
  "name": "@quincarter/$APP_NAME",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "start": "vite",
    "build": "tsc && vite build",
    "preview": "yarn build && vite preview",
    "test": "vitest run"
  },
  "dependencies": {
    $DEPS
  },
  "devDependencies": {
    "@biomejs/biome": "2.5.5",
    "@types/luxon": "^3.7.2",
    "@types/mocha": "^10.0.10",
    "typescript": "^5.4.5",
    "vite": "^5.2.11",
    "vite-plugin-pwa": "^0.20.0",
    "vitest": "^1.6.0"
  }
}
EOF

# ------------------------------------------------------------------------------
# Generate Configuration Files
# ------------------------------------------------------------------------------
log_info "Generating configuration files (tsconfig.json, vite.config.ts, biome.json)..."

cat <<'EOF' > tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "declaration": true,
    "emitDeclarationOnly": false,
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true,
    "experimentalDecorators": true,
    "useDefineForClassFields": false,
    "skipLibCheck": true
  },
  "include": ["src/**/*.ts"]
}
EOF

cat <<'EOF' > vite.config.ts
import { defineConfig } from 'vite';

export default defineConfig({
  build: {
    target: 'esnext',
  },
});
EOF

cat <<'EOF' > biome.json
{
  "$schema": "https://biomejs.dev/schemas/1.8.3/schema.json",
  "organizeImports": {
    "enabled": true
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true
    }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "tab"
  }
}
EOF

cat <<'EOF' > .gitignore
node_modules
dist
.DS_Store
*.log
EOF

cat <<EOF > index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>$APP_NAME</title>
    <script src="/detect-color-scheme.js"></script>
    <link rel="stylesheet" href="/src/index.css" />
  </head>
  <body>
    <app-shell></app-shell>
    <script type="module" src="/src/app-shell.ts"></script>
  </body>
</html>
EOF

mkdir -p public
cat <<'EOF' > public/detect-color-scheme.js
(function () {
  const storedTheme = localStorage.getItem("theme");
  if (storedTheme) {
    document.documentElement.setAttribute("data-theme", storedTheme);
  } else if (window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches) {
    document.documentElement.setAttribute("data-theme", "dark");
  } else {
    document.documentElement.setAttribute("data-theme", "light");
  }
})();
EOF

mkdir -p src/assets

cat <<'EOF' > src/index.css
:root {
  --primary-text-color: #212529;
  --bg-color: #ffffff;
  --nav-background-color: #f8f9fa;
  --primary-box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  font-family: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif;
  line-height: 1.5;
  font-weight: 400;
}

[data-theme="dark"] {
  --primary-text-color: #f8f9fa;
  --bg-color: #121212;
  --nav-background-color: #1e1e1e;
  --primary-box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.5);
}

body {
  margin: 0;
  padding: 0;
  background-color: var(--bg-color);
  color: var(--primary-text-color);
}
EOF

cat <<'EOF' > src/vite-env.d.ts
/// <reference types="vite/client" />
EOF

# ------------------------------------------------------------------------------
# Create Shared Directories & Modules
# ------------------------------------------------------------------------------
log_info "Scaffolding shared modules..."
mkdir -p src/shared/configuration
mkdir -p src/shared/contexts
mkdir -p src/shared/interfaces
mkdir -p src/shared/internal-views
mkdir -p src/shared/stores
mkdir -p src/shared/utilities

cat <<'EOF' > src/shared/configuration/base-path.ts
const raw = import.meta.env.BASE_URL ?? "/";
export const BASE_PATH = raw.endsWith("/") ? raw.slice(0, -1) : raw;

export const withBase = (path: string): string => {
	const normalized = path.startsWith("/") ? path : `/${path}`;
	return `${BASE_PATH}${normalized}`;
};
EOF

cat <<'EOF' > src/shared/interfaces/navigation.interface.ts
import type { MfeItem } from "../utilities/mfe-loader.utility";

export interface NavItem {
	name: string;
	path: string;
	directory: string;
	filePath: string;
	levelOfAccess: string[];
	action?: () => void;
	children?: NavItem[];
	component: string;
	tagName: string;
	icon?: IconType;
	userHasPermission?: boolean;
	mfeComponent?: MfeItem;
	isMfe: boolean;
}

export declare type IconType = "test";
EOF

cat <<'EOF' > src/shared/interfaces/todos.interface.ts
export interface ITodoItem {
	id: string;
	title: string;
	description?: string;
	checked: boolean;
}
EOF

cat <<'EOF' > src/shared/utilities/mfe-loader.utility.ts
export type CrossoriginType = "anonymous" | "use-credentials" | "";

export interface MfeItem {
	mfeBundleUrl: string;
	scriptType: string;
	isAsync: boolean;
	defer: boolean;
	crossOrigin: CrossoriginType;
	tagName: string;
	associatedInternalTag?: string;
}

export class MfeLoader {
	public config: MfeItem[];

	constructor(mfeConfig: MfeItem[]) {
		this.config = mfeConfig;
	}

	init(): void {
		this.config.forEach(async (configItem) => {
			await this.createLink(configItem);
			await this.createScript(configItem);
		});
	}

	private async createScript(configItem: MfeItem): Promise<void> {
		if (!document.querySelector(`#mfe-${configItem.tagName}`)) {
			const script = document.createElement("script");
			script.src = configItem.mfeBundleUrl;
			script.type = configItem.scriptType;
			script.async = configItem.isAsync;
			script.defer = configItem.defer;
			script.crossOrigin = configItem.crossOrigin;
			script.id = `mfe-${configItem.tagName}`;
			await document.body.appendChild(script);
		}
	}

	private async createLink(configItem: MfeItem): Promise<void> {
		if (!document.querySelector(`#link-mfe-${configItem.tagName}`)) {
			const link = document.createElement("link");
			link.id = `link-mfe-${configItem.tagName}`;
			link.href = configItem.mfeBundleUrl;
			link.rel = "prefetch";
			link.as = "script";
			await document.head.appendChild(link);
		}
	}
}
EOF

cat <<'EOF' > src/shared/configuration/mfes.ts
import type { MfeItem } from "../utilities/mfe-loader.utility";

export const MFE_LOADER_CONFIG: MfeItem[] = [
	{
		mfeBundleUrl: "https://quincarter.github.io/my-coffee-app/assets/coffee-users-PQOfY16o.js",
		scriptType: "module",
		isAsync: false,
		defer: false,
		crossOrigin: "anonymous",
		tagName: "coffee-users",
		associatedInternalTag: "home-page",
	}
];
EOF

cat <<'EOF' > src/shared/utilities/app-root.utility.ts
import type { NavItem } from "../interfaces/navigation.interface";

export namespace AppRootUtilities {
	export function getNotAllowedRoutes(
		fullNavList: NavItem[],
		notAlowedRouteList: NavItem[],
	) {
		const notAllowed: NavItem[] = [];
		const navItems = fullNavList.filter((item) => {
			if (item.userHasPermission) {
				return true;
			}
			notAllowed.push(item);
			return false;
		});

		return {
			navItems,
			notAllowed: [...notAlowedRouteList, ...notAllowed],
		};
	}
}
EOF

# Build navigation routes based on enabled features
if [ "$ENABLE_ROUTER" = true ]; then
  NAV_ITEMS='{
		name: "Home",
		path: "/home",
		directory: "home-page",
		component: "home-page",
		filePath: "../../views/home-page/home-page.ts",
		levelOfAccess: ["public"],
		tagName: "home-page",
		isMfe: false,
	}'

  if [ "$ENABLE_TODOS" = true ]; then
    NAV_ITEMS="$NAV_ITEMS,
	{
		name: \"Todos (Signals)\",
		path: \"/todos-page\",
		directory: \"todos-page\",
		component: \"todos-page\",
		filePath: \"../../views/todos-page/todos-page.ts\",
		levelOfAccess: [\"public\"],
		tagName: \"todos-page\",
		isMfe: false,
	}"
  fi

  if [ "$ENABLE_CARDS" = true ]; then
    NAV_ITEMS="$NAV_ITEMS,
	{
		name: \"Card Examples\",
		path: \"/card-examples\",
		directory: \"card-examples\",
		component: \"card-examples\",
		filePath: \"../../views/card-examples/card-examples.ts\",
		levelOfAccess: [\"public\"],
		tagName: \"card-examples\",
		isMfe: false,
	}"
  fi

  if [ "$ENABLE_CHARTS" = true ]; then
    NAV_ITEMS="$NAV_ITEMS,
	{
		name: \"Charts\",
		path: \"/chart-examples\",
		directory: \"chart-examples\",
		component: \"chart-examples\",
		filePath: \"../../views/chart-examples/chart-examples.ts\",
		levelOfAccess: [\"public\"],
		tagName: \"chart-examples\",
		isMfe: false,
	}"
  fi

  if [ "$ENABLE_MFE_LOADER" = true ]; then
    NAV_ITEMS="$NAV_ITEMS,
	{
		name: \"Vite MFE\",
		path: \"/vite-mfe\",
		directory: \"vite-mfe\",
		component: \"vite-mfe\",
		filePath: \"../../views/vite-mfe/vite-mfe.ts\",
		levelOfAccess: [\"public\"],
		tagName: \"vite-mfe\",
		isMfe: true,
	}"
  fi

cat <<EOF > src/shared/configuration/nav.ts
import type { NavItem } from "../interfaces/navigation.interface";

export const navigationRouting: NavItem[] = [
$NAV_ITEMS
];

export const sidePages: NavItem[] = [];
EOF

cat <<'EOF' > src/shared/configuration/routes.ts
import type { IconType, NavItem } from "../interfaces/navigation.interface";
import type { MfeItem } from "../utilities/mfe-loader.utility";
import { MFE_LOADER_CONFIG } from "./mfes";

export const getAccessPermissions = (
	item: NavItem,
	accesses: string[],
): boolean => item.levelOfAccess.some((access) => accesses.includes(access));

export const getMfeComponent = (
	internalTagName: string,
): MfeItem | undefined => {
	const mfe = MFE_LOADER_CONFIG.filter(
		(mfe: MfeItem) => mfe.associatedInternalTag === internalTagName,
	);
	return mfe.length > 0 ? mfe[0] : undefined;
};

export const routesBuilt = (
	navItems: NavItem[],
	accesses: string[],
): NavItem[] => {
	return navItems.map((navItem: NavItem) => ({
		...navItem,
		icon: navItem.icon || ("" as IconType),
		mfeComponent: getMfeComponent(navItem.tagName),
		userHasPermission: getAccessPermissions(navItem, accesses),
	}));
};
EOF
fi

# Contexts
if [ "$ENABLE_CONTEXT" = true ]; then
cat <<'EOF' > src/shared/contexts/accesses.context.ts
import { createContext } from "@lit/context";
export const AccessesContext = createContext<string[]>("accessesContext");
EOF
cat <<'EOF' > src/shared/contexts/navigation.context.ts
import { createContext } from "@lit/context";
import type { NavItem } from "../interfaces/navigation.interface";
export const NavigationContext = createContext<NavItem[]>("navContext");
EOF
cat <<'EOF' > src/shared/contexts/mfe-loader.context.ts
import { createContext } from "@lit/context";
import type { MfeLoader } from "../utilities/mfe-loader.utility";
export const MfeLoaderContext = createContext<MfeLoader>("mfeLoaderContext");
EOF
fi

# Preact Signals & Persistence Stores
if [ "$ENABLE_SIGNALS" = true ]; then
cat <<'EOF' > src/shared/stores/persistent-signal.ts
import { effect, signal, type Signal } from "@lit-labs/preact-signals";
import { openDB, type IDBPDatabase } from "idb";

const DB_NAME = "app-shell-store";
const STORE_NAME = "signals";
const DB_VERSION = 1;

let dbPromise: Promise<IDBPDatabase> | null = null;

const getDB = () => {
	if (!dbPromise) {
		dbPromise = openDB(DB_NAME, DB_VERSION, {
			upgrade(db) {
				if (!db.objectStoreNames.contains(STORE_NAME)) {
					db.createObjectStore(STORE_NAME);
				}
			},
		});
	}
	return dbPromise;
};

export interface PersistentSignalOptions {
	key?: string;
}

export function persistentSignal<T>(
	defaultValue: T,
	options: PersistentSignalOptions = {},
): Signal<T> {
	const { key } = options;
	const s = signal<T>(defaultValue);

	if (!key) return s;

	const initialized = signal(false);

	getDB().then(async (db) => {
		try {
			const storedValue = await db.get(STORE_NAME, key);
			if (storedValue !== undefined) {
				s.value = storedValue;
			}
		} catch (error) {
			console.error(`Failed to load persistent signal for key "${key}":`, error);
		} finally {
			initialized.value = true;
		}
	});

	effect(() => {
		const value = s.value;
		if (!initialized.value) return;

		(async () => {
			try {
				const db = await getDB();
				await db.put(STORE_NAME, value, key);
			} catch (error) {
				console.error(`Failed to persist signal for key "${key}":`, error);
			}
		})();
	});

	return s;
}

export async function clearPersistentSignals(): Promise<void> {
	const db = await getDB();
	await db.clear(STORE_NAME);
}
EOF

cat <<'EOF' > src/shared/stores/todo.store.ts
import { persistentSignal } from "./persistent-signal";
import type { ITodoItem } from "../interfaces/todos.interface";

export const todosSignal = persistentSignal<Record<string, ITodoItem>>({}, { key: "todos" });

export const addTodo = (title: string, description?: string) => {
	const id = crypto.randomUUID();
	todosSignal.value = {
		...todosSignal.value,
		[id]: { id, title, description, checked: false },
	};
	return id;
};

export const toggleTodo = (id: string) => {
	const todo = todosSignal.value[id];
	if (todo) {
		todosSignal.value = {
			...todosSignal.value,
			[id]: { ...todo, checked: !todo.checked },
		};
	}
};

export const removeTodo = (id: string) => {
	const newTodos = { ...todosSignal.value };
	delete newTodos[id];
	todosSignal.value = newTodos;
};
EOF

cat <<'EOF' > src/shared/stores/todo-list.store.ts
import { computed } from "@lit-labs/preact-signals";
import { persistentSignal } from "./persistent-signal";
import { todosSignal } from "./todo.store";

export const todoOrderSignal = persistentSignal<string[]>([], { key: "todo-order" });
export const sortDirectionSignal = persistentSignal<"asc" | "desc">("asc", { key: "sort-direction" });

export const sortedTodosSignal = computed(() => {
	const todos = todoOrderSignal.value
		.map((id) => todosSignal.value[id])
		.filter(Boolean);

	return sortDirectionSignal.value === "asc"
		? [...todos].sort((a, b) => a.title.localeCompare(b.title))
		: [...todos].sort((a, b) => b.title.localeCompare(a.title));
});

export const addIdToOrder = (id: string) => {
	todoOrderSignal.value = [...todoOrderSignal.value, id];
};

export const removeIdFromOrder = (id: string) => {
	todoOrderSignal.value = todoOrderSignal.value.filter(
		(todoId) => todoId !== id,
	);
};

export const toggleSortDirection = () => {
	sortDirectionSignal.value =
		sortDirectionSignal.value === "asc" ? "desc" : "asc";
};
EOF
fi

# Internal Views
mkdir -p src/shared/internal-views/404-not-found
cat <<'EOF' > src/shared/internal-views/404-not-found/PageNotFound.ts
import { css, html, LitElement } from "lit";
export class PageNotFound extends LitElement {
	static styles = [css`:host { display: block; padding: 2rem; }`];
	render() { return html`<h2>404 - Page Not Found</h2>`; }
}
EOF
cat <<'EOF' > src/shared/internal-views/404-not-found/page-not-found.ts
import { PageNotFound } from "./PageNotFound";
customElements.define("page-not-found", PageNotFound);
EOF

mkdir -p src/shared/internal-views/no-access
cat <<'EOF' > src/shared/internal-views/no-access/NoAccess.ts
import { css, html, LitElement } from "lit";
export class NoAccess extends LitElement {
	static styles = [css`:host { display: block; padding: 2rem; }`];
	render() { return html`<h2>Access Denied</h2>`; }
}
EOF
cat <<'EOF' > src/shared/internal-views/no-access/no-access.ts
import { NoAccess } from "./NoAccess";
customElements.define("no-access", NoAccess);
EOF

mkdir -p src/shared/internal-views/under-construction
cat <<'EOF' > src/shared/internal-views/under-construction/UnderConstruction.ts
import { css, html, LitElement } from "lit";
export class UnderConstruction extends LitElement {
	static styles = [css`:host { display: block; padding: 2rem; }`];
	render() { return html`<h2>Under Construction</h2>`; }
}
EOF
cat <<'EOF' > src/shared/internal-views/under-construction/under-construction.ts
import { UnderConstruction } from "./UnderConstruction";
customElements.define("under-construction", UnderConstruction);
EOF

# ------------------------------------------------------------------------------
# Create Components
# ------------------------------------------------------------------------------
log_info "Generating UI components..."
mkdir -p src/components

if [ "$ENABLE_THEME_SWITCHER" = true ]; then
mkdir -p src/components/theme-switcher
cat <<'EOF' > src/components/theme-switcher/theme-switcher.styles.ts
import { css } from "lit";
export const ThemeSwitcherStyles = css`
  :host { height: fit-content; justify-content: right; display: flex; }
  .switch { position: relative; display: inline-block; width: 3rem; height: 1.5rem; }
  .switch input { opacity: 0; width: 0; height: 0; }
  .slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #27173a; transition: 0.4s; border-radius: 5rem; }
  .slider:before { position: absolute; content: ''; height: 1rem; width: 1rem; left: 5px; bottom: 4px; background-color: #ffc207; transition: 0.4s; border-radius: 50%; }
  input:checked + .slider:before { transform: translateX(1.5rem); box-shadow: inset -3px 0 0 2px #ffc207; background-color: #27173a; }
`;
EOF
cat <<'EOF' > src/components/theme-switcher/ThemeSwitcher.ts
import { type HTMLTemplateResult, html, LitElement, type PropertyValues } from "lit";
import { query } from "lit/decorators.js";
import { ThemeSwitcherStyles } from "./theme-switcher.styles";

export class ThemeSwitcher extends LitElement {
	@query('#theme-switch input[type="checkbox"]')
	switchBox: HTMLInputElement | undefined;

	static styles = [ThemeSwitcherStyles];

	protected firstUpdated(_changedProperties: PropertyValues): void {
		super.firstUpdated(_changedProperties);
		if (document.documentElement.getAttribute("data-theme") === "dark") {
			this.switchBox?.setAttribute("checked", "");
		}
	}

	switchTheme(e: Event) {
		const target = e.target as HTMLInputElement;
		if (target.checked) {
			localStorage.setItem("theme", "dark");
			document.documentElement.setAttribute("data-theme", "dark");
			this.switchBox?.setAttribute("checked", "");
		} else {
			localStorage.setItem("theme", "light");
			document.documentElement.setAttribute("data-theme", "light");
			this.switchBox?.removeAttribute("checked");
		}
	}

	render(): HTMLTemplateResult {
		return html`
      <label id="theme-switch" class="switch">
        <input type="checkbox" @click="${this.switchTheme}" />
        <span class="slider round"></span>
      </label>
    `;
	}
}
EOF
cat <<'EOF' > src/components/theme-switcher/theme-switcher.ts
import { ThemeSwitcher } from "./ThemeSwitcher";
customElements.define("theme-switcher", ThemeSwitcher);
EOF
fi

if [ "$ENABLE_HEADER" = true ]; then
mkdir -p src/components/header
cat <<'EOF' > src/components/header/app-shell-header.styles.ts
import { css } from "lit";
export const AppShellHeaderStyles = css`
  nav { align-items: center; background-color: var(--nav-background-color); box-shadow: var(--primary-box-shadow); display: flex; justify-content: space-between; padding: 0.75rem 1.5rem; }
  ul { display: flex; gap: 1.5rem; list-style: none; margin: 0; padding: 0; }
  a { font-weight: 500; color: var(--primary-text-color); text-decoration: none; }
  a:hover { text-decoration: underline; }
`;
EOF
cat <<'EOF' > src/components/header/AppShellHeader.ts
import { type HTMLTemplateResult, html, LitElement, nothing } from "lit";
import { property } from "lit/decorators.js";
import { withBase } from "../../shared/configuration/base-path";
import type { NavItem } from "../../shared/interfaces/navigation.interface";
import { AppShellHeaderStyles } from "./app-shell-header.styles";
import "../theme-switcher/theme-switcher";

export class AppShellHeader extends LitElement {
	@property({ attribute: "routes", type: Array })
	routes: NavItem[] = [] as NavItem[];

	@property({ type: Boolean, attribute: "enable-theme-switcher" })
	enableThemeSwitcher = false;

	static styles = [AppShellHeaderStyles];

	render(): HTMLTemplateResult {
		return html`
      <nav>
        <div class="brand">
          <a href="${withBase("/")}"><strong>App Shell</strong></a>
        </div>
        ${
					this.routes.length > 0
						? html`<ul>
                ${this.routes.map(
									(route) =>
										html`<li><a href="${withBase(route.path)}">${route.name}</a></li>`,
								)}
              </ul>`
						: nothing
				}
        ${
					this.enableThemeSwitcher
						? html`<theme-switcher></theme-switcher>`
						: nothing
				}
      </nav>
      <slot></slot>
    `;
	}
}
EOF
cat <<'EOF' > src/components/header/app-shell-header.ts
import { AppShellHeader } from "./AppShellHeader";
customElements.define("app-shell-header", AppShellHeader);
EOF
fi

if [ "$ENABLE_CARDS" = true ]; then
mkdir -p src/components/card
cat <<'EOF' > src/components/card/generic-card.styles.ts
import { css } from "lit";
export const GenericCardStyles = css`
  :host { display: block; }
  .card-wrapper {
    border: 1px solid rgba(0, 0, 0, 0.125);
    border-radius: 0.5rem;
    padding: 1.25rem;
    background-color: var(--bg-color);
  }
`;
EOF
cat <<'EOF' > src/components/card/GenericCard.ts
import { html, LitElement } from "lit";
import { GenericCardStyles } from "./generic-card.styles";

export class GenericCard extends LitElement {
	static styles = [GenericCardStyles];
	render() {
		return html`<div class="card-wrapper"><slot></slot></div>`;
	}
}
EOF
cat <<'EOF' > src/components/card/generic-card.ts
import { GenericCard } from "./GenericCard";
customElements.define("generic-card", GenericCard);
EOF
cat <<'EOF' > src/components/card/vite-logo.svg.ts
import type { SVGTemplateResult } from "lit";
import { svg } from "lit";

export const ViteLogo: SVGTemplateResult = svg`<svg xmlns="http://www.w3.org/2000/svg" width="31.88" height="32" viewBox="0 0 256 257"><path fill="#41D1FF" d="M255.153 37.938L134.897 252.976c-2.483 4.44-8.862 4.466-11.382.048L.875 37.958c-2.746-4.814 1.371-10.646 6.827-9.67l120.385 21.517a6.537 6.537 0 0 0 2.322-.004l117.867-21.483c5.438-.991 9.574 4.796 6.877 9.62Z"></path></svg>`;
EOF
fi

if [ "$ENABLE_CHARTS" = true ]; then
mkdir -p src/components/chart-js
cat <<'EOF' > src/components/chart-js/chart-js.utility.ts
import colorLib, { type Color, type RGBA } from "@kurkle/color";
import { DateTime } from "luxon";
import "chartjs-adapter-luxon";

var _seed = Date.now();
export function srand(seed: number) { _seed = seed; }
export function valueOrDefault<T>(value: T | undefined, defaultValue: T) {
	return typeof value === "undefined" ? defaultValue : value;
}
export function rand(min?: number, max?: number) {
	min = valueOrDefault(min, 0); max = valueOrDefault(max, 0);
	_seed = (_seed * 9301 + 49297) % 233280;
	return min + (_seed / 233280) * (max - min);
}
export function months(config: Record<string, unknown>) {
	const cfg = config || {}; const count = (cfg.count as number) || 12;
	const MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
	const values = [];
	for (let i = 0; i < count; ++i) { values.push(MONTHS[Math.ceil(i) % 12]); }
	return values;
}
EOF

cat <<'EOF' > src/components/chart-js/chart-types.interface.ts
import type { ChartConfiguration } from "chart.js/auto";
import * as Utils from "./chart-js.utility";

const barLabels = Utils.months({ count: 7 });
export const SAMPLE_BAR_DATA: ChartConfiguration = {
	type: "bar",
	data: {
		labels: barLabels,
		datasets: [{ label: "Sample Dataset", data: [65, 59, 80, 81, 56, 55, 40], backgroundColor: "rgba(54, 162, 235, 0.5)" }]
	}
};
export const SAMPLE_PIE_DATA: ChartConfiguration = {
	type: "pie",
	data: { labels: ["Red", "Blue", "Yellow"], datasets: [{ data: [300, 50, 100], backgroundColor: ["rgb(255, 99, 132)", "rgb(54, 162, 235)", "rgb(255, 205, 86)"] }] }
};
export const SAMPLE_DOUGHNUT_DATA: ChartConfiguration = {
	type: "doughnut",
	data: { labels: ["Red", "Blue", "Yellow"], datasets: [{ data: [300, 50, 100], backgroundColor: ["rgb(255, 99, 132)", "rgb(54, 162, 235)", "rgb(255, 205, 86)"] }] }
};
EOF

cat <<'EOF' > src/components/chart-js/ChartJs.ts
import { Chart, type ChartConfiguration, type ChartItem, type ChartType } from "chart.js/auto";
import { type HTMLTemplateResult, html, LitElement, type PropertyValues } from "lit";
import { property, query, state } from "lit/decorators.js";
import { SAMPLE_BAR_DATA, SAMPLE_DOUGHNUT_DATA, SAMPLE_PIE_DATA } from "./chart-types.interface";

export class ChartJsComponent extends LitElement {
	@property({ type: String, attribute: "chart-type" }) chartType: ChartType | undefined;
	@property({ type: Object, attribute: "chart-config" }) config: ChartConfiguration | undefined;
	@state() chart: Chart | undefined;
	@query("canvas") canvasElement: HTMLCanvasElement | undefined;

	protected firstUpdated(_changedProperties: PropertyValues): void {
		const ctx = this.canvasElement?.getContext("2d") as ChartItem;
		let data = this.config;
		if (!data) {
			switch (this.chartType) {
				case "bar": data = { ...SAMPLE_BAR_DATA }; break;
				case "pie": data = { ...SAMPLE_PIE_DATA }; break;
				case "doughnut": data = { ...SAMPLE_DOUGHNUT_DATA }; break;
				default: break;
			}
		}
		this.chart = new Chart(ctx, { ...data } as ChartConfiguration);
	}

	render(): HTMLTemplateResult { return html`<canvas></canvas>`; }
}
EOF

cat <<'EOF' > src/components/chart-js/chart-js.ts
import { ChartJsComponent } from "./ChartJs";
if (!customElements.get("base-chart")) {
	customElements.define("base-chart", ChartJsComponent);
}
EOF
fi

if [ "$ENABLE_TODOS" = true ]; then
mkdir -p src/components/todos/todo-item
cat <<'EOF' > src/components/todos/todo-item/todo-item.styles.ts
import { css } from "lit";
export const TodoItemStyles = css`
	:host { display: block; padding: 0.5rem; border-bottom: 1px solid #eee; }
	.todo-item { display: flex; align-items: center; gap: 1rem; }
	.todo-item.checked .title { text-decoration: line-through; color: #888; }
	.content { flex: 1; display: flex; flex-direction: column; }
	.title { font-weight: bold; }
	.description { font-size: 0.85rem; color: #666; }
	button { background-color: #ff4d4d; color: white; border: none; padding: 0.25rem 0.5rem; border-radius: 4px; cursor: pointer; }
	button:hover { background-color: #cc0000; }
`;
EOF

cat <<'EOF' > src/components/todos/todo-item/TodoItem.ts
import { html, LitElement } from "lit";
import { property } from "lit/decorators.js";
import { removeTodo, toggleTodo } from "../../../shared/stores/todo.store";
import { removeIdFromOrder } from "../../../shared/stores/todo-list.store";
import { TodoItemStyles } from "./todo-item.styles";

export class TodoItem extends LitElement {
	@property({ type: String }) id = "";
	@property({ type: String, attribute: "item-title" }) title = "";
	@property({ type: String, attribute: "item-description" }) description = "";
	@property({ type: Boolean, attribute: "is-checked" }) isChecked = false;

	static styles = [TodoItemStyles];

	onChecked() { toggleTodo(this.id); }
	onDelete() { removeTodo(this.id); removeIdFromOrder(this.id); }

	render() {
		return html`
			<div class="todo-item ${this.isChecked ? "checked" : ""}">
				<input type="checkbox" .checked="${this.isChecked}" @change="${this.onChecked}" />
				<div class="content">
					<span class="title">${this.title}</span>
					${this.description ? html`<span class="description">${this.description}</span>` : ""}
				</div>
				<button @click="${this.onDelete}">Delete</button>
			</div>
		`;
	}
}
EOF

cat <<'EOF' > src/components/todos/todo-item/todo-item.ts
import { TodoItem } from "./TodoItem";
customElements.define("todo-item", TodoItem);
EOF

mkdir -p src/components/todos/todo-list
cat <<'EOF' > src/components/todos/todo-list/todo-list.styles.ts
import { css } from "lit";
export const TodoListStyles = css`
	:host { display: block; font-family: sans-serif; }
	.todo-list-container { max-width: 500px; margin: 0 auto; background: var(--bg-color); border-radius: 8px; box-shadow: var(--primary-box-shadow); padding: 1.5rem; }
	header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
	h2 { margin: 0; color: var(--primary-text-color); }
	.sort-btn { background: #6c757d; color: white; border: none; padding: 0.4rem 0.8rem; border-radius: 4px; cursor: pointer; }
	.input-area { display: flex; gap: 0.5rem; margin-bottom: 1.5rem; }
	input { flex: 1; padding: 0.6rem; border: 1px solid #ced4da; border-radius: 4px; }
	button { padding: 0.6rem 1.2rem; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; }
	.list { border-top: 1px solid #dee2e6; }
`;
EOF

cat <<'EOF' > src/components/todos/todo-list/TodoList.ts
import { SignalWatcher } from "@lit-labs/preact-signals";
import { type CSSResultOrNative, html, LitElement } from "lit";
import { query } from "lit/decorators.js";
import { repeat } from "lit/directives/repeat.js";
import { addTodo } from "../../../shared/stores/todo.store";
import { addIdToOrder, sortDirectionSignal, sortedTodosSignal, toggleSortDirection } from "../../../shared/stores/todo-list.store";
import "../todo-item/todo-item";
import { TodoListStyles } from "./todo-list.styles";

export class TodoList extends SignalWatcher(LitElement) {
	static styles: CSSResultOrNative[] = [TodoListStyles];

	@query("#todo-input") inputElement!: HTMLInputElement;

	private _onAddTodo() {
		const title = this.inputElement.value.trim();
		if (title) {
			const id = addTodo(title);
			addIdToOrder(id);
			this.inputElement.value = "";
		}
	}

	private _toggleSort() { toggleSortDirection(); }

	render() {
		return html`
            <div class="todo-list-container">
                <header>
                    <h2>Todos (Signals & IndexedDB)</h2>
                    <button class="sort-btn" @click="${this._toggleSort}">
                        Sort: ${sortDirectionSignal.value.toUpperCase()}
                    </button>
                </header>

                <div class="input-area">
                    <input id="todo-input" type="text" placeholder="Add a new todo..." />
                    <button @click="${this._onAddTodo}">Add</button>
                </div>

                <div class="list">
                    ${repeat(
											sortedTodosSignal.value,
											(item) => item.id,
											(item) => html`
                        <todo-item
                            .id="${item.id}"
                            .title="${item.title}"
                            .description="${item.description || ""}"
                            .isChecked="${item.checked}"
                        ></todo-item>
                    `,
										)}
                </div>
            </div>
        `;
	}
}
EOF

cat <<'EOF' > src/components/todos/todo-list/todo-list.ts
import { TodoList } from "./TodoList";
customElements.define("todo-list", TodoList);
EOF
fi

# ------------------------------------------------------------------------------
# Create Views
# ------------------------------------------------------------------------------
log_info "Generating Views & ViewMixin..."
mkdir -p src/views

if [ "$ENABLE_ROUTER" = true ]; then
cat <<'EOF' > src/views/view.mixin.ts
import { consume } from "@lit/context";
import { type HTMLTemplateResult, html, type LitElement } from "lit";
import { property, state } from "lit/decorators.js";
import { AccessesContext } from "../shared/contexts/accesses.context";
import { MfeLoaderContext } from "../shared/contexts/mfe-loader.context";
import { NavigationContext } from "../shared/contexts/navigation.context";
import type { NavItem } from "../shared/interfaces/navigation.interface";
import type { MfeLoader } from "../shared/utilities/mfe-loader.utility";

type Constructor<T = {}> = new (...args: any[]) => T;

export declare class ViewMixinInterface {
	navItems: NavItem[];
	mfeLoader: MfeLoader | undefined;
	tagName: string;
	componentData: NavItem;
	featureIsEnabled: boolean;
	isMfe: boolean;
	renderUnderConstruction(): HTMLTemplateResult;
	renderMfe(customTemplate?: HTMLTemplateResult): HTMLTemplateResult;
}

export const ViewMixin = <T extends Constructor<LitElement>>(superClass: T) => {
	class ViewMixinClass extends superClass {
		@consume({ context: NavigationContext, subscribe: true })
		@property({ type: Array }) navItems: NavItem[] = [];

		@consume({ context: AccessesContext, subscribe: true })
		@state() accesses: string[] = [];

		@consume({ context: MfeLoaderContext, subscribe: true })
		@state() mfeLoader: MfeLoader | undefined;

		@state() tagName = "";
		@state() featureIsEnabled = false;
		isMfe = false;

		get componentData(): NavItem {
			if (this.isMfe) {
				return (
					this.navItems.find(
						(item: NavItem) => item.mfeComponent?.tagName === this.tagName,
					) ?? ({} as NavItem)
				);
			}
			return (
				this.navItems.find((item: NavItem) => item.tagName === this.tagName) ??
				({} as NavItem)
			);
		}

		connectedCallback(): void {
			super.connectedCallback();
			this.featureIsEnabled = true;
			this.mfeLoader?.init();
		}

		renderUnderConstruction(): HTMLTemplateResult {
			const hasPermission = this.componentData?.userHasPermission ?? true;
			return !hasPermission
				? html`<no-access></no-access>`
				: html`<under-construction></under-construction>`;
		}

		renderMfe(customTemplate?: HTMLTemplateResult): HTMLTemplateResult {
			const hasPermission = this.componentData?.userHasPermission ?? true;
			if (!hasPermission) {
				return this.renderUnderConstruction();
			}

			if (customTemplate) return html`${customTemplate}`;

			return html`${
				this.featureIsEnabled && this.isMfe
					? html`<div id="mfe-container-${this.tagName}"></div>`
					: this.renderUnderConstruction()
			}`;
		}

		protected render(): HTMLTemplateResult { return html`${this.renderMfe()}`; }
	}
	return ViewMixinClass as unknown as Constructor<ViewMixinInterface> & T;
};
EOF

mkdir -p src/views/home-page
cat <<'EOF' > src/views/home-page/home-page.ts
import { type HTMLTemplateResult, html, LitElement } from "lit";
import { customElement } from "lit/decorators.js";
import { ViewMixin } from "../view.mixin";

@customElement("home-page")
export class HomePage extends ViewMixin(LitElement) {
	tagName = "home-page";

	render(): HTMLTemplateResult {
		return html`
			<div style="padding: 2rem;">
				<h1>Welcome to your Lit App Shell!</h1>
				<p>Your modular application structure is initialized and ready for development.</p>
			</div>
		`;
	}
}
EOF

if [ "$ENABLE_TODOS" = true ]; then
mkdir -p src/views/todos-page
cat <<'EOF' > src/views/todos-page/todos-page.styles.ts
import { css } from "lit";
export const TodosPageStyles = css``;
EOF

cat <<'EOF' > src/views/todos-page/todos-page.ts
import { type HTMLTemplateResult, html, LitElement } from "lit";
import { customElement } from "lit/decorators.js";
import { ViewMixin } from "../view.mixin";
import { TodosPageStyles } from "./todos-page.styles";
import "../../components/todos/todo-list/todo-list";

@customElement("todos-page")
export class TodosPage extends ViewMixin(LitElement) {
	featureIsEnabled = true;
	isMfe = false;
	static styles = [TodosPageStyles];

	render(): HTMLTemplateResult {
		return this.renderMfe(html`<todo-list></todo-list>`);
	}
}
EOF
fi

if [ "$ENABLE_CARDS" = true ]; then
mkdir -p src/views/card-examples
cat <<'EOF' > src/views/card-examples/card-page.styles.ts
import { css } from "lit";
export const CardPageStyles = css`
  .card-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1rem; padding: 1rem; }
`;
EOF
cat <<'EOF' > src/views/card-examples/card-examples.ts
import { type HTMLTemplateResult, html, LitElement } from "lit";
import { customElement } from "lit/decorators.js";
import { ViewMixin } from "../view.mixin";
import { CardPageStyles } from "./card-page.styles";
import "../../components/card/generic-card";

@customElement("card-examples")
export class CardExamples extends ViewMixin(LitElement) {
	featureIsEnabled = true;
	isMfe = false;
	static styles = [CardPageStyles];

	render(): HTMLTemplateResult {
		return this.renderMfe(
			html`<div class="card-container">
				<generic-card>
					<div slot="card-title"><h2>Generic Card</h2></div>
					This is a sample card component.
				</generic-card>
			</div>`,
		);
	}
}
EOF
fi

if [ "$ENABLE_CHARTS" = true ]; then
mkdir -p src/views/chart-examples
cat <<'EOF' > src/views/chart-examples/chart-examples.ts
import { css, type HTMLTemplateResult, html, LitElement } from "lit";
import { customElement } from "lit/decorators.js";
import { ViewMixin } from "../view.mixin";
import "../../components/chart-js/chart-js";

@customElement("chart-examples")
export class ChartExamples extends ViewMixin(LitElement) {
	featureIsEnabled = true;
	isMfe = false;

	static styles = [
		css`.pie-container { display: flex; gap: 2rem; flex-wrap: wrap; }`,
	];

	render(): HTMLTemplateResult {
		return this.renderMfe(
			html`
        <h2>Basic Bar Chart</h2>
        <base-chart chart-type="bar"></base-chart>
        <h2>Pie & Doughnut Charts</h2>
        <div class="pie-container">
          <base-chart chart-type="pie"></base-chart>
          <base-chart chart-type="doughnut"></base-chart>
        </div>`,
		);
	}
}
EOF
fi

if [ "$ENABLE_MFE_LOADER" = true ]; then
mkdir -p src/views/vite-mfe
cat <<'EOF' > src/views/vite-mfe/vite-mfe.ts
import { type HTMLTemplateResult, html, LitElement } from "lit";
import { customElement } from "lit/decorators.js";
import { ViewMixin } from "../view.mixin";

@customElement("vite-mfe")
export class ViteMfe extends ViewMixin(LitElement) {
	tagName = "coffee-users";
	featureIsEnabled = true;
	isMfe = true;

	render(): HTMLTemplateResult {
		return html`${this.renderMfe()}`;
	}
}
EOF
fi

fi

# ------------------------------------------------------------------------------
# Create src/app-shell.ts & src/app-shell.styles.ts
# ------------------------------------------------------------------------------
log_info "Generating App Shell root component..."

cat <<'EOF' > src/app-shell.styles.ts
import { css } from "lit";
export const AppShellStyles = css`
  :host { display: block; min-height: 100vh; }
  main { padding: 1rem; }
`;
EOF

IMPORTS="import { type HTMLTemplateResult, html, LitElement } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import { AppShellStyles } from './app-shell.styles';
import type { NavItem } from './shared/interfaces/navigation.interface';"

if [ "$ENABLE_CONTEXT" = true ]; then
  IMPORTS="$IMPORTS
import { provide } from '@lit/context';
import { AccessesContext } from './shared/contexts/accesses.context';
import { NavigationContext } from './shared/contexts/navigation.context';
import { MfeLoaderContext } from './shared/contexts/mfe-loader.context';"
fi

if [ "$ENABLE_ROUTER" = true ]; then
  IMPORTS="$IMPORTS
import { Router } from '@lit-labs/router';
import { html as staticHtml, unsafeStatic } from 'lit/static-html.js';
import 'urlpattern-polyfill';
import { navigationRouting } from './shared/configuration/nav';
import { routesBuilt } from './shared/configuration/routes';
import { withBase } from './shared/configuration/base-path';"
fi

if [ "$ENABLE_HEADER" = true ]; then
  IMPORTS="$IMPORTS
import './components/header/app-shell-header';"
fi

if [ "$ENABLE_MFE_LOADER" = true ]; then
  IMPORTS="$IMPORTS
import { MFE_LOADER_CONFIG } from './shared/configuration/mfes';
import { MfeLoader } from './shared/utilities/mfe-loader.utility';"
fi

cat <<EOF > src/app-shell.ts
$IMPORTS

@customElement("app-shell")
export class AppShell extends LitElement {
EOF

if [ "$ENABLE_CONTEXT" = true ]; then
cat <<EOF >> src/app-shell.ts
  @provide({ context: NavigationContext })
  @property({ type: Array })
  routing: NavItem[] = [];

  @provide({ context: AccessesContext })
  @property({ type: Array })
  accesses: string[] = ["public"];
EOF
  if [ "$ENABLE_MFE_LOADER" = true ]; then
cat <<EOF >> src/app-shell.ts
  @provide({ context: MfeLoaderContext })
  @state()
  mfeLoader = new MfeLoader(MFE_LOADER_CONFIG);
EOF
  fi
fi

if [ "$ENABLE_ROUTER" = true ]; then
cat <<EOF >> src/app-shell.ts
  private _router = new Router(this, []);
EOF
fi

cat <<EOF >> src/app-shell.ts

  static styles = [AppShellStyles];

  async connectedCallback(): Promise<void> {
    super.connectedCallback();
EOF

if [ "$ENABLE_ROUTER" = true ]; then
cat <<EOF >> src/app-shell.ts
    await this._setupRoutes();
EOF
fi

cat <<EOF >> src/app-shell.ts
  }
EOF

if [ "$ENABLE_ROUTER" = true ]; then
cat <<EOF >> src/app-shell.ts

  private async _setupRoutes(): Promise<void> {
    this.routing = routesBuilt(navigationRouting, ["public"]);
    const routeConfigs = this.routing.map((navItem) => ({
      path: withBase(navItem.path),
      enter: async () => {
        await import(\`./views/\${navItem.directory}/\${navItem.component}.ts\`);
        return true;
      },
      render: () => {
        const tag = unsafeStatic(navItem.tagName);
        return staticHtml\`<\${tag}></\${tag}>\`;
      },
    }));

    const firstPath = navigationRouting[0]?.path || "/home";
    const firstItem = navigationRouting[0];

    this._router.routes = [
      {
        path: withBase("/"),
        enter: async () => {
          window.history.replaceState({}, "", withBase(firstPath));
          if (firstItem) {
            await import(\`./views/\${firstItem.directory}/\${firstItem.component}.ts\`);
          }
          return true;
        },
        render: () => {
          const tag = unsafeStatic(firstItem?.tagName || "home-page");
          return staticHtml\`<\${tag}></\${tag}>\`;
        },
      },
      ...routeConfigs,
    ];

    const currentPath = window.location.pathname + window.location.search + window.location.hash;
    await this._router.goto(currentPath);
  }
EOF
fi

cat <<EOF >> src/app-shell.ts

  render(): HTMLTemplateResult {
    return html\`
EOF

if [ "$ENABLE_HEADER" = true ]; then
cat <<EOF >> src/app-shell.ts
      <app-shell-header .routes="\${this.routing}" enable-theme-switcher>
        <main>
EOF
else
cat <<EOF >> src/app-shell.ts
        <main>
EOF
fi

if [ "$ENABLE_ROUTER" = true ]; then
cat <<EOF >> src/app-shell.ts
          \${this._router.outlet()}
EOF
else
cat <<EOF >> src/app-shell.ts
          <h2>Welcome to $APP_NAME</h2>
EOF
fi

cat <<EOF >> src/app-shell.ts
        </main>
EOF

if [ "$ENABLE_HEADER" = true ]; then
cat <<EOF >> src/app-shell.ts
      </app-shell-header>
EOF
fi

cat <<EOF >> src/app-shell.ts
    \`;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    "app-shell": AppShell;
  }
}
EOF

# ------------------------------------------------------------------------------
# Post-Generation Steps
# ------------------------------------------------------------------------------
if [ "$INIT_GIT" = true ]; then
  log_info "Initializing git repository..."
  git init -q
  log_success "Git repository initialized."
fi

if [ "$RUN_INSTALL" = true ]; then
  log_info "Installing dependencies with $PACKAGE_MANAGER..."
  $PACKAGE_MANAGER install
  log_success "Dependencies installed."
fi

log_title "App Shell Scaffolding Complete!"
echo -e "${GREEN}Project successfully created at:${RESET} ${BOLD}$TARGET_DIR${RESET}\n"

START_CMD="$PACKAGE_MANAGER start"

if [ "$NON_INTERACTIVE" = false ]; then
  read -rp "Would you like to cd into '$APP_NAME' and run '$START_CMD' now? (y/N): " AUTO_START
  if [[ "$AUTO_START" =~ ^[Yy]$ ]]; then
    echo -e "\n${CYAN}Directory changed to:${RESET} ${BOLD}$TARGET_DIR${RESET}"
    echo -e "${CYAN}Launching dev server with:${RESET} ${BOLD}$START_CMD${RESET}\n"
    cd "$TARGET_DIR" || exit 1
    if [ "$RUN_INSTALL" = false ]; then
      log_info "Installing dependencies first..."
      $PACKAGE_MANAGER install
    fi
    exec $PACKAGE_MANAGER start
  fi
fi

echo -e "Next steps:"
echo -e "  cd ${BOLD}$APP_NAME${RESET}"
if [ "$RUN_INSTALL" = false ]; then
  echo -e "  ${BOLD}$PACKAGE_MANAGER install${RESET}"
fi
echo -e "  ${BOLD}$START_CMD${RESET}\n"
