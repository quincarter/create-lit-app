#!/usr/bin/env node

import { spawn } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { findBash } from "./find-bash.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const scriptPath = join(__dirname, "..", "create-app-shell.sh");

const bash = findBash();
if (!bash) {
  console.error(
    "create-lit-app needs Git for Windows (Git Bash) to run: https://git-scm.com/download/win\n" +
      "If it is installed somewhere unusual, set CREATE_LIT_APP_BASH to the full path of its bash.exe.",
  );
  process.exit(1);
}

const child = spawn(bash, [scriptPath, ...process.argv.slice(2)], {
  stdio: "inherit",
});

child.on("error", (error) => {
  console.error(`Could not start ${bash}: ${error.message}`);
  process.exit(1);
});

child.on("exit", (code) => {
  process.exit(code ?? 0);
});
