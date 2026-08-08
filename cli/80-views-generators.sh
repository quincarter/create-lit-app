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

			if (customTemplate && this.featureIsEnabled) return html`${customTemplate}`;

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
	tagName = "todos-page";
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
	tagName = "card-examples";
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
	tagName = "chart-examples";
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
	tagName = "my-element";
	featureIsEnabled = true;
	isMfe = true;

	render(): HTMLTemplateResult {
		return html`${this.renderMfe()}`;
	}
}
EOF
fi

fi
