---
name: multi-agent-orchestration
description: Orchestration policy for multi-agent (Enterprise Ops) work and evidence adjudication — Lead Coordinator, a five-phase pipeline with a mandatory plan-approval gate, sequential scheduling that protects single-board hardware, evidence-first findings (4 parts), four-class bug triage, two-head debate, and capability-based adapters for Paseo / OpenCode / Roo-Code / Cline / Pi.dev. Use when taking the Lead Coordinator role, delegating to subagents, or running a large audit/refactor that needs a plan gate.
license: MIT
metadata:
  author: van90bg
  version: "1.6"
  category: core
  triggers: ["orchestrate", "delegate", "multi-agent", "lead coordinator", "subagent", "audit", "refactor", "plan approval"]
---

# Multi-Agent Orchestration — Delegation & Evidence Adjudication

> A machine-level policy, reusable in any repo: explicit ownership, a controlled blast radius, care for
> single-board hardware, and decisions that rest on measured evidence instead of narration.

## When to Use / Not Use

- **Use:** a task big enough to split into plan → code → test → review → docs; an audit or refactor with a
  plan-approval gate; any time you take the Lead Coordinator role.
- **Don't use:** a one-file trivial fix (just make it), or a pure read-only question.

## 0. Boundaries & Supreme Law

- **The host repo's law always wins.** Before entering the pipeline, read the repo's `AGENTS.md` (plus its
  progress log, e.g. `PROGRESS.md`) to get the exact rules for: deterministic edits, the gate chain,
  commit/branch conventions, report format, and the plan-approval threshold.
- **Never hardcode another repo's numbers here.** Gate counts, script names, template paths and section
  numbers quoted in this file are *placeholders* — resolve them from the current repo's `AGENTS.md` and
  `package.json`, not from memory.
- **The core is harness-agnostic; only the execution layer adapts.** The five phases, the approval gate,
  the sequential discipline, the four-part evidence contract, the bug classes and the two-head debate are
  invariant. Which tools you call to run them is the only thing that changes — see §5, and decide the
  model from the tool schema this session actually exposes, not from the harness's name.
- **The plan gate is human-in-the-loop.** The trigger threshold follows repo law (typically: ≥3 source
  files touched, or a change to API/UI/flow/metrics, or any P0/P1). When the repo requires a plan first,
  you **must stop and wait** for the user's approval (`duyệt` / `LGTM` / `OK`) before writing code.

## 1. Lead Coordinator Role & Hardware Discipline

The orchestration host is typically a single-board machine shared with a self-hosted CI runner — few CPU
cores, limited RAM (the exact figures belong to machine-level memory, not to this skill).

1. **Don't hog the work.** The Lead Coordinator conducts: decompose the goal, route the phases, judge the
   outputs, synthesize the report. Do not write production code while specialized profiles exist.
2. **Sequential pipeline by default.**
   - Heavy phases (the coder building, the tester driving headless Chromium/CDP across the whole gate
     chain, the self-hosted CI runner) **run one agent at a time**.
   - Never run several heavy subagents in parallel: it saturates the cores, times out CDP gates, or lets
     the OOM killer shoot down background processes.
   - **Parallel exception:** a two-head technical debate is read-only — it spends inference tokens only
     and no local CPU/RAM, so the two heads may run concurrently.
3. **Check the model budget before you fan out.** Spend one cheap probe per model you are about to use,
   then dispatch. A phase that dies on a rate limit wastes the turn and — worse — tempts the Lead into
   writing the answer itself, which rule 1 forbids.
   - Free tiers and trial keys hit `429` on a schedule, not on demand. On a quota error: switch model or
     provider once, disclose the substitution, and never retry the same exhausted tier in a loop.
   - Never let a head "work shorthanded" without saying so in the final report; a synthesised answer that
     silently drops a phase is worse than a short report that names the gap.

## 2. The Five-Phase Pipeline

```
Phase 1: Survey & Plan (se-planner)
               │
               ▼
   [MANDATORY STOP: USER APPROVES THE PLAN]
               │
               ▼
Phase 2: Implement (se-coder)
               │
               ▼
Phase 3: Test & Quality (se-tester)
               │
               ▼
Phase 4: Independent Review (se-reviewer)
               │
               ▼
Phase 5: Docs & Release (se-documenter)
```

