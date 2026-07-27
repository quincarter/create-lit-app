import {
	type CSSResultOrNative,
	type HTMLTemplateResult,
	html,
	LitElement,
	nothing,
	type SVGTemplateResult,
} from "lit";
import { property } from "lit/decorators.js";
import { styleMap } from "lit/directives/style-map.js";
import { GenericCardStyles } from "./generic-card.styles";

export type CardVariant = "default" | "no-outline-column" | "no-outline-row";

/**
 * # Generic Card Component
 * This is a generic card component with multiple variants available for use to give a different look/feel on the page.
 * ## Usage
 *
 * ```typescript
 * import { GenericCard } from 'path/to/GenericCard.ts';
 *
 * // doing class extends prevents the GenericCard constructor from failing to initialize in the current scope
 * customElements.define('your-tag-name', class extends GenericCard {});
 * ```
 *
 * ## Basic markup
 *
 * ```html
 * <your-tag-name>
 *   <div slot="card-title">
 *     This is a card title
 *   </div>
 *   <div>
 *     This is a default slot
 *   </div>
 *   <div slot="card-footer">
 *     This is in the footer
 *   </div>
 * </your-tag-name>
 * ```
 *
 * @element generic-card
 *
 * @slot card-title - This is for the title section of the card.
 * @slot - This is the card body and the default, unnamed slot.
 * @slot card-footer - This is for the footer section of the card.
 *
 * @fires card-clicked - This event fires if 'card-interactive' is set on the element
 */
export class GenericCard extends LitElement {
	static styles: CSSResultOrNative[] = [GenericCardStyles];

	/**
	 * Describes the variant displayed for the card
	 * @attr card-variant
	 * @type {CardVariant} 'default' | 'no-outline-column' | 'no-outline-row'
	 * @default default
	 */
	@property({ type: String, attribute: "card-variant" })
	variant: CardVariant = "default";

	@property({ type: Array, attribute: "lit-svg" })
	litSvg: SVGTemplateResult | undefined;

	/**
	 * Sets the path for the image to be displayed
	 * @attr img-src
	 * @type {String}
	 * @default ''
	 */
	@property({ type: String, attribute: "img-src" })
	imgSrc = "";

	/**
	 * Sets the ID for the card internally
	 * @attr card-id
	 * @type {String}
	 * @default ''
	 */
	@property({ type: String, attribute: "card-id" })
	cardId = "";

	/**
	 * Sets the alt text for the <img> tag for accessibility reasons.
	 * @attr img-alt
	 * @type {String}
	 * @default 'card-img'
	 */
	@property({ type: String, attribute: "img-alt" })
	imgAlt = "card-img";

	/**
	 * Sets the height of the image.
	 * @attr img-height
	 * @type {String}
	 * @default 'inherit'
	 */
	@property({ type: String, attribute: "img-height" })
	imgHeight = "inherit";

	/**
	 * Sets the width of the image
	 * @attr img-width
	 * @type {String}
	 * @default 'inherit'
	 */
	@property({ type: String, attribute: "img-width" })
	imgWidth = "inherit";

	/**
	 * If attached to the element, this disables the card from any interaction.
	 * @attr card-disabled
	 * @type {Boolean}
	 * @default false
	 */
	@property({ type: Boolean, attribute: "card-disabled" })
	disabled = false;

	/**
	 * If attached to the element, this will make the img tag be circular like an avatar
	 * @attr img-avatar
	 * @type {Boolean}
	 * @default false
	 */
	@property({ type: Boolean, attribute: "img-avatar" })
	avatar = false;

	/**
	 * If attached to the element, this makes the card appear to be clickable.
	 * @attr card-interactive
	 * @type {Boolean}
	 * @default false
	 */
	@property({ type: Boolean, attribute: "card-interactive" })
	interactive = false;

	/**
	 * If attached to the element, this makes the card appear to be clickable and allows navigation to occur. This will show as a <a href=""></a> under the hood and a path will need to be provided in the element implementation.
	 * @attr card-navigation
	 * @type {Boolean}
	 * @default false
	 */
	@property({ type: Boolean, attribute: "card-navigation" })
	navigation = false;

	/**
	 * If attached to the element, this will assign the href to the card itself ready for navigation
	 * @attr card-navigation-href
	 * @type {String}
	 * @default false
	 */
	@property({ type: String, attribute: "card-navigation-href" })
	navigationHref = "";

	@property({ type: Object, attribute: "card-click-callback" })
	cardClickEvent: (e: Event) => void = (e) => {
		e.preventDefault();
		e.stopPropagation();
		const clickEvent = new CustomEvent("card-clicked", {
			bubbles: true,
			composed: true,
			detail: {
				id: (e.currentTarget as HTMLElement).id,
				data: "this card was clicked",
			},
		});

		this.shadowRoot?.dispatchEvent(clickEvent);
	};

	renderCard(): HTMLTemplateResult {
		return html`<div
      @click="${
				this.interactive && !this.disabled ? this.cardClickEvent : () => {}
			}"
      id="${this.cardId ? this.cardId : `card-${this.variant}`}"
      class="card-wrapper ${this.variant} ${
				this.disabled ? "disabled" : ""
			} ${this.interactive ? "interactive" : ""}"
    >
      ${
				this.imgSrc && !this.litSvg
					? html`<img
            class="${this.variant} ${this.avatar ? "avatar" : ""}"
            src="${this.imgSrc}"
            alt="${this.imgAlt}"
            style="${styleMap({
							height: this.imgHeight,
							width: this.imgWidth,
						})}"
          />`
					: nothing
			}
      ${this.litSvg ? html`${this.litSvg}` : nothing}
      <div class="card ${this.disabled ? "disabled" : ""}">
        <slot name="card-title"></slot>
        <slot></slot>
        <slot name="card-footer"></slot>
      </div>
    </div>`;
	}

	render(): HTMLTemplateResult {
		return html`${
			this.navigation && this.navigationHref
				? html`<a href="${this.navigationHref}">${this.renderCard()}</a>`
				: html`${this.renderCard()}`
		}`;
	}
}
