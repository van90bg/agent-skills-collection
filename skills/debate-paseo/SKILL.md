---
name: debate-paseo
description: Paseo-native multi-head deliberation. Three independent heads, critique rounds, VERDICT/consensus gate, plus red-team and code-audit modes. Sequential by default, three heads on a 16 GB host (two when RAM is low); uses Paseo agents, labels, and finish notifications. Use for /debate-paseo, debate, brainstorm, critique, converge, red-team, or audit inside Paseo.
license: MIT
metadata:
  author: van90bg
  version: "1.1"
  category: core
  triggers: ["debate-paseo", "multi-head deliberation", "converge", "red-team", "paseo agents"]
user-invocable: true
---

# debate-paseo — Paseo-native deliberation

**User's additional context:** $ARGUMENTS

You are the **chair**, not a head. You have no authority to answer the question
yourself. Every substantive claim must come from a head agent. Your job is to
dispatch, collect, verify evidence, parse verdicts, and synthesize.

Paseo tool names below are the MCP names (`create_agent`,
`send_agent_prompt`, `get_agent_activity`, ...). Some providers expose them with
a `paseo_` prefix (`paseo_create_agent`); harnesses given the Paseo MCP server
namespace them (`mcp__paseo__create_agent` in Pi). Match by the trailing name and
use whichever form the live schema shows — read the schema before the first call
instead of assuming one form.

## Modes

- `/debate-paseo <question>` — consensus debate. Default.
- `/debate-paseo --redteam <question>` — assigned-target attacks; converge on
  exhaustion, not agreement.
- `/debate-paseo --audit <target>` — two-phase audit: broad find, then
  red-team the top findings.

Optional: `/debate-paseo --heads 2 <question>` to force two heads,
`--rounds N` to cap critique rounds, `--clean` to archive heads at the end.

## Rule 0 — never answer for the heads

- Do not write the answer, the critique, or the verdict yourself.
- Do not silently replace a failed head with your own opinion.
- A missing head is reported as `missing (reason)`.
- Synthesis may organize, verify, and attribute claims; it may not invent them.
- If every head fails, stop and report the failure. Do not fake a debate.

## Preflight

1. Parse the mode and question. If the question is empty, ask once.
2. Call `list_profiles`. If profiles exist, read their `notes` and use the
   matching profile's provider/model/mode/thinking/features. Profiles beat the
   roster below. If none exist, use the roster.
3. Call `list_providers`. Drop unavailable providers. If a roster provider is
   unavailable, fall back to another available provider/model and disclose the
   substitution. Never pretend a fallback is the original head.
4. Check resources if a shell is available (`free -m`). If available memory is
   under ~4500 MB, use **two heads** and say so. Use three heads when
   available memory is at least ~4500 MB, or when the user explicitly asks and
   accepts the risk. This host now has 16 GB RAM, so **three heads is the
   default**; fall back to two only if available memory drops below ~4500 MB
   or the user passes `--heads 2`.
5. Choose a short stable slug: lowercase ASCII, hyphenated, 2–5 words, <= 40
   characters. Titles are `debate-<slug>-headN`, `redteam-<slug>-headN`, or
   `audit-<slug>-headN`. Labels: `{ "debate": "<slug>", "role": "head",
   "head": "N" }`. Never use bare `head1`.
6. This is analysis-only. Do **not** create a workspace or worktree. Do not
   edit, create, or delete files. Do not run commands that modify state.

## Head roster (fallback when no profiles exist)

Profiles beat this roster. Without profiles, build the roster at runtime: three
heads from three **different provider families** that `list_providers` reports as
`available`, with each `provider/model` pinned from `list_models`.

| Head | Provider family | Mode | Lens |
|---|---|---|---|
| 1 | strongest available coding family | `plan` | systems, implementation, failure modes |
| 2 | a different family from head 1 | `plan` | edge cases, adversarial reading, missing evidence |
| 3 | a third family, else a different model from family 1 or 2 | `plan` | pragmatism, verification, cost/benefit |

Rules for the roster:

- Never copy a model id out of this file; model ids move. `list_providers` and
  `list_models` are the only source, and every substitution gets disclosed.
- Drop every provider whose status is not `available`.
- Prefer `plan` (read-only) for all heads. A head created with `build` or
  `full-access` **can** write files, so the no-edit suffix in its prompt is the
  only guard — never drop it.
- A provider that reports no `modes` (single-mode harnesses) cannot take
  `modeId`: omit `settings.modeId` for it instead of inventing a value.
- Fewer than three families available: run two heads and say so.

Do not use the same model for every head when alternatives exist. Do not let a
head choose its own model. Pin the provider/model at creation and keep it for
the whole debate. Change a model mid-debate only to recover from a provider
failure, and disclose it.

A head that also receives Paseo tools must be told explicitly not to delegate —
nesting debates behind a head breaks the chair's sequential accounting.

## Hard rules

1. **Sequential only, one head per turn.** Never create all heads at once.
   Create or prompt head 1, wait for it to finish, then head 2, then head 3.
   This is deliberate: Paseo agents stay alive, so keep memory use predictable.
2. **Reuse agent IDs.** Round 1+ uses `send_agent_prompt` on the same heads.
   Do not create new agents for a critique round.
3. **Wait for the finish notification.** Do not poll in a loop, send
   hurry-ups, or interrupt a reasoning head. If a notification never arrives
   and the agent is clearly stuck, check `get_agent_status` once, then
   `get_agent_activity`; retry the same send at most once.
4. **Evidence before acceptance.** For repo questions, require `file:line`.
   Verify cited files exist before accepting a claim. Drop hallucinated lines
   with a note. A claim without evidence is lower confidence.
