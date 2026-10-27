# Agent Skills Collection

Curated, publish-ready **Agent Skills** (`SKILL.md`) for AI coding agents — compatible with [opencode](https://opencode.ai), Claude Code, Cursor, and any tool supporting the [Agent Skills spec](https://opencode.ai/docs/skills).

Focus: **webapp audit, Google Apps Script webapps, docs↔code drift, responsive/touch craft, debugging & design** — distilled from real-world GAS + Sheets projects (`van90bg/attendance-portal` RollCall v2, 261 tests, 17 `.gs` + 9 HtmlService modules; `soc-portal-gas`).

## Skills (21)

| Skill | Category | Use When |
|---|---|---|
| [`gas-webapp-review`](skills/gas-webapp-review/SKILL.md) | `gas` | Review GAS HtmlService webapps (`doGet`, `Sheets`, `LockService`, `CacheService`) — 30+ failure modes, confidence scoring |
| [`webapp-ui-ux-audit`](skills/webapp-ui-ux-audit/SKILL.md) | `web` | Comprehensive UI/UX audit: every tier + fail-fast + WCAG 2.2 + perf + CDP verify + 3-layer cross-audit |
| [`audit-report-format`](skills/audit-report-format/SKILL.md) | `core` | Canonical report contract — TL;DR verdict, P0/P1/P2 table, rule check, empty state, anti-patterns |
| [`verify-subagent-claims`](skills/verify-subagent-claims/SKILL.md) | `core` | Re-derive every agent claim — VERIFIED / FALSE / UNVERIFIED, evidence column, public retraction |
| [`docs-code-drift-audit`](skills/docs-code-drift-audit/SKILL.md) | `core` | Docs contradict code while numeric gates are green — six-layer T0–T5 drift audit, docs-only fix |
| [`systematic-debugging`](skills/systematic-debugging/SKILL.md) | `core` | 4-phase debugging (Iron Law: no fix before Phase 1) — tight loop, Rule of Three, deployed-build check |
| [`accessibility-audit`](skills/accessibility-audit/SKILL.md) | `web` | WCAG 2.2 POUR audit — contrast, keyboard, focus, screen reader |
| [`performance-audit`](skills/performance-audit/SKILL.md) | `web` | Core Web Vitals, budgets, caching, runtime — Lighthouse |
| [`design-system`](skills/design-system/SKILL.md) | `web` | Tailwind v4 + tokens (primitive→semantic→component), surface-first, slop blacklist |
| [`design-taste`](skills/design-taste/SKILL.md) | `web` | Anti-AI-slop doctrine — brief inference, slop/copy tells, variance, typography, motion, pre-flight |
| [`ui-redesign`](skills/ui-redesign/SKILL.md) | `web` | Upgrade an existing view without changing the stack — diagnose, fix in order, tokens only, approve first |
| [`responsive-craft`](skills/responsive-craft/SKILL.md) | `web` | Prevent responsive failures — 13-point checklist, escalation ladder, breakpoint single source, overflow catalog |
| [`mobile-native`](skills/mobile-native/SKILL.md) | `web` | Touch-platform layer — hover gate, tap highlight, 16px floor, overscroll, safe areas, real-device checks |
| [`ux-flow-designer`](skills/ux-flow-designer/SKILL.md) | `web` | New view/flow — use cases, Mermaid, ASCII wireframes, handoff dossier, six-place view checklist |
| [`codebase-explorer`](skills/codebase-explorer/SKILL.md) | `core` | Fast read-only exploration with parallel `grep`/`glob` + thoroughness levels |
| [`code-research`](skills/code-research/SKILL.md) | `core` | Research libs via source + docs (local first, then clone), verbatim signatures |
| [`security-review`](skills/security-review/SKILL.md) | `core` | Trace source→sink, privilege boundaries, separate root causes |
| [`writing-plans`](skills/writing-plans/SKILL.md) | `core` | Write implementation plans before code — bite-sized tasks, no placeholders |
| [`project-bootstrap`](skills/project-bootstrap/SKILL.md) | `gas` | Bootstrap GAS + Sheets projects — deterministic edit, CRLF, token system |
| [`debate`](skills/debate/SKILL.md) | `core` | Three-model deliberation — consensus debate, red-team attack, two-phase audit |
| [`multi-agent-orchestration`](skills/multi-agent-orchestration/SKILL.md) | `core` | Delegate a large task — Lead Coordinator, five phases, plan-approval gate, evidence-first findings, capability-based harness adapters |

Categories: `gas` (2) · `web` (9) · `core` (10). See [`SKILLS.md`](SKILLS.md) for the full index with triggers and sources.

## Quick Start

### opencode

```bash
# Copy a skill to your project
cp -r skills/gas-webapp-review /path/to/your-project/.agents/skills/

# Or add as git submodule
git submodule add https://github.com/van90bg/agent-skills-collection .agents/skills-collection
```

### Claude Code / Cursor

Skills follow the standard `SKILL.md` frontmatter (`name`, `description`, `license`, `metadata`). Drop the `skills/<name>` folder into your project's skills directory.

## Format

Each skill is a single `SKILL.md` with frontmatter:

```yaml
---
name: gas-webapp-review
description: Review GAS webapps ...
license: MIT
metadata:
  author: van90bg
  version: "1.0"
  category: gas
  triggers: ["gas review", "apps script audit"]
---
```

Body: `When to Use` → `Procedure` → `Checklist` → `Output Format` → `References`. Output follows the canonical contract in [`skills/audit-report-format/SKILL.md`](skills/audit-report-format/SKILL.md): `TL;DR` + `| # | Sev | Issue | Location | Fix |` + markers 🔴🟠🟡. `templates/SKILL-TEMPLATE.md` is the scaffold for new skills.

## Examples

- `examples/rollcall/` — RollCall v2 real-world details: `AGENTS.md`, deterministic batch runner, architecture gotchas, mockup language (kept as English example, original VI archived).

## Contributing

PRs welcome. Keep skills: **single responsibility, evidence-backed, no speculative features, surgical edits**. Run `npm run lint:skills` (if present) before PR.

## License

MIT — see [LICENSE](LICENSE).
