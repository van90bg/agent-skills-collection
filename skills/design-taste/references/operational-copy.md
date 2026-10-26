# Operational Copy + A11y Review — Templates

> Copy is part of the interface. Every sentence must help the user decide, act, understand state, recover from an error, or consent with information. Everything else is deleted: narration ("This section helps you…"), technical commentary, subtitles that repeat the heading, marketing inside an operations tool.

Write in the **product's operating language**; the templates below are language-neutral patterns. Replace `{...}` with real values — never invent a number, name, or timestamp.

## Message Templates

| Situation | Pattern | Channel |
|---|---|---|
| Action succeeded | `{Action} {object} — {shift}, {time}.` | Toast + log row |
| Duplicate / idempotent | `This code was scanned at {time} — no new row was written.` | Toast; no new row |
| Transport failure | `Connection lost — the row is kept and will be resent when online.` | Toast + backlog badge |
| Business failure | `{Reason} — {next action}.` + keep the entered input | Inline at the field/row |
| Out-of-station, read path | Silent block sentence, no toast/retry | Inline replaces content |
| Out-of-station, write path | `{Blocked action} — contact {owner} to enable this station.` | Toast |
| Backlog drained | `Resent {n} queued scans.` | One-time toast |
| Destructive action (delete/approve) | State the consequence + an explicit confirm button | Modal confirm |

Rules:

- Keep user input after any recoverable error.
- Destructive actions always require explicit confirmation.
- Never fabricate numbers, names, or verification in copy.
- One action = one verb across button, toast, and dialog title.

## A11y Copy Checklist (manual review)

Automated gates cover mechanics; these are the parts a machine cannot judge. Do not claim compliance from a manual pass.

- Touch targets ≥44px, enough spacing, operable with one finger on a kiosk.
- Keyboard reaches the whole main flow in visual order; focus is visible on light and dark surfaces.
- State is never conveyed by color alone — add text/icon.
- Inputs have a real visible label; placeholders are not labels. Errors sit next to the source and state cause + fix.
- Zoom/reflow produces no horizontal scroll; sticky/fixed elements never cover the focused element.
- `prefers-reduced-motion` respected; animation is short, interruptible, never holds input, and never required to understand state.
- Dates/times/numbers follow the operating locale; table numbers use tabular figures.
- Icon-only buttons have an accessible name; decorative icons are hidden from assistive tech.
- Dynamic updates announce politely (`aria-live="polite"`) without moving focus.

## Related

- `../SKILL.md` — copy tells and the full taste doctrine.
- `../webapp-ui-ux-audit/SKILL.md` — the audit that consumes these checks.
