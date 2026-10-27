# debate-paseo

Paseo-native debate skill: three heads, sequential rounds, a VERDICT/consensus gate, plus
red-team and two-phase audit modes. Sibling of [`../debate/SKILL.md`](../debate/SKILL.md), which
runs the same policy through OpenCode subagents instead of Paseo agents.

## Discovery

The skill is a directory containing `SKILL.md`, so any harness implementing the Agent Skills spec
finds it under `~/.agents/skills/` or `~/.pi/agent/skills/` (Pi reads both; Paseo reads the shared
directory). OpenCode reads its own `~/.config/opencode/skills/`, so a symlink is needed there. A
symlink works: the scanner follows symlinked entries.

## Roster

Each head is a Paseo agent, so a head is defined by a provider/model pair plus a mode. The roster is
built at runtime from three different provider families, every one reported `available` by
`list_providers`:

| Head | Provider family | Mode |
|---|---|---|
| 1 | strongest available coding family | `plan` |
| 2 | a different family from head 1 | `plan` |
| 3 | a third family, else a different model from family 1 or 2 | `plan` |

Model ids move, so none are pinned in this file — read them from `paseo provider models <provider>`
(or `list_models`) and disclose every substitution. Prefer `plan` for all heads: a head created with
`build` or `full-access` can write, so its no-edit suffix is the only guard.

Providers that report no `modes` cannot take `modeId`; omit it for them. Providers that are built-in
plugins (rather than extensible base providers) cannot take a provider-level tool override, so those
head prompts forbid delegation explicitly instead.

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
paseo provider models opencode
npx skills ls -g | grep debate-paseo
```

## Removing

```bash
rm -rf ~/.agents/skills/debate-paseo
```
