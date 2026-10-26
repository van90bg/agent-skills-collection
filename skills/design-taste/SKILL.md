---
name: design-taste
description: Anti-AI-slop aesthetic doctrine for product UI — infer the brief before drawing, recognize slop tells in layout/copy/color/depth/motion, keep variance without breaking material coherence, and run a pre-flight before commit. Use before designing or redesigning a view, when a screen "looks generic", or when choosing typography, spacing, color, depth, or motion.
license: MIT
metadata:
  author: van90bg
  version: "1.0"
  category: web
  triggers: ["design taste", "ai slop", "looks generic", "aesthetic", "visual polish", "design critique"]
---

# Design Taste — The Doctrine Against AI Slop

> Priority when rules conflict: **user need > accessibility > consistency > aesthetics**. Taste only tunes the last layer; it never breaks the layers below.

Adapted from the **taste** collection in `plugin87/ux-ui-agent-skills` (`taste/design-taste.md`, `aesthetic-systems.md`, `motion-choreography.md`, MIT © 2026 Thientan Soparat). Rewritten for product UI and tied to project law; when they conflict, project law wins.

## 0. Guardrails

- **Tokens are law.** Every color, space, type size, radius, shadow, and duration comes from the design tokens. A new value means a new token + a consumer, never a raw literal.
- **Copy follows the product's operating language.** Imperative verbs, domain terms, errors that say what happened and what to do next. No interjections, emoji, or borrowed English in an otherwise localized UI.
- **Existing gates are the floor.** Contrast, focus trap, motion, reflow, token, breakpoint, touch, and platform audits must stay green. Beautiful but red is a fail.
- **Doctrine does not change behavior.** Keep the existing framework, component library, icon set, API, and flows. Taste is a visual/interaction decision, not a rewrite.
- **One dash rule.** If the product intentionally uses one em dash for an explanatory aside in operational copy, keep it consistent. Never scatter dashes, use them as decoration, or use them in marketing copy.

## 1. When to Read / Skip

- **Read:** new view or UI block; upgrade/redesign; review that says "generic" or "AI-generated"; choosing type/spacing/color/depth/motion; before committing UI.
- **Skip:** logic-only fixes, server work, a single copy change that does not alter layout.

## 2. Boundary With Other Skills

| Skill | Use for | Overlap |
|---|---|---|
| `webapp-ui-ux-audit` | Technical UI/a11y review with gates | Taste supplies judgment; audit supplies the checklist |
| `responsive-craft` | Layout thresholds and overflow prevention | Taste does not repeat responsive patterns |
| `ui-redesign` | Upgrade workflow: audit → wireframe → approval → code | Read taste when choosing the aesthetic direction |
| `design-system` | Tokens, Tailwind, component architecture | Taste is doctrine; design-system is infrastructure |

## 3. Brief Inference — Decide Before Drawing

Slop comes from "draw first, think later". Write a 1–2 line brief before opening a file:

| Field | Product default (change only with a reason) |
|---|---|
| Domain | Operations: scheduling, check-in, leave requests, reports — not marketing |
| Audience | Kiosk/operator (fast, hands busy) · manager (decisions) · viewer (read-only) |
| Mood to earn | Precise · calm · trustworthy — not "fun", not "dramatic" |
| Motion depth | Feedback only: sound + haptic + row flash on scan is already a signature; no decorative motion |
| Layout family | Dense dashboard: tables, lists, info cards — no full-bleed hero |
| Anchor archetype | **Tactical/Industrial** (clear structure, high density, hairlines) tempered with High-End restraint (off-white/off-black surfaces, rare elevation). No morphism, glass, or neon. |

## 4. Slop Tells → Taste Move

| Tell | Why it looks cheap | Move |
|---|---|---|
| Heading wraps 5–6 lines in a narrow column | Reads as a paragraph, loses force | Short display line, wider measure; cut words instead of widening the column |
| Everything is centered | No visual contrast | Real grid + deliberate asymmetry; centering is rare |
| Three identical cards with equal weight | Flat, no focal point | One lead item by **content density** (not by being larger); the rest stay quiet |
| Empty labels "SECTION 01", "FEATURES" | Filler text that says nothing | Specific microcopy or remove |
| Faint button text / low contrast | Looks broken and fails WCAG | Firm contrast; clear primary/secondary/ghost hierarchy |
| Shadow on every box | Muddy, dated depth | Hairline rule + surface layer; shadows only for true elevation |
| Pure `#000` on `#fff` | Harsh, amateur | Surface/text tokens (off-white/off-black) |
| Rainbow accents | No discipline | One primary + at most one accent; neutrals carry the mass |
| Uniform default spacing | No rhythm | Spacing scale with a larger jump at block level |
| Colored border on one side | Generated-UI cliché; decoration instead of hierarchy | Status = icon + text (not color alone) + full hairline or surface/elevation |
| Emoji in UI | Toy-like, platform-inconsistent | Inline SVG icon with `currentColor`; plain text |

## 5. Copy Tells — Words Are Half the Taste

- **Marketing filler:** "elevate", "seamless", "revolutionary", "optimize the experience" → state the concrete benefit.
- **Empty adjective triads:** "powerful, smart, and beautiful" → one verifiable statement.
- **Fake structural labels:** "SECTION 01", "PART 2", "Content goes here" → real microcopy or remove.
- **Verb drift between button and result:** button says "Reload" but toast says "Updated" → one action, one verb, used in button, toast, and dialog title; change all three together.
- **Numbering without sequence:** number only when the user truly goes 1→2→3; an unordered list with numbers is slop — use headings.
- **Excessive hedging:** "you might want to consider..." → imperative, short sentence.
- **Em dash** (see guardrail): at most one explanatory dash in an operational sentence; never in marketing copy.
- **Read it aloud:** if it sounds like a press release, rewrite shorter and more specific.

