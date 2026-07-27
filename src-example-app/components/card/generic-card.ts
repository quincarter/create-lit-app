import { GenericCard } from "./GenericCard";

!customElements.get("generic-card") &&
	customElements.define("generic-card", GenericCard);
