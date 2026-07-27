import type {
	BarControllerChartOptions,
	BarControllerDatasetOptions,
	CartesianParsedData,
	ChartConfiguration,
	ChartTypeRegistry,
	DoughnutControllerChartOptions,
	DoughnutControllerDatasetOptions,
	DoughnutDataPoint,
	DoughnutMetaExtensions,
	PieControllerChartOptions,
	PieControllerDatasetOptions,
	PieDataPoint,
	PieMetaExtensions,
} from "chart.js/auto";

import * as Utils from "./chart-js.utility";

const pieData = {
	labels: ["Red", "Blue", "Yellow"],
	datasets: [
		{
			label: "Sample Pie Dataset",
			data: [300, 50, 100],
			backgroundColor: [
				"rgb(255, 99, 132)",
				"rgb(54, 162, 235)",
				"rgb(255, 205, 86)",
			],
			hoverOffset: 4,
		},
	],
};

const barLabels = Utils.months({ count: 7 });
const barData = {
	labels: barLabels,
	datasets: [
		{
			label: "My First Dataset",
			data: [65, 59, 80, 81, 56, 55, 40],
			backgroundColor: [
				"rgba(255, 99, 132, 0.2)",
				"rgba(255, 159, 64, 0.2)",
				"rgba(255, 205, 86, 0.2)",
				"rgba(75, 192, 192, 0.2)",
				"rgba(54, 162, 235, 0.2)",
				"rgba(153, 102, 255, 0.2)",
				"rgba(201, 203, 207, 0.2)",
			],
			borderColor: [
				"rgb(255, 99, 132)",
				"rgb(255, 159, 64)",
				"rgb(255, 205, 86)",
				"rgb(75, 192, 192)",
				"rgb(54, 162, 235)",
				"rgb(153, 102, 255)",
				"rgb(201, 203, 207)",
			],
			borderWidth: 1,
		},
	],
};

export const SAMPLE_PIE_DATA: ChartConfiguration = {
	type: "pie",
	data: { ...pieData },
};

export const SAMPLE_DOUGHNUT_DATA: ChartConfiguration = {
	type: "doughnut",
	data: { ...pieData },
};

export const SAMPLE_BAR_DATA: ChartConfiguration = {
	type: "bar",
	data: { ...barData },
	options: {
		scales: {
			y: {
				beginAtZero: true,
			},
		},
	},
};

interface BarParsedData extends CartesianParsedData {
	// Only specified if floating bars are show
	_custom?: {
		barStart: number;
		barEnd: number;
		start: number;
		end: number;
		min: number;
		max: number;
	};
}

// interface BubbleParsedData extends CartesianParsedData {
//   // The bubble radius value
//   _custom: number;
// }

// interface RadialParsedData {
//   r: number;
// }

export const CHART_TYPES_INITIAL_DATA: Partial<ChartTypeRegistry> = {
	bar: {
		chartOptions: {} as BarControllerChartOptions,
		datasetOptions: {} as BarControllerDatasetOptions,
		defaultDataPoint: null,
		metaExtensions: {},
		parsedDataType: {} as BarParsedData,
		scales: "linear",
	},
	pie: {
		chartOptions: {} as PieControllerChartOptions,
		datasetOptions: {} as PieControllerDatasetOptions,
		defaultDataPoint: {} as PieDataPoint,
		metaExtensions: {} as PieMetaExtensions,
		parsedDataType: 0,
		scales: "linear",
	},
	doughnut: {
		chartOptions: {} as DoughnutControllerChartOptions,
		datasetOptions: {} as DoughnutControllerDatasetOptions,
		defaultDataPoint: {} as DoughnutDataPoint,
		metaExtensions: {} as DoughnutMetaExtensions,
		parsedDataType: 0,
		scales: "linear",
	},
};
