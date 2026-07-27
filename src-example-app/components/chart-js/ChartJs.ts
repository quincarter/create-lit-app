import {
	Chart,
	type ChartConfiguration,
	type ChartItem,
	type ChartType,
} from "chart.js/auto";
import {
	type HTMLTemplateResult,
	html,
	LitElement,
	type PropertyValues,
} from "lit";
import { property, query, state } from "lit/decorators.js";
import {
	SAMPLE_BAR_DATA,
	SAMPLE_DOUGHNUT_DATA,
	SAMPLE_PIE_DATA,
} from "./chart-types.interface";

/**
 * This component will render a few different charts out of the box based on chart type. If importing this without renaming the custom element, you will use `<base-chart>`
 *
 * ## Usage
 * ```typescript
 * import { ChartJsComponent } from 'path/to/ChartJsComponent.ts';
 *
 * // doing class extends prevents the ChartJsComponent constructor from failing to initialize in the current scope
 * customElements.define('your-tag-name', class extends ChartJsComponent {});
 * ```
 * ## Basic markup
 *
 * ```tsx
 * <your-tag-name chart-type="bar" .config="${someChartData}">
 * </your-tag-name>
 * ```
 * @element base-chart
 */
export class ChartJsComponent extends LitElement {
	/**
	 * This is the type based on the data in the chart-js typing.
	 * @attr chart-type
	 * @type {ChartType}
	 * @default undefined
	 */
	@property({ type: String, attribute: "chart-type" })
	chartType: ChartType | undefined;

	/**
	 * This is the chart config based on the chart JS configuration options in their site and documentation. Currently supported types are bar, pie, and doughnut. More are coming.
	 * @attr chart-config
	 * @type {Object} The structure of this typing is polymorphic and changes based on the type of chart that you want to generate.
	 * @default undefined
	 */
	@property({ type: Object, attribute: "chart-config" })
	config: ChartConfiguration | undefined;

	@state()
	chart: Chart | undefined;

	@query("canvas")
	canvasElement: HTMLCanvasElement | undefined;

	protected firstUpdated(_changedProperties: PropertyValues): void {
		const ctx = this.canvasElement?.getContext("2d") as ChartItem;

		let data = this.config;

		if (!data) {
			switch (this.chartType) {
				case "bar":
					data = { ...SAMPLE_BAR_DATA };
					break;
				case "pie":
					data = { ...SAMPLE_PIE_DATA };
					break;
				case "doughnut":
					data = { ...SAMPLE_DOUGHNUT_DATA };
					break;
				default:
					break;
			}
		}

		this.chart = new Chart(ctx, { ...data } as ChartConfiguration);
	}

	render(): HTMLTemplateResult {
		return html`<canvas></canvas>`;
	}
}
