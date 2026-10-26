# Quick Reference — Audit Report

## Copy-Paste Skeleton

```markdown
## Audit Report: [Component / Feature]

### TL;DR
✅ Approve — 0 P0 · X P1 · Y P2 | ⚠️ Needs review — A P0 | 🔴 Blocked — B P0

**Rule check:** A: <rule> · B: <rule> · C: <rule>

| # | Sev | Issue | Location | Fix |
|---|---|---|---|---|
| P0-1 | 🔴 P0 | ... | `file:function()` | ... |

### Architecture Strengths (N/M)
### Known Issues
### Recommendations

**Overall verdict:** ...
```

## Severity at a Glance

| Marker | Level | Test | Action |
|---|---|---|---|
| 🔴 | P0 | Data loss / auth bypass / task impossible / invariant broken | Stop, fix before merge |
| 🟠 | P1 | Broken or hard flow, wrong result with workaround | Fix soon |
| 🟡 | P2 | Cosmetic, consistency, cleanup | Optional |

IDs: `P0-1`, `P0-2` → `P1-1` → `P2-1`.

## Column Rules

| Column | Must contain | Must not contain |
|---|---|---|
| `#` | Severity-prefixed ID | "1", "2", "3" |
| `Sev` | Marker + level | Only "high/low" |
| `Issue` | Observable failure | "refactor", "improve" |
| `Location` | `file:function()` | File name only, no anchor |
| `Fix` | Concrete change | "investigate", "consider" |

## Before Writing

- [ ] Ran the repo's verify/test command and have real counts?
- [ ] Every finding has an anchor and a reproducer or code path?
- [ ] Severity assigned by impact, not by effort?
- [ ] Duplicates merged; one row per issue?
- [ ] Agent claims verified (`verify-subagent-claims`)?

## After Writing

- [ ] TL;DR states verdict + counts in one line?
- [ ] No "some places", "seems", "probably"?
- [ ] Every row has an actionable fix?
- [ ] >5 issues grouped by theme before the table?
- [ ] Rule check names the rules it enforces?
- [ ] Empty state includes scanned scope?

## Empty State

```markdown
✅ Clean — 0 P0 · 0 P1 · 0 P2

Scope scanned: `view-scan.js`, `ScanService.gs`, `scan.test.js`
```

## Post-Fix Report

```markdown
✅ Verified — 0 P0 · 0 P1 · 1 P2 (accepted)

| Check | Result |
|---|---|
| build | pass |
| tests | 582 pass / 0 fail / 14 skipped |
| a11y gate | 0 violations |
| tokens | 0 raw values |

**Accepted P2:** table header wraps at 320px — tracked as DEBT-14.
```

## Related

- `../SKILL.md` — full contract and anti-patterns.
- `../verify-subagent-claims/SKILL.md` — evidence column and retraction line.