1. **Phase 1 — Survey & Plan (`se-planner`, read-only):** measure the current state with real commands,
   never from memory; write the plan into the repo's plan directory using the repo's plan template; run
   the repo's plan gate until it passes. Rules the plan gate cannot express (vague wording, missing
   anchors) still apply — the plan must name *what*, *where*, *how*, *why* and *how it is verified*.
2. **Phase 2 — Implement (`se-coder`):** work only inside the approved plan's scope; prefer an isolated
   branch or worktree; obey the repo's deterministic-edit rule and preserve its declared encoding and
   line-ending invariants.
3. **Phase 3 — Test & Quality (`se-tester`):** run the repo's full test suite and the complete gate chain
   listed in `AGENTS.md`; report every failure through the four-part evidence contract (§3).
4. **Phase 4 — Independent Review (`se-reviewer`, read-only):** audit the diff against the acceptance
   criteria; run adversarial checks for logic errors, OWASP-class security gaps, and dishonest tests or
   mocks that assert the wrong thing.
5. **Phase 5 — Docs & Release (`se-documenter`):** take live numbers from the repo's single stats source
   instead of retyping them; update the progress log and docs in the same commit; bump SemVer per the
   repo's rule; keep 1 task = 1 commit = 1 push.

## 3. Evidence & Adjudication

A finding from `se-tester` is routed onward only when it is complete.

1. **Four mandatory evidence parts** — no finding reaches the coder without all four:
   1. the exact reproduction command;
   2. the exit code it returned;
   3. a raw stdout/stderr excerpt, quoted verbatim and never paraphrased;
   4. a precise location (`file:line` or `file:function()`).
2. **Four classifications:**
   - `product-bug` — a real product logic defect → hand to `se-coder`.
   - `test-bug` — a wrong test or an assertion that drifted from the business requirement → return to
     `se-tester`, then have `se-reviewer` audit the assertion. **The coder must never change product code
     to satisfy a wrong test.**
   - `environment` — a missing dependency, network, permissions or infrastructure problem → route to the
     devops role; leave product code untouched.
   - `flaky` — rerun twice; if it does not reproduce, record it as known debt and do not block the pipeline.
3. **Testers do not diagnose root causes.** A tester records objective facts only; root-cause analysis
   and the fix belong to the coder and the reviewer.

## 4. Two-Head Technical Debate

Triggered by an irreconcilable tester/coder disagreement, or when a complex architecture decision needs
to be challenged.

1. **Two opposing heads:**
   - **Head 1 — Systems & Architecture:** whole-system view, operational feasibility, memory and hardware
     budget, compatibility with the system contract.
   - **Head 2 — Adversarial Rebuttal:** attacks the claim, hunts failing edge cases, false-green risks and
     regressions.
2. **Identical raw evidence packet** — the Lead sends the *same* verbatim packet (commands, exit codes,
   logs, `file:line`) to both heads; no subjective framing.
3. **Independent verdicts** — each head returns exactly one of `FINDING ĐÚNG` (the finding stands) /
   `FINDING SAI` (the finding is wrong) / `KHÔNG ĐỦ KẾT LUẬN` (insufficient evidence to decide), together
   with measured proof or a concrete counterexample.
4. **The Lead adjudicates** on the experimental evidence of both verdicts, never on preference.

## 5. Capability-Based Harness Adapters

The core policy (five phases, approval gate, sequential discipline, four-part evidence, bug classes,
two-head debate) is **harness-agnostic and invariant**. Only the execution layer adapts:

> **Golden rule:** never call a tool by assumption. An agent may call only the tools that actually exist
> in the tool schema the current harness exposes to this session.
>
> **Match tools by the trailing name, never by the prefix.** The same Paseo tool appears as `create_agent`
> (Paseo's own agents), `paseo_create_agent` (some providers) or `mcp__paseo__create_agent` (a harness
> given the Paseo MCP server). Read the schema before the first delegation and use the names you see.

### Model 1 — Subagent-native harness
- **Signal:** the harness exposes a tool that creates independent child sessions/subagents (e.g. Paseo
  `create_agent`, Antigravity CLI `invoke_subagent`, or a Pi session that Paseo spawned — the Paseo
  supervisor injects its MCP tools into that session even when `pi mcp list` reports none configured).
