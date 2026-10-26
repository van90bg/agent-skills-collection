---
name: debate
description: Three-model deliberation through subagents — consensus debate (default), adversarial red-team (--redteam), two-phase code audit (--audit). Sequential, cap 3, lean for low-RAM and free quotas. Use for debate, brainstorm, critique, converge, red-team, stress-test, review, audit.
license: MIT
metadata:
  author: van90bg
  version: "1.0"
  category: core
  triggers: ["debate", "brainstorm", "critique", "converge", "red-team", "stress-test", "review", "audit"]
---

# Debate — one skill, three modes

Select mode from invocation:
- default (`/debate <q>`): consensus debate, converge on agreement.
- `--redteam` (`/debate --redteam <position>`): assigned-target attacks, converge on exhaustion, not consensus.
- `--audit` (`/debate --audit <target>`): two-phase audit — broad find, then red-team top findings.

## When to Use

- **Consensus debate** (`/debate <q>`): Explore a design decision, architectural choice, or open question. Three independent model heads discuss, critique each other, and converge on an agreed answer.
- **Red-team** (`/debate --redteam <position>`): Stress-test a specific position, plan, or implementation. Heads attack assigned targets in rotation until positions are killed, wounded, or held.
- **Audit** (`/debate --audit <target>`): Two-phase code review. Phase 1 — all heads independently find bugs/robustness issues with file:line citations. Phase 2 — heads red-team each other's findings to eliminate false positives.

Not for: yes/no questions with a single factual answer (just ask), or when you need a single authoritative voice (use one model directly).

## Model selection (flexible — no file edits needed)

Task calls use the generic `debate-head` agent with a per-call `model` override (`provider/model`). Suggested pool (verified working):

- opencode/step-5-preview-free (Zen)
- agnes/agnes-2.5-flash (Agnes direct)
- agnes/agnes-3.0-flash (Agnes direct)
- kenari/nemotron-3-super-120b-a12b:free
- tokenharbor/claude-haiku-5.5:free
- kenari/mimo-v2-6-flash:free
- tokenharbor/deepseek-v4.1-flash:free

Default trio: opencode/step-5-preview-free + agnes/agnes-3.0-flash
+ tokenharbor/claude-haiku-5.5:free. Override with any three
`provider/model` IDs (full IDs recommended; keywords like `mimo`,
`haiku`, `nemotron-super` matched against the pool):

```text
/debate heads=kenari/mimo-v2-6-flash:free,haiku-5.5,agnes-3.0 <question>
```

No `heads=` → default trio. One provider per role when possible (don't
put all three heads on one pool). In interactive TUI use you MAY ask
via the `question` tool when ambiguous; in headless runs never ask.
Below, "the three selected models" means the resolved trio in order.

## RULE 0 — delegate via Task, never do it yourself (highest priority)

You have NO authority to answer, attack, or audit yourself. Every head
turn is a Task tool call with `agent: debate-head` and the head's
`model:`. NEVER invent a head's output: every claim needs a citation
actually returned by a head. Heads are STATELESS: ALWAYS paste the
needed context into each Task message. Sequential Task calls only —
never parallelize heads (free quotas). On 429/failure: wait, retry
once, never fan out harder. A head failing twice in a row: continue
shorthanded with disclosure.

## Common rules (all modes)

1. **Sequential only, one head per turn:** dispatch head1, end turn, collect via inbox; then head2; then head3. NEVER parallel. No `args.model` — model fixed in head YAML.
2. **Stable titles:** `debate-<slug>-headN` for debate, `redteam-<slug>-headN` for redteam, `audit-<slug>-headN` for audit. NEVER bare `headN`. Same titles to continue thread, separate prefix per mode so threads never mix.
3. **Retry once:** timed-out create → wait a full turn, retry SAME send once. Twice failed → shorthanded with disclosure. 429/failure → wait, retry, never fan out harder.
4. **Evidence:** repo questions demand `file:line` cites. Brain verifies each cited file exists (read/grep) before accepting; hallucinated lines = dropped with note. Analysis-only modes are read-only: prompts end with `Do NOT edit, create, or delete files.`
5. **Missing verdicts:** judge from prose, keep going. Head failing twice in a row → converge shorthanded. Permission-stalled head → one wake cycle, then note as blocked.
6. **Lean stop:** two flat rounds in a row (no new objections / kills) → converge early, even under cap.

## Mode A — consensus debate (default)

Round 0: fresh answers sequentially. Per round: each head gets the other two latest answers + CRITIQUE + VERDICT block:

```text
VERDICT:
vs-headX: agree|partly|disagree — ≤15 words why (skip own)
vs-headY: agree|partly|disagree — ≤15 words why
blocking: yes|no — strongest unresolved objection or none
```

