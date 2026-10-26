---
name: project-bootstrap
description: Bootstrap or work inside a GAS + Sheets webapp project. Use for any edit (UI, server, tests, docs) — provides architecture mental model, gotchas, deterministic editing, batch runner, perf, and pitfalls.
license: MIT
metadata:
  author: van90bg
  version: "1.0"
  category: gas
  triggers: ["gas project", "apps script project", "rollcall", "sheets webapp"]
---

# Project Bootstrap — GAS + Sheets Webapp

> Generic template derived from `van90bg/attendance-portal` (RollCall v2). Adapt `Repo facts` to your repo; keep the workflow (deterministic edit, CRLF, token system, verify) as-is.

## Repo Facts (adapt to your repo)

- **Source:** Google Apps Script WebApp + Google Sheets. Example: 17 `.gs` files (Code/Config/Spreadsheet/Cache/Repo/Service/Logic) + `index.html` (GAS template) + `styles.html` + 9 `app-*.html` modules (Vanilla JS, shared global scope) + `tests/` (261 tests via `node:test`).
- **Deploy:** `git push` → CI `clasp push` (user runs `clasp deploy` manually). CI may be late — check `gh run list --limit 5` (`.head_sha`) before concluding a bug.
- **Example structure:** see `examples/rollcall/` for full file list, API table (19 `*Api` endpoints), and sheet schemas (7 sheets).

## Architecture Mental Model (read before fixing)

- **Task state machine:** `open` (write `LISTED_AT`/timeRef) → `attend` (write `SCANNED_AT`/timeScan) → `done`. Log row `PENDING`/`PRESENT`/`ABSENT`/`EXTRA`.
- **Epoch is truth** for counters/sort (`listedAtEpoch`/`scannedAtEpoch`); text `HH:mm:ss` loses date across midnight.
- **Layers:** `*Api` (DEFENSE try/catch → `{ok:false}`) → Service (gate + `LockService` + business) → Repo (sheet + versioned cache) → Sheets.
- **Fail-safe order:** write supplementary data before primary status (e.g., `markUnscannedAbsent` → `updateTaskStatus(DONE)`) — retry is idempotent.
- **Gates:** `requireRole_(min)` at service layer on every function receiving client input (not only `*Api` wrappers — `google.script.run` can call any global).

## Recurring Gotchas (don't regress)

- Extra row `status` param — strangers in phase 2 = `EXTRA`, not `PRESENT`; phase 1 of empty task = `PENDING`.
- Lazy `staffIndex` cache gap — preload via `warmStaffCacheApi` on app open.
- Date serialization — never return `Date` via `google.script.run` (becomes `null`); return `text+epoch`.
- Mobile card desktop rule leak — `td:nth-child(n)` specificity beats mobile base; override with `tbody td:nth-child(n)`.

## Deterministic Editing (required for CRLF + i18n files)

```python
path = r"..."
with open(path, 'r', encoding='utf-8-sig', newline='') as f:
    content = f.read()
# exact string replace, assert count==1 per anchor, anchor includes \r\n
with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(content)
```

- Verify: `head -c 3 file | xxd -p` not `efbbbf` (BOM) · CRLF counts · `new vm.Script` for .gs · CSS brace balance.
- Large blocks: write to temp `.txt` then splice via index to avoid 8K token limits.
- See `examples/rollcall/references/deterministic-batch-runner.md` for collapsed multi-file runner skeleton (avoids write-last-wins bug).

## Design Tokens (example)

- 92 tokens in `:root` — semantic colors, `--space-1..8` (4pt grid), `--text-3xs..8xl`, `--radius-2xs..full`, `--header-h`. Never hard-code `hex`/`px` outside `:root` (exceptions: 1–3px micro, `#fff`/`#000`, fallback `var(--x,#hex)`, runtime px).

## Verify Workflow

- `npm test` (runs `test:css` + `test:gs` guards first) · `node scripts/audit-css.js` · `node scripts/audit-gs.js` · `node scripts/audit-docs.js` · `node scripts/audit-style.js --strict` · `node scripts/audit-ui.js`.
- CDP: `node scripts/build-local.js` → `node scripts/cdp-helper.js open "file:///…/index.local.html?t=N"` — geometry is truth.

## References

- `examples/rollcall/references/` — `architecture-gotchas.md`, `deterministic-batch-runner.md`, `slot-fueled-classification.md`, `mockup-design-language.md` (real-world details).

## Output Format

Follow the host repo's `AGENTS.md` if present, otherwise `../audit-report-format/SKILL.md`: `TL;DR` + table `| # | Sev | Issue | Location | Fix |` + markers 🔴🟠🟡 + Rule check. See host repo for full spec.
