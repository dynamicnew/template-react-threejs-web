---
applyTo: "src/catalog/**, public/catalog/**, api/**, src/utils/**"
description: Rules for schema-validated authored data catalogs, deterministic generated assets, and serverless API/client relay boundaries.
---

- For schema-validated authored catalogs (`src/catalog/`, `public/catalog/`):
  - Validate schema, acyclic relationships, units, and asset paths during
    builds (`npm run validate:catalog` before Vite build).
  - Track provenance and status honestly (distinguish established/approved data
    from proposed drafts); never invent approved facts to fill omitted fields.
  - **Zero is not unknown.** Represent unestablished numeric values explicitly
    as `null`/unknown with a reason rather than substituting `0` or a guess.
  - Keep generated asset paths case-collision-safe on Windows and regenerate
    manifests/outputs via the generator CLI rather than hand-editing outputs.
- For serverless API handlers (`api/`) and browser clients (`src/utils/`):
  - Validate HTTP method and payload shape at the trust boundary and enforce
    explicit outbound fetch timeouts.
  - Return truthful HTTP statuses: for example `4xx` on validation rejection,
    `503` when an optional outbound webhook/relay is unconfigured (never fake
    `200`), and `502` on upstream relay failure/rejection.
  - In browser clients, distinguish `4xx` validation rejections (surface the
    reason, do not silently queue) from offline/5xx/network unavailability
    (explicit bounded local fallback when designed).
  - Keep optional webhook URLs and secrets strictly server-side (document only
    empty variable names in `.env.example`; never embed secrets in client code
    or Docker build contexts).