- **Mechanism:** read the role definitions from whichever config surface the harness really reads (or use
  its profile-listing tool); delegate phases strictly in order; force read-only mode for the planner, the
  reviewer and both debate heads; judge each subagent's evidence before advancing a phase.
- **Pi without Paseo, still Model 1:** the `pi` npm package ships `examples/extensions/subagent` — a tool
  named `subagent` with single / parallel / chain modes where every child is a **separate `pi` process**
  with its own context, driven by agent files in `~/.pi/agent/agents/*.md` (a `model:` line pins the
  child's model; omit it to inherit). Wire it up without any MCP server:

  ```bash
  PKG="$(npm root -g)/@earendil-works/pi-coding-agent/examples/extensions/subagent"
  mkdir -p ~/.pi/agent/extensions/subagent ~/.pi/agent/agents
  ln -sfn "$PKG/index.ts" "$PKG/agents.ts" ~/.pi/agent/extensions/subagent/
  ```

  Verify with the parent stripped of its own read tools, so the facts can only come from a child:
  `pi -p --tools subagent "use the subagent tool with agent scout to report X with file:line"`.

#### Role ids are the contract — one name per role, on every surface

The phase ids in §2 (`se-planner`, `se-coder`, `se-tester`, `se-reviewer`, `se-documenter`, plus
`se-devops` for `environment` findings and the debate heads) must be the **same string** on every surface
that can launch them: the Paseo profile, the Pi agent file, **and the magpie routing group**. Otherwise the
Lead writes a delegation the harness cannot resolve — the child never starts and the pipeline dies at
Phase 1. Keep one row per role and reconcile it when any surface moves:

| Phase / role | Paseo profile id | Pi agent file (`~/.pi/agent/agents/`) | magpie routing group | Bash fallback |
|---|---|---|---|---|
| 1 planner (read-only) | `se-planner` | `se-planner.md` | `group/se-planner` | `paseo run --provider pi/magpie/group/se-planner --title plan "…"` |
| 2 coder | `se-coder` | `se-coder.md` | `group/se-coder` | same, `--title code` |
| 3 tester | `se-tester` | `se-tester.md` | `group/se-tester` | same, `--title test` |
| 4 reviewer (read-only) | `se-reviewer` | `se-reviewer.md` | `group/se-reviewer` | same, `--title review` |
| 5 documenter | `se-documenter` | `se-documenter.md` | `group/se-documenter` | same, `--title docs` |
| `environment` routing | `se-devops` | `se-devops.md` | `group/se-devops` | same, `--title env` |
| debate head 1 — systems | `debate-h1-systems` | `debate-h1-systems.md` | `group/debate-h1-systems` | same, `--title h1` |
| debate head 2 — adversarial | `debate-h2-adversarial` | `debate-h2-adversarial.md` | `group/debate-h2-adversarial` | same, `--title h2` |
| debate head 3 — pragmatism (tie-break only) | `debate-h3-pragmatism` | `debate-h3-pragmatism.md` | `group/debate-h3-pragmatism` | same, `--title h3` |
| recon (optional) | `scout` | `scout.md` | `group/scout` | same, `--title recon` |
| Lead (this session) | `lead-coordinator` | — | `group/lead-coordinator` | — |

#### One routing group per role — capability is encoded in the group, not in the role name

A role id that also names a magpie routing group (`group/<role-id>`) makes the model policy editable in one
place, without touching a single agent file or profile:

```bash
magpie group set se-coder models=workbuddy-ai/deepseek-v4.1-flash,tokenharbor/deepseek-v4.1-flash:free,…
magpie group set se-planner models=autoclaw/zai_glm-5.3-flash,workbuddy-ai/glm-5.3-flash,…
magpie groups                       # every role's chain, in order
```

Two consequences worth stating out loud:

- **Order is policy.** `routing=order` walks the list front to back, so the first member is the role's
  primary and the rest are failover. Put a quota-exhausted model *last*, not first: a member that answers
  `429 … free quota used up` costs a wasted round-trip on every single call (measured: `tries=3` before the
  first usable member, versus `tries=1` after reordering).
- **Family separation is a group decision.** “GLM plans, DeepSeek codes” is expressed by putting only GLM
  models in `se-planner` and only DeepSeek models first in `se-coder`. Never enforce it by renaming a role or
  by editing an agent file per model change.

Verify the policy landed, don't assume it — the router records which member actually served each call:

```bash
magpie usage --csv 7d | grep 'group/se-'     # requested_model=group/se-coder  served_model=deepseek-v4.1-flash
```

A role whose requests show a *different family* than its group intends is a group-ordering bug, not a
model-quality judgement.

#### Editing group members needs no follow-up edit — but four things can still bite

Because every pin (Paseo profile, Pi agent file) names `group/<role-id>` and never a member, changing what a
role runs is **one command and nothing else** — no profile edit, no agent-file edit, no restart:

```bash
magpie group set se-coder models=<new chain>   # pins still say group/se-coder → they keep working
```

What does *not* follow automatically:

1. **A member id can lie about the model it serves.** `autoclaw/zai_auto` answers as
   `deepseek/deepseek-v4-flash-vision-exp`; the router happily reports the id you asked for, so a group can
   silently break its own family policy. Probe identity, don't trust the label:
   `bash scripts/audit-pins.sh --probe` (or read `served_model` in `magpie usage --csv`).
2. **Thinking levels are per member and get downgraded silently.** A group's `levels` is what agents are
   *offered*; a member that lacks the level is sent its nearest (measured: profile pinned `xhigh`, the
   served request logged `effort=high` on a member whose max is `high`). If a role's reasoning level is part
   of the contract, put a member that actually supports it first.
3. **A dead primary costs a round-trip on every call.** Quota-exhausted members answer `429` before
   failover; keep them last or drop them.
4. **Advertised context can shrink.** A group's context is derived from its members, so adding a small-context
   model can lower the window the agent is told it has — set `context=` explicitly if that matters.

Structural pins (does the id exist, is it the role's own group, is the thinking level offered, does every
profile have a Pi twin) are cheap to re-check and catch 1, 3 and 4 partially: run `audit-pins.sh` after any
member edit; run it with `--probe` when you changed a *provider*, not just a model.

#### Probe the model pin before the first delegation

A `model:` line in a Pi agent file, or a `model` in a Paseo profile, is a **claim about the provider's
catalogue**, and a stale claim fails instantly and loudly — the child never starts:

```
404: magpie knows no model "group/free"; did you mean group/glm-free …?
```

So list what the provider really serves (`curl -s "$BASE/v1/models" | jq -r '.data[].id'`, or
`pi --list-models`) and match the pin to an id that is actually there, *including the routing group's
real name*. Do not invent a `group/<adjective>` because it looks consistent with its neighbours; one
probe per pin (`pi -p --model <pin> "reply OK"`) is cheaper than a phase that dies mid-pipeline.

#### Surviving model / provider churn

Three things are hard-coded and **none of them is edited by picking a model for the *current* agent** in a
daemon UI:

1. `daemon.agentProfiles[].provider` + `.model` + `.thinkingOptionId` (Paseo)
2. the `model:` line in each `~/.pi/agent/agents/*.md`
3. the routing group behind each of those pins (`group/<role-id>`) and the group's `levels` list

| You change | Does delegation still work? |
|---|---|
| The Lead agent's own model (per-agent picker) | ✅ profiles and agent files are untouched — children keep their own pins |
| A profile's model / thinking level | ✅ if the id is real for `provider: pi`; a typed id still routes even when Pi's picker (a snapshot) does not list it |
| Magpie routing-group **members** | ✅ `routing: "order"` fails over to the next member |
| Magpie routing-group **id** renamed or deleted | ❌ every pin pointing at it dies with `404 … knows no model` |
| `agents.providers.pi.enabled = false` in the Paseo config | ❌ all roles are `provider: pi` — nothing launches |
| The Lead switched to another provider (opencode / codex / …) | ✅ MCP is injected per harness, so `create_agent` still works; only the Pi-specific notes above stop applying |
| A group's `levels` narrowed | ⚠️ a profile whose `thinkingOptionId` fell out of the list fails on launch (a group with `levels=low,high,xhigh,max` has no `medium`) |

After any of those changes, audit every pin in one shot instead of discovering the break at Phase 2:

```bash
bash scripts/audit-pins.sh        # exit 0 = all pins resolve; exit 1 = names the dead pin + a suggestion
```

It checks each profile's provider against `agents.providers.<name>.enabled`, each model id against the live
`/v1/models`, each thinking level against that model's `reasoning_levels`, and that every profile id has a
Pi agent twin. Pi's own `models.json` is **metadata only**: an id it does not list still routes (Pi warns
`Using custom model id`), so the router — not `models.json` — is the source of truth; add new ids to
`models.json` anyway to keep context-window and thinking-level handling correct.

