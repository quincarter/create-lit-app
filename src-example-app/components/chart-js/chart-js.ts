import { ChartJsComponent } from "./ChartJs";

if (!customElements.get("base-chart")) {
	customElements.define("base-chart", ChartJsComponent);
}
