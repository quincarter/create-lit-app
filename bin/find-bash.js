import { execFileSync } from "node:child_process";
import { existsSync } from "node:fs";
import { dirname, join } from "node:path";

/**
 * Returns the bash to run the generator with, or null when none is usable.
 *
 * Outside Windows this is plain `bash` from PATH. On Windows, `bash` on PATH is
 * often WSL's (C:\Windows\System32\bash.exe), which cannot open C:\ paths and
 * does not have the Windows toolchain, so we look for Git for Windows' bash.exe
 * instead. CREATE_LIT_APP_BASH overrides the lookup.
 *
 * @returns {string | null}
 */
export function findBash() {
  if (process.env.CREATE_LIT_APP_BASH) return process.env.CREATE_LIT_APP_BASH;
  if (process.platform !== "win32") return "bash";

  const candidates = [];
  for (const root of [
    process.env.ProgramFiles,
    process.env["ProgramFiles(x86)"],
    process.env.ProgramW6432,
  ]) {
    if (root) candidates.push(join(root, "Git", "bin", "bash.exe"));
  }
  if (process.env.LOCALAPPDATA)
    candidates.push(join(process.env.LOCALAPPDATA, "Programs", "Git", "bin", "bash.exe"));
  if (process.env.USERPROFILE) {
    candidates.push(
      join(process.env.USERPROFILE, "scoop", "apps", "git", "current", "bin", "bash.exe"),
    );
  }

  // Git installed elsewhere: walk up from each git.exe on PATH (…\Git\cmd\git.exe,
  // …\Git\mingw64\bin\git.exe) to its bin\bash.exe.
  try {
    const gits = execFileSync("where.exe", ["git"], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    });
    for (const gitPath of gits.split(/\r?\n/).filter(Boolean)) {
      let dir = dirname(gitPath);
      for (let i = 0; i < 3; i++) {
        candidates.push(join(dir, "bin", "bash.exe"));
        dir = dirname(dir);
      }
    }
  } catch {
    // git is not on PATH; the fixed locations above may still have it.
  }

  return candidates.find((path) => existsSync(path) && !/\\system32\\/i.test(path)) ?? null;
}