#### When the MCP tools are not in the declared tool list

A Paseo-hosted Pi session gets `mcp__paseo__create_agent`, `mcp__paseo__list_profiles`,
`mcp__paseo__send_agent_prompt`, `mcp__paseo__get_agent_status`, … — but depending on the Pi build they are
**codemode-only**: callable from a `codemode` script via `ALL_TOOLS` / `searchTools("agent")` /
`describeTool(...)`, and absent from the top-level tool list. Never conclude "the tool does not exist"
from the declared list alone; enumerate the codemode tool namespace first. If the server is genuinely
unreachable, drop to the bash fallback, which needs no MCP at all:

```bash
paseo run --provider pi/magpie/group/se-planner --thinking high --title "phase-1-plan" \
  --label role=se-planner "…task…"      # waits for completion, prints agent id + status only
paseo logs <id>                          # the child's transcript — final answer on the last line
paseo ls --label role=se-planner         # find a run started with --no-wait
paseo inspect <id>                       # status, model, token usage, parent agent
```

`paseo run` does **not** print the answer — it returns the table row (`agent id / status`). Always read the
child's output back with `paseo logs <id>`; treating an empty `run` result as "no answer" is how a phase
gets silently skipped.

### Model 2 — Mode / role switching inside one session
- **Signal:** the harness runs a single chat session but can switch persona/mode with permission limits.
- **Mechanism:** load the role definitions from the config surface the harness actually reads, then switch
  before each phase — Phase 1 planner (read-only) → Phase 2 coder (after approval) → Phase 3 tester →
  Phase 4 reviewer → Phase 5 documenter.

