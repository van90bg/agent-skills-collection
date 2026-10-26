---
name: ui-redesign
description: Upgrade or redesign an existing view without changing the framework — scan, diagnose typography/color/layout/state, fix in priority order, force every value back to design tokens, and present an ASCII wireframe for approval before coding. Use when the user asks to redesign, modernize, or visually upgrade an existing UI. Not for finding bugs (webapp-ui-ux-audit) or preventing responsive breakage (responsive-craft).
license: MIT
metadata:
  author: van90bg
  version: "1.0"
  category: web
  triggers: ["redesign", "UI upgrade", "modernize UI", "visual refresh", "restyle view"]
---

# UI Redesign — Improve, Don't Rewrite

> Rule number one: **renovate, don't rebuild.** Keep the existing stack (plain HTML/CSS/JS, framework, component library) and improve it in place.

## 0. Guardrails

- **No new stack.** Do not add a framework, CSS-in-JS, icon pack, or animation library. If the project is vanilla, stay vanilla.
- **Tokens only.** Color, spacing, type, radius, and shadow come from the token file. A needed value that does not exist becomes a **new token**, not a literal.
- **Shared code has a home.** A helper used by ≥2 views lives in the shared module; a component used by ≥2 views lives in the shared component stylesheet. Do not clone it into one view.
- **Copy law.** Imperative verbs, domain terms, errors that state what happened + what to do next. No interjections, emoji, or borrowed English.
- **Not applicable here:** parallax, scroll-jacking, heavy glass, mesh gradients, stock background photos, decorative grain/noise, "AI" gradients. Icons are monochrome inline SVG using `currentColor`; no emoji.
- **Approval before code.** A redesign touching ≥3 files or changing visible layout needs a plan + wireframe and explicit user approval.
- **Deterministic edits.** For files with CRLF or non-ASCII content, edit with a script that asserts `count == 1` per anchor and preserves encoding; verify no BOM and no LF-only lines.

## 1. Sequence

1. **Scan** — read the target view and its styles; confirm the stack and list which tokens are already in use.
2. **Diagnose** — run the checklist in section 2; list every generic pattern, weak point, and missing state.
3. **Fix** — targeted upgrades only; keep class names and components already used by ≥2 views.

## 2. Diagnosis Checklist

**Typography** — browser default font · headings without weight contrast · line length too long (target ~65 characters) · only 400/700 · numbers without tabular figures · no letter-spacing adjustment · orphan last line (`text-wrap: balance` / `pretty`).

**Color & surface** — absolute `#000` background · over-saturated accent · more than one accent · two gray families mixed · purple-blue "AI" gradient · generic gray shadow not tinted by the surface · inconsistent light direction · a dark patch in a light page.

**Layout** — everything centered · container without `max-width` on ultrawide · `height: 100vh` → `min-height: 100dvh` · complex percentage flex → grid · equal-height cards forced by flex · one radius at every level · mechanical symmetric vertical rhythm · no breathing room.

**Interaction & state** — no hover · no press feedback · 0ms transition · no focus ring (a11y must) · generic round spinner instead of a layout-shaped skeleton · empty state without a next step · no inline error box (never `alert()`) · buttons linking to `#` · nav not marking the current page · animation on `top`/`left`/`width`/`height` → `transform`/`opacity`.

**Icons** — one set, one stroke weight, monochrome `currentColor`; favicon present.

**Code quality** — div soup → semantic elements · inline styles mixed with classes · hard `px` instead of relative units · missing or meaningless `alt` · arbitrary `z-index` · commented-out dead code.

## 3. Fix Priority

1. Clean palette/tokens (remove off-hue colors).
2. Hover/active/focus states.
3. Layout and spacing.
4. Replace generic components.
5. Add skeleton/empty/error states.
6. Polish the type scale.

## 4. When Adding Color Tokens

Only when a token is genuinely missing; keep existing tokens untouched.

- New palettes/scales use **OKLCH**, not HSL — HSL lightness is a mathematical average, not perceived lightness.
- Token graph: **reference** (raw color) → **semantic** (surface/accent/success/warning/danger) → **component** consumes semantic. Hover/dark variants derive from the base with `color-mix()` or relative color; do not hand-pick a second hex.
- Gamut mapping: reduce chroma while keeping L/H; do not clip RGB (it shifts hue).
- Contrast: body text ≥4.5:1, large text ≥3:1. Check both themes.

## 5. Verify

```bash
npm run build        # CSS/JS into dist — a bad token or missing file fails
npm run smoke        # boot + render + core flows in a headless browser
npm test             # EOL/BOM, manifest, build order, contract tests
npm run audit:tokens # if present: every value is a token; every token has a consumer
```

If the repo lacks a contrast gate, measure contrast manually and say so in the report. Do not imply automated coverage.

## 6. Report

Use `audit-report-format`, plus:

```markdown
| Component | Before | After | Token applied | Location |
|---|---|---|---|---|
| Table header | 12px muted, no weight | 12px / 600 / uppercase tracking | --text-xs, --font-semibold | components.css:.table th |
```

Include an ASCII wireframe with **≥2 states** (e.g. default + empty) and a **mobile ≤700px** frame, with labels taken from the real code.

## Related Skills

- `../design-taste/SKILL.md` — aesthetic doctrine and pre-flight.
- `../responsive-craft/SKILL.md` — prevent layout breakage while redesigning.
- `../webapp-ui-ux-audit/SKILL.md` — audit before/after.
- `../audit-report-format/SKILL.md` — report contract.
