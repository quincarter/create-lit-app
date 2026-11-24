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

## Starter Templates & Interactive TUI

When prompted, an interactive terminal user interface (TUI) lets you easily select options using **Arrow Keys** (or `j`/`k`), **Spacebar** to toggle checkboxes, and **Enter** to confirm. 

You can choose from three starter presets:

1. **Full App Shell Starter**: header, navigation, router, contexts, signals Todo List, cards, charts, and MFE loader.
2. **Blank App Shell Host**: minimal Lit App host container with App Shell foundations.
3. **Custom Selection**: interactively toggle specific architectural features in a scrollable TUI checkbox list with automatic dependency checks (e.g. selecting Routing enforces Lit Context).

Single-select questions (Package Manager, Git Initialization, Install Dependencies) use interactive TUI radio options.

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
| `--pm=<yarn\|npm\|pnpm>` | Package manager to use (`yarn`, `npm`, or `pnpm`) | `yarn` |
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

## Shared AI Assistant Configuration

Every template generates `AGENTS.md`, with `CLAUDE.md` and `GEMINI.md` symlinked
to it. Add skills to `.agents/skills/<skill-name>/SKILL.md` and agent definitions
to `.agents/agents`. Both directories include `.gitkeep` files so Git preserves them.

Every template includes five sub-agents in `.agents/agents` as Markdown files with
`name` and `description` frontmatter:

| Agent | Focus |
| :--- | :--- |
| `lit-expert` | Lit components, reactivity, lifecycle, context, signals, and routing |
| `typescript-expert` | Strict typing, component APIs, and module boundaries |
| `code-reviewer` | Correctness, security, regressions, and test coverage |
| `ui-designer` | Accessible, responsive layouts, themes, and interaction states |
| `test-expert` | Vitest unit tests, Lit component fixtures, and Playwright browser tests |

The `.claude/skills` and `.windsurf/skills` directories link to `.agents/skills`;
`.claude/agents` and `.windsurf/agents` link to `.agents/agents`. Assistant support
for agent definition formats varies; use a format supported by the consuming tool.
Edit the canonical files to keep all links synchronized. Windows requires Developer
Mode or symlink privileges; generation stops with guidance if links cannot be created.

Templates also include skills in `.agents/skills/<skill-name>/SKILL.md` that teach
assistants the project's file conventions, and `AGENTS.md` lists the ones generated:

| Skill | Generated when | What it does |
| :--- | :--- | :--- |
| `create-component` | Always | New component in `src/components/<tag>/`: `MyCard.ts` (class), `my-card.styles.ts` (styles) and `my-card.ts` (registers the element) |
| `create-view` | Router enabled | New page in `src/views/<tag>/` on `ViewMixin`, with its styles file and `nav.ts` route entry |
| `create-signal-store` | Signals enabled | Shared state in `src/shared/stores`, persisted with `persistentSignal`, read through `SignalWatcher` |

## Development & Modular Architecture

The generator CLI source is modularized under the `cli/` directory:

- `cli/00-header.sh`: Shebang, metadata, ANSI colors, and logging utilities.
- `cli/10-defaults.sh`: Configuration variable defaults.
- `cli/20-args.sh`: CLI flag parsing and help documentation.
- `cli/30-tui.sh`: TUI raw mode helpers, radio menus, and scrollable checkbox list with dependency checks.
- `cli/40-config-generators.sh`: Scaffolding setup & core config file generators (`package.json`, `tsconfig.json`, `vite.config.ts`, etc.).
- `cli/50-shared-generators.sh`: Shared modules & context generators.
- `cli/60-stores-generators.sh`: Persistent signal stores & internal status view generators.
- `cli/70-components-generators.sh`: UI component generators (`header`, `theme-switcher`, `card`, `chart-js`, `todos`).
- `cli/80-views-generators.sh`: Views & ViewMixin generators.
- `cli/90-app-shell-generator.sh`: Root `app-shell.ts` Lit component generator.
- `cli/96-agent-generators.sh`: Shared assistant instructions and directory symlinks.
- `cli/97-skill-generators.sh`: Project skills (`create-component`, `create-view`, `create-signal-store`) and the conventions section of `AGENTS.md`.
- `cli/99-post-install.sh`: Post-generation setup steps.

To assemble and validate the combined `create-app-shell.sh` script after making changes in `cli/`:

```bash
npm run build
```

---

## Publishing to NPM

To publish updates to npm under your scope:

```bash
npm run build
npm publish --access public
```

---

## License

MIT © Quin Carter
