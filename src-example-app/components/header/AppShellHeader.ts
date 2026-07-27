import { type HTMLTemplateResult, html, LitElement, nothing } from "lit";
import { property } from "lit/decorators.js";
import { withBase } from "../../shared/configuration/base-path";
import type { NavItem } from "../../shared/interfaces/navigation.interface";
import "../theme-switcher/theme-switcher";
import logoPng from "/pwa-192x192.png";
import { AppShellHeaderStyles } from "./app-shell-header.styles";

export class AppShellHeader extends LitElement {
	@property({ attribute: "routes", type: Array })
	routes: NavItem[] = [] as NavItem[];

	@property({ type: Boolean, attribute: "enable-theme-switcher" })
	enableThemeSwitcher = false;

	static styles = [AppShellHeaderStyles];

	render(): HTMLTemplateResult {
		return html`${
			this.routes.length > 0
				? html`<nav>
            <a href="${withBase("/home")}"><img class="logo" src="${logoPng}" alt="logo" /></a>
            <ul>
              ${this.routes.map(
								(route) =>
									html`<li><a href="${withBase(route.path)}">${route.name}</a></li>`,
							)}
            </ul>
            ${
							this.enableThemeSwitcher
								? html`<theme-switcher></theme-switcher>`
								: nothing
						}
          </nav>
          <slot></slot>`
				: nothing
		} `;
	}
}
