---
name: mobile-native
description: Touch-platform foundation for web UIs — gate hover behind device capability, kill tap highlight, stop iOS input zoom with a 16px floor, use touch-action/overscroll/safe-area/theme-color/dvh correctly, and verify on real hardware. Use when the UI is "correct in Chrome, wrong on a phone", when editing CSS that touches hover/viewport/scrolling, or before claiming a mobile fix is done.
license: MIT
metadata:
  author: van90bg
  version: "1.0"
  category: web
  triggers: ["mobile native", "touch device", "hover sticky", "tap highlight", "safe area", "theme-color", "ios zoom"]
---

# Mobile Native — The Touch-Platform Layer

> This layer is about **device capability** (`hover`, `pointer`), touch feedback, scrolling, safe areas, and browser chrome. It is not layout-by-breakpoint (that is `responsive-craft`) and not an overflow/copy/a11y review (that is `webapp-ui-ux-audit`).

Adapted from `emilkowalski/skills` (`skills/mobile-native`, MIT © Emil Kowalski). PWA install/manifest and React Native sections were removed — a web app inside an Apps Script iframe does not use them. If your product does ship a PWA, add those sections back deliberately.

## 0. Guardrails

- Project law wins: design tokens for every color/space/duration, operating-language copy rules, and the repo's gates.
- Examples below use token names generically (`--header-bg`, `--text-lg`); in a real repo, consume tokens instead of hard-coded values.

## 1. Layer Boundary

| Skill | Owns |
|---|---|
| `responsive-craft` | Layout thresholds, breakpoint tokens, overflow, 13 failure patterns |
| `webapp-ui-ux-audit` | Overflow/copy/a11y review after code |
| **this skill** | Capability queries, touch feedback, scroll behavior, safe areas, browser chrome |

## 2. Symptom → Fix

| Symptom | Cause | Fix |
|---|---|---|
| One tap, and the tapped cell keeps its hover background until another tap | `:hover` rule with no capability gate | Wrap it in `@media (hover: hover) and (pointer: fine)` |
| Grey flash/square when tapping a button on Android | Default WebView tap highlight | `-webkit-tap-highlight-color: transparent` on `html` |
| Tapping a field zooms the whole page and does not zoom back (iOS) | Input `font-size` < 16px | 16px floor under `@media (pointer: coarse)` |
| ~300ms delay after tapping a button | Browser waits for a possible double-tap zoom | `touch-action: manipulation` on interactive controls |
| Pulling a list at the top reloads the whole app | Document pull-to-refresh | `overscroll-behavior: none` on `html, body` when the shell owns scrolling |
| Text/buttons slide under the notch or home indicator | Missing safe-area handling | `viewport-fit=cover` + `env(safe-area-inset-*)` on edge-anchored blocks |
| Holding a finger on a button selects its label | Default text selection | `user-select: none` on controls — **not** on `body` |
| Status bar color clashes with the header | Missing or stale `theme-color` | `<meta name="theme-color">` + set it from a token at boot and on theme change |
| "Works in Chrome, broken on the phone" | Conclusion drawn from device emulation | Verify on real hardware (section 5) |

## 3. Patterns

1. **Hover is a capability, not a default.** Gate every `:hover` rule:
   ```css
   @media (hover: hover) and (pointer: fine) {
     .row:hover { background: var(--surface-hover); }
   }
   ```
   If a mixed rule must stay ungated (e.g. it also styles a selected state), keep it and register it in the platform-audit allowlist rather than duplicating the declaration.

2. **Tap highlight.** Set `-webkit-tap-highlight-color: transparent` on `html`; provide your own `:active`/pressed state so the control still responds.

3. **Touch action + label selection.**
   ```css
   button, a[href], [role="button"] {
     touch-action: manipulation;
     user-select: none;
   }
   ```
   Never put `user-select: none` on `body` — users must be able to copy codes and content.

4. **Overscroll.** If the app shell scrolls inside a pane (`#main-content`), disable document-level pull-to-refresh:
   ```css
   html, body { overscroll-behavior: none; }
   ```
   Do not use `touchmove` + `preventDefault()` to lock scrolling; it kills momentum.

5. **16px input floor by capability, not width.**
   ```css
   @media (pointer: coarse) {
     input, select, textarea { font-size: var(--text-lg); } /* ≥16px */
   }
   ```
   An iPad at 701–1024px is still touch; a width query would miss it.

6. **Safe areas.**
   ```html
   <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
   ```
   ```css
   .bottom-bar {
     padding-bottom: max(var(--space-3), env(safe-area-inset-bottom));
   }
   ```
   `env()` returns 0 without `viewport-fit=cover`.

7. **Theme color from a token.** Declare the meta tag once, then set its `content` from the computed header background at boot and whenever the theme changes. No raw hex in JS; read the token.

8. **Viewport units.** App shell: `100dvh` (or `min-height: 100%`) instead of `100vh`, because the address bar slides. Marketing/hero blocks: avoid `dvh` — it changes as the bar moves and makes content jump.

## 4. Never Ship

| Don't | Why |
|---|---|
| `user-scalable=no` / `maximum-scale=1` | Blocks zoom = a11y violation; iOS ignores it anyway |
| Ungated `:hover` rules | Hover sticks after a tap on touch devices |
| `100vh` for an app shell | Address bar movement causes layout jump; use `dvh` or `min-height: 100%` |
| `100dvh` for a marketing hero | `dvh` changes while scrolling → content jitter |
| `click`-only feedback | Touch needs feedback on `pointerdown`/`:active` |
| `touchmove` + `preventDefault()` to lock scroll | Kills inertial scrolling; use `overflow`/`overscroll-behavior` |
| `user-select: none` on `body` | Users cannot copy codes/content |
| `touch-action: none` on a scrollable area | Blocks panning entirely |
| `env(safe-area-inset-*)` without `viewport-fit=cover` | `env()` resolves to 0 |
| One `theme-color` for both themes | Status bar mismatches after a theme switch |
| "Done" from Chrome device emulation | Emulation does not reproduce tap highlight, input zoom, or pull-to-refresh |

## 5. Verification

**Static gate (no browser needed):** a platform audit should check five dimensions: `hover` (every `:hover` is inside a capability media query), `tap` (`-webkit-tap-highlight-color`), `touch` (`touch-action` on controls), `over` (root `overscroll-behavior`), `theme` (`meta theme-color` exists and is updated), plus a `stale` check for the allowlist.

**Why a static gate is required:** CDP device metrics do **not** enable touch emulation by default. `Emulation.setDeviceMetricsOverride` alone leaves `(hover: none)` and `(pointer: coarse)` false, so runtime checks can pass while real phones fail. If your harness needs it, call `Emulation.setTouchEmulationEnabled`.

**Real hardware only** (no gate replaces this):

- Hover sticking after a tap.
- Tap highlight when pressing a button.
- `dvh` behavior while the address bar slides.
- Whether focusing a field zooms the page.
- Whether pulling at the top reloads.
- Text under the notch / home indicator.
- Whether the virtual keyboard covers the focused field (drive a `--keyboard-height` variable from `visualViewport`).

## Related Skills

- `../responsive-craft/SKILL.md` — layout thresholds and overflow.
- `../webapp-ui-ux-audit/SKILL.md` — post-code UI/a11y audit.
- `../design-taste/SKILL.md` — motion and interaction polish on touch.