See `references/operational-copy.md` for message templates by situation.

## 6. Variance & Block Coherence

- **Variance:** two adjacent blocks must not share the same column structure/alignment; alternate archetypes (dense table ↔ cards ↔ list ↔ info band). A dashboard has no hero, but it can still vary.
- **Coherence:** a new block uses the **exact** tokens, scale, radius, and components that already exist. Vary the **layout**, keep the **material** (color, type, depth, motion). Density must flow into the neighboring block.
- **Stranger test:** place the new block next to the old ones — if a stranger can tell "two authors", it fails.

## 7. Typography

- Short, wide display; tight leading (1.05–1.15); a large scale contrast (`--text-3xl` vs `--text-base`), not half-steps.
- Body measure 60–75ch; use a prose max-width token (e.g. `--prose-max: 72ch`) for prose; data tables get the full frame with their own scroll.
- Numbers in tables/counters use tabular figures (`.num` / `td.num`) so columns do not jump.
- One UI family (`--font-sans`); `--font-mono` only for codes, canaries, and technical labels.

## 8. Spatial Rhythm

- **Outer > inner:** block padding > card padding > element gap. Never invert.
- Macro whitespace at block boundaries; group by proximity, not by drawing a border around everything.
- Vertical rhythm consistent within a view; the spacing scale is the only source.
- Edge tension is rare and only after the surrounding grid is disciplined.

## 9. Color & Surface

- Neutrals carry the mass; one `--primary` + at most one `--accent`; lower chroma for large surfaces, keep saturation for small highlights.
- Depth = hairline + surface layer + restrained shadow (not a shadow on every box).
- Dark mode is designed, not inverted: dark surfaces, lower accent saturation, elevation via a lighter surface. Contrast gates must run for both themes.
- Status is never color alone: icon + text + (optionally) background.

## 10. Depth & Detail

- One radius language (`--radius-*`) across the system; mixing radii arbitrarily is an accident.
- Micro-detail is where taste shows: focus ring, hover/press/disabled, empty state, skeleton/loading. Missing states = missing taste.
- Effects (glass/gradient/glow): each used once, with a reason, never stacked. If the product does not use them, adding one requires a token and an operational reason.

## 11. Motion

Principles: (1) only to guide the eye, connect cause/effect, or confirm an action; (2) fast — routine ≤ `--duration-normal`, only large transitions reach `--duration-slow`; (3) meaningful easing (`--ease-smooth`, rarely `--ease-spring`); (4) animate only `transform`/`opacity`; (5) restrained — one signature motion per view.

| Pattern | Do | Reduced motion |
|---|---|---|
| Enter screen/block | translate ≤ 8–16px + fade | fade only, ≤ `--duration-fast` |
| Stagger group | 40–80ms steps, total < ~400ms | show the group at once |
| Hover (mouse) | lift −2px + slight elevation | do not depend on hover |
| Press | scale ~0.97 then release | unchanged |
| Overlay (modal/drawer/toast) | scale 0.96→1 + fade; focus in/out correctly | fade only |
| Loading | skeleton matching layout > spinner | static skeleton / gentle pulse |

Anti-patterns: everything animates on load · > 500ms for routine UI · bounce/spring everywhere · animating `box-shadow`/`filter`/`width` · no reduced-motion fallback · scroll-jacking.

## 12. Screen Economy — Every Region Must Earn Its Space

- First screen earns itself: at 390×844, show the main heading + at least one primary action without scrolling.
- No large empty box: a big card must contain real text/control/data; padding is not content.
- Bento only when tiles are dense; no dead cells, precise alignment.
- Images: never wider than the container (no `100vw`), declare `width`/`height`, lazy-load below the fold.
- No infinite animation or autoplay background video.
- Respect the project's reflow (320/280) and touch floors (44/30/24px); never trade them for "beauty".

## 13. Pre-Flight Before Committing UI

1. Heading ≤ ~3 lines; display wide and short.
2. Two adjacent blocks do not share the same archetype.
3. Prose 60–75ch; numeric tables use tabular figures.
4. One primary + at most one accent; neutrals carry.
5. Surfaces/text via tokens (no pure `#000`/`#fff` outside documented exceptions).
6. Outer > inner; macro whitespace at block boundaries.
7. Depth via hairline/surface, not a shadow on every box.
8. Grid has no dead cells; alignment is exact.
9. Hover/focus/press/disabled/empty/loading all present.
10. No emoji, empty labels, faint button text, filler, or triads.
11. Reduced-motion fallback verified by the motion gate.
12. Every value is a token; no raw literals.
13. Cover the logo/name and show the screen to an outsider: if it could be any SaaS dashboard, the new block still has slop — fix before commit.

Required sequence: `build` → `test` → `verify` (or the repo's equivalent). Read the actual output; do not infer. Items 4–13 are human judgment — gates only prove the technical floor.

## Related Skills

- `references/operational-copy.md` — message templates and copy/a11y checklist.
- `../ui-redesign/SKILL.md` — the upgrade workflow.
- `../design-system/SKILL.md` — tokens and component architecture.
- `../webapp-ui-ux-audit/SKILL.md` — technical audit with gates.
