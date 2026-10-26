# Viewport × State Matrix

> A layout that has not passed this matrix is not responsive. Every cell must have: no page-level horizontal scroll, no clipped/overlapping content, readable text, tappable controls, and alignment with the neighboring section.

## Viewport Matrix

| Width | Represents | Why test it |
|---|---|---|
| 320px | Smallest phone / split screen | Hardest case; test first |
| 360px | Common Android | Broad coverage |
| 375px | Standard iPhone | Phone baseline |
| 414px | Large phone (Plus/Pro Max) | Wide reflow |
| 768px | Portrait tablet | 1-column → multi-column transition |
| 1024px | Landscape tablet / small laptop | Sidebar/nav decision |
| 1280px | Desktop | Full layout |
| 1440px+ | Large desktop | Must cap `max-width` |
| Landscape phone (~640×360) | Rotated kiosk/phone | No `100vh` hero hiding content; use `min-height` + scroll |

## State Matrix (test alongside every viewport)

| State | Typical source | What to check |
|---|---|---|
| Offline backlog + badge | Queue/retry feature | Badge fits a narrow frame; optimistic row does not overlap others; FIFO drain on reconnect |
| Camera/permission gate | Feature gated by URL + task + status | Button visibility matches the gate; `postMessage` to a scanner page does not break layout |
| Poll/delta refresh | 5s polling | No layout jank; unchanged data does not re-render; guard when a modal/backlog/page-hidden is active |
| Forbidden / out-of-station | Permission or station check | Read path blocks silently (inline sentence, no toast/retry); write path keeps a toast; store keeps the failure object so `code` survives |
| Audio unlock | Kiosk sound | First `pointerdown` unlocks on touch; fallback tone if decode fails |
| Long/late content | Real data | Long names, unbroken codes, validation text, long dynamic lists — see `../responsive-craft/references/overflow-plain-css.md` §4 |
| Empty | First use / cleared data | Empty state has a next step, not a blank box |
| Loading | Slow network | Skeleton matches the final layout; no spinner-only flash |
| Error | Transport/business failure | Inline at the source, keeps input, states what to do next |

## Severity

- **Blocker** — action/content unreachable (page-level horizontal scroll, button trapped under a sticky bar, forbidden error swallows the write path).
- **Major** — clear interaction/comprehension loss (text clipped, badge covers a button, toast in the wrong place).
- **Minor** — visible polish defect, no task failure.

## Fix Rules

- Fix the root constraint (`min-width: 0`, `max-width`, `aspect-ratio`, a scroll wrapper), not per-viewport offsets — unless the design genuinely changes at that width.
- Never fix overflow by shrinking text below a readable size.
- Sticky/fixed elements must not cover the focused element or the anchor target.
- Re-test the broken case + the two adjacent viewports + the adjacent state before reporting done.

## Related

- `../SKILL.md` — the audit that consumes this matrix.
- `../responsive-craft/SKILL.md` — prevention checklist and breakpoint rules.
- `../mobile-native/SKILL.md` — touch capability and real-device checks.
