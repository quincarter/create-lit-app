# @quincarter/create-lit-app

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
