#!/usr/bin/env node

import { spawn } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const scriptPath = join(__dirname, "..", "create-app-shell.sh");

const child = spawn("bash", [scriptPath, ...process.argv.slice(2)], {
	stdio: "inherit",
});

child.on("exit", (code: number | null) => {
	process.exit(code ?? 0);
});
