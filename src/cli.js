import { mkdtemp, mkdir, readdir, readFile, rm, stat, cp } from "node:fs/promises";
import { createWriteStream } from "node:fs";
import { basename, join, resolve } from "node:path";
import { homedir, tmpdir } from "node:os";
import { pipeline } from "node:stream/promises";
import { select, checkbox } from "@inquirer/prompts";
import { Command } from "commander";
import * as tar from "tar";

const REPO_PATTERN = /^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/;

export async function runCli(argv = process.argv) {
  const program = new Command();

  program
    .name("rcaskills")
    .description("Install agent skills from a GitHub repository")
    .showHelpAfterError();

  program
    .command("add")
    .argument("<repo>", "GitHub repo in owner/repo format")
    .option("--list", "List skills and exit")
    .option("--skill <skills...>", "Install only specific skill names")
    .option("--project", "Install into current project .agent/skills without prompting")
    .option("--global", "Install into ~/.agent/skills without prompting")
    .action(async (repo, options) => {
      await handleAddCommand(repo, options);
    });

  await program.parseAsync(argv);
}

async function handleAddCommand(repo, options) {
  validateRepo(repo);

  const tempRoot = await mkdtemp(join(tmpdir(), "rcaskills-"));
  let extractedRoot;

  try {
    extractedRoot = await fetchRepoToTemp(repo, tempRoot);
    const skills = await discoverSkills(extractedRoot);

    if (skills.length === 0) {
      throw new Error(`No skills found under skills/ in ${repo}.`);
    }

    if (options.list) {
      printSkills(repo, skills);
      return;
    }

    const selectedSkills = await chooseSkills(skills, options.skill ?? []);
    const targetDir = await chooseInstallTarget(options);
    await mkdir(targetDir, { recursive: true });
    const installed = await installSkills(selectedSkills, targetDir);

    console.log("");
    console.log(`Installed ${installed.length} skill(s) to ${targetDir}:`);
    for (const skill of installed) {
      console.log(`- ${skill.name}`);
    }
  } finally {
    await rm(tempRoot, { recursive: true, force: true });
  }
}

function validateRepo(repo) {
  if (!REPO_PATTERN.test(repo)) {
    throw new Error("Repository must use owner/repo format (example: arohitu/salesforce-revenue-cloud-skills).");
  }
}

async function fetchRepoToTemp(repo, tempRoot) {
  const [owner, repoName] = repo.split("/");
  const repoRoot = join(tempRoot, "repo");
  await mkdir(repoRoot, { recursive: true });

  const candidates = await buildTarballCandidates(owner, repoName);
  let lastError = null;

  for (const url of candidates) {
    try {
      await downloadAndExtract(url, repoRoot);
      return repoRoot;
    } catch (error) {
      lastError = error;
    }
  }

  throw new Error(
    `Unable to download ${repo}. Ensure the repository exists and is public. Last error: ${formatError(lastError)}`
  );
}

async function buildTarballCandidates(owner, repoName) {
  const baseCandidates = [
    `https://codeload.github.com/${owner}/${repoName}/tar.gz/refs/heads/main`,
    `https://codeload.github.com/${owner}/${repoName}/tar.gz/refs/heads/master`
  ];

  try {
    const response = await fetch(`https://api.github.com/repos/${owner}/${repoName}`, {
      headers: {
        "User-Agent": "rcaskills",
        Accept: "application/vnd.github+json"
      }
    });
    if (!response.ok) {
      return baseCandidates;
    }
    const data = await response.json();
    const branch = data.default_branch;
    if (typeof branch === "string" && branch.length > 0) {
      const defaultUrl = `https://codeload.github.com/${owner}/${repoName}/tar.gz/refs/heads/${branch}`;
      return [defaultUrl, ...baseCandidates.filter((candidate) => candidate !== defaultUrl)];
    }
  } catch {
    return baseCandidates;
  }

  return baseCandidates;
}

async function downloadAndExtract(url, outputDir) {
  const archivePath = join(outputDir, `${basename(url)}.tar.gz`);
  const response = await fetch(url, { headers: { "User-Agent": "rcaskills" } });

  if (!response.ok || !response.body) {
    throw new Error(`Download failed for ${url} (${response.status})`);
  }

  await pipeline(response.body, createWriteStream(archivePath));
  await tar.x({
    cwd: outputDir,
    file: archivePath,
    strip: 1
  });
  await rm(archivePath, { force: true });
}

