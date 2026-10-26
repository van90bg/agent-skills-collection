---
name: audit-report-format
description: Canonical output contract for every audit, review, security scan, or post-fix report — TL;DR verdict, severity markers, numbered findings table, rule check, empty state, and grouping for large reports. Use when writing or reviewing any P0/P1/P2 report, or when a report needs to be consistent across agents and PRs.
license: MIT
metadata:
  author: van90bg
  version: "1.0"
  category: core
  triggers: ["audit report", "review format", "findings table", "p0 p1 p2", "report template"]
---

# Audit Report Format — One Contract for Every Report

> The reader must know **pass/fail in 10 seconds**, then be able to act on every row. A report without anchors and severity is narration, not an audit.

If the host repo defines its own report law (e.g. an `AGENTS.md` report section), that law wins; this skill is the default and the cross-repo baseline.

## 1. Skeleton

```markdown
## Audit Report: [Component / Feature]

### TL;DR
✅ Approve — 0 P0 · 2 P1 · 5 P2 | ⚠️ Needs review — 1 P0 | 🔴 Blocked — 3 P0

**Rule check:** A: <rule> · B: <rule> · C: <rule>

| # | Sev | Issue | Location | Fix |
|---|---|---|---|---|
| P0-1 | 🔴 P0 | ... | `Code.gs:getMetaApi` | ... |
| P1-1 | 🟠 P1 | ... | `adapter/api-gas.js` | ... |

### Architecture Strengths (N/7)
...

### Known Issues
...

### Recommendations
...

**Overall verdict:** ...
```

Order is fixed: **verdict → rule check → table → detail → next step**. Never open with background.

## 2. Verdict Line

One line, no period at the end, counts first:

| Verdict | Use when |
|---|---|
| `✅ Approve — 0 P0 · X P1 · Y P2` | Mergeable; P1/P2 may follow |
| `✅ Clean — 0 P0 · 0 P1 · 0 P2` | Nothing found; add scanned scope |
| `⚠️ Needs review — N P0` | P0 exists but needs a human decision |
| `🔴 Blocked — N P0` | Cannot merge/deploy until fixed |

Empty state is still a report: `✅ Clean — 0 P0 · 0 P1 · 0 P2` + `Scope scanned: ...`.

## 3. Severity

| Marker | Level | Meaning | Action |
|---|---|---|---|
| 🔴 | P0 | Data loss, auth bypass, unusable flow, invariant broken, gate bypassed | Must fix before merge |
| 🟠 | P1 | Broken layout, hard-to-use flow, wrong behavior with a workaround | Should fix soon |
| 🟡 | P2 | Cosmetic, consistency, cleanup, docs polish | Nice to have |

- Number per severity: `P0-1`, `P0-2` → `P1-1` → `P2-1`.
- When in doubt between P0 and P1, ask: *can a user lose data, bypass a gate, or complete the task at all?* If yes → P0.
- Review skills may add a `Conf` column (0–100): blocker/security always reported; major ≥70; minor/nit ≥80; below threshold dropped silently.

## 4. Findings Table

Required columns: `# | Sev | Issue | Location | Fix`. Review skills add `Conf`; verification skills add `Evidence`.

- **Every claim carries an anchor**: `file:function()` preferred, `file:line` acceptable. Never "some places", "seems", "looks like".
- **One issue per row.** Do not merge a layout bug and a missing test into one line.
- **Fix is an action**, not a restatement: `add min-width: 0 to the flex child`, not `fix overflow`.
- **Location is the source of truth**, not the symptom: point to the function that decides, not the CSS rule that reveals it.
- Rows sorted P0 → P1 → P2; within a severity, highest impact first.
- More than 5 issues: add a short themed grouping (`### Group: Locking`, one bullet per issue) **before** the table.

## 5. Deep-Audit Sections

Use only the sections that carry content:

```
### Architecture Strengths (N/M)   — what is already correct, counted
### Code Quality Metrics            — lines, functions, tests, duplication
### Test Suite Status               — pass/fail/skip, with the command
### API Surface                     — client ↔ server endpoints
### UI Patterns                     — reusable patterns and drift
### Known Issues                    — pre-existing, not introduced here
### Recommendations                 — ordered, actionable
### Next Steps                      — who does what next
```

"Strengths (N/7)" must be a real count against a named checklist, not praise.

## 6. Rule Check

One line, only when code changed or the audit invokes project law:

```markdown
**Rule check:** A: no dead code (§2.4) · B: tokens only (§2.5) · C: docs synced (§2.8)
```

- 2–3 rules max, each with the section that defines it.
- If no project law exists, use the audit's own invariants (e.g. `A: no client-only gates · B: batch I/O · C: regression test added`).

## 7. Writing Rules

1. **Counts before prose.** "3 P1, all in the adapter" beats a paragraph.
2. **No paragraph longer than 3 lines** without a break or a bullet.
3. **No unanchored claim.** If you cannot anchor it, it is an open question, not a finding.
4. **No vague recommendation.** Every row says what to change and where.
5. **No inflated severity.** P0 means stop-the-line; using it for polish destroys the signal.
6. **No silent drops.** A false positive from an agent is retracted in the report, with the test that killed it (see `verify-subagent-claims`).
7. **No history rewrite.** Changelogs and progress logs are append-only; correct the future, not the past.

## 8. Anti-Patterns

| Don't write | Write instead |
|---|---|
| "There are some color inconsistencies and small buttons" | `P2-1 🟡 \| Buttons 32px < 44px kiosk floor \| components.css:.btn \| raise min-height to var(--touch-min)` |
| "Should refactor this component" | `P2-3 🟡 \| Same card markup duplicated in 3 views \| view-a.js:renderCard, view-b.js:renderCard \| extract to shared renderer` |
| "Code is not optimized" | `P1-2 🟠 \| getValues() inside row loop → 200 calls/scan \| ScanService.gs:writeRows_ \| read range once, write once` |
| "Tests pass" | `Tests: 574 pass / 0 fail / 14 skipped (node --test)` |
| "Fixed the bug" | `Fix: guard headers.indexOf() < 0 in ScanService.gs:writeRows_; regression test scan-header.test.js` |

## 9. Integration Points

- **Before commit:** run the repo verify command, then attach the findings table to the PR description.
- **Before a plan:** copy open P0/P1 rows into the plan's "Pre-audit findings"; the plan must contain a fix step for each.
- **After verify:** report measured results, not intentions: `audit:tokens: 0 raw values · tests: 582 pass, 1 pre-existing fail`.
- **After subagent work:** verify each claim first; only VERIFIED rows enter the table (`verify-subagent-claims`).

## 10. Quick Reference

`references/quick-ref.md` — copy-paste skeleton, severity table, pre/post checklist. Read it when writing a report under time pressure.

## Related Skills

- `../verify-subagent-claims/SKILL.md` — turn agent output into evidence-backed rows.
- `../webapp-ui-ux-audit/SKILL.md` — the audit that produces these rows.
- `../docs-code-drift-audit/SKILL.md` — docs↔code findings with the same contract.
- `../gas-webapp-review/SKILL.md` — GAS-specific failure modes and confidence scoring.