| Harness | Config surface | Notes / constraints |
|---|---|---|
| Roo-Code / Cline | `.roomodes` at the repo root | roles live in `customModes`; read-only boundaries are enforced by `groups: ["read"]`; keep a repo test so the file cannot silently drift |
| OpenCode | the `agent` key in `opencode.json`, or `~/.config/opencode/agents/<role>.md` | if the roles are not declared here, Model 2 cannot run — fall back to Model 3 |
| Paseo | `daemon.agentProfiles` in `~/.paseo/config.json`, invoked via `create_agent` / `send_agent_prompt` | profiles ship ready-made and are the SSOT for role ids; `create_agent` has no `profile` parameter — materialize one as `provider: "<provider>/<model>"` plus `settings.thinkingOptionId` / `settings.modeId`, and check the profile's model still exists in the provider catalogue |

- **`.roomodes` is not a shared SSOT.** It is a Roo-Code/Cline format; OpenCode and Pi.dev never read it.
  Under those harnesses it is documentation only — use that harness's own surface, or fall back to Model 3.
- **Read-only drift warning.** A role marked read-only on one surface may be write-enabled on another
  (e.g. a profile whose `modeId` is `build` or `full-access`). **Never infer a read-only boundary from the
  role name** — state the prohibition explicitly in the role's prompt.
- **No cross-surface sync gate is possible.** Global harness config lives outside the repo, so a CI test
  cannot read it. Drift between surfaces is a known risk: review both by hand whenever either changes.

### Model 3 — Single-agent sequential fallback
- **Signal:** the harness has neither a subagent tool nor mode switching (e.g. a **standalone** `pi` CLI
  session with no Paseo MCP server and no `subagent` extension, Aider, a plain CLI chat). Pi ships no
  native subagent tool and no mode switch, so it lands here *unless* something hands it a subagent tool —
  Paseo and the `subagent` extension both do. Inspect the tool schema before choosing: an empty
  `pi mcp list` does not rule Model 1 out.
- **Mechanism:** the same agent runs the whole pipeline by context-shifting between roles, and must hold
  each role's boundary honestly:
  - Phase 1 — act as the planner (read-only; plan per the repo template; run the plan gate).
  - **Stop and ask the user.**
  - Phase 2 — only after approval, act as the coder.
  - Phase 3 — act as the tester and run the full gate chain.
  - Phase 4 — act as the reviewer; attack your own diff and rebut your own decisions.
  - Phase 5 — act as the documenter; sync metrics from the live source and bump the version.

