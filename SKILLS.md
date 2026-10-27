# Skills Index

| # | Name | Category | Triggers | Source |
|---|---|---|---|---|
| 1 | `gas-webapp-review` | `gas` | `gas review`, `apps script audit`, `sheets webapp`, `lockservice`, `cacheservice` | `gas-webapp-reviewer` + `review-gas-failure-modes` + `SubAgent/reviewer1` |
| 2 | `webapp-ui-ux-audit` | `web` | `ui audit`, `ux audit`, `wcag`, `performance audit`, `cdp` | `ui-ux-audit` + `reviewer2/3` + `designer` |
| 3 | `systematic-debugging` | `core` | `debug`, `bug fix`, `root cause`, `flaky` | `systematic-debugging` + `debug-systematic` + `scout` |
| 4 | `accessibility-audit` | `web` | `a11y`, `wcag`, `accessibility`, `screen reader` | `accessibility` |
| 5 | `performance-audit` | `web` | `performance`, `lighthouse`, `core web vitals` | `performance` |
| 6 | `design-system` | `web` | `design system`, `tailwind`, `tokens`, `component library` | `tailwind-design-system` + `ui-design-process` |
| 7 | `codebase-explorer` | `core` | `explore codebase`, `find files`, `trace dependencies` | `scout` + `improve-codebase-architecture` |
| 8 | `code-research` | `core` | `research library`, `api docs`, `read source` | `librarian` |
| 9 | `security-review` | `core` | `security review`, `xss`, `injection`, `privilege` | `security-reviewer` |
| 10 | `writing-plans` | `core` | `write plan`, `implementation plan`, `spec to plan` | `writing-plans` |
| 11 | `project-bootstrap` | `gas` | `gas project`, `apps script`, `rollcall`, `bootstrap` | `project-skill` (generalized) |
| 12 | `debate` | `core` | `debate`, `brainstorm`, `critique`, `converge`, `red-team`, `stress-test`, `review`, `audit` | `debate` (three-model deliberation skill) |
| 13 | `audit-report-format` | `core` | `audit report`, `review format`, `findings table`, `p0 p1 p2`, `report template` | `audit-report-format` (soc-portal-gas) + host `AGENTS.md` report law |
| 14 | `verify-subagent-claims` | `core` | `verify agent`, `subagent findings`, `check claims`, `agent output`, `false positive` | `verify-subagent-claims` (soc-portal-gas) |
| 15 | `docs-code-drift-audit` | `core` | `docs drift`, `docs out of date`, `documentation audit`, `docs vs code`, `stale docs` | `docs-code-drift-audit` (soc-portal-gas) |
| 16 | `responsive-craft` | `web` | `responsive`, `mobile layout`, `breakpoint`, `viewport`, `clamp`, `sticky`, `safe-area` | `responsive-craft` + `soc-ui/references/overflow-plain-css` |
| 17 | `mobile-native` | `web` | `mobile native`, `touch device`, `hover sticky`, `tap highlight`, `safe area`, `theme-color`, `ios zoom` | `mobile-native` (soc-portal-gas) ← `emilkowalski/skills` (MIT) |
| 18 | `design-taste` | `web` | `design taste`, `ai slop`, `looks generic`, `aesthetic`, `visual polish`, `design critique` | `soc-taste` (soc-portal-gas) ← `plugin87/ux-ui-agent-skills` (MIT) |
| 19 | `ui-redesign` | `web` | `redesign`, `UI upgrade`, `modernize UI`, `visual refresh`, `restyle view` | `redesign` (soc-portal-gas) |
| 20 | `ux-flow-designer` | `web` | `user flow`, `user journey`, `screen map`, `use case`, `navigation flow`, `new view` | `ux-flow-designer` (soc-portal-gas) ← `ThomasPraun/ux-flow-designer` |
| 21 | `multi-agent-orchestration` | `core` | `orchestrate`, `delegate`, `multi-agent`, `lead coordinator`, `subagent`, `audit`, `refactor`, `plan approval` | `multi-agent-orchestration` (soc-portal-gas) + host `AGENTS.md` orchestration law |

## Categories

- `gas` — Google Apps Script + Sheets specific (2 skills)
- `web` — Web UI/UX, a11y, perf, responsive/touch, design (9 skills)
- `core` — Debugging, exploration, research, security, planning, reporting, verification, orchestration (10 skills)

## Output Format (shared)

Canonical contract: [`skills/audit-report-format/SKILL.md`](skills/audit-report-format/SKILL.md). If the host repo defines its own report law in `AGENTS.md`, that law wins.

`TL;DR` 1 line (`✅ Approve — 0 P0 · 2 P1` or `🔴 Blocked — 3 P0`) + table `| # | Sev | Issue | Location | Fix |` (+ `Conf` for review skills, `Evidence` for verified agent output) + markers 🔴 P0 (blocker/security) · 🟠 P1 (break) · 🟡 P2 (cosmetic) + Rule check `A/B/C` + `Anti-pattern` (no vague narration, every claim needs `file:function()` or `file:line`).

Confidence thresholds (review skills): Blocker/security always reported; Major ≥70; Minor/Nit ≥80.
