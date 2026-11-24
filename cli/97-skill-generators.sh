# ------------------------------------------------------------------------------
# Project skills: scaffolding recipes that match this app's file conventions
# ------------------------------------------------------------------------------
log_info "Generating project skills..."

mkdir -p .agents/skills/create-component
cat <<'EOF' > .agents/skills/create-component/SKILL.md
---
name: create-component
description: Create a new reusable Lit web component in src/components using the project's three-file pattern (class file, styles file, registration file). Use whenever a new custom element, widget or UI building block is needed.
---

# Create a Lit component

Every component in this project is split across three files named after its tag.
For a tag `my-card`:

| File | Holds |
| :--- | :--- |
| `src/components/my-card/MyCard.ts` | The `MyCard` class. No registration. |
| `src/components/my-card/my-card.styles.ts` | ``export const MyCardStyles = css`...` `` |
| `src/components/my-card/my-card.ts` | `customElements.define("my-card", MyCard)` and the tag-name map entry. |

Other code imports the registration file (`my-card.ts`), never the class file, so
the element is defined exactly once and only where it is used.

## Steps

1. **Name it.** The tag is lowercase kebab-case with at least one hyphen
   (`my-card`, `user-avatar`). The class is the PascalCase of the tag (`MyCard`)
   and the styles constant is the class name plus `Styles` (`MyCardStyles`).
   Check `src/components` first: reuse or extend an existing component rather
   than adding a near-duplicate.
2. **Pick the folder.** Use `src/components/<tag>/`. Closely related components
   can share a parent folder (`src/components/todos/todo-item/`), but each still
   gets its own folder and three files. Create `src/components` if it is missing.
3. **Write the styles file** `<tag>.styles.ts`:

   ```ts
   import { css } from "lit";

   export const MyCardStyles = css`
     :host {
       display: block;
     }
   `;
   ```

   Use the theme's CSS custom properties from `src/index.css` (for example
   `var(--primary-text-color)`) instead of hard-coded colors so light and dark
   themes keep working. Never put a `css` block inline in the class file.

4. **Write the class file** `<PascalName>.ts`:

   ```ts
   import { html, LitElement, type CSSResultOrNative, type HTMLTemplateResult } from "lit";
   import { property } from "lit/decorators.js";
   import { MyCardStyles } from "./my-card.styles";

   /**
    * A short description of what the component is for.
    *
    * @element my-card
    * @slot - Default slot for the card body.
    * @fires my-card-selected - Fired when the card is activated.
    */
   export class MyCard extends LitElement {
     static styles: CSSResultOrNative[] = [MyCardStyles];

     /**
      * The heading shown at the top of the card.
      * @attr card-title
      */
     @property({ type: String, attribute: "card-title" })
     cardTitle = "";

     private _select(): void {
       this.dispatchEvent(
         new CustomEvent("my-card-selected", { bubbles: true, composed: true, detail: { title: this.cardTitle } }),
       );
     }

     render(): HTMLTemplateResult {
       return html`<button type="button" @click=${this._select}>${this.cardTitle}</button><slot></slot>`;
     }
   }
   ```

   - Do not use the `@customElement` decorator here; registration lives in the
     registration file. (Views in `src/views` are the exception and use it.)
   - Public inputs are `@property` with an explicit kebab-case `attribute`;
     internal state is `@state`. Give every property a default.
   - Custom events use `bubbles: true, composed: true` so they cross shadow roots,
     and are documented with `@fires`.
   - Document `@element`, `@slot`, `@fires` and each `@attr` in JSDoc, as the
     existing components do.
   - Clean up anything added in `connectedCallback` (listeners, timers,
     subscriptions) in `disconnectedCallback`.

5. **Write the registration file** `<tag>.ts`:

   ```ts
   import { MyCard } from "./MyCard";

   customElements.define("my-card", MyCard);

   declare global {
     interface HTMLElementTagNameMap {
       "my-card": MyCard;
     }
   }
   ```

6. **Use it.** Import the registration file where the element is rendered, for
   example from a view: `import "../../components/my-card/my-card";`. Then use
   `<my-card card-title="Hello"></my-card>`.
7. **Check it.** Run the project's `fmt`, `lint`, `build` and `test` scripts. For
   behavior worth covering, add a focused test (the test-expert agent covers the
   fixture setup).

## Checklist

- [ ] Three files: `PascalName.ts`, `<tag>.styles.ts`, `<tag>.ts`, in `src/components/<tag>/`.
- [ ] Class file has no `customElements.define` and no `@customElement`.
- [ ] Styles come only from `<tag>.styles.ts` and use theme custom properties.
- [ ] Consumers import `<tag>.ts`, not the class file.
- [ ] fmt, lint, build and test pass.
EOF

