---
trigger: model_decision
description: Performance, cleanup, reduced-motion, and architecture rules for Three.js and WebGL viewports and procedural 3D export utilities.
---

- Cap `renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))` so
  high-DPI displays do not exhaust software or mobile GPU fill-rate budgets.
- Honor `prefers-reduced-motion: reduce`: pause or disable continuous rotation,
  particle, and pulse animations when reduced motion is requested, while
  keeping manual interactive controls responsive.
- Never write React state inside the `requestAnimationFrame` loop. Bridge live
  React props/controls into the animation loop through a ref (such as
  `stateRef.current`) so renderer setup is not torn down on slider changes.
- Reuse pre-allocated scratch vectors, matrices, and temporary objects outside
  the frame loop (zero per-frame allocations).
- Dispose all WebGL resources cleanly on unmount (geometries, materials,
  textures, render targets, event listeners, `ResizeObserver`/`MutationObserver`,
  and the renderer itself).
- Guard WebGL renderer creation with a visible, accessible fallback notice
  (such as "3D preview unavailable") while keeping non-WebGL controls usable.
- Lazy-load Three.js routes/viewports via `React.lazy`/`Suspense` and split
  Three.js into a shared vendor chunk (`three-vendor`) to keep the entry bundle
  lean. Preserve existing interactive controls and exporters unless explicitly
  revised by the user.
