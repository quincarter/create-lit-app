# ------------------------------------------------------------------------------
# Create src/app-shell.ts & src/app-shell.styles.ts
# ------------------------------------------------------------------------------
log_info "Generating App Shell root component..."

cat <<'EOF' > src/app-shell.styles.ts
import { css } from "lit";
export const AppShellStyles = css`
  :host { display: block; min-height: 100vh; }
  main { padding: 1rem; }
`;
EOF

IMPORTS="import { type HTMLTemplateResult, html, LitElement } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import { AppShellStyles } from './app-shell.styles';
import type { NavItem } from './shared/interfaces/navigation.interface';"

if [ "$ENABLE_CONTEXT" = true ]; then
  IMPORTS="$IMPORTS
import { provide } from '@lit/context';
import { AccessesContext } from './shared/contexts/accesses.context';
import { NavigationContext } from './shared/contexts/navigation.context';
import { MfeLoaderContext } from './shared/contexts/mfe-loader.context';"
fi

if [ "$ENABLE_ROUTER" = true ]; then
  IMPORTS="$IMPORTS
import { Router } from '@lit-labs/router';
import { html as staticHtml, unsafeStatic } from 'lit/static-html.js';
import 'urlpattern-polyfill';
import { navigationRouting } from './shared/configuration/nav';
import { routesBuilt } from './shared/configuration/routes';
import { withBase } from './shared/configuration/base-path';"
fi

if [ "$ENABLE_HEADER" = true ]; then
  IMPORTS="$IMPORTS
import './components/header/app-shell-header';"
fi

if [ "$ENABLE_MFE_LOADER" = true ]; then
  IMPORTS="$IMPORTS
import { MFE_LOADER_CONFIG } from './shared/configuration/mfes';
import { MfeLoader } from './shared/utilities/mfe-loader.utility';"
fi

cat <<EOF > src/app-shell.ts
$IMPORTS

@customElement("app-shell")
export class AppShell extends LitElement {
EOF

if [ "$ENABLE_CONTEXT" = true ]; then
cat <<EOF >> src/app-shell.ts
  @provide({ context: NavigationContext })
  @property({ type: Array })
  routing: NavItem[] = [];

  @provide({ context: AccessesContext })
  @property({ type: Array })
  accesses: string[] = ["public"];
EOF
  if [ "$ENABLE_MFE_LOADER" = true ]; then
cat <<EOF >> src/app-shell.ts
  @provide({ context: MfeLoaderContext })
  @state()
  mfeLoader = new MfeLoader(MFE_LOADER_CONFIG);
EOF
  fi
fi

if [ "$ENABLE_ROUTER" = true ]; then
cat <<EOF >> src/app-shell.ts
  private _router = new Router(this, []);
EOF
fi

cat <<EOF >> src/app-shell.ts

  static styles = [AppShellStyles];

  async connectedCallback(): Promise<void> {
    super.connectedCallback();
EOF

if [ "$ENABLE_ROUTER" = true ]; then
cat <<EOF >> src/app-shell.ts
    await this._setupRoutes();
EOF
fi

cat <<EOF >> src/app-shell.ts
  }
EOF

if [ "$ENABLE_ROUTER" = true ]; then
cat <<EOF >> src/app-shell.ts

  private async _setupRoutes(): Promise<void> {
    this.routing = routesBuilt(navigationRouting, ["public"]);
    const routeConfigs = this.routing.map((navItem) => ({
      path: withBase(navItem.path),
      enter: async () => {
        await import(\`./views/\${navItem.directory}/\${navItem.component}.ts\`);
        return true;
      },
      render: () => {
        const tag = unsafeStatic(navItem.tagName);
        return staticHtml\`<\${tag}></\${tag}>\`;
      },
    }));

    const firstPath = navigationRouting[0]?.path || "/home";
    const firstItem = navigationRouting[0];

    this._router.routes = [
      {
        path: withBase("/"),
        enter: async () => {
          window.history.replaceState({}, "", withBase(firstPath));
          if (firstItem) {
            await import(\`./views/\${firstItem.directory}/\${firstItem.component}.ts\`);
          }
          return true;
        },
        render: () => {
          const tag = unsafeStatic(firstItem?.tagName || "home-page");
          return staticHtml\`<\${tag}></\${tag}>\`;
        },
      },
      ...routeConfigs,
    ];

    const currentPath = window.location.pathname + window.location.search + window.location.hash;
    await this._router.goto(currentPath);
  }
EOF
fi

cat <<EOF >> src/app-shell.ts

  render(): HTMLTemplateResult {
    return html\`
EOF

if [ "$ENABLE_HEADER" = true ]; then
cat <<EOF >> src/app-shell.ts
      <app-shell-header .routes="\${this.routing}" enable-theme-switcher>
        <main>
EOF
else
cat <<EOF >> src/app-shell.ts
        <main>
EOF
fi

if [ "$ENABLE_ROUTER" = true ]; then
cat <<EOF >> src/app-shell.ts
          \${this._router.outlet()}
EOF
else
cat <<EOF >> src/app-shell.ts
          <h2>Welcome to $APP_NAME</h2>
EOF
fi

cat <<EOF >> src/app-shell.ts
        </main>
EOF

if [ "$ENABLE_HEADER" = true ]; then
cat <<EOF >> src/app-shell.ts
      </app-shell-header>
EOF
fi

cat <<EOF >> src/app-shell.ts
    \`;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    "app-shell": AppShell;
  }
}
EOF