if [ "$ENABLE_ROUTER" = true ]; then
mkdir -p .agents/skills/create-view
cat <<'EOF' > .agents/skills/create-view/SKILL.md
---
name: create-view
description: Add a new routed page (view) to the app using ViewMixin, with its styles file and its entry in src/shared/configuration/nav.ts. Use whenever a new page, screen or route is needed.
---

# Create a routed view

Pages live in `src/views` and extend `ViewMixin(LitElement)` from
`src/views/view.mixin.ts`. The mixin wires the view to the navigation, access and
MFE contexts and gives it `renderMfe()`, which shows the page only when the user
has access and the feature is enabled. The app shell lazy-loads each view from
its entry in `src/shared/configuration/nav.ts`.

For a page with tag `reports-page`:

| File | Holds |
| :--- | :--- |
| `src/views/reports-page/reports-page.ts` | The `ReportsPage` view, registered with `@customElement`. |
| `src/views/reports-page/reports-page.styles.ts` | ``export const ReportsPageStyles = css`...` `` |
| `src/shared/configuration/nav.ts` | A `NavItem` entry that routes `/reports-page` to the view. |

## Steps

1. **Name it.** Lowercase kebab-case tag with a hyphen (`reports-page`); the class
   is its PascalCase (`ReportsPage`). The folder, the file and the tag all use
   the same name, because the shell imports
   `./views/${directory}/${component}.ts` and renders `<${tagName}>`.
2. **Write the styles file** `src/views/<tag>/<tag>.styles.ts`:

   ```ts
   import { css } from "lit";

   export const ReportsPageStyles = css`
     :host {
       display: block;
       padding: 2rem;
     }
   `;
   ```

3. **Write the view** `src/views/<tag>/<tag>.ts`:

   ```ts
   import { type HTMLTemplateResult, html, LitElement } from "lit";
   import { customElement } from "lit/decorators.js";
   import { ViewMixin } from "../view.mixin";
   import { ReportsPageStyles } from "./reports-page.styles";
   import "../../components/my-card/my-card";

   @customElement("reports-page")
   export class ReportsPage extends ViewMixin(LitElement) {
     tagName = "reports-page";
     featureIsEnabled = true;
     isMfe = false;

     static styles = [ReportsPageStyles];

     render(): HTMLTemplateResult {
       return this.renderMfe(html`
         <h1>Reports</h1>
         <my-card card-title="Monthly"></my-card>
       `);
     }
   }
   ```

   - `tagName` must equal the `@customElement` name and the nav entry's `tagName`;
     the mixin finds the page's nav entry (and its permission) by it.
   - Wrap the content in ``this.renderMfe(html`...`)``. With
     `featureIsEnabled = false` the page shows the under-construction view
     instead, which is how a page is shipped dark.
   - Keep the page thin: build reusable pieces as components (see the
     create-component skill) and import their registration files.
   - Put styles in the styles file, not inline `css` in the view.

4. **Register the route** in `src/shared/configuration/nav.ts`. Add to
   `navigationRouting` for a page shown in the header navigation, or to
   `sidePages` for a routed page that is not in the navigation (a detail page):

   ```ts
   {
     name: "Reports",
     path: "/reports-page",
     directory: "reports-page",
     component: "reports-page",
     filePath: "../../views/reports-page/reports-page.ts",
     levelOfAccess: ["public"],
     tagName: "reports-page",
     isMfe: false,
   },
   ```

   - `path` starts with `/` and does not include the deploy base path; the shell
     adds it with `withBase()`.
   - `directory` is the folder, `component` is the file name without `.ts`.
   - `levelOfAccess` lists the accesses that may open the page. A user without a
     matching access gets the no-access view; `["public"]` is open to everyone.
   - The first entry in `navigationRouting` is where `/` redirects.

5. **Check it.** Run the project's `fmt`, `lint`, `build` and `test` scripts, then
   start the dev server and open the new path, including a direct load of the URL
   (not only navigating from another page).

## Checklist

- [ ] `src/views/<tag>/<tag>.ts` and `<tag>.styles.ts`, folder and file named after the tag.
- [ ] View extends `ViewMixin(LitElement)`, sets `tagName`, `featureIsEnabled`, `isMfe`, and renders through `renderMfe`.
- [ ] Nav entry's `directory`, `component` and `tagName` all match the tag.
- [ ] The page loads from a direct URL and from the navigation.
EOF
fi

if [ "$ENABLE_SIGNALS" = true ]; then
mkdir -p .agents/skills/create-signal-store
cat <<'EOF' > .agents/skills/create-signal-store/SKILL.md
---
name: create-signal-store
description: Add shared application state as a Preact-signals store in src/shared/stores, optionally persisted to IndexedDB with persistentSignal, and connect components to it with SignalWatcher. Use when state must be shared between components or survive a reload.
---

