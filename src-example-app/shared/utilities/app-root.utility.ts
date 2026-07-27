import type { NavItem } from "../interfaces/navigation.interface";

export namespace AppRootUtilities {
	/**
	 *
	 * @param fullNavList An array of all NavItems configured for the application
	 * @param notAlowedRouteList An array of items that may not be allowed access for the current user.
	 * @returns {navItems, notAllowed}
	 */
	export function getNotAllowedRoutes(
		fullNavList: NavItem[],
		notAlowedRouteList: NavItem[],
	) {
		const notAllowed: NavItem[] = [];
		const navItems = fullNavList.filter((item) => {
			if (item.userHasPermission) {
				return true;
			}

			notAllowed.push(item);
			return false;
		});

		return {
			navItems,
			notAllowed: [...notAlowedRouteList, ...notAllowed],
		};
	}
}
