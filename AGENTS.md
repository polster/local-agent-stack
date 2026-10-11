# AGENTS

## Purpose of this repo
- This is a scaffold for running local coding agents on macOS: MLX inference on host + OpenShell sandbox + opencode client.
- The executable flow is driven by shell scripts and `Makefile`; trust those over README prose when they differ.

## Commands that matter
- `make doctor` runs preflight checks (macOS/arm64, Docker, OpenShell, MLX endpoint) via `bin/doctor`.
- `make mlx` starts `mlx-openai-server` using values from `config.env` via `host/mlx/start-mlx.sh`.
- `make image` builds a sandbox image with `opencode` preinstalled via `bin/build-image`.
- `make sandbox` runs `bin/agent`: ensures MLX is up, renders selected policy with concrete host/port values, and creates sandbox.
- `make policy` reapplies `openshell/policies/dev-workspace.yaml` to `${SANDBOX_NAME:-local-agent}`.
- `make connect` and `make logs` are the normal inspection path for an existing sandbox.

## Real entrypoints and config
- `.env.example` is the tracked source for env keys/defaults; copy values into local `config.env`/`.env` as needed.
- `OPENSHELL_BASE_IMAGE` is build-time (used by `make image`); `SANDBOX_IMAGE`/`IMAGE` is runtime (used by `make sandbox`).
- `bin/agent` is the orchestration entrypoint; if behavior seems wrong, inspect it before editing docs.
- `bin/render-policy` materializes policy templates to `build/` before sandbox creation.
- `image/opencode.json` wires opencode to `MLX_BASE_URL` and defaults model to `mlx/local-coder`.
- Optional per-dev overrides live in `.env` (from `.env.example`); `.env` is gitignored.

## Repo-specific gotchas
- OpenShell policy files under `openshell/policies/` are explicitly marked draft shape; do not assume field names are valid for the pinned OpenShell version.
- If changing policy structure, regenerate/validate against OpenShell's current schema/skill flow, then commit the authoritative YAML.
- `MLX_HOST=auto` resolves LAN IP (`en0`/`en1`) in scripts; this is intentional because `host.docker.internal` may fail from sandbox networking.
- `bin/agent` does not use an OpenShell inference router command; sandbox MLX access relies on policy-managed network egress to `${MLX_HOST}:${MLX_PORT}`.
- `frameworks/bmad/install.sh` is a placeholder: BMAD is not actually installed unless a real installer is wired in.

## Boundaries and expectations
- No app source tree or language build system exists here (no package manifests, test runner, linter, or CI workflow in repo); primary verification is running the make/script flow.
- Keep edits focused on scripts/config/docs in this scaffold; avoid adding generic development conventions that are not enforced by files in this repo.
