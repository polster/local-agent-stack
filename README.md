# local-agent-stack

Re-usable, distributable setup for running **local coding agents** on macOS:
**MLX** (inference) + **OpenShell** (policy sandbox) + **opencode** (agent),
with optional **BMAD** / **Superpowers** overlays.

```text
                                 Request / tool loop
  ┌───────────────────────────────────────────────────────────────────────┐
  │ OpenShell sandbox (Docker/Podman)                                     │
  │                                                                       │
  │  ┌──────────────────────────────┐    reads/writes    ┌──────────────┐ │
  │  │ opencode (+ optional BMAD /  │<------------------>| /workspace   │ │
  │  │ skills overlays)             │                    │ (your repo)  │ │
  │  └───────────────┬──────────────┘                    └──────────────┘ │
  └──────────────────┼────────────────────────────────────────────────────┘
                     │ OpenAI-compatible HTTP (`/v1/*`)
                     ▼
  ┌───────────────────────────────────────────────────────────────────────┐
  │ macOS host                                                            │
  │                                                                       │
  │  mlx-openai-server (`${MLX_HOST}:${MLX_PORT:-8080}`)                  │
  │  launched by `make mlx` / `host/mlx/start-mlx.sh`                     │
  └───────────────────────────────────────────────────────────────────────┘
```

## Status of this scaffold

| Part | Confidence |
|---|---|
| MLX serving commands | verified against mlx-lm / mlx-openai-server usage |
| opencode OpenAI-compatible provider config | standard opencode schema |
| OpenShell *CLI commands* | match documented CLI surface |
| OpenShell *policy YAML field names* | **DRAFT — validate against the real schema** |
| Version pins | **TODO — fill in from your own `openshell --version`** |

OpenShell is alpha and its policy schema is still moving. Third-party write-ups
disagree on field names, so `openshell/policies/*.yaml` are a starting shape, not
gospel. Generate the authoritative version with OpenShell's own agent skill
(`generate-sandbox-policy`) or the schema reference, then commit the result here.

## Quickstart (host)

```bash
make doctor        # check macOS, Docker, RAM, MLX endpoint
make mlx           # start local inference on :8080
make image         # build a sandbox image with opencode
IMAGE=local-agent-stack:opencode make sandbox  # one-off override
make sandbox       # create an OpenShell sandbox running opencode
```

`make sandbox` image selection order:
1. `IMAGE=...` (one-off)
2. `SANDBOX_IMAGE` from env/`config.env` (default)
3. no `--from` (OpenShell default image)

## Layout

```
bin/agent              one-command launcher (start MLX if down, create sandbox)
bin/build-image        build local sandbox image with opencode installed
bin/render-policy      render policy templates with MLX_HOST/MLX_PORT values
bin/doctor             preflight checks
host/mlx/models.yaml   approved model manifest (repo id, quant, RAM floor, parser)
host/mlx/start-mlx.sh  inference launcher
openshell/policies/    reviewable policy artifacts, one per profile
image/Dockerfile       base + framework overlay (only needed for BMAD/skills)
image/opencode.json    points opencode at the local MLX endpoint
frameworks/            opt-in BMAD / Superpowers installers
docs/SECURITY-NOTES.md what to hand your security reviewer
.env.example           tracked template for all env keys/defaults
config.env             local pins/defaults loaded by scripts (gitignored)
```

## Known gotchas

- **OpenShell CLI/policy surface varies by version.** Authored policy fields
  like `filesystem:` may be rejected by your pinned OpenShell version.
  `bin/agent` renders and applies the selected policy at sandbox creation time,
  then falls back to default policy if create fails.
  For fail-closed behavior, run with `STRICT_POLICY=1 make sandbox`.
- **Python 3.14 can force source builds for Rust-backed deps.** If `make mlx`
  fails while building `outlines-core` with `can't find Rust compiler`, reinstall
  the tool with Python 3.12:
  `uv tool uninstall mlx-openai-server && uv tool install --python 3.12 mlx-openai-server`.
  This scaffold defaults `host/mlx/start-mlx.sh` to `MLX_TOOL_PYTHON=3.12` in
  `config.env` for that reason.
- **Host networking from the sandbox.** OpenShell runs sandboxes inside a
  K3s-in-Docker gateway, so `host.docker.internal` may not resolve. `bin/doctor`
  prints your LAN IP; `MLX_HOST` is parameterised everywhere for that reason.
  This scaffold uses an explicit egress allow to `${MLX_HOST}:${MLX_PORT}`.
- **MLX must listen on a non-loopback interface when sandbox uses LAN host IP.**
  If opencode reports `Cannot connect to API`, verify host reachability from
  macOS first: `curl http://$MLX_HOST:$MLX_PORT/v1/models`. If that fails while
  `curl http://127.0.0.1:$MLX_PORT/v1/models` works, restart MLX with
  `MLX_BIND_ALL=1 make mlx` (or set `MLX_BIND_ALL=1` in `.env`).
- **Policy templates need concrete host/port values.** OpenShell policy YAML
  does not interpolate `${...}` variables. `bin/agent` renders
  `openshell/policies/*.yaml` into `build/policy.<sandbox>.<profile>.yaml`
  before sandbox creation.
- **Base images may not include agent binaries.** This repo's default
  `OPENSHELL_BASE_IMAGE` is for building `make image`. Runtime sandbox creation
  uses `SANDBOX_IMAGE` (or one-off `IMAGE=...`). If neither is set,
  OpenShell's default runtime image is used and may not include `opencode`.
- **Reasoning-only models emit no tool calls** and fail silently in agent loops.
  Stick to the manifest.
- **BMAD/Superpowers are context-hungry.** 64 GB+ unified memory for a 30B-class
  coder at 4-bit with usable context; 16–24 GB means 4–9B models and short stories.
- **Bind-mount I/O is slow** on large repos under Docker Desktop on macOS.
- **Podman via shell alias may fail in scripts.** `bin/doctor` and other entry
  scripts run non-interactive shells, so a `docker=podman` alias from `zshrc`
  is not sourced. If you use Podman, expose a real `docker` executable on
  `PATH` (for example: `sudo ln -sf /opt/podman/bin/podman /usr/local/bin/docker`).
