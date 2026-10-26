# Publishing Guide

## Format

Skills follow the [Agent Skills spec](https://opencode.ai/docs/skills) — a single `SKILL.md` per skill with frontmatter `name`, `description`, `license`, `metadata` (author, version, category, triggers). Body uses `When to Use` → `Procedure/Checklist` → `Output Format` → `References`.

Generalization rules applied when extracting from RollCall:

- Replace hardcoded paths like `C:\Users\Van90BG\...` with `{{REPO_ROOT}}` or `examples/rollcall/`.
- Replace RollCall-specific constants (`StaffData 20 cols`, `LOG_COLS`, `ATTENDANCE_TASK`) with generic placeholders + example callout.
- Keep English for publish; Vietnamese notes archived in `examples/rollcall/README_VI.md` if needed.
- Output format is standardized to the host repo's `AGENTS.md` report law (`TL;DR` + `| # | Sev | Issue | Location | Fix |` + markers) — that law is the SSOT if present; otherwise the canonical contract is `skills/audit-report-format/SKILL.md`.
- **Attribution:** if a skill adapts an external MIT work, keep a credit line in the body (source repo, author, license) and state what was removed or changed for the target context. Examples in this collection: `mobile-native` (Emil Kowalski), `design-taste` (Thientan Soparat), `ux-flow-designer` (ThomasPraun).

## Adding a New Skill

1. Copy `templates/SKILL-TEMPLATE.md` to `skills/<new-skill>/SKILL.md`.
2. Fill `name` (kebab-case), `description` (one line, include triggers), `metadata.triggers`.
3. Keep skill **single responsibility**; link related skills via `References`.
4. Add the row to both `SKILLS.md` (triggers + source) and the `README.md` table (category + use when); update the category counts if needed.
5. If the skill adapts an external work, add the attribution line and license to the body.

## Versioning

- Bump `metadata.version` on breaking checklist changes; patch on wording fixes.
- Tag releases `v1.0.0`, `v1.1.0` etc. Keep `CHANGELOG.md` if needed.

## Testing

- Run the skill on `examples/rollcall/` and verify `file:line` + fix are correct before PR.

## Publishing to Registry (if applicable)

- `opencode` skills are discovered via `skills/` folders or git submodules — no central registry yet. Share via GitHub URL.
- For `npx` distribution, add `package.json` with `bin` if you want CLI.
