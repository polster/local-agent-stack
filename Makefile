SHELL := /bin/bash
include config.env
export

PRE_COMMIT ?= pre-commit

.PHONY: doctor
doctor:          ## preflight checks
	@./bin/doctor

.PHONY: mlx-start
mlx-start:             ## start local MLX inference server
	@./host/mlx/start-mlx.sh

.PHONY: mlx-stop
mlx-stop:
	@pkill -f mlx-openai-server || echo "not running"

.PHONY: sandbox
sandbox:         ## create sandbox running opencode
	@./bin/agent

.PHONY: image
image:           ## build a sandbox image with opencode preinstalled
	@./bin/build-image

.PHONY: policy
policy:          ## (re)apply the dev-workspace policy to a running sandbox
	@./bin/apply-policy

.PHONY: connect
connect:
	@openshell sandbox connect $${SANDBOX_NAME:-local-agent}

.PHONY: logs
logs:
	@openshell logs $${SANDBOX_NAME:-local-agent} --tail

.PHONY: clean
clean:
	@rm -rf build

.PHONY: hooks-install
hooks-install:   ## install pre-commit git hook and hook environments
	@command -v $(PRE_COMMIT) >/dev/null 2>&1 || { echo "pre-commit not found; install it first (for example: brew install pre-commit)"; exit 1; }
	@$(PRE_COMMIT) install --install-hooks --hook-type pre-commit

.PHONY: hooks-run
hooks-run:       ## run pre-commit hooks against all tracked files
	@command -v $(PRE_COMMIT) >/dev/null 2>&1 || { echo "pre-commit not found; install it first (for example: brew install pre-commit)"; exit 1; }
	@$(PRE_COMMIT) run --all-files --show-diff-on-failure

.PHONY: hooks-remove
hooks-remove:    ## uninstall pre-commit git hook
	@command -v $(PRE_COMMIT) >/dev/null 2>&1 || { echo "pre-commit not found; install it first (for example: brew install pre-commit)"; exit 1; }
	@$(PRE_COMMIT) uninstall --hook-type pre-commit
