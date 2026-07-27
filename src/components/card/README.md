# generic-card

# Generic Card Component
This is a generic card component with multiple variants available for use to give a different look/feel on the page.
## Usage

```typescript
import { GenericCard } from 'path/to/GenericCard.ts';

// doing class extends prevents the GenericCard constructor from failing to initialize in the current scope
customElements.define('your-tag-name', class extends GenericCard {});
```

## Basic markup

```html
<your-tag-name>
  <div slot="card-title">
    This is a card title
  </div>
  <div>
    This is a default slot
  </div>
  <div slot="card-footer">
    This is in the footer
  </div>
</your-tag-name>
```

## Properties

| Property         | Attribute              | Type                             | Default                                          | Description                                      |
|------------------|------------------------|----------------------------------|--------------------------------------------------|--------------------------------------------------|
| `avatar`         | `img-avatar`           | `Boolean`                        | "false"                                          | If attached to the element, this will make the img tag be circular like an avatar |
| `cardClickEvent` | `card-click-callback`  | `(e: any) => void`               | "e => {\n    e.preventDefault();\n    e.stopPropagation();\n    const clickEvent = new CustomEvent('card-clicked', {\n      bubbles: true,\n      composed: true,\n      detail: { id: e.currentTarget.id, data: 'this card was clicked' },\n    });\n\n    this.shadowRoot?.dispatchEvent(clickEvent);\n  }" |                                                  |
| `cardId`         | `card-id`              | `String`                         | "''"                                             | Sets the ID for the card internally              |
| `disabled`       | `card-disabled`        | `Boolean`                        | "false"                                          | If attached to the element, this disables the card from any interaction. |
| `imgAlt`         | `img-alt`              | `String`                         | "'card-img'"                                     | Sets the alt text for the <img> tag for accessibility reasons. |
| `imgHeight`      | `img-height`           | `String`                         | "'inherit'"                                      | Sets the height of the image.                    |
| `imgSrc`         | `img-src`              | `String`                         | "''"                                             | Sets the path for the image to be displayed      |
| `imgWidth`       | `img-width`            | `String`                         | "'inherit'"                                      | Sets the width of the image                      |
| `interactive`    | `card-interactive`     | `Boolean`                        | "false"                                          | If attached to the element, this makes the card appear to be clickable. |
| `litSvg`         | `lit-svg`              | `SVGTemplateResult \| undefined` |                                                  |                                                  |
| `navigation`     | `card-navigation`      | `Boolean`                        | "false"                                          | If attached to the element, this makes the card appear to be clickable and allows navigation to occur. This will show as a <a href=""></a> under the hood and a path will need to be provided in the element implementation. |
| `navigationHref` | `card-navigation-href` | `String`                         | "false"                                          | If attached to the element, this will assign the href to the card itself ready for navigation |
| `variant`        | `card-variant`         | `CardVariant`                    | "default"                                        | Describes the variant displayed for the card     |

## Methods

| Method       | Type                     |
|--------------|--------------------------|
| `renderCard` | `(): HTMLTemplateResult` |

## Events

| Event          | Type                                      | Description                                      |
|----------------|-------------------------------------------|--------------------------------------------------|
| `card-clicked` | `CustomEvent<{ id: any; data: string; }>` | This event fires if 'card-interactive' is set on the element |

## Slots

| Name          | Description                                      |
|---------------|--------------------------------------------------|
|               | This is the card body and the default, unnamed slot. |
| `card-footer` | This is for the footer section of the card.      |
| `card-title`  | This is for the title section of the card.       |
