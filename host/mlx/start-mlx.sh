#!/usr/bin/env bash
# Local OpenAI-compatible inference on Apple Silicon.
#
# Why mlx-openai-server rather than plain `mlx_lm.server`: tool-call parsing.
# Bare mlx-lm's server has thin function-calling support, which is exactly what
# an agent loop depends on. If you prefer, LM Studio's MLX backend also works.
set -euo pipefail
cd "$(dirname "$0")/../.."
source config.env

BACKGROUND=0
[[ "${1:-}" == "--background" ]] && BACKGROUND=1

command -v mlx-openai-server >/dev/null 2>&1 || {
  echo "installing ${MLX_SERVER_PKG}"
  command -v uv >/dev/null 2>&1 || { echo "install uv first: brew install uv"; exit 1; }
  uv tool install --python "${MLX_TOOL_PYTHON:-3.12}" "${MLX_SERVER_PKG}"
}

ARGS=(launch
  --model-path "${MODEL_ID}"
  --port "${MLX_PORT}"
  --served-model-name "${MODEL_ALIAS}"
)
[[ -n "${TOOL_CALL_PARSER:-}" ]] && ARGS+=(--tool-call-parser "${TOOL_CALL_PARSER}")

# Bind to 0.0.0.0 only if the sandbox must reach the host over the LAN IP.
# Leave it on loopback otherwise — smaller blast radius.
[[ "${MLX_BIND_ALL:-0}" == "1" ]] && ARGS+=(--host 0.0.0.0)

echo "==> mlx-openai-server ${ARGS[*]}"
if (( BACKGROUND )); then
  mkdir -p build
  nohup mlx-openai-server "${ARGS[@]}" > build/mlx.log 2>&1 &
  echo "pid $! — logs: build/mlx.log"
else
  exec mlx-openai-server "${ARGS[@]}"
fi
