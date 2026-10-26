---
name: docs-code-drift-audit
description: Audit semantic drift between documentation and real code — run numeric gates to exclude what they already cover, then compare names and claims in six layers (T0–T5) — set-diff entities, turn prose into testable axioms, re-anchor references, and find dead labels/keys. Use when docs may be stale, after commits that skipped docs, before a release, or when onboarding. Docs-only fix; does not change code.
license: MIT
metadata:
  author: van90bg
  version: "1.0"
  category: core
  triggers: ["docs drift", "docs out of date", "documentation audit", "docs vs code", "stale docs"]
---

# Docs ↔ Code Drift Audit — When the Numbers Are Green but the Prose Is Wrong

> Goal: find places where documentation **contradicts** code that numeric gates cannot catch, then fix the **docs** (not the code) through an approved plan.

## When to Use / Not Use

- **Use:** docs feel old; N commits changed code without docs; before release; onboarding; before a large plan that needs ground truth.
- **Don't use:** a UI or runtime bug (use `webapp-ui-ux-audit`); a single wrong number (fix it directly with a deterministic edit).

## Three Principles

1. **Correct numbers ≠ correct prose.** A green gate is an *input*, not a conclusion.
2. **Only command output counts.** Every finding needs `file:function()` + the command that proves it. Agent claims must be re-derived first (`verify-subagent-claims`).
3. **History is immutable.** Lines in `PROGRESS.md` and changelogs describe the state *at that time* — never edit them; append a new line instead.

## T0 — Exclude What Numeric Gates Already Cover

Run the repo's own gates first and record the result in the plan's context. This proves the gate does not cover the prose layer.

```bash
npm test -- tests/contract-shape.test.js      # payload shape
npm test -- tests/api-arity.test.js           # signatures / arity
npm test -- tests/build-order.test.js         # include order
npm test -- tests/include-allowlist.test.js
npm test -- tests/repo-integrity.test.js
npm run stats                                 # canonical counts
```

Then narrow by blast radius: find the last docs change, list code files changed since, and audit the hottest ones first.

```bash
last=$(git log -1 --format=%cd --date=short -- README.md SPECIFICATION.md docs/)
git log --since="$last" --name-only --pretty=format:%h -- src server scripts | sort | uniq -c | sort -rn | head -12
```

## T1 — Set-Diff Entity Names (take names from code, not docs)

| Entity | Canonical source | Command to extract / count |
|---|---|---|
| Public API | server/service files | `grep -rhoE "function [A-Za-z0-9_]+Api\b" server/*.gs \| sort -u` |
| Views / sections | view files + HTML shell | `grep -rhoE 'id="view[A-Za-z]+"' index.html \| sort -u` |
| Sheets | config module | `grep -n "SHEETS" server/Config.gs` |
| Cache keys | config module | `grep -oE "[A-Z_]+:" server/Config.gs \| sort -u` |
| Design tokens | token stylesheet | `grep -cE "^\s+--[a-z0-9-]+:" css/tokens.css` |
| Partials / includes | build output | `grep -oE "include_\('[a-z-]+'\)" dist/index.html` |
| Frontend files | manifest script | `node -e "console.log(require('./scripts/_frontend-files.js').FRONTEND_FILES.length)"` |

Compare both directions with `comm`:

- **Code has · docs don't** → docs are missing an entity (an undocumented API is an API no gate describes).
- **Docs have · code doesn't** → ghost name; check `git log -S<name>` to see whether it was renamed or removed, then fix the docs.

## T2 — Turn Each Sentence into a Testable Axiom

| Claim type | How to test it | Trap |
|---|---|---|
| Role gate ("only admin can call X") | `grep -n "requireRole_('" ` in the **service body**, not only the API wrapper | The real gate may live in an intermediate `_` helper |
| State guard ("blocked when open") | Read the whole function; enumerate every `status` branch | Docs mention one branch; code allows two |
| Token value | `grep -n -- "--<token>:" css/tokens.css` | Token defined in one place, docs cite another |
| Range / technical number (e.g. timeout 20s vs 25s) | `grep -n "20000\|25000" adapter/api-gas.js` | Asymmetric thresholds read as "±" |
| "N keys / N columns" | Count object-literal keys by brace depth, or the header constant | Comment says A:P but the parser returns something else |
| Feature ("Offline: no") | T1 name set-diff + grep for `localStorage` / backlog code | A "known differences" section can stay frozen for years |
| Volatile counts (tests, partials) | `npm run stats` | Hand-copied numbers drift immediately |

