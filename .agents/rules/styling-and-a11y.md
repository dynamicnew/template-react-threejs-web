---
trigger: model_decision
description: Tailwind CSS v4 single-stylesheet, semantic theme tokens, accessibility, and production copy rules for UI pages and styles.
---

- Retain the CSS-first Tailwind v4 entry (`@import "tailwindcss";` and `@theme`)
  in one canonical stylesheet (`src/styles/main.css`) holding tonal color
  scales, semantic theme modes (for example `light`, `dark`, and a brand
  accent mode via `data-theme` on `<html>`), keyframe animations, and
  typography rules. Do not introduce competing theme systems or accidentally
  migrate CSS frameworks.
- Have pages and interactive surfaces read semantic theme tokens rather than
  hardcoded colors, reserving fixed hex values for 3D materials, artwork, and
  intentional swatch displays. Sync `<meta name="theme-color">` with the active
  computed background surface.
- Preserve accessibility fundamentals:
  - Visible `:focus-visible` outlines and full keyboard navigation.
  - `aria-live="polite"` status/toast announcements.
  - `tabular-nums` for live HUD counters and telemetry readouts.
  - `@media (prefers-reduced-motion: reduce)` guards on CSS animations.
  - Decorative symbols/brackets marked `aria-hidden="true"` while exposing a
    natural accessible name to screen readers.
  - Never wrap headings inside `<button>` elements; use semantic containers
    (such as `<article>` with an `<h3>`) and an appropriately named button.
- Keep internal project status, open decisions, pending approvals, and
  unfinished-work commentary out of production UI copy; record them in
  `docs/ai/concerns.md` instead.
