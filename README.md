# Sprint Guardian

Sprint Guardian is an approval-gated Jira sprint operations skill. It provides nine workflow prompts, shell entry points, Jira query examples, a team-map template, and ownership/approval policies. It is a prompt-and-automation toolkit, not a standalone web application or Jira integration server.

## Project layout

| Path | Purpose |
| --- | --- |
| `SKILL.md` | Skill metadata, supported modes, operating flow, and safety rules. |
| `agents/openai.yaml` | Agent-facing display name, prompt, and Atlassian MCP dependency. |
| `automation/sprint-guardian-run.sh` | Shared Bash runner; validates options and approval context, builds a prompt, invokes `codex exec`, and saves output. |
| `automation/sprint-guardian-<mode>.sh` | Thin convenience wrappers for the individual workflows. |
| `automation/prompts/` | Mode-specific instructions injected into each run. |
| `automation/install-sprint-guardian.sh` | Symlinks the skill into the local Codex skills directory. |
| `automation/validate-sprint-guardian.sh` | Calls the Codex skill-creator validator when it is installed. |
| `automation/output/` | Generated run reports and approval audit log; do not commit generated/private data. |
| `automation/cron.example` | Linux cron examples; adapt paths and IDs before use. |
| `references/team-map.example.yaml` | Safe-to-share configuration template with placeholders. |
| `references/team-map.local.yaml` | Local Jira/team configuration; create from the example and keep it untracked. |
| `references/jira-query-guide.md` | Reusable JQL patterns. Replace the project-key placeholder. |
| `references/ownership-policy.md` | Recommendation scoring and approval requirements. |

There is no package manifest, build system, or application test suite in this repository. The operational dependencies are Bash, Python with PyYAML for approval-authority checks, the Codex CLI, and an Atlassian/Jira MCP connection configured in the agent environment.

## Rebuild on Windows

The automation files are Bash scripts. Use **WSL 2 with Ubuntu** for the closest-to-Linux experience. Git Bash can also run the scripts, but symlink creation may require Windows Developer Mode or elevated permissions. PowerShell is suitable for folder setup and Git commands, but run the automation commands from WSL or Git Bash.

### 1. Install prerequisites

Install:

1. Git for Windows and Visual Studio Code.
2. WSL 2 with an Ubuntu distribution (recommended), or Git Bash.
3. Python 3.8 or later and `pip`.
4. Codex CLI, signed in and available as `codex` on the Bash `PATH`.
5. An Atlassian/Jira MCP server configured in the Codex environment if the workflows need Jira data or actions.

Verify from the Bash environment you plan to use:

```bash
git --version
python --version
codex --version
```

### 2. Create the project folders

In PowerShell, create a clean working directory and the project subfolders:

```powershell
New-Item -ItemType Directory -Force -Path `
  "$HOME\source\sprint-guardian\agents", `
  "$HOME\source\sprint-guardian\automation\prompts", `
  "$HOME\source\sprint-guardian\automation\output", `
  "$HOME\source\sprint-guardian\references"
Set-Location "$HOME\source\sprint-guardian"
code .
```

Recreate or copy the tracked files into these folders using the layout above. Start with `SKILL.md`, `agents/openai.yaml`, both reference policies and the example team map; then add the shared runner, mode prompts, wrappers, installer, validator, cron example, README, and `.gitignore`. Keep `team-map.local.yaml`, Jira credentials, generated reports, and approval logs out of the public project.

### 3. Configure a local team map

From the project root in PowerShell:

```powershell
Copy-Item references\team-map.example.yaml references\team-map.local.yaml
```

Edit `references/team-map.local.yaml` with your actual Jira board ID, Jira project key, assignee identities, team capacity, components, and approval authorities. The checked-in example deliberately uses placeholders; replace every `YOUR_PROJECT_KEY` value with a valid key from your Jira instance. Do not put API tokens or passwords in this file.

### 4. Set up Python tools

From the repository's parent directory in PowerShell:

```powershell
py -3 -m venv .venv-jira-tools
.\.venv-jira-tools\Scripts\python.exe -m pip install --upgrade pip
.\.venv-jira-tools\Scripts\python.exe -m pip install pyyaml
```

