#!/usr/bin/env bash
# Launch OpenHands GUI with the TradeChefPro repo mounted at /workspace.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TCP_REPO="${TCP_REPO:-/home/vib/code/tradechefpro/tcp}"
OPENHANDS_STATE_DIR="${OPENHANDS_STATE_DIR:-${HOME}/.openhands}"
RUNTIME_DIR="${SCRIPT_DIR}/runtime"
SANDBOX_USER_ID="$(id -u)"
export TCP_REPO OPENHANDS_STATE_DIR SANDBOX_USER_ID RUNTIME_DIR

if [[ -f "${SCRIPT_DIR}/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/.env"
  set +a
fi

if [[ ! -d "${TCP_REPO}" ]]; then
  echo "TCP repo not found: ${TCP_REPO}" >&2
  exit 1
fi

"${SCRIPT_DIR}/setup-workspace.sh"
mkdir -p "${OPENHANDS_STATE_DIR}"

echo "openhands-poc: mounting ${TCP_REPO} -> /workspace"
echo "openhands-poc: UI at http://localhost:3000"

if [[ -t 1 ]]; then
  cd "${TCP_REPO}"
  exec openhands serve --mount-cwd "$@"
fi

echo "openhands-poc: non-TTY run — starting detached via docker compose"
docker compose -f "${SCRIPT_DIR}/docker-compose.yml" up -d --pull always "$@"
