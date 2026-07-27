import type { MfeItem } from "../utilities/mfe-loader.utility";

export const MFE_LOADER_CONFIG: MfeItem[] = [
	{
		mfeBundleUrl:
			"https://quincarter.github.io/my-coffee-app/assets/coffee-users-PQOfY16o.js",
		scriptType: "module",
		isAsync: false,
		defer: false,
		crossOrigin: "anonymous",
		tagName: "coffee-users",
		associatedInternalTag: "home-page",
	},
	{
		mfeBundleUrl:
			"https://quincarter.github.io/vite-test-my-element-mfe/assets/index-DVYAdQcO.js",
		scriptType: "module",
		isAsync: false,
		defer: false,
		crossOrigin: "anonymous",
		tagName: "my-element",
		associatedInternalTag: "vite-mfe",
	},
];
