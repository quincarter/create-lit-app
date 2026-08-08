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
                ${this.routes
									.filter((route) => route.userHasPermission !== false)
									.map(
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
