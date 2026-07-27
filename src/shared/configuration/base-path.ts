const raw = import.meta.env.BASE_URL ?? "/";

/** Base path without trailing slash, e.g. '' or '/app-shell-starter' */
export const BASE_PATH = raw.endsWith("/") ? raw.slice(0, -1) : raw;

/** Prefix a path with the configured base, e.g. '/home' → '/app-shell-starter/home' */
export const withBase = (path: string): string => {
	const normalized = path.startsWith("/") ? path : `/${path}`;
	return `${BASE_PATH}${normalized}`;
};
