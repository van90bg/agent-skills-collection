---
name: your-skill-name
description: One-line description — when to use this skill. Use when the user says "..." or asks to "...".
license: MIT
metadata:
  author: van90bg
  version: "1.0"
  category: core  # gas | web | core
  triggers: ["trigger phrase", "another trigger"]
---

# Your Skill Title

> One-line summary of what this skill does and when to use it.

## When to Use

- Bullet list of trigger phrases / file patterns / project signals that should invoke this skill.
- Be specific: `Use when the project uses doGet/doPost, HtmlService, Sheets as DB`.

## Procedure / Checklist

### Step 1 — ...

1. Do X
2. Do Y
3. Verify Z

### Checklist (if applicable)

| Category | Check |
|---|---|
| Example | Verify `requireRole_(min)` on every global callable via `google.script.run` |

## Output Format

Follow host `AGENTS.md §8` if present, otherwise:

**1. TL;DR 1 line** — `✅ Approve — 0 P0 · 2 P1` | `⚠️ Needs Review — 1 P0` | `🔴 Blocked — 3 P0`

**2. Table** — `| # | Sev | Issue | Location | Fix |` (+ `Conf` column for review skills) — one row per issue, `file:line` required, ≤1 line per cell.

- Markers: 🔴 P0 (blocker/security/data loss) · 🟠 P1 (break/hard to use) · 🟡 P2 (cosmetic)
- Confidence (review skills): Blocker/security always; Major ≥70; Minor/Nit ≥80; below → drop silently.
- Group by severity (P0 → P1 → P2), number as `P0-1`, `P1-1`.

**3. Verdict** — `Approve` / `Request Changes` / `Comment`.

**Anti-pattern (don't):**
> ✗ I looked through the code and saw some color inconsistencies and small buttons on mobile...

Replace with TL;DR + table with `file:line` + fix.

## References

- `../other-skill/SKILL.md` — related skill
- `references/details.md` — extra details (if any)
- Attribution line if adapted from an external MIT work (source repo, author, license, what changed).

## Examples (optional)

- `examples/<your-example>/` — real-world worked example.
