export type CrossoriginType = "anonymous" | "use-credentials" | "";

export interface MfeItem {
	mfeBundleUrl: string;
	scriptType: string;
	isAsync: boolean;
	defer: boolean;
	crossOrigin: CrossoriginType;
	tagName: string;
	associatedInternalTag?: string;
}

export class MfeLoader {
	public config: MfeItem[];

	constructor(mfeConfig: MfeItem[]) {
		this.config = mfeConfig;
	}

	init(): void {
		this.config.forEach(async (configItem) => {
			await this.createLink(configItem);
			await this.createScript(configItem);
		});
	}

	private async createScript(configItem: MfeItem): Promise<void> {
		if (!document.querySelector(`#mfe-${configItem.tagName}`)) {
			const script = document.createElement("script");
			script.src = configItem.mfeBundleUrl;
			script.type = configItem.scriptType;
			script.async = configItem.isAsync;
			script.defer = configItem.defer;
			script.crossOrigin = configItem.crossOrigin;
			script.id = `mfe-${configItem.tagName}`;
			await document.body.appendChild(script);
		}
	}

	private async createLink(configItem: MfeItem): Promise<void> {
		if (!document.querySelector(`#link-mfe-${configItem.tagName}`)) {
			const link = document.createElement("link");
			link.id = `link-mfe-${configItem.tagName}`;
			link.href = configItem.mfeBundleUrl;
			link.rel = "prefetch";
			link.as = "script";
			await document.head.appendChild(link);
		}
	}
}