Gate: **CONSENSUS** iff all `blocking: no` AND zero `disagree` → converge immediately. Else if rounds < cap 3 → next round focused on blocking objections. Else converge listing remaining disagreements with holder + best reason. Honor explicit `debate N rounds`.

Converge as: three finals + how-the-debate-moved bullets + synthesis flagging genuine splits.

## Mode R — red-team (`--redteam`)

Each head attacks exactly ONE assigned target. Rotate: R1 `h1→h2, h2→h3, h3→h1`; R2 `h1→h3, h2→h1, h3→h2`; alternate. Send ONLY the target's latest answer, not all three.

Order: "Attack this position. Find factual errors (cite file:line), logical gaps, hidden assumptions stated as facts, counterexamples, worst-case readings, what would collapse it. Attack the POSITION, never the head. A hit without file:line or concrete counterexample is not a hit." End with:

```text
VERDICT:
vs-<target>: kill|wound|hold — ≤15 words why
blocking: yes|no — single hit that must be answered, or none
```

`kill` = refuted (say what refutes it). `wound` = damaged but standing (state new boundary). `hold` = honest attack, nothing found (say what you tried). Stop when a full round adds zero NEW hits OR cap 3. Converge as: surviving → wounded (with new conditions) → killed (with refutation) → one-paragraph what-to-believe.

Cost: 3 attacks/round, cheaper than debate's 6 critiques. Prefer for stress-test.

## Mode C — audit (`--audit <target>`)

Phase 1 — find: each head audits read-only. "Audit <target>. Read AGENTS.md first if present. Read files before answering (min 3 for scoped targets). Return numbered findings: severity (P0 blocker/correctness/security, P1 likely bug/real impact, P2 hygiene/nit) + file:line + one-line what + one-line why." Merge, dedupe, keep author tag per finding (`[h1]`, `[h2]`, `[h3]`).

Phase 2 — confirm (only top max 8 P0/P1; P2 reported as-is `unverified`; zero P0/P1 → skip): partition so **no head attacks its own findings** — h1 attacks h2-authored, h2 attacks h3-authored, h3 attacks h1-authored (deduped items keep first author; overflow round-robin). Same ATTACK order as Mode R plus "false positive? wrong severity? already handled elsewhere? not exploitable?" Verdict per finding `keep|kill` mapped to `hold|kill` (`wound` = keep narrowed with new boundary). Default 1 round, cap 3, stop when a round adds zero new kills.

## Checklist

- [ ] Mode selected (consensus / red-team / audit)
- [ ] Three models resolved (default trio or `heads=` override)
- [ ] Round 0: all three heads tasked with faithful question
- [ ] Consensus: critique rounds with VERDICT blocks; gate check after each
- [ ] Red-team: target rotation per round; kill/wound/hold per attack
- [ ] Audit Phase 1: findings merged, deduped, tagged with author head
- [ ] Audit Phase 2: no head attacks own findings; file:line verified by supervisor
- [ ] Convergence: remaining disagreements or refutations surfaced with attribution

## Output Format

**Consensus mode:**
```
TL;DR ✅ Consensus reached after N rounds — <one-line conclusion>

| # | Head | Position (final) | Key change from debate |
|---|------|------------------|------------------------|
| 1 | <model-A> | <position> | <what moved> |
| 2 | <model-B> | <position> | <what moved> |
| 3 | <model-C> | <position> | <what moved> |

Agree: <where all three align>
Differ: <remaining disagreements + holder + best reason>
```

**Red-team mode:**
```
TL;DR 🔴 <position> — killed | wounded | survived

| Round | Attacker → Target | Verdict | Key hit / refutation |
|-------|-------------------|---------|----------------------|
| 1 | h1 → h2 | kill/wound/hold | <what happened> |
| 2 | h1 → h3 | kill/wound/hold | <what happened> |

Surviving: <positions that survived, attacks named>
Wounded: <positions with new boundary conditions>
Killed: <positions with refutation>
What to believe: <one-paragraph synthesis>
```

**Audit mode:**
```
## Audit: <target>

### ✅ Confirmed (survived red-team)
- [P0/P1] file:line — what + why (attacks survived named)

### 🔴 Killed in red-team (were false positives)
- <claim> — refutation

### ⚠️ Unverified (P2 and beyond-scope, no red-team)
- <claim> — file:line

### Synthesis
<overall health + top 3 actions in priority order>
```

Confidence thresholds: Blocker/security always reported; Major ≥70; Minor/Nit ≥80.

## References

- AgentSkills spec: https://opencode.ai/docs/skills
- Template: `templates/SKILL-TEMPLATE.md` (in this repo)
- Host repo `AGENTS.md` (if defined): output style override
