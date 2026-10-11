SHELL := /bin/bash
include config.env
export

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
