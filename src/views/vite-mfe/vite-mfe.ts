import { type HTMLTemplateResult, html, LitElement } from "lit";
import { customElement } from "lit/decorators.js";
import { ViewMixin } from "../view.mixin";

@customElement("vite-mfe")
export class ViteMfe extends ViewMixin(LitElement) {
	tagName = "my-element";
	featureIsEnabled = true;
	isMfe = true;

	render(): HTMLTemplateResult {
		return html`isMfe = ${this.isMfe}${this.renderMfe()}`;
	}
}
