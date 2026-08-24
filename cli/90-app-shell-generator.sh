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
import type { NavItem } from './shared/interfaces/navigation.interface';
import \"./shared/internal-views/404-not-found/page-not-found\";
import \"./shared/internal-views/no-access/no-access\";
import \"./shared/internal-views/under-construction/under-construction\";"

if [ "$ENABLE_CONTEXT" = true ]; then
  IMPORTS="$IMPORTS
import { provide } from '@lit/context';
import { AccessesContext } from './shared/contexts/accesses.context';
import { NavigationContext } from './shared/contexts/navigation.context';"
fi

# MFE loader context is provided independently of ENABLE_CONTEXT so the
# micro-frontend (MFE) utility works even when context features are off.
if [ "$ENABLE_MFE_LOADER" = true ]; then
  IMPORTS="$IMPORTS
import { MfeLoaderContext } from './shared/contexts/mfe-loader.context';"
fi

if [ "$ENABLE_ROUTER" = true ]; then
  IMPORTS="$IMPORTS
import { Router } from '@lit-labs/router';
import { html as staticHtml, unsafeStatic } from 'lit/static-html.js';
import 'urlpattern-polyfill';
import { navigationRouting, sidePages } from './shared/configuration/nav';
import { routesBuilt } from './shared/configuration/routes';
import { withBase } from './shared/configuration/base-path';
import { AppRootUtilities } from './shared/utilities/app-root.utility';"
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
else
cat <<EOF >> src/app-shell.ts
  @property({ type: Array })
  routing: NavItem[] = [];

  @property({ type: Array })
  accesses: string[] = ["public"];
EOF
fi

if [ "$ENABLE_ROUTER" = true ]; then
cat <<EOF >> src/app-shell.ts
  @state()
  navRoutes: NavItem[] = [] as NavItem[];

  @state()
  notAllowedRouteList: NavItem[] = [];
EOF
fi

# Provide the MFE loader independently of ENABLE_CONTEXT so that the MFE
# utility initializes even when context features are disabled.
if [ "$ENABLE_MFE_LOADER" = true ]; then
cat <<EOF >> src/app-shell.ts
  @provide({ context: MfeLoaderContext })
  @state()
  mfeLoader = new MfeLoader(MFE_LOADER_CONFIG);
EOF
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
    this.navRoutes = this._buildNavBarRoutes(navigationRouting);
    await this._setupRoutes();
EOF
fi

# Initialize the MFE loader at the shell level (independent of ENABLE_CONTEXT)
# so micro-frontend bundles are injected regardless of context feature state.
if [ "$ENABLE_MFE_LOADER" = true ]; then
cat <<EOF >> src/app-shell.ts
    await this.mfeLoader?.init();
EOF
fi

cat <<EOF >> src/app-shell.ts
  }
EOF

if [ "$ENABLE_ROUTER" = true ]; then
cat <<EOF >> src/app-shell.ts

  private _buildNavBarRoutes(navItems: NavItem[]): NavItem[] {
    const navi = routesBuilt(navItems, this.accesses);
    const { notAllowed, navItems: filtered } =
      AppRootUtilities.getNotAllowedRoutes(navi, this.notAllowedRouteList);
    this.notAllowedRouteList = notAllowed;
    return filtered;
  }

  private async _setupRoutes(): Promise<void> {
    const detailRoutes = this._buildNavBarRoutes([...sidePages]);
    this.routing = routesBuilt(
      [...this.navRoutes, ...this.notAllowedRouteList, ...detailRoutes],
      this.accesses,
    );
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

    const firstPath = this.navRoutes[0]?.path || "/home";
    const firstItem = this.navRoutes[0];

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
      <app-shell-header .routes="\${this.navRoutes}" enable-theme-switcher>
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
