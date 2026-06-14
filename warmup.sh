#!/usr/bin/env bash
# Pre-pull sandbox images so the first conversation doesn't hit Docker's 60s timeout.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/.env"
  set +a
fi

OPENHANDS_VERSION="${OPENHANDS_VERSION:-latest}"
AGENT_SERVER_TAG="${AGENT_SERVER_TAG:-1.27.1-python}"

echo "openhands-poc: pulling app image..."
docker pull "docker.openhands.dev/openhands/openhands:${OPENHANDS_VERSION}"

echo "openhands-poc: pulling agent-server image (this is the slow one)..."
docker pull "ghcr.io/openhands/agent-server:${AGENT_SERVER_TAG}"

echo "openhands-poc: removing stuck sandbox containers (status=created)..."
mapfile -t stuck < <(docker ps -aq --filter status=created 2>/dev/null || true)
if ((${#stuck[@]})); then
  docker rm -f "${stuck[@]}"
fi

echo "openhands-poc: warmup done"