5. **Read the final text from activity.** Notifications are best-effort. Use
   `get_agent_activity` for the final answer; if the summary is truncated, use
   `paseo logs <agentId>` through the shell or request a larger limit.
6. **Lean stop.** Two flat rounds in a row (no new objections or kills) means
   converge early, even under the cap.
7. **Cap 3 critique rounds** unless the user explicitly asks for a different
   count. Never exceed 5 without explicit confirmation.

## Round 0 — independent answers

For each head, in order:

```
create_agent({
  title: "debate-<slug>-headN",
  provider: "<provider/model>",
  settings: { modeId: "<plan|full-access>" },
  labels: { debate: "<slug>", role: "head", head: "N" },
  notifyOnFinish: true,
  initialPrompt: "<role + lens + question + evidence rules + no-edit suffix>"
})
```

Omit `workspaceId` so each head is created in the current workspace; never
create a worktree for a debate. Record `agentId`. Wait for the finish
notification before creating the next head.

Prompt template:

```
You are head N in a multi-head deliberation. Your lens: <lens>.

Question: <question>

Answer independently. Do not assume what the other heads will say. Do not
delegate to other agents. Read the relevant files before answering; for repo
claims cite file:line. Analysis only: do NOT edit, create, or delete any files,
and do NOT run commands that modify state.
```

## Critique rounds — consensus mode

Each round, for each head in order:

1. Send the head its own latest answer plus the other active heads' latest
   answers.
2. Require an updated answer and this exact block:

```
VERDICT:
vs-headX: agree|partly|disagree — <=15 words why
vs-headY: agree|partly|disagree — <=15 words why
blocking: yes|no — strongest unresolved objection or none
```

Skip the head's own row. Use the actual active head numbers. For two heads,
there is one `vs-` row per head.

Consensus gate:

- **CONSENSUS** iff every active head reports `blocking: no` and there is zero
  `disagree`.
- Otherwise, if rounds < cap, run another round focused only on the blocking
  objections.
- Otherwise converge and list remaining disagreements with holder + reason.
- Missing head: consensus is among active heads; disclose the gap.

## Red-team mode

Each head attacks exactly one assigned target:

- R1: h1 -> h2, h2 -> h3, h3 -> h1
- R2: h1 -> h3, h2 -> h1, h3 -> h2
- Alternate each round.

Send **only the target's latest answer**, not all three. Attack the position,
never the head. Require this block:

```
VERDICT:
vs-<target>: kill|wound|hold — <=15 words why
blocking: yes|no — single hit that must be answered, or none
```

Definitions: `kill` = refuted (say what refutes it); `wound` = damaged but
standing (state the new boundary); `hold` = honest attack found nothing (say
what was tried). Stop when a full round adds zero new hits, or at cap 3.

Converge as: surviving -> wounded (with new conditions) -> killed (with
refutation) -> one-paragraph what-to-believe.

## Audit mode

Phase 1 — find. Each head audits the target read-only. Read `AGENTS.md` first
if present. For scoped targets, read at least 3 files before answering. Return
numbered findings:

```
[P0|P1|P2] file:line — what — why
```

P0 = blocker/correctness/security; P1 = likely bug/real impact; P2 = hygiene.
Merge and dedupe, keeping author tags (`[h1]`, `[h2]`, `[h3]`).

Phase 2 — confirm. Only the top max 8 P0/P1 findings; P2 is reported as
`unverified`; if there are zero P0/P1, skip Phase 2. Partition so **no head
attacks its own findings**: h1 attacks h2-authored, h2 attacks h3-authored,
h3 attacks h1-authored; overflow round-robin. Same attack order as red-team,
plus: false positive? wrong severity? already handled elsewhere? not
exploitable? Verdict per finding `keep|kill` (map `wound` to keep-narrowed).
Default 1 round, cap 3, stop when a round adds zero new kills.

Report:

```
## Audit: <target>
### Confirmed (survived)
- [P0/P1] file:line — what + why (attacks survived named)
### Killed (false positives)
- <claim> — refutation
### Unverified (P2, no red-team)
- <claim> — file:line
### Synthesis
<health + top 3 actions in order>
```

## Failure handling

- `create_agent` error: retry once with the same provider/model, then fall back
  to an available provider and disclose.
- 429/quota: wait, retry once, never fan out harder.
- Timeout: check status once; retry the same send once; then mark
  `missing (timeout)`.
- Head fails twice in a row: converge shorthanded.
- Permission stall: call `list_pending_permissions`; approve read-only requests
  only; otherwise mark `blocked (permission)` and continue.
- Missing verdict: judge from prose and continue; do not invent a verdict.

## Converge — final output

```
## 1) Head 1 — <lens> (final)
<final answer>

## 2) Head 2 — <lens> (final)
<final answer>

## 3) Head 3 — <lens> (final)
<final answer>

## How the debate moved
- <bullet: objection -> resolution, or unresolved split>

## Where they agree / differ
- <attributed>

## Chair synthesis
<evidence-weighted synthesis; flag genuine splits; no invented claims>
```

For red-team or audit, use the matching report format above instead.

## Cleanup and continuation

- To continue the same debate, find the existing heads by title/labels and
  reuse their `agentId`s. Do not create duplicates.
- A new topic gets a new slug and new heads.
- On `--clean`, or when available memory drops below ~2500 MB, `archive_agent`
  the heads after the final answer. Do not `kill_agent` unless the user asks
  to delete them.
- Leave heads idle and reusable by default; they are the debate's memory.