## T3 — Re-Anchor Every `file:line` Reference

```bash
grep -n "^function <name>" server/*.gs
```

- Anchor drifted → switch to a **name anchor** `file:function()` (no line number).
- Function no longer exists → it is a ghost name (back to T1) or moved files (`git log --follow`).

Line anchors rot after every batch. Name anchors are the only stable form.

## T4 — Dead Labels, Ghost Keys, Orphan Claims

```bash
grep -rn "<LABEL_NAME>" server src adapter | wc -l    # ==1 → definition only, zero usage
grep -rn "<key_name>" server/Config.gs                 # ==0 → docs describe a deleted key
```

Docs that describe a dead label or a key absent from the config are P1. **Do not fix dead code in a docs commit** — file it as a separate issue.

## T5 — Classify, Report, Plan, Wait

- Output follows `audit-report-format`: TL;DR + rule check A/B/C + P0/P1/P2 table + grouping for >5 issues + next-step block.
- Write `docs/plans/YYYY-MM-DD-<slug>.md` with: context · decisions needing approval · file:line detail · verify plan · risks.
- **Stop and wait for approval** (`approved` / `LGTM` / `OK`). Do not edit docs before that.

## After Approval

1. Edit with a **deterministic script** (section 3 of the publishing/host rules): assert `count == 1` per anchor, preserve CRLF, write UTF-8 **without BOM**.
2. Verify: no LF-only lines, no BOM → re-run T0 → `npm test` → `git diff --stat` contains **only** docs + the plan.
3. Cross-check: the corrected number must be **identical in every document** (fixing one and forgetting two creates fresh drift).
4. Commit docs separately (one issue = one commit); a new guard, if added, gets its own commit.

## Worked Drift Examples (all gates were green)

| Docs said | Code actually did | Layer |
|---|---|---|
| "`dist/` ships mock data as fallback" | Production build never includes mock; only sound → core → adapter → views | T2 feature |
| "26 partials" | 23 partials + `index.html` | T0/T1 |
| "573 tests (559 pass)" | 574 / 560 at that run; now 577 / 563 — `npm run stats` | T2 volatile count |
| "Smoke test SKIP" | Smoke runs (boot + 4 flows); CI requires it | T2 feature |
| "§2.6 … FileName.gs:77" | Anchor drifted; no such line | T3 |
| "Cache key `attList`" | Key renamed; old key absent from `CACHE_KEYS` | T4 |

## Traps

- Running numeric gates, seeing green, and declaring docs fine — that is the exact failure this skill exists to catch.
- Trusting an agent finding without re-deriving it — you will "fix" docs to match a false claim.
- Editing old `PROGRESS.md` / changelog lines to match today — that erases history (append only).
- Changing only the line number instead of anchoring to the function — it will drift again.
- "While I'm here" code changes inside a docs commit — scope violation.
- Intentionally future-state docs (design docs, unexecuted plans) are **not** drift; ask the user first.

## Self-Acceptance

- [ ] Every finding has `file:function()` + command output; no "seems / some places".
- [ ] Proved the finding is **not** caught by an existing gate (if it is, propose a new guard instead).
- [ ] Old `PROGRESS.md` lines untouched.
- [ ] Plan written and approved before editing docs.
- [ ] `git diff --stat` after the fix contains only docs + plan.
- [ ] T0 + full test suite re-run, exit 0.
- [ ] Corrected numbers identical across every document.

## Related Skills

- `../verify-subagent-claims/SKILL.md` — verify the claims this audit consumes.
- `../audit-report-format/SKILL.md` — report contract.
- `../codebase-explorer/SKILL.md` — fast entity discovery before T1.
