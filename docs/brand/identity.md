# Brand identity & creative canon (fill in)

Read this before changing brand copy, naming, visual marks, theme palettes, or
user-facing features. Explicit user direction can revise any item here; update
this document and affected tests together when it does.

## Core identity

- **Project / product name:** *(fill in)*
- **Visual mark & screen-reader display rule:** *(fill in — e.g., decorative
  brackets hidden via `aria-hidden="true"`, natural accessible name preserved)*
- **Banned / retired legacy strings (if any):** *(fill in)*

## Semantic color & theme system (`src/styles/main.css`)

- **Theme modes (`data-theme`):** *(e.g., `light`, `dark`, and brand accent mode)*
- **Primary / secondary / accent / neutral scales (`50`–`950`):** *(fill in)*
- **Semantic surface tokens:** `--background`, `--foreground`, `--card`,
  `--surface-elevated`, `--muted`, `--border`, `--ring`

## Preserved signature features

List interactive controls, exporters, or views that must remain intact unless
explicitly revised by the user:

- *(e.g., interactive 3D viewport controls, material presets, `.glb` / PNG
  exporters, palette workbench)*

## Canon vs proposed boundaries

- Distinguish approved canon from draft/proposed creative material.
- Never copy verbatim text or identifiers from external mood-board artwork.
- Record unresolved creative questions in [docs/ai/concerns.md](../ai/concerns.md),
  never in production UI copy.
