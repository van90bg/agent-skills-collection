# debate-paseo

Paseo-native debate skill: three heads, sequential rounds, a VERDICT/consensus gate, plus
red-team and two-phase audit modes. Sibling of [`../debate/SKILL.md`](../debate/SKILL.md), which
runs the same policy through OpenCode subagents instead of Paseo agents.

## Discovery

The skill is a directory containing `SKILL.md`, so any harness implementing the Agent Skills spec
finds it under `~/.agents/skills/` (opencode, Pi) or `~/.pi/agent/skills/` (Pi). Paseo reads the
same directory. A symlink also works: the skill scanner follows symlinked entries.

## Roster

Each head is a Paseo agent, so a head is defined by a provider/model pair plus a mode:

| Head | Provider/model | Mode |
|---|---|---|
| 1 | `debate-head-opencode/opencode/minimax-m3.1-flash-free` | `plan` |
| 2 | `antigravity/gemini-3.8-flash-high` | `full-access` |
| 3 | `qoder/qfmodel` | `plan` |

Providers that are built-in plugins (rather than extensible base providers) cannot take a
provider-level tool override, so those head prompts forbid delegation explicitly instead.

If Paseo agent profiles exist, the skill reads their `notes` and materializes heads from them;
the roster above is only the fallback when no profiles are configured.

## Usage

```
/debate-paseo <question>
/debate-paseo --redteam <question>
/debate-paseo --audit <path>
/debate-paseo --heads 2 <question>
```

Defaults to three heads on a host with enough RAM, drops to two when available memory is low, and
always runs the heads sequentially — they are read-only, so nothing is edited and no worktree is
created.

## Verifying on a host

```bash
paseo status
paseo provider models antigravity
paseo provider models qoder
npx skills ls -g | grep debate-paseo
```

## Removing

```bash
rm -rf ~/.agents/skills/debate-paseo
```