# Create a signal store

Shared state lives in `src/shared/stores/<name>.store.ts` as signals from
`@lit-labs/preact-signals`. `src/shared/stores/persistent-signal.ts` provides
`persistentSignal()`, which saves a signal's value to IndexedDB under a key and
restores it on load. The todo stores (`todo.store.ts`, `todo-list.store.ts`) are
the reference implementation.

## Steps

1. **Type the data** in `src/shared/interfaces/<name>.interface.ts`:

   ```ts
   export interface IFavorite {
     id: string;
     label: string;
   }
   ```

2. **Write the store** `src/shared/stores/<name>.store.ts`:

   ```ts
   import { computed, signal } from "@lit-labs/preact-signals";
   import type { IFavorite } from "../interfaces/favorites.interface";
   import { persistentSignal } from "./persistent-signal";

   // Persisted: survives a reload. The key must be unique across all stores.
   export const favoritesSignal = persistentSignal<IFavorite[]>([], { key: "favorites" });

   // Transient: resets on reload.
   export const favoritesFilterSignal = signal("");

   // Derived values use computed, never a copy kept in sync by hand.
   export const visibleFavoritesSignal = computed(() =>
     favoritesSignal.value.filter((f) => f.label.includes(favoritesFilterSignal.value)),
   );

   export const addFavorite = (label: string): string => {
     const id = crypto.randomUUID();
     favoritesSignal.value = [...favoritesSignal.value, { id, label }];
     return id;
   };

   export const removeFavorite = (id: string): void => {
     favoritesSignal.value = favoritesSignal.value.filter((f) => f.id !== id);
   };
   ```

   - Export small action functions and change state only through them.
   - Always assign a new array or object to `.value`; mutating the existing value
     in place does not notify subscribers and is not persisted.
   - Use `persistentSignal` only for state that should survive a reload, and give
     each one a unique `key`. Persisted values must be structured-cloneable (no
     functions, class instances or DOM nodes).

3. **Connect components.** A component that reads signals extends
   `SignalWatcher(LitElement)` and reads `.value` in `render()`; it re-renders when
   those signals change. Call the action functions from event handlers:

   ```ts
   import { SignalWatcher } from "@lit-labs/preact-signals";
   import { html, LitElement } from "lit";
   import { addFavorite, visibleFavoritesSignal } from "../../shared/stores/favorites.store";

   export class FavoritesList extends SignalWatcher(LitElement) {
     render() {
       return html`
         <button type="button" @click=${() => addFavorite("New favorite")}>Add</button>
         <ul>${visibleFavoritesSignal.value.map((f) => html`<li>${f.label}</li>`)}</ul>
       `;
     }
   }
   ```

   Build the component itself with the create-component skill (class, styles and
   registration files).

4. **Check it.** Run the project's `fmt`, `lint`, `build` and `test` scripts. For a
   persisted store, change the state in the running app, reload, and confirm it
   is restored.

## Checklist

- [ ] Data types in `src/shared/interfaces`, store in `src/shared/stores/<name>.store.ts`.
- [ ] State changes only through exported actions that assign new values.
- [ ] Every `persistentSignal` has a unique key.
- [ ] Components that read signals extend `SignalWatcher(LitElement)`.
EOF
fi

# Point AGENTS.md (and the CLAUDE.md / GEMINI.md links to it) at the conventions
# and at the skills this template actually generated.
{
  cat <<'EOF'

## Code conventions

- Components: one folder per component in src/components, named after its tag,
  with three files. `my-card.ts` registers the element, `MyCard.ts` holds the
  class, and `my-card.styles.ts` holds its styles. Import the registration file
  where the element is used. See the create-component skill.
EOF
  if [ "$ENABLE_ROUTER" = true ]; then
    cat <<'EOF'
- Views: pages in src/views/<tag>/ extend ViewMixin(LitElement), keep styles in
  `<tag>.styles.ts`, render through renderMfe(), and are routed by an entry in
  src/shared/configuration/nav.ts. See the create-view skill.
EOF
  fi
  if [ "$ENABLE_SIGNALS" = true ]; then
    cat <<'EOF'
- Shared state: signal stores in src/shared/stores, persisted with
  persistentSignal where it must survive a reload; components that read signals
  extend SignalWatcher(LitElement). See the create-signal-store skill.
EOF
  fi
  cat <<'EOF'

## Skills

Use these skills from .agents/skills when the task matches:

- create-component: a new reusable Lit component.
EOF
  if [ "$ENABLE_ROUTER" = true ]; then
    echo "- create-view: a new routed page."
  fi
  if [ "$ENABLE_SIGNALS" = true ]; then
    echo "- create-signal-store: new shared or persisted state."
  fi
} >> AGENTS.md