## Worked Example — `soc-portal-gas` (the repo this policy was extracted from)

- **Gate chain:** 21 gates (`12 audit:*` + `9 verify:*`) plus the test suite — `npm run verify` and
  `npm test`; take the counts from `npm run stats`, never from memory.
- **Plan gate:** template `docs/templates/PLAN.template.md`, plans at `docs/plans/YYYY-MM-DD-<slug>.md`,
  machine check `npm run check:plan -- <file>` must print `PLAN-PASS`.
- **Working branch:** `dev` (build and deploy from `dev`; `main` only accepts PRs).
- **Docs to sync in the same commit:** `PROGRESS.md` + `README.md` + `SPECIFICATION.md` + `AGENTS.md`.
- **Role surfaces present:** `.roomodes` with 7 roles (guarded by `tests/roomodes-integrity.test.js`) and
  10 Paseo `daemon.agentProfiles`; OpenCode declares only `debate-head`, so OpenCode falls back to Model 3.
- **Skill discovery is per harness, and the copies drift.** Paseo installs `/paseo`, `/paseo-handoff`,
  `/paseo-committee` and `/paseo-advisor` into each harness's own skill directory and refreshes them when
  the daemon starts — never patch those files by hand. This policy and `debate-paseo` live in the
  `agent-skills-collection` repo and are symlinked into `~/.agents/skills/`, which is where Pi looks;
  OpenCode is configured to read `~/.config/opencode/skills/`. Check the inventory per harness instead of
  assuming the skill is visible everywhere.
- **Read-only drift measured per profile:** the debate heads and the Lead Coordinator run with
  `modeId: build` / `full-access`, so they *can* write. The no-edit suffix in the prompt is the only
  guard — keep it in every analysis-only delegation.
- **Hardware:** Intel Pentium Silver J5005 (4 cores, 15 GB RAM) shared with the self-hosted `dietpi-dev`
  CI runner — the reason the sequential rule is strict.
- **Delegation paths, cheapest first:** (1) Paseo `create_agent` — real model diversity per phase; (2) the
  Pi `subagent` extension — same model, isolated context, still a separate process; (3) Model 3 in one
  session. Pick (1) when independence matters (Phase 4 review, debate heads), (3) only for small work.

## Self-Acceptance Checklist

| # | Check |
|---|---|
| 1 | The host `AGENTS.md` was read before planning; its gates and thresholds were used, not remembered |
| 2 | The plan follows the repo template and the repo's plan gate passed |
| 3 | User approval was obtained before any code change |
| 4 | Heavy phases ran strictly sequentially |
| 5 | Every routed finding carries the four evidence parts plus a classification |
| 6 | The tester reported facts only; root cause came from the coder or reviewer |
| 7 | Read-only/write drift between role config surfaces was checked by hand |
| 8 | Docs, progress log and version were updated in the same commit |
| 9 | The harness model (1/2/3) was chosen from the tool schema actually exposed, not from the harness name |
| 10 | Tool names were read from the live schema, including any `mcp__<server>__<tool>` namespacing |
| 11 | Each model was probed before dispatch, and every quota-driven substitution is disclosed in the report |
| 12 | Every role id used in a delegation exists on the surface that will launch it (Paseo profile **and** Pi agent file use the same string) |
| 13 | Every `model:` pin names an id the provider actually serves — verified against `/v1/models`, not remembered |
| 14 | Before declaring a delegation tool missing, the codemode namespace (`ALL_TOOLS` / `searchTools`) and the `paseo` CLI fallback were both checked |

## References

- `scripts/audit-pins.sh` — one-shot audit of every profile/agent model pin against the live router
  (`--probe` also verifies each group member serves the model its id claims)
- `../verify-subagent-claims/SKILL.md` — re-derive subagent claims before trusting them
- `../audit-report-format/SKILL.md` — canonical report contract for the Phase 4 output
- `../writing-plans/SKILL.md` — how to write the Phase 1 plan
- `../systematic-debugging/SKILL.md` — used by the coder once a finding is classified `product-bug`
