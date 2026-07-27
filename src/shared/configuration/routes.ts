import type { IconType, NavItem } from "../interfaces/navigation.interface";
import type { MfeItem } from "../utilities/mfe-loader.utility";
import { MFE_LOADER_CONFIG } from "./mfes";

export const getAccessPermissions = (
	item: NavItem,
	accesses: string[],
): boolean => item.levelOfAccess.some((access) => accesses.includes(access));

export const getMfeComponent = (
	internalTagName: string,
): MfeItem | undefined => {
	const mfe = MFE_LOADER_CONFIG.filter(
		(mfe: MfeItem) => mfe.associatedInternalTag === internalTagName,
	);

	return mfe.length > 0 ? mfe[0] : undefined;
};

export const routesBuilt = (
	navItems: NavItem[],
	accesses: string[],
): NavItem[] => {
	return navItems.map((navItem: NavItem) => ({
		...navItem,
		icon: navItem.icon || ("" as IconType),
		mfeComponent: getMfeComponent(navItem.tagName),
		userHasPermission: getAccessPermissions(navItem, accesses),
		children: navItem.children?.map((child: NavItem) => ({
			...child,
			icon: child.icon || ("" as IconType),
			userHasPermission: getAccessPermissions(navItem, accesses),
		})),
	}));
};
