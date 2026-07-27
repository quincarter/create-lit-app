import { css, html, LitElement } from "lit";

export class UnderConstruction extends LitElement {
	static styles = [
		css`
      :host {
        display: block;
      }
    `,
	];

	render() {
		return html`Under Construction!`;
	}
}
