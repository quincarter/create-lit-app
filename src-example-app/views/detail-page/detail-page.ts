import { type HTMLTemplateResult, html, LitElement } from "lit";
import { customElement } from "lit/decorators.js";
import { ViewMixin } from "../view.mixin";

@customElement("detail-page")
export class DetailPage extends ViewMixin(LitElement) {
	tagName = "detail-page";
	featureIsEnabled = true;

	render(): HTMLTemplateResult {
		return html`isMfe = ${this.isMfe}
      <p>The detail page works now</p>`;
	}
}
