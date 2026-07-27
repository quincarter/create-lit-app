import colorLib, { type Color, type RGBA } from "@kurkle/color";
import { DateTime } from "luxon";
import "chartjs-adapter-luxon";

// Adapted from http://indiegamr.com/generate-repeatable-random-numbers-in-js/
var _seed = Date.now();

export function srand(seed: number) {
	_seed = seed;
}

/**
 * Returns `value` if defined, else returns `defaultValue`.
 * @param value - The value to return if defined.
 * @param defaultValue - The value to return if `value` is undefined.
 */
export function valueOrDefault<T>(value: T | undefined, defaultValue: T) {
	return typeof value === "undefined" ? defaultValue : value;
}

export function rand(min?: number, max?: number) {
	min = valueOrDefault(min, 0);
	max = valueOrDefault(max, 0);
	_seed = (_seed * 9301 + 49297) % 233280;
	return min + (_seed / 233280) * (max - min);
}

export function numbers(config: Record<string, unknown>) {
	const cfg = config || {};
	const min = valueOrDefault(cfg.min as number, 0);
	const max = valueOrDefault(cfg.max as number, 100);
	const from = valueOrDefault(cfg.from as number[], []);
	const count = valueOrDefault(cfg.count as number, 8);
	const decimals = valueOrDefault(cfg.decimals as number, 8);
	const continuity = valueOrDefault(cfg.continuity as number, 1);
	const dfactor = 10 ** decimals || 0;
	const data = [];

	for (let i = 0; i < count; ++i) {
		const value = (from[i] || 0) + rand(min, max);
		if (rand() <= continuity) {
			data.push(Math.round(dfactor * value) / dfactor);
		} else {
			data.push(null);
		}
	}

	return data;
}

interface Point {
	x: number;
	y: number | null;
	r?: number;
}

export function points(config: Record<string, unknown>): Point[] {
	const xs = numbers(config);
	const ys = numbers(config);
	return xs.map((x: number | null, i: number) => ({
		x: x as number,
		y: ys[i],
	}));
}

export function bubbles(
	config: { rmin: number; rmax: number } & Record<string, unknown>,
) {
	return points(config).map((pt: Point) => {
		pt.r = rand(config.rmin, config.rmax);
		return pt;
	});
}

export function labels(config: Record<string, unknown>) {
	const cfg = config || {};
	const min = (cfg.min as number) || 0;
	const max = (cfg.max as number) || 100;
	const count = (cfg.count as number) || 8;
	const step = (max - min) / count;
	const decimals = (cfg.decimals as number) || 8;
	const dfactor = 10 ** decimals || 0;
	const prefix = (cfg.prefix as string) || "";
	const values = [];

	for (let i = min; i < max; i += step) {
		values.push(prefix + Math.round(dfactor * i) / dfactor);
	}

	return values;
}

const MONTHS = [
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December",
];

export function months(config: Record<string, unknown>) {
	const cfg = config || {};
	const count = (cfg.count as number) || 12;
	const section = cfg.section as number | undefined;
	const values = [];

	for (let i = 0; i < count; ++i) {
		const value = MONTHS[Math.ceil(i) % 12];
		values.push(value.substring(0, section));
	}

	return values;
}

const COLORS = [
	"#4dc9f6",
	"#f67019",
	"#f53794",
	"#537bc4",
	"#acc236",
	"#166a8f",
	"#00a950",
	"#58595b",
	"#8549ba",
];

export function color(index: number) {
	return COLORS[index % COLORS.length];
}

export function transparentize(
	value: string | number[] | Color | RGBA,
	opacity: number | undefined,
) {
	var alpha = opacity === undefined ? 0.5 : 1 - opacity;
	return colorLib(value).alpha(alpha).rgbString();
}

export const CHART_COLORS = {
	red: "rgb(255, 99, 132)",
	orange: "rgb(255, 159, 64)",
	yellow: "rgb(255, 205, 86)",
	green: "rgb(75, 192, 192)",
	blue: "rgb(54, 162, 235)",
	purple: "rgb(153, 102, 255)",
	grey: "rgb(201, 203, 207)",
};

const NAMED_COLORS = [
	CHART_COLORS.red,
	CHART_COLORS.orange,
	CHART_COLORS.yellow,
	CHART_COLORS.green,
	CHART_COLORS.blue,
	CHART_COLORS.purple,
	CHART_COLORS.grey,
];

export function namedColor(index: number) {
	return NAMED_COLORS[index % NAMED_COLORS.length];
}

export function newDate(days: number) {
	return DateTime.now().plus({ days }).toJSDate();
}

export function newDateString(days: number) {
	return DateTime.now().plus({ days }).toISO();
}

export function parseISODate(str: string) {
	return DateTime.fromISO(str);
}
