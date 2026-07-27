# @quincarter/create-lit-app

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
