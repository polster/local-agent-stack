#!/usr/bin/env bash
# Superpowers-style skills: markdown skill files the agent discovers at runtime.
# Cheapest overlay to distribute — no installer, just files on a path.
set -euo pipefail

SKILLS_SRC="${SKILLS_SRC:-/opt/frameworks/superpowers/skills}"
SKILLS_DST="${SKILLS_DST:-$HOME/.config/opencode/skills}"

mkdir -p "$SKILLS_DST"
if [[ -d "$SKILLS_SRC" ]]; then
  cp -R "$SKILLS_SRC/." "$SKILLS_DST/"
  echo "==> installed skills into $SKILLS_DST"
else
  echo "!! no skills at $SKILLS_SRC — vendor them in, then rebuild"
fi
