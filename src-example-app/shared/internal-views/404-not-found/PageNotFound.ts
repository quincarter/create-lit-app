import { css, html, LitElement } from "lit";

export class PageNotFound extends LitElement {
	static styles = [
		css`
      :host {
        display: block;
      }
    `,
	];

	render() {
		return html`404 not found!`;
	}
}