async function discoverSkills(repoRoot) {
  const skillsDir = join(repoRoot, "skills");
  const entries = await readdir(skillsDir, { withFileTypes: true }).catch(() => []);
  const results = [];

  for (const entry of entries) {
    if (!entry.isDirectory()) {
      continue;
    }
    const folderName = entry.name;
    const skillDir = join(skillsDir, folderName);
    const skillFile = join(skillDir, "SKILL.md");
    const exists = await stat(skillFile)
      .then((stats) => stats.isFile())
      .catch(() => false);
    if (!exists) {
      continue;
    }
    const name = await readSkillName(skillFile, folderName);
    results.push({ name, folderName, sourceDir: skillDir });
  }

  return results.sort((a, b) => a.name.localeCompare(b.name));
}

async function readSkillName(skillFile, fallback) {
  const content = await readFile(skillFile, "utf8");
  const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---/);
  if (!frontmatterMatch) {
    return fallback;
  }

  const nameMatch = frontmatterMatch[1].match(/^\s*name:\s*(.+)\s*$/m);
  if (!nameMatch) {
    return fallback;
  }

  return nameMatch[1].trim().replace(/^['"]|['"]$/g, "") || fallback;
}

function printSkills(repo, skills) {
  console.log(`Available skills in ${repo}:`);
  for (const skill of skills) {
    console.log(`- ${skill.name}`);
  }
}

async function chooseSkills(skills, requestedSkills) {
  if (requestedSkills.length > 0) {
    const normalized = new Map();
    for (const skill of skills) {
      normalized.set(skill.name.toLowerCase(), skill);
      normalized.set(skill.folderName.toLowerCase(), skill);
    }

    const chosen = [];
    for (const name of requestedSkills) {
      const match = normalized.get(String(name).toLowerCase());
      if (!match) {
        throw new Error(`Unknown skill '${name}'. Use --list to see available skills.`);
      }
      if (!chosen.includes(match)) {
        chosen.push(match);
      }
    }
    return chosen;
  }

  const selected = await checkbox({
    message: "Select skills to install",
    choices: skills.map((skill) => ({
      name: skill.name,
      value: skill.name,
      checked: true
    })),
    required: true
  });

  return skills.filter((skill) => selected.includes(skill.name));
}

async function chooseInstallTarget(options) {
  if (options.project && options.global) {
    throw new Error("Use only one of --project or --global.");
  }
  if (options.global) {
    return resolve(homedir(), ".agent", "skills");
  }
  if (options.project) {
    return resolve(process.cwd(), ".agent", "skills");
  }

  const target = await select({
    message: "Choose installation location",
    choices: [
      { name: "Project (.agent/skills)", value: "project" },
      { name: "Global (~/.agent/skills)", value: "global" }
    ]
  });

  return target === "global" ? resolve(homedir(), ".agent", "skills") : resolve(process.cwd(), ".agent", "skills");
}

async function installSkills(skills, targetDir) {
  const installed = [];
  let conflictResolution = null;

  for (const skill of skills) {
    const destination = join(targetDir, skill.folderName);
    const exists = await stat(destination)
      .then((stats) => stats.isDirectory())
      .catch(() => false);

    let action = "overwrite";
    if (exists) {
      if (conflictResolution) {
        action = conflictResolution;
      } else {
        const choice = await select({
          message: `Skill '${skill.folderName}' already exists. What should happen?`,
          choices: [
            { name: "Overwrite", value: "overwrite" },
            { name: "Skip", value: "skip" },
            { name: "Overwrite all conflicts", value: "overwrite_all" },
            { name: "Skip all conflicts", value: "skip_all" }
          ]
        });

        if (choice === "overwrite_all") {
          conflictResolution = "overwrite";
          action = "overwrite";
        } else if (choice === "skip_all") {
          conflictResolution = "skip";
          action = "skip";
        } else {
          action = choice;
        }
      }
    }

    if (action === "skip") {
      continue;
    }

    await rm(destination, { recursive: true, force: true });
    await cp(skill.sourceDir, destination, { recursive: true, force: true });
    installed.push(skill);
  }

  return installed;
}

function formatError(error) {
  if (error instanceof Error) {
    return error.message;
  }
  return String(error);
}
