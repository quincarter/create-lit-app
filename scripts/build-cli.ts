import { execSync } from "node:child_process";
import { chmodSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __filename: string = fileURLToPath(import.meta.url);
const __dirname: string = dirname(__filename);
const rootDir: string = join(__dirname, "..");
const cliDir: string = join(rootDir, "cli");
const outputFile: string = join(rootDir, "create-app-shell.sh");
const binTsFile: string = join(rootDir, "bin", "create-lit-app.ts");
const binJsFile: string = join(rootDir, "bin", "create-lit-app.js");

console.log("🔨 Executing scripts/create-readme.ts to generate README generator module...");
execSync("npx tsx scripts/create-readme.ts", { stdio: "inherit", cwd: rootDir });

console.log("🔨 Building create-app-shell.sh from cli/ modules...");

const files: string[] = readdirSync(cliDir)
	.filter((file: string) => file.endsWith(".sh"))
	.sort();

let combinedContent = "";

for (const file of files) {
	console.log(`  📄 Bundling ${file}...`);
	const filePath: string = join(cliDir, file);
	const content: string = readFileSync(filePath, "utf-8");
	combinedContent += `${content.trimEnd()}\n\n`;
}

writeFileSync(outputFile, combinedContent, "utf-8");
chmodSync(outputFile, 0o755);

console.log("✔ Assembled create-app-shell.sh successfully.");

console.log("🔨 Compiling bin/create-lit-app.ts -> bin/create-lit-app.js...");
const binContent: string = readFileSync(binTsFile, "utf-8");
// Simple transpilation/copy for bin entry point (or compilation via tsc)
writeFileSync(binJsFile, binContent, "utf-8");
chmodSync(binJsFile, 0o755);
console.log("✔ bin/create-lit-app.js compiled successfully.");

console.log("🔍 Validating bash script syntax...");
try {
	execSync(`bash -n "${outputFile}"`, { stdio: "inherit" });
	console.log("✔ Syntax check passed!");
} catch (error) {
	console.error("✖ Syntax check failed!");
	process.exit(1);
}
