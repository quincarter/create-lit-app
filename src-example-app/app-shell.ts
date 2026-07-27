import { provide } from "@lit/context";
import { Router } from "@lit-labs/router";
import { type HTMLTemplateResult, html, LitElement } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { html as staticHtml, unsafeStatic } from "lit/static-html.js";
import "urlpattern-polyfill";
import { AppShellStyles } from "./app-shell.styles";
import "./components/header/app-shell-header";
import { withBase } from "./shared/configuration/base-path";
import { MFE_LOADER_CONFIG } from "./shared/configuration/mfes";
import { navigationRouting, sidePages } from "./shared/configuration/nav";
import { routesBuilt } from "./shared/configuration/routes";
import { AccessesContext } from "./shared/contexts/accesses.context";
import { MfeLoaderContext } from "./shared/contexts/mfe-loader.context";
import { NavigationContext } from "./shared/contexts/navigation.context";
import type { NavItem } from "./shared/interfaces/navigation.interface";
import "./shared/internal-views/404-not-found/page-not-found";
import "./shared/internal-views/no-access/no-access";
import "./shared/internal-views/under-construction/under-construction";
import "./components/card/generic-card";
import "./components/chart-js/chart-js";
import { AppRootUtilities } from "./shared/utilities/app-root.utility";
import { MfeLoader } from "./shared/utilities/mfe-loader.utility";
import "./components/todos/todo-list/todo-list";

@customElement("app-shell")
export class AppShell extends LitElement {
	@provide({ context: NavigationContext })
	@property({ type: Array })
	routing: NavItem[] = [];

	@provide({ context: AccessesContext })
	@property({ type: Array })
	accesses: string[] = [];

	@provide({ context: MfeLoaderContext })
	@state()
	mfeLoader = new MfeLoader(MFE_LOADER_CONFIG);

	@state()
	navRoutes: NavItem[] = [] as NavItem[];

	@state()
	notAllowedRouteList: NavItem[] = [];

	private _router = new Router(this, []);

	static styles = [AppShellStyles];

	async connectedCallback(): Promise<void> {
		super.connectedCallback();
		this.accesses = ["public"];
		this.navRoutes = this._buildNavBarRoutes(navigationRouting);
		await this._setupRoutes();
	}

	private _buildNavBarRoutes(navItems: NavItem[]): NavItem[] {
		const navi = routesBuilt(navItems, this.accesses);

		const { notAllowed, navItems: filtered } =
			AppRootUtilities.getNotAllowedRoutes(navi, this.notAllowedRouteList);

		this.notAllowedRouteList = notAllowed;
		return filtered;
	}

	private async _setupRoutes(): Promise<void> {
		const detailRoutes = this._buildNavBarRoutes([...sidePages]);

		this.routing = routesBuilt(
			[...this.navRoutes, ...this.notAllowedRouteList, ...detailRoutes],
			this.accesses,
		);

		const routeConfigs = this.routing.map((navItem) => ({
			path: withBase(navItem.path),
			enter: async () => {
				await import(`./views/${navItem.directory}/${navItem.component}.ts`);
				return true;
			},
			render: () => {
				const tag = unsafeStatic(navItem.tagName);
				return staticHtml`<${tag}></${tag}>`;
			},
		}));

		const firstPath = this.navRoutes[0]?.path || "/home";
		const firstItem = this.navRoutes[0];

		this._router.routes = [
			{
				path: withBase("/"),
				enter: async () => {
					window.history.replaceState({}, "", withBase(firstPath));
					if (firstItem) {
						await import(`./views/${firstItem.directory}/${firstItem.component}.ts`);
					}
					return true;
				},
				render: () => {
					const tag = unsafeStatic(firstItem?.tagName || "home-page");
					return staticHtml`<${tag}></${tag}>`;
				},
			},
			...routeConfigs,
		];

		const currentPath =
			window.location.pathname + window.location.search + window.location.hash;

		await this._router.goto(currentPath);
	}

	render(): HTMLTemplateResult {
		return html`
      <app-shell-header .routes="${this.navRoutes}" enable-theme-switcher>
        <main>${this._router.outlet()}</main>
      </app-shell-header>
    `;
	}
}

declare global {
	interface HTMLElementTagNameMap {
		"app-shell": AppShell;
	}
}
