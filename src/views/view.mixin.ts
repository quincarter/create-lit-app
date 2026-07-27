import { consume } from "@lit/context";
import {
	type HTMLTemplateResult,
	html,
	type LitElement,
	type PropertyValues,
} from "lit";
import { property, state } from "lit/decorators.js";
import { AccessesContext } from "../shared/contexts/accesses.context";
import { MfeLoaderContext } from "../shared/contexts/mfe-loader.context";
import { NavigationContext } from "../shared/contexts/navigation.context";
import type { NavItem } from "../shared/interfaces/navigation.interface";
import type { MfeLoader } from "../shared/utilities/mfe-loader.utility";

type Constructor<T = {}> = new (...args: any[]) => T;

export declare class ViewMixinInterface {
	navItems: NavItem[];
	roles: string[];
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
		@property({ type: Array })
		navItems: NavItem[] = [];

		@consume({ context: AccessesContext, subscribe: true })
		@state()
		accesses: string[] = [];

		@consume({ context: MfeLoaderContext, subscribe: true })
		@state()
		mfeLoader: MfeLoader | undefined;

		@state()
		tagName = "";

		@state()
		featureIsEnabled = false;

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

		protected firstUpdated(_changedProperties: PropertyValues): void {
			super.firstUpdated(_changedProperties);
			let loadMfe: HTMLElement | undefined;
			const selectedMfeItem = this.mfeLoader?.config.find((item) => {
				if (item.tagName === this.tagName) {
					return item;
				}
				return false;
			});

			if (selectedMfeItem) {
				loadMfe = document.createElement(selectedMfeItem.tagName);
			}

			if (loadMfe) {
				const container = this.shadowRoot?.querySelector(
					`#mfe-container-${this.tagName}`,
				);
				container?.appendChild(loadMfe);
			}
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

			if (customTemplate) {
				return html`${customTemplate}`;
			}

			return html`${
				this.featureIsEnabled && this.isMfe
					? html`<div id="mfe-container-${this.tagName}"></div>`
					: this.renderUnderConstruction()
			}`;
		}

		protected render(): HTMLTemplateResult {
			return html`${this.renderMfe()}`;
		}
	}

	return ViewMixinClass as unknown as Constructor<ViewMixinInterface> & T;
};
