---
name: responsive-craft
description: Prevent responsive failures before writing layout code — a 13-item failure checklist, an escalation ladder from fluid sizing to media queries, breakpoint thresholds kept in one source, and a fork table for decisions that need the user. Use when editing mobile layout, adding a breakpoint, designing sidebar/table/sticky behavior, or when the user says responsive, mobile, breakpoint, viewport, clamp, sticky, or safe-area.
license: MIT
metadata:
  author: van90bg
  version: "1.0"
  category: web
  triggers: ["responsive", "mobile layout", "breakpoint", "viewport", "clamp", "sticky", "safe-area"]
---

# Responsive Craft — Prevent the Breakage

> This is the **prevention** layer (checklist before code). Detection lives in `webapp-ui-ux-audit`. The default is mobile-first with plain CSS, and **the breakpoint numbers live in one source**.

## 0. Where Thresholds Live

- Define breakpoints once as design tokens, e.g. `--bp-narrow: 700px` · `--bp-card: 991px` · `--bp-tablet: 1024px` · `--bp-sheet: 1100px` · `--bp-wide: 1260px` · `--bp-ultra: 1440px`.
- Mirror the ones JavaScript needs in one map (`BP` / `bpPx(name)`) and expose named helpers (`isNarrow()`, `isCardMode()`); do not scatter new `matchMedia` calls.
- `@media` cannot read `var()`, so the numbers are necessarily repeated in CSS rules. **Changing a breakpoint means changing three places**: token, rule, JS map. No gate catches a mismatch unless you add one.
- Prefer a breakpoint audit gate: every number inside `@media` must match a token; a declared-but-unused token is an error; the JS map must be derived from tokens.

## 1. Escalation Ladder — simplest tool first

1. **Fluid only** (font, padding, gap) → `clamp(min, rem + vw, max)`. The middle value **must contain `rem`** so user zoom still works; never pure `vw`.
2. **Structure changes by page width** (column count, show/hide) → `@media (min-width: …)`, mobile-first. Avoid `max-width` queries except for genuinely desktop-only behavior.
3. **Component reused in two contexts** → explicit variant class. Do not add container queries unless the project already has that layer.

## 2. The 13-Point Failure Checklist (run before commit)

| # | Failure | Fix |
|---|---|---|
| 1 | `100vh` on an app shell | Keep a fallback, add `100svh`/`dvh` for true viewport height |
| 2 | Desktop-first `max-width` media queries | Rewrite as `min-width`, mobile-first |
| 3 | Flex/grid child with long text/URL has no `min-width: 0` | Add it; overflow breaks the track |
| 4 | Ancestor `overflow: hidden/scroll/auto` kills `position: sticky` | Use `overflow: clip` when only visual clipping is needed |
| 5 | `transform`/`filter`/`backdrop-filter` on an ancestor breaks `position: fixed` | Check the whole ancestor chain |
| 6 | Input `font-size` < 16px | `max(16px, 1rem)`; never `maximum-scale=1` |
| 7 | Fixed/sticky element at an edge ignores safe areas | `viewport-fit=cover` + `env(safe-area-inset-*)` |
| 8 | `z-index` arms race | Tokenized scale; `isolation: isolate` for a local stacking context |
| 9 | Sticky child in flex/grid without `align-self: start` | Add it |
| 10 | Virtual keyboard covers a bottom input | `--keyboard-height` driven by `visualViewport` |
| 11 | Separate desktop/mobile clones toggled by `display: none` | One adaptive component |
| 12 | Images without `width`/`height`, or below-fold without `loading="lazy"` | Declare dimensions; lazy-load below the fold |
| 13 | Container without `max-width`; button cluster without `flex-wrap` | Cap the content column; allow wrapping |

Horizontal overflow is a **P0** defect on mobile. See `references/overflow-plain-css.md` for the 10-root-cause catalog and the debug snippet.

## 3. Forks — If There Is No Single Right Answer, Ask

| Desktop pattern | Ask the user (options + trade-off) |
|---|---|
| Content-heavy sidebar | drawer (a) / tab bar (b) / inline accordion (c) |
| Wide table | horizontal scroll + sticky first column (a) / stacked cards (b) / priority columns + expand (c) |
| Numeric dashboard with many panels | one panel per tab (a) / stack + anchor nav (b) / collapsible summary (c) |
| Multiple stacked sticky bars | cascading collapse (a) / merge into header (b) / floating filter + sheet (c) |
| Multi-column form | single-column stack (a) / wizard for ≥10 fields (b) / accordion for edit forms (c) |

After the choice, draw an ASCII wireframe with **≥2 states** and a **mobile ≤700px** frame before coding.

## 4. Verify

```bash
npm run build             # syntax / missing file fails immediately
npm run smoke             # boot + core flows in a headless browser
npm test                  # manifest, build order, EOL/BOM, contract tests
npm run audit:breakpoints # if present: every @media number matches a token + flip check (needs Chrome)
```

Suspected overflow: open the built page, then **drag** the window from 280px to 2560px — do not only test the named breakpoints. Drag slowly across each threshold and watch for a one-frame jump.

## 5. Gate Coverage (be honest about what is missing)

| Dimension | Typical gate | What it proves |
|---|---|---|
| Breakpoints | `audit:breakpoints` | Every `@media` number matches a token; JS map derived from tokens; a real computed property flips at each threshold |
| Touch floor | `audit:touch` | Tap targets ≥ token floor across viewports/pages on the real DOM |
| Platform capability | `audit:platform` | `:hover` gated by capability media query; tap highlight; `touch-action`; overscroll; `theme-color` |
| Reflow | `verify:a11y` | No horizontal scroll at 320/280; keyboard path into table scroll regions |
| Visual regression | screenshot matrix | Every view × viewport × theme — only if the repo has it |

If a dimension has no gate, write "manual only" in the report. Do not imply coverage that does not exist.

## Related Skills

- `references/overflow-plain-css.md` — 10 causes + fix snippets.
- `../mobile-native/SKILL.md` — touch capability, safe areas, real-device checks (complements this layout layer).
- `../webapp-ui-ux-audit/SKILL.md` — detection after code.
- `../ui-redesign/SKILL.md` — redesign workflow and token rules.
