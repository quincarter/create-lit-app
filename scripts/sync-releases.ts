import { execSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { join } from "node:path";

const rootDir = process.cwd();
const changelogPath = join(rootDir, "CHANGELOG.md");

try {
	const content = readFileSync(changelogPath, "utf-8");
	const sections = content.split(/^## /m).slice(1);

	for (const section of sections) {
		const lines = section.trim().split("\n");
		const version = lines[0].trim();
		const notes = lines.slice(1).join("\n").trim();
		const tag = `v${version}`;

		try {
			execSync(`gh release view "${tag}"`, { stdio: "ignore" });
		} catch {
			console.log(`🚀 Creating GitHub release for ${tag}...`);
			try {
				execSync(
					`gh release create "${tag}" --title "${tag}" --notes ${JSON.stringify(notes)}`,
					{ stdio: "inherit", cwd: rootDir }
				);
				console.log(`✔ Release ${tag} created on GitHub.`);
			} catch (err) {
				console.error(`✖ Failed to create GitHub release for ${tag}:`, err);
			}
		}
	}
} catch (err) {
	console.error("✖ Error syncing GitHub releases:", err);
}
