import { type HTMLTemplateResult, html, LitElement } from "lit";
import { customElement } from "lit/decorators.js";
import { ViteLogo } from "../../components/card/vite-logo.svg";
import { ViewMixin } from "../view.mixin";
import { CardPageStyles } from "./card-page.styles";

@customElement("card-examples")
export class CardExamples extends ViewMixin(LitElement) {
	featureIsEnabled = false;
	isMfe = false;

	static styles = [CardPageStyles];

	render(): HTMLTemplateResult {
		return this.renderMfe(
			html`isMfe = ${this.isMfe}
        <div class="card-container">
          <generic-card
            img-src="https://images.rawpixel.com/image_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIzLTA4L3Jhd3BpeGVsX29mZmljZV8xNV9waG90b19vZl9hX2RvZ19ydW5uaW5nX3dpdGhfb3duZXJfYXRfcGFya19lcF9mM2I3MDQyZC0zNWJlLTRlMTQtOGZhNy1kY2Q2OWQ1YzQzZjlfMi5qcGc.jpg"
            img-alt="doggo"
            img-width="90%"
          >
            <div slot="card-title">
              <h2>This is a Default Card</h2>
            </div>
            This is in the default slot
            <div slot="card-footer">
              <p>This is in the card-footer</p>
            </div>
          </generic-card>
          <generic-card
            img-src="https://images.rawpixel.com/image_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIzLTA4L3Jhd3BpeGVsX29mZmljZV8xNV9waG90b19vZl9hX2RvZ19ydW5uaW5nX3dpdGhfb3duZXJfYXRfcGFya19lcF9mM2I3MDQyZC0zNWJlLTRlMTQtOGZhNy1kY2Q2OWQ1YzQzZjlfMi5qcGc.jpg"
            img-alt="doggo"
            img-width="90%"
            card-variant="no-outline-column"
            card-interactive
            @card-clicked="${this.listenForClicks}"
          >
            <div slot="card-title">
              <h2>This is a default image</h2>
            </div>
            With a no-outline-column (default slot)
            <div slot="card-footer">
              <p>This is in the card-footer</p>
            </div>
          </generic-card>
          <generic-card
            .litSvg="${ViteLogo}"
            card-disabled
            card-interactive
            img-src="https://images.rawpixel.com/image_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIzLTA4L3Jhd3BpeGVsX29mZmljZV8xNV9waG90b19vZl9hX2RvZ19ydW5uaW5nX3dpdGhfb3duZXJfYXRfcGFya19lcF9mM2I3MDQyZC0zNWJlLTRlMTQtOGZhNy1kY2Q2OWQ1YzQzZjlfMi5qcGc.jpg"
            img-alt="doggo"
            img-width="5rem"
            img-height="5rem"
            card-variant="no-outline-row"
            img-avatar
            @card-clicked="${this.listenForClicks}"
          >
            <div slot="card-title">
              <h2>This is an avatar image card with a lit svg passed in</h2>
            </div>
            with a no-outline-row variant (default slot)
            <div slot="card-footer">This is in the card-footer</div>
          </generic-card>
          <generic-card
            card-variant="no-outline-column"
            img-src="https://images.rawpixel.com/image_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIzLTA4L3Jhd3BpeGVsX29mZmljZV8xNV9waG90b19vZl9hX2RvZ19ydW5uaW5nX3dpdGhfb3duZXJfYXRfcGFya19lcF9mM2I3MDQyZC0zNWJlLTRlMTQtOGZhNy1kY2Q2OWQ1YzQzZjlfMi5qcGc.jpg"
            img-alt="doggo"
            img-height="5rem"
            img-width="5rem"
            img-avatar
            card-navigation
            card-navigation-href="/chart-examples"
            @card-clicked="${this.listenForClicks}"
          >
            <div slot="card-title">
              <h2>This is a Card with an Avatar Image</h2>
            </div>
            with no-outline-column variant (default slot)
            <div slot="card-footer">
              <p>This is in the card-footer</p>
            </div>
          </generic-card>
        </div>`,
		);
	}

	listenForClicks(e: CustomEvent<{ id: string; data: string }>): void {
		console.log("item clicked", e.detail);
	}
}
