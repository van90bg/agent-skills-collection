---
name: verify-subagent-claims
description: Verify subagent findings before reporting them — re-derive each anchored claim with a deterministic command, classify VERIFIED / FALSE / UNVERIFIED, and publish the retraction. Use when an agent returns file:line findings, when two agents disagree, before writing a P0/P1 table or plan from agent output, or when the user asks "did you verify this?".
license: MIT
metadata:
  author: van90bg
  version: "1.0"
  category: core
  triggers: ["verify agent", "subagent findings", "check claims", "agent output", "false positive"]
---

# Verify Subagent Claims — Evidence Before Report

> Subagent output is a **list of hypotheses**, not a list of findings. A claim becomes a finding only after you re-derive it from the source with a command whose output you can show.

## When to Activate

- After **every** delegation, before summarizing to the user.
- Before writing `docs/plans/*` whose input is agent output.
- When two agents overlap or contradict — agreement is not evidence (they may share the same false premise).
- Before committing a fix list produced by an agent.
- When the user asks whether a report was verified.

Do not skip because "the agent pasted the code" — the paste may come from another file, an old revision, or a comment.

## The 4-Step Loop (per claim)

1. **Open the exact anchor.** `Read` with offset/limit or `sed -n '<a>,<b>p' <file>`. Read the source, not the agent's paraphrase.
2. **Re-derive with a deterministic command.** Count, grep, print the real signature. Never re-derive by eye. Record the command.
3. **Classify:**
   - `VERIFIED` — the command reproduces the claim.
   - `FALSE` — the command contradicts it; retract it publicly.
   - `UNVERIFIED` — no cheap test exists; it becomes an open question, never a finding.
4. **Normalize the anchor** before writing: `file:1234` → `file:function()` (line numbers drift after every batch).

## Re-Derive Recipes

| Agent claim | Re-derive with |
|---|---|
| "Metric X is missing/wrong" | Count per file, then sum: `grep -rhoE "function [A-Za-z0-9_]+Api\b" server/*.gs \| sort -u \| wc -l`, compare with the doc's number |
| "Symbol/feature Y does not exist" | `grep -rin "<exact_identifier>"` — use the identifier as spelled in code, not a paraphrase |
| "API has no gate / wrong role" | `awk '/^function <name>/,/^}/' server/<file>.gs`, then look for `requireRole_` / `isEditor_` in the **body**, not the wrapper comment |
| "Signature/arity differs from docs" | `grep -rn "^function .*Api(" server/*.gs` + the arity test if present |
| "Cache TTL / key / sheet name is wrong" | `grep -n "CACHE_KEYS\|SHEETS" -A40 server/Config.gs`, count the keys |
| "Docs contradict themselves" | `grep -rn "<number-or-label>" README.md SPECIFICATION.md AGENTS.md docs/ PROGRESS.md` |
| "Behavior inferred from a comment/label" | Remove comments; read the executing lines only |
| "Line 394 has bug Z" | Open lines 380–430; if the anchor drifted, find the function by name |

Numeric claims: run the repo's stats command first (`npm run stats`, `cloc`, test count) to eliminate drift. Prose claims (who is gated, what a flow does) have no automatic guard — use `docs-code-drift-audit`.

## Exit Conditions

- 100% of P0/P1 rows have a command + observed output.
- Every FALSE claim is named **and** the test that killed it is stated. A silent drop lets the next agent trust it again.
- Tally: `N verified · M dropped · K open question`. If `N+M+K` ≠ number of claims received, some claims were never examined.
- P2 sampling: verify at least one row per cluster instead of every cosmetic row.

## Failure Modes (seen in practice)

| Failure | What happened | Guard |
|---|---|---|
| **Undercount → false accusation** | Counted one file and concluded docs were wrong; symbols were spread across many files | Count per file, then total |
| **Ghost identifier** | Agent cited a paraphrased name; case-sensitive grep found 0 hits, so "feature absent" was declared | Grep the exact identifier from code |
| **Comment-based inference** | Claimed an API was ungated by reading the wrapper comment; the real gate sat in the service body | Read executing lines, not comments |
| **Stale line anchor** | `file:394` was correct two commits ago | Re-anchor to `file:function()` |
| **Two agents disagree** | Merged/averaged the two answers | Re-derive; drop whichever the command contradicts |
| **Pasted code from elsewhere** | Snippet looked authoritative but belonged to another module | Open the cited file and line range |

## Prevent It at Delegation Time

Put this in every agent brief:

> For each finding: paste the command you ran and its raw output, plus the symbol name exactly as it appears in the code. A finding that cannot be reproduced by a command is worthless.

- Narrow each agent to one file set and one question. "Audit everything" correlates strongly with invented detail.
- Ask for `file:function()` anchors, not line numbers.
- Ask for counts with the counting command, not just the number.

## Output Contract

Keep the standard report table and add an **Evidence** column:

```markdown
| # | Sev | Issue | Location (`file:fn()`) | Evidence (command → result) | Fix |
|---|---|---|---|---|---|
| P1-1 | 🟠 P1 | Lock helper returns falsy, caller continues | `Lock.gs:takeLockOrFail_` | `sed -n '40,58p' Lock.gs` → `return null` on timeout; caller has no guard | Stop mutation when falsy |
```

Immediately below the table, always include the retraction line:

> Retracted agent claim: "26 partials" — `grep -c "include_(" dist/index.html` returns 23; the doc is correct.

Then the tally: `7 verified · 2 dropped · 1 open question`.

## Anti-Patterns

- ✗ Trusting an agent because it pasted code (the paste can be stale or from another file).
- ✗ "Agent A and B agree, so it must be true."
- ✗ Writing findings first and verifying later "to save time".
- ✗ Dropping a false claim silently instead of retracting it.
- ✗ Spending the whole budget verifying P2 cosmetics while P0 rows are unverified.

## Related Skills

- `../docs-code-drift-audit/SKILL.md` — proactively audit docs↔code; this skill audits **agent output**.
- `../systematic-debugging/SKILL.md` — find root cause after the claim is VERIFIED.
- `../audit-report-format/SKILL.md` — the table contract these rows must satisfy.