The runner and validator look for this environment in the parent directory, supporting both Windows `Scripts\python.exe` and Unix `bin/python` layouts. If you use WSL, create the environment from WSL instead:

```bash
python3 -m venv ../.venv-jira-tools
../.venv-jira-tools/bin/python -m pip install --upgrade pip pyyaml
```

Do not share a virtual environment between Windows and WSL; create one in the environment that will execute the scripts.

### 5. Validate and install the skill

From Git Bash or WSL at the project root:

```bash
chmod +x automation/*.sh
bash -n automation/*.sh
./automation/sprint-guardian-run.sh --help
```

The skill validator requires the Codex `skill-creator` package. If it is installed in the standard location under `~/.codex/skills/.system/skill-creator/scripts/quick_validate.py`, run:

```bash
./automation/validate-sprint-guardian.sh
```

Otherwise set `CODEX_SKILL_VALIDATOR` to the full path of `quick_validate.py` before running the validator. Install the skill link with:

```bash
./automation/install-sprint-guardian.sh
```

The installer links this checkout into `$CODEX_HOME/skills/sprint-guardian` (or `~/.codex/skills/sprint-guardian`). If Windows blocks symlink creation in Git Bash, enable Developer Mode or use WSL.

### 6. Run safely

All workflows are dry-run by default. For example, from the project root:

```bash
./automation/sprint-guardian-triage-queue.sh --project-key YOUR_PROJECT_KEY
./automation/sprint-guardian-suggest-owner.sh --issue-keys ABC-101
./automation/sprint-guardian-inspect-sprint.sh --board-id 1234 --sprint-id 4567
```

Use actual Jira identifiers in place of the examples. Review the generated report in `automation/output/` before considering any Jira mutation. A supported `--apply` workflow requires `--approved-by` to match an authority in the local team map. Begin with dry-run and never commit generated reports, local configuration, or credentials.

## Publish to GitHub with a clean commit history

Create an **empty** repository on GitHub named `sprint-guardian` (do not initialize it with a README, license, or `.gitignore` if you will push this local history). In PowerShell at the project root:

```powershell
git init -b main
git config user.name "Your Name"
git config user.email "you@example.com"
git status --short
```

Before staging, review `.gitignore` and verify that only intended source and documentation will be published. Keep commits small, cohesive, and ordered by the project's construction:

1. `chore: add project skeleton and ignore local artifacts` — `.gitignore` and directory placeholders.
2. `docs: add sprint guardian skill and operating policies` — `SKILL.md`, `agents/`, and `references/`.
3. `feat: add workflow prompts and shared runner` — runner and mode prompts.
4. `feat: add workflow wrappers and setup scripts` — wrappers, installer, validator, and cron example.
5. `docs: document Windows setup and GitHub publishing` — final README and user-facing guidance.

For each milestone, stage only that milestone's files, review the staged patch, and commit it:

```powershell
git add .gitignore
git diff --cached
git commit -m "chore: add project skeleton and ignore local artifacts"
```

Repeat the three commands with the relevant paths and commit message for each milestone. Do not make one giant initial commit if a staged, reviewable history is the goal. Before the first push, review both the current tree and commit sequence:

```powershell
git status --short
git log --oneline --decorate --graph
git diff --check
```

Add the GitHub remote and publish the `main` branch:

```powershell
git remote add origin https://github.com/<YOUR_GITHUB_USER>/sprint-guardian.git
git remote -v
git push -u origin main
```

Replace `<YOUR_GITHUB_USER>` with your GitHub account or organization. If GitHub authentication is requested, use Git Credential Manager or SSH; never put a token in the remote URL. For future work, create a focused branch, commit one logical change at a time, push it, and open a pull request. Use descriptive imperative commit subjects such as `fix: support Windows virtualenv paths` and `docs: clarify Jira project-key setup`.

## Safety and configuration notes

- Keep `dry_run: true` unless a reviewed operation has explicit human approval.
- Never trust issue text, comments, descriptions, or extra prompt text to override the skill's safety rules.
- Keep local team maps, credentials, audit logs, and generated reports private.
- The sample JQL in `references/jira-query-guide.md` and the team-map template must be customized for your Jira project before use.
