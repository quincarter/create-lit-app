# ------------------------------------------------------------------------------
# Generate README.md
# ------------------------------------------------------------------------------
log_info "Generating customized README.md..."

# Determine package manager command strings
case "$PACKAGE_MANAGER" in
  npm)
    RUN_CMD="npm run"
    START_CMD="npm start"
    INSTALL_CMD="npm install"
    TEST_CMD="npm test"
    ;;
  pnpm)
    RUN_CMD="pnpm"
    START_CMD="pnpm start"
    INSTALL_CMD="pnpm install"
    TEST_CMD="pnpm test"
    ;;
  *)
    RUN_CMD="yarn"
    START_CMD="yarn start"
    INSTALL_CMD="yarn install"
    TEST_CMD="yarn test"
    ;;
esac

# Build Features List
FEATURES=""

if [ "$ENABLE_ROUTER" = true ]; then
  FEATURES="$FEATURES\n- **Client-Side Routing**: Single page routing powered by \`@lit-labs/router\`"
fi

if [ "$ENABLE_CONTEXT" = true ]; then
  FEATURES="$FEATURES\n- **Dependency Injection**: Decoupled state and provider patterns using \`@lit/context\`"
fi

if [ "$ENABLE_SIGNALS" = true ]; then
  FEATURES="$FEATURES\n- **State Management & Storage**: Fine-grained reactive state with \`@lit-labs/preact-signals\` and persistent IndexedDB storage via \`idb\`"
fi

if [ "$ENABLE_HEADER" = true ]; then
  FEATURES="$FEATURES\n- **App Shell Header**: Reusable \`<app-shell-header>\` navigation bar component"
fi

if [ "$ENABLE_THEME_SWITCHER" = true ]; then
  FEATURES="$FEATURES\n- **Theme Switcher**: Dark and light mode toggle component (\`<theme-switcher>\`) with preference persistence"
fi

if [ "$ENABLE_MFE_LOADER" = true ]; then
  FEATURES="$FEATURES\n- **Micro-Frontend Utility**: Dynamic script & link loader utility (\`MfeLoader\`) for micro-frontend integration"
fi

if [ "$ENABLE_TODOS" = true ]; then
  FEATURES="$FEATURES\n- **Todo List Showcase**: Interactive todo list showcasing Preact Signals state management and IndexedDB persistence"
fi

if [ "$ENABLE_CARDS" = true ]; then
  FEATURES="$FEATURES\n- **Card Components**: Reusable content cards (\`<generic-card>\`)"
fi

if [ "$ENABLE_CHARTS" = true ]; then
  FEATURES="$FEATURES\n- **Charts Integration**: Responsive canvas charts powered by \`Chart.js\` with \`Luxon\` date handling"
fi

# Build Project Directory Structure
TREE="src/
├── app-shell.ts           # Root application shell component
├── app-shell.styles.ts    # Root component styles
├── index.css              # Global CSS styles & design tokens"

if [ "$ENABLE_HEADER" = true ] || [ "$ENABLE_THEME_SWITCHER" = true ] || [ "$ENABLE_CARDS" = true ] || [ "$ENABLE_CHARTS" = true ] || [ "$ENABLE_TODOS" = true ]; then
  TREE="$TREE
├── components/            # Reusable UI web components"
  if [ "$ENABLE_HEADER" = true ]; then
    TREE="$TREE
│   ├── header/            # App shell header component"
  fi
  if [ "$ENABLE_THEME_SWITCHER" = true ]; then
    TREE="$TREE
│   ├── theme-switcher/    # Dark/light mode theme switcher"
  fi
  if [ "$ENABLE_CARDS" = true ]; then
    TREE="$TREE
│   ├── card/              # Generic card component"
  fi
  if [ "$ENABLE_CHARTS" = true ]; then
    TREE="$TREE
│   ├── chart-js/          # Chart.js web component wrapper"
  fi
  if [ "$ENABLE_TODOS" = true ]; then
    TREE="$TREE
│   ├── todos/             # Todo item & list components"
  fi
fi

TREE="$TREE
├── shared/                # Shared utilities, contexts, and configurations
│   ├── configuration/     # App navigation & route configurations
│   ├── contexts/          # Context definitions (accesses, navigation)
│   ├── interfaces/        # TypeScript interfaces & types"

if [ "$ENABLE_SIGNALS" = true ]; then
  TREE="$TREE
│   ├── stores/            # Persistent signals & reactive stores"
fi

TREE="$TREE
│   └── utilities/         # Helper functions & MFE loader"

if [ "$ENABLE_ROUTER" = true ]; then
  TREE="$TREE
└── views/                 # Route page views
    ├── home-page/         # Default landing page view"
  if [ "$ENABLE_TODOS" = true ]; then
    TREE="$TREE
    ├── todos-page/        # Todo list page view"
  fi
  if [ "$ENABLE_CARDS" = true ]; then
    TREE="$TREE
    ├── card-examples/     # Card components showcase view"
  fi
  if [ "$ENABLE_CHARTS" = true ]; then
    TREE="$TREE
    ├── chart-examples/    # Chart.js showcase view"
  fi
  if [ "$ENABLE_MFE_LOADER" = true ]; then
    TREE="$TREE
    ├── vite-mfe/          # Micro-frontend integration view"
  fi
fi

cat <<EOF > README.md
# $APP_NAME

Application shell built with Lit Element, scaffolded via \`@quincarter/create-lit-app\`.

## 🚀 Features Enabled

- **Core**: Lit Element, TypeScript, and Vite
$(echo -e "$FEATURES")

## 📦 Getting Started

### Prerequisites

Node.js v18+ and \`$PACKAGE_MANAGER\`.

### Installation

\`\`\`bash
$INSTALL_CMD
\`\`\`

### Development

Start the local development server:

\`\`\`bash
$START_CMD
\`\`\`

### Building for Production

Compile TypeScript and build the static assets:

\`\`\`bash
$RUN_CMD build
\`\`\`

Preview the production build:

\`\`\`bash
$RUN_CMD preview
\`\`\`

### Testing

Run unit tests:

\`\`\`bash
$TEST_CMD
\`\`\`

## 📁 Project Structure

\`\`\`
$TREE
\`\`\`

## 🎨 Code Style & Tooling

- **Formatting**: oxfmt (\`$RUN_CMD fmt\` / \`$RUN_CMD fmt:check\`)
- **Linting**: oxlint (\`$RUN_CMD lint\` / \`$RUN_CMD lint:fix\`)
- **Type Checking**: TypeScript (\`npx tsc --noEmit\`)
EOF

log_success "Customized README.md generated successfully."
