import { type HTMLTemplateResult, html, LitElement } from "lit";
import { customElement } from "lit/decorators.js";
import { ViewMixin } from "../view.mixin";

@customElement("home-page")
export class HomePage extends ViewMixin(LitElement) {
	tagName = "coffee-users";
	featureIsEnabled = true;
	isMfe = true;

	render(): HTMLTemplateResult {
		return html`isMfe = ${this.isMfe}${this.renderMfe()}`;
	}
}
