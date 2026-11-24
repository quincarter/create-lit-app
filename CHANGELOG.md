# @quincarter/create-lit-app

## 1.3.1

### Patch Changes

- On Windows, run the generator and the build's syntax check with Git for Windows' bash instead of whichever `bash` is first on PATH, which from PowerShell or cmd is usually WSL's and failed on `C:\` paths. Set `CREATE_LIT_APP_BASH` to use a different bash.
- 9592c96: Generated apps now start on vite 8.3.8, vitest 5.1.1, oxlint 1.95.0, oxfmt 0.80.0, chart.js 4.6.2, idb 8.0.4 and @kurkle/color 0.6.6.
- 9592c96: Generate project skills: create-component (every template), create-view (router) and create-signal-store (signals), each following the app's file conventions, and list them with those conventions in AGENTS.md.
- 9592c96: Generate shared assistant instructions, skills and agents with Claude, Gemini and Windsurf symlinks.
  Include lit-expert, typescript-expert, code-reviewer, ui-designer, and test-expert sub-agent definitions in every template.

## 1.3.0

### Minor Changes

- updated dependencies and fixed TS errors

### Patch Changes

- Fix scaffolds that failed to compile for some flag combinations (header without router, header without theme switcher, MFE loader without context), render the 404 view for unknown routes, report the real CLI version, validate the app name, warn on unknown flags, format the project after install, and bump oxfmt, oxlint and vitest in generated apps.

## 1.2.0

### Minor Changes

- Replace Biome with OXC tooling (`oxfmt` and `oxlint`) for code formatting and linting in scaffolded projects.

## 1.1.7

### Patch Changes

- 817b445: Bump dependencies to latest (vite 8, vitest 4, typescript 7, vite-plugin-pwa 1, biome 2.5) and fix generated-app lint/format issues

## 1.1.6

### Patch Changes

- fixed permissions issues again

## 1.1.5

### Patch Changes

- Fixing permissions checks and feature enabled

## 1.1.4

### Patch Changes

- fixed issue with feature not being enabled.

## 1.1.3

### Patch Changes

- fixing bug

## 1.1.2

### Patch Changes

- Adding readme generation to the final script

## 1.1.1

### Patch Changes

- updated so arrow keys work

## 1.1.0

### Minor Changes

- updated terminal UI to have a multi-select

## 1.0.15

### Patch Changes

- updated vite.mfe

## 1.0.13

### Patch Changes

- Updated script to detect name properly

## 1.0.11

### Patch Changes

- updated url

## 1.0.9

### Patch Changes

- updated vite mfe so it works on generation

## 1.0.7

### Patch Changes

- Update script to have a completion flow

## 1.0.3

### Patch Changes

- Added public access

## 1.0.2

### Patch Changes

- Created a Node.js CLI binary wrapper (
  bin/create-lit-app.js
  ) with #!/usr/bin/env node that delegates directly to create-app-shell.sh.
  Updated package.json to version 1.0.1 with "bin": { "create-lit-app": "./bin/create-lit-app.js" }.
  Verified locally with npx ./quincarter-create-lit-app-1.0.1.tgz --help — it runs cleanly without any warnings!
