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
		mfeBundleUrl:
			"https://quincarter.github.io/vite-test-my-element-mfe/assets/index-DVYAdQcO.js",
		scriptType: "module",
		isAsync: false,
		defer: false,
		crossOrigin: "anonymous",
		tagName: "my-element",
		associatedInternalTag: "vite-mfe",
	},
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
		levelOfAccess: [\"private\"],
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
		children: navItem.children?.map((child: NavItem) => ({
			...child,
			icon: child.icon || ("" as IconType),
			userHasPermission: getAccessPermissions(child, accesses),
		})),
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
