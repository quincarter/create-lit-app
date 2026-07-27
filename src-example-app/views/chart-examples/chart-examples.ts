import { css, type HTMLTemplateResult, html, LitElement } from "lit";
import { customElement } from "lit/decorators.js";
import { ViewMixin } from "../view.mixin";

@customElement("chart-examples")
export class ChartExamples extends ViewMixin(LitElement) {
	featureIsEnabled = false;
	isMfe = false;

	static styles = [
		css`
      .pie-container {
        display: flex;
        flex-direction: row;
        flex-wrap: wrap;
        justify-content: space-evenly;
      }
    `,
	];

	render(): HTMLTemplateResult {
		return this.renderMfe(
			html` isMfe = ${this.isMfe}
        <h2>Basic Bar chart</h2>
        <base-chart chart-type="bar"></base-chart>
        <h2>Pie and Doughnut</h2>
        <div class="pie-container">
          <base-chart chart-type="pie"></base-chart>
          <base-chart chart-type="doughnut"></base-chart>
        </div>`,
		);
	}
}
