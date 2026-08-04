# ------------------------------------------------------------------------------
# Generate package.json
# ------------------------------------------------------------------------------
log_info "Generating package.json..."

DEPS='"lit": "^3.3.3"'
if [ "$ENABLE_ROUTER" = true ]; then
  DEPS="$DEPS,
    \"@lit-labs/router\": \"^0.1.4\",
    \"urlpattern-polyfill\": \"^10.1.0\""
fi
if [ "$ENABLE_CONTEXT" = true ]; then
  DEPS="$DEPS,
    \"@lit/context\": \"^1.1.6\""
fi
if [ "$ENABLE_SIGNALS" = true ]; then
  DEPS="$DEPS,
    \"@lit-labs/preact-signals\": \"^1.0.3\",
    \"idb\": \"^8.0.3\""
fi
if [ "$ENABLE_CHARTS" = true ]; then
  DEPS="$DEPS,
    \"chart.js\": \"^4.5.1\",
    \"chartjs-adapter-luxon\": \"^1.3.1\",
    \"luxon\": \"^3.7.2\",
    \"@kurkle/color\": \"^0.4.0\""
fi

cat <<EOF > package.json
{
  "name": "@quincarter/$APP_NAME",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "start": "vite",
    "build": "tsc && vite build",
    "preview": "yarn build && vite preview",
    "test": "vitest run"
  },
  "dependencies": {
    $DEPS
  },
  "devDependencies": {
    "@biomejs/biome": "2.5.5",
    "@types/luxon": "^3.7.2",
    "@types/mocha": "^10.0.10",
    "typescript": "^5.4.5",
    "vite": "^5.2.11",
    "vite-plugin-pwa": "^0.20.0",
    "vitest": "^1.6.0"
  }
}
EOF

# ------------------------------------------------------------------------------
# Generate Configuration Files
# ------------------------------------------------------------------------------
log_info "Generating configuration files (tsconfig.json, vite.config.ts, biome.json)..."

cat <<'EOF' > tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "declaration": true,
    "emitDeclarationOnly": false,
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true,
    "experimentalDecorators": true,
    "useDefineForClassFields": false,
    "skipLibCheck": true
  },
  "include": ["src/**/*.ts"]
}
EOF

cat <<'EOF' > vite.config.ts
import { defineConfig } from 'vite';

export default defineConfig({
  build: {
    target: 'esnext',
  },
});
EOF

cat <<'EOF' > biome.json
{
  "$schema": "https://biomejs.dev/schemas/1.8.3/schema.json",
  "organizeImports": {
    "enabled": true
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true
    }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "tab"
  }
}
EOF

cat <<'EOF' > .gitignore
node_modules
dist
.DS_Store
*.log
EOF

cat <<EOF > index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>$APP_NAME</title>
    <script src="/detect-color-scheme.js"></script>
    <link rel="stylesheet" href="/src/index.css" />
  </head>
  <body>
    <app-shell></app-shell>
    <script type="module" src="/src/app-shell.ts"></script>
  </body>
</html>
EOF

mkdir -p public
cat <<'EOF' > public/detect-color-scheme.js
(function () {
  const storedTheme = localStorage.getItem("theme");
  if (storedTheme) {
    document.documentElement.setAttribute("data-theme", storedTheme);
  } else if (window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches) {
    document.documentElement.setAttribute("data-theme", "dark");
  } else {
    document.documentElement.setAttribute("data-theme", "light");
  }
})();
EOF

mkdir -p src/assets

cat <<'EOF' > src/index.css
:root {
  --primary-text-color: #212529;
  --bg-color: #ffffff;
  --nav-background-color: #f8f9fa;
  --primary-box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  font-family: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif;
  line-height: 1.5;
  font-weight: 400;
}

[data-theme="dark"] {
  --primary-text-color: #f8f9fa;
  --bg-color: #121212;
  --nav-background-color: #1e1e1e;
  --primary-box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.5);
}

body {
  margin: 0;
  padding: 0;
  background-color: var(--bg-color);
  color: var(--primary-text-color);
}
EOF

cat <<'EOF' > src/vite-env.d.ts
/// <reference types="vite/client" />
EOF
