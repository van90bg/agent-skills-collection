---
name: gas-webapp-review
description: Review Google Apps Script webapps served via HtmlService. Use when the project uses doGet/doPost, HtmlService templates, google.script.run, Session.getActiveUser(), CacheService/LockService, or Sheets as DB. Covers failure-modes checklist, confidence scoring, and optional MoA second opinion.
license: MIT
metadata:
  author: van90bg
  version: "1.1"
  category: gas
  triggers: ["gas review", "apps script audit", "sheets webapp", "htmlservice review", "lockservice", "cacheservice"]
---

# GAS Webapp Review — Failure Modes & Confidence

> Use for: post-feature diff review, pre-deploy sanity check, or full-base audit of attendance/queue/kiosk GAS webapps. Default scope is `git diff` (unstaged); caller may override.

## Approach

- **Scope:** `git diff` by default. For non-git projects, read current files and audit the full base.
- **Stages:** Requirements → Correctness → Quality → Testing → Security/Performance.
- **Confidence 0–100:** Blocker/security always reported; Major ≥70; Minor/Nit ≥80; below threshold dropped silently.
- **Verdict:** `Approve` / `Request Changes` / `Comment`.

## Failure Modes Checklist (GAS webapps)

- `getUserRole()` falling back to `'admin'` on exception — must fail closed.
- Lock helper swallowing timeout and returning `null` → callers must check `{__lockError:true}`, **stop the mutation**, and surface a user message. Running the write outside the lock is worse than failing.
- `genTaskId() = Date.now().toString(36)+Math.random()` (~1ms) — use `Utilities.getUuid()` (RFC4122 v4).
- Client cooldown early-return bypass via clock skew — server is sole authority.
- Blind `CacheService.put(key)` losing concurrent writes — must read-merge-write.
- `queue.slice(idx+1)` retry dropping subsequent items — per-item retry counter.
- `getLogTail()` including header when `startRow <= 1` — use `Math.max(2, lastRow - tailRows + 1)`.
- `var SS = _ensureSS()` at module scope caching `null` — use getter function.
- Task metadata helpers calling `getDataRange().getValues()` in hot path — cache with short TTL keyed by id.
- Flush ordering: `setValues` must succeed before `cache.remove(batchKey)`.
- Reset during active batch — inside write lock, read pending and abort if unflushed entries exist.
- Cache invalidation limited to 2 date keys — use versioned keys `prefix:v1:{key}`.
- Role-mutating APIs (`setAdminEmails`, `setSpreadsheetId`) must invalidate role cache.
- Client-supplied timestamps in write path breaking cooldown — use server `new Date()` + grace window.
- Deep link `#id:<id>` without existence check.
- `appendRow` column order vs header — count lengths, off-by-one writes to wrong column.
- `headers.indexOf('X') === -1` used as index → `String(undefined)` — guard `< 0`.
- Single cache invalidation helper called from every mutation path (most forgotten: `attListCache`).
- Client flush gate `_pendingScanCount` — skip RPC when 0 (~240 calls/hour/tab saved).
- `executeAs USER_ACCESSING` requires server gate on every mutator (client hiding button is not a gate).
- Cooldown value mismatch client vs server — single source of truth.
- **Gate inside `try`** — a `requireRole_` call wrapped in a broad `try/catch` can be swallowed and execution continues. The gate must run before the guarded block, or the catch must rethrow authorization failures.
- **Missing idempotency** — every write API needs an idempotency guard (`idemGuarded_` or equivalent) keyed by API + user + client key, with a bounded TTL. A retried scan after a timeout must return the prior result, not write a second row.
- **GAS I/O constitution** — `getValues()` the whole range once → process in memory → `setValues()` once. `getValue` / `setValue` / `appendRow` inside a loop is a P1 (quota + latency), and under a lock it is a P0 for contention.
- **Ad-hoc cache access** — the only cache path is the project's `cachedJson_` / `cachePut_` helpers. Direct `CacheService` calls bypass invalidation and read-merge-write.
- **Anonymous kiosk = operator** — a client-hidden button is not a gate. Any mutator reachable from a kiosk session still enforces the server-side role/station check.
- **Server clock is the source** — never trust a client timestamp for cooldown, ordering, or audit fields; use server time plus an explicit grace window.
- **Supplemental (archived prompts):**
  - Every **global** function callable via `google.script.run` (not only `*Api` wrappers) must have `requireRole_(min)` + DEFENSE try/catch. Report all missing gates.
  - `LOG_COLS`/sheet column sync between `ensureSheets_` and all `setValues`/`appendRow` — drift = silent data corruption.
  - **Epoch is truth** — never use text `HH:mm:ss` for logic/counters/sort (loses date across midnight); use epoch numbers.
  - `Session.getScriptTimeZone()` used consistently; empty states (empty sheet/task/cache expiry) must not crash.
  - **Cross-boundary:** every type/value crossing a boundary (`google.script.run` payload, queue, event) needs an explicit branch at the consumer dispatch (switch/router/handler) — silent drop = P0. *(criteria: Provable, Actionable, Unintentional, Introduced in patch, No hidden assumptions, Proportionate rigor)*

## Minimal UI/A11y Checks

Backend reviewer's quick pass only. For a full UI/a11y audit, use `webapp-ui-ux-audit`.

- `th[scope="col"]` · sort headers `aria-sort` · filter `role="listbox"` + `aria-label` · decorative icons `aria-hidden="true"` · dynamic regions `aria-live="polite"` (remove from static spinners) · `prefers-reduced-motion` for scan-line.

## GAS Quotas Quick Reference

| Resource | Limit | Implication |
|---|---|---|
| Execution | 6 min | Batch or use triggers |
| CacheService | 100KB/key, evictable | Never source of truth; slim payload ≤90KB |
| LockService | 10s default | Keep lock scope minimal |
| UrlFetchApp | 20MB / 60s | Paginate |
| Concurrency | Single execution | Use LockService |

## MoA Second Opinion (optional)

For high-stakes reviews (pre-deploy). Scope doc must be self-contained (reference models have no file access). Dispatch via MoA provider, then host merges (dedupe, keep severity, flag disagreements).

**Before concluding "the fix didn't work":** check the deployed build, not just the local tree. Run `gh run list --limit 5`, then verify the live web-app URL / deployment SHA. CI lags and users often test a stale deployment; a correct fix on an old build looks like a failed fix.

## Output Format

Follow the host repo's `AGENTS.md` if present, otherwise `../audit-report-format/SKILL.md`: `TL;DR` 1 line (`✅ Approve — 0 P0 · 2 P1`) + table `| # | Sev | Issue | Location | Conf | Fix |` + markers 🔴 P0 · 🟠 P1 · 🟡 P2 + Rule check `A/B/C`. Confidence: Blocker always, Major ≥70, Minor/Nit ≥80. Empty: `✅ Clean — 0 P0 · 0 P1 · 0 P2 (scope)`.

## References

- `examples/rollcall/` — real-world GAS attendance webapp (17 .gs + 9 HtmlService modules, 261 tests) as worked example.
- `../webapp-ui-ux-audit/SKILL.md` — full UI/a11y/performance audit.
- `../security-review/SKILL.md` — source→sink security pass.
- `../audit-report-format/SKILL.md` — report contract.
