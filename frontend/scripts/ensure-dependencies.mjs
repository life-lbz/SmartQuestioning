import { spawnSync } from "node:child_process";
import { existsSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(scriptDirectory, "..");
const npmCache = join(projectRoot, ".npm-cache");
const viteExecutable = join(
  projectRoot,
  "node_modules",
  ".bin",
  process.platform === "win32" ? "vite.cmd" : "vite",
);

if (!existsSync(viteExecutable)) {
  const npmCli = process.env.npm_execpath;
  if (!npmCli) {
    console.error("缺少前端依赖，请先执行 npm install");
    process.exit(1);
  }

  console.log("首次运行，正在安装前端依赖...");
  const result = spawnSync(
    process.execPath,
    [npmCli, "install", "--cache", npmCache, "--no-audit", "--no-fund"],
    { cwd: projectRoot, stdio: "inherit" },
  );
  if (result.status !== 0) process.exit(result.status ?? 1);
}
