#!/usr/bin/env bash
# BMAD is installed per-project by its own installer, which writes agent and
# workflow definitions into the target repo. Pin the version and vendor the
# installer internally rather than curling it at image build time.
set -euo pipefail

BMAD_VERSION="${BMAD_VERSION:-TODO}"
TARGET="${1:-/workspace}"

echo "==> installing BMAD ${BMAD_VERSION} into ${TARGET}"
echo "!! placeholder: wire up your vendored installer here."
echo "   Two constraints for this stack:"
echo "   1. run it on the HOST against the repo, or inside a sandbox whose"
echo "      policy makes the repo writable (dev-workspace, not readonly-review)"
echo "   2. BMAD's installer wants network access; do it at image build or"
echo "      project setup time, NOT from inside a default-deny sandbox"
exit 0
