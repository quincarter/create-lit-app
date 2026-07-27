import {
	type HTMLTemplateResult,
	html,
	LitElement,
	type PropertyValues,
} from "lit";
import { query } from "lit/decorators.js";
import { ThemeSwitcherStyles } from "./theme-switcher.styles";

/**
 * This is a toggle switch component that should be easily addable to any project, but specifically sets different variables at the document level to help determine what theme is set. This also sets localStorage values for the current theme to persist
 * @element theme-switcher
 */
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
