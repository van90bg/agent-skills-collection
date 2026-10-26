---
name: systematic-debugging
description: 4-phase systematic debugging — root cause BEFORE fix. Use for every technical bug — test failures, production bugs, unexpected behavior, performance issues. Required for emergencies, quick-fix temptations, or repeated failed fixes.
license: MIT
metadata:
  author: van90bg
  version: "1.1"
  category: core
  triggers: ["debug", "bug fix", "test failure", "flaky", "root cause"]
---

# Systematic Debugging — 4 Phases

> For every bug: `Iron Law — NO fixes before Phase 1 is complete.`

## Phase 1 — Root Cause Investigation

1. **Read error carefully** — full stack trace, line/file/code, don't skip warnings.
2. **Build tight feedback loop** — command that reproduces the exact symptom: test at seam, `curl`, CLI with fixture, headless browser assert, replay trace, `git bisect run`, differential. Loop must be fast, deterministic, **red-capable** (fails on bug, passes when fixed). Flaky → amplify (100×, stress, sleep). For GAS: a `.gs` sandbox loader plus a fake `google.script.run` that can inject one API failure at a time; run `npm test` for logic and `npm run smoke` for boot + flows.
3. **Check recent changes:** `git log --oneline -10`, `git diff`, `git log -p --follow`.
4. **Multi-component:** instrument every boundary (log in/out, env, state) — run once to collect evidence, then conclude.
5. **Trace data flow** — where does bad value originate? Follow up the call stack to the source; fix at source.

**Done when:** error read, loop ran red at least once, recent changes reviewed, evidence collected, component isolated, hypothesis stated. **STOP — don't proceed if you don't know why.**

## Phase 2 — Pattern Analysis

1. **Minimize repro** — cut input/caller/config one at a time, loop each time, keep only load-bearing parts.
2. Find working example in codebase.
3. Read reference implementation fully — don't skim.
4. List all differences working vs broken.

## Phase 3 — Hypothesis & Test

1. Form **3–5 falsifiable hypotheses**, rank by likelihood + cost. Each needs a prediction: "If X is cause, then observing Y will show Z." Show ranked list if user is present.
2. Test **one variable at a time**.
3. Tag temp logs with unique prefix (`[DEBUG-a4f2]`) for one-grep cleanup.
4. If you don't understand, say so.

## Phase 4 — Implementation

1. **Create failing test** (regression) before fix.
2. Fix root cause — **one change**, no opportunistic refactors.
3. Verify: single test → full suite.
4. **Rule of Three:** 3rd fix failed → STOP, don't try #4; question architecture (each fix exposing new coupling = wrong pattern) — discuss with user first.

## Red Flags (STOP → Phase 1)

"Quick fix, investigate later" · "try X and see" · "fix many places then test" · "skip test" · "probably X" · proposing fix before tracing data flow · Fix #4+ → architecture.

**Repo-specific (example):** CDP geometry (`getBoundingClientRect`, parent chain) is truth, screenshot is feel.

## Environment Truth — Verify the Build Before the Fix

Before concluding "the fix didn't work", prove which build the user is testing:

- **Local tree ≠ deployed app.** Check the deployment URL / build SHA, not only the working copy. CI can lag; a user can be on a stale deployment.
- **GAS:** `gh run list --limit 5` shows CI status and `.head_sha`; the live `/exec` URL is the deployment the user actually sees. A correct fix on an old deployment looks like a failed fix.
- **Browser cache:** hard reload, cache-busting query, or an incognito window. A stale service worker can serve old JS/CSS.
- **Truth sources, in order:** failing test → full test suite → smoke (boot + flows) → live deployment. A screenshot is feel; a computed value is fact.

When the evidence and the user's observation disagree, re-check the environment before re-opening the root cause.

## Integrated from Archived Prompts

- Parallel `grep`/`glob`, `thoroughness Quick/Medium/Thorough`; empty search → try ≥1 fallback before concluding absent.
- Worker hyperfocus: narrow `grep` first, read only needed ranges, prefer editing existing files, concise.
- Trace implementation to find defaults/config, cross-ref ≥2 places, copy signatures verbatim.

## Output Format

Follow the host repo's `AGENTS.md` if present, otherwise `../audit-report-format/SKILL.md`: `TL;DR` + table `| # | Sev | Issue | Location | Fix |` + markers. If using confidence (review), add `Conf` column and thresholds (Blocker always, Major ≥70, Minor ≥80).

## Related Skills

- `../verify-subagent-claims/SKILL.md` — verify a claimed root cause before acting on it.
- `../gas-webapp-review/SKILL.md` — GAS failure modes that often cause the bug.
- `../audit-report-format/SKILL.md` — report contract.
