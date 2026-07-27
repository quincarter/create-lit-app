# @quincarter/create-lit-app ⚡

> Interactive CLI initializer to scaffold production-ready Lit Element applications with an App Shell architecture, Preact Signals, Lit Context, Lit Router, and UI component suites.

## Quick Start

Run instantly with `npx` (no pre-installation required):

```bash
npx @quincarter/create-lit-app
```

Or pass a project name directly:

```bash
npx @quincarter/create-lit-app my-app
```

---

## Starter Templates

When prompted, you can choose from three starter presets:

1. **Full App Shell Starter**: header, navigation, router, contexts, signals Todo List, cards, charts, and MFE loader.
2. **Blank App Shell Host**: minimal Lit App host container with App Shell foundations.
3. **Custom Selection**: interactively toggle specific architectural features and component showcases.

---

## CLI Options & Flags

```bash
npx @quincarter/create-lit-app [options]
```

### Options Overview

| Flag | Description | Default |
| :--- | :--- | :--- |
| `--name=<name>` | Project directory / package name | `my-app-shell` |
| `--template=<type>` | Preset: `full` \| `blank` \| `custom` | `full` |
| `--pm=<yarn\|npm>` | Package manager to use | `yarn` |
| `--router` / `--no-router` | `@lit-labs/router` (auto-enables `@lit/context`) | `true` |
| `--context` / `--no-context` | `@lit/context` dependency injection | `true` |
| `--signals` / `--no-signals` | Preact Signals & IndexedDB store | `true` |
| `--todos` / `--no-todos` | Signals Todo List component & view | `true` |
| `--cards` / `--no-cards` | Generic Card component & view | `true` |
| `--charts` / `--no-charts` | Chart.js wrapper component & view | `true` |
| `--header` / `--no-header` | AppShellHeader navigation bar | `true` |
| `--theme-switcher` / `--no-theme-switcher` | Dark/Light mode theme switcher toggle | `true` |
| `--mfe-loader` / `--no-mfe-loader` | Micro-Frontend (MFE) loader utility | `true` |
| `--git` / `--no-git` | Initialize Git repository | `true` |
| `--install` / `--no-install` | Run package manager installation step | `false` |
| `-y`, `--yes` | Run non-interactively with defaults | `false` |
| `-v`, `--version` | Display version number | - |
| `-h`, `--help` | Display CLI help menu | - |

---

## Publishing to NPM

To publish updates to npm under your scope:

```bash
npm publish --access public
```

---

## License

MIT © Quin Carter
