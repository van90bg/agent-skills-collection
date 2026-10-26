# Overflow in Plain CSS — 10 Root Causes + Fixes

> Horizontal page scroll on mobile is a **P0** defect. Fix the element that overflows; never hide the symptom with `overflow-x: hidden` on `body`.

## 1. Fixed `px` width

```css
/* wrong */
.box { width: 600px; }

/* right */
.box { width: 100%; max-width: 600px; }
```

## 2. Flex/grid child refuses to shrink (`min-width: auto` default)

```css
.child { min-width: 0; }
/* add text-overflow: ellipsis if the text should truncate */
```

## 3. Oversized media

```css
img, video, iframe, svg { max-width: 100%; height: auto; }
```

Background images use `background-size: cover`; do not stretch an `<img>` with a hard `px` width.

## 4. Unbreakable long strings (URL, employee code, token, hash)

```css
.text { overflow-wrap: anywhere; word-break: break-word; }
```

## 5. Wide table (pivot / attendance grid)

Do not squeeze the table. Wrap it so the table scrolls, not the page:

```html
<div class="table-scroll"><table>…</table></div>
```

```css
.table-scroll { overflow-x: auto; }
```

## 6. `100vw`

`100vw` includes the scrollbar width and overflows by a few pixels. Use `width: 100%`.

## 7. Negative margin / absolutely positioned edge leak

An element with `margin-left: -2rem` or a `left` value outside the parent: clip it on a sized parent (`overflow: hidden`), or constrain its position per breakpoint.

## 8. Padding/border on a full-width box

Confirm the global reset is intact:

```css
*, *::before, *::after { box-sizing: border-box; }
```

## 9. `pre` / code block

```css
pre { overflow-x: auto; white-space: pre; } /* block scrolls, page does not */
```

## 10. Grid track with a hard minimum

`repeat(auto-fit, minmax(16rem, 1fr))` overflows when the container is narrower than `16rem`:

```css
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 16rem), 1fr));
}
```

## Debug — Find the Culprit

```css
* { outline: 1px solid red; }
```

```js
var docW = document.documentElement.clientWidth;
document.querySelectorAll('*').forEach(function (el) {
  var r = el.getBoundingClientRect();
  if (r.right > docW + 1 || r.left < -1) {
    console.log(el, r.right - docW);
  }
});
```

Walk up from the widest element to the nearest ancestor that is already within bounds; the first child that exceeds its parent is the culprit.

## Last-Resort Safety Net (not a fix)

```css
html, body { overflow-x: clip; }
```

`clip` is safer than `hidden` because it does not create a scroll container (so it does not break `position: sticky`). Use it **only after** fixing the real cause, as a guard against future regressions.

## Review Checklist

- [ ] 320px, 360px, 375px, 414px, 768px, 1024px, 1280px, 1440px+ — no page-level horizontal scroll.
- [ ] Landscape phone (~640×360) — no `100vh` hero hiding content.
- [ ] Long names, codes without spaces, validation text, and dynamic lists all tested.
- [ ] Table scroll regions have a keyboard path (focusable wrapper).
- [ ] No `overflow-x: hidden` on `body` added as a patch.
- [ ] Re-tested the broken case + the two adjacent viewports.
