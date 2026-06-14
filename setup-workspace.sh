#!/usr/bin/env bash
# Prepare tcp workspace for OpenHands agent-server (runs as uid 10001 inside sandbox).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TCP_REPO="${TCP_REPO:-/home/vib/code/tradechefpro/tcp}"
OH_UID=10001
OH_GID=10001

SUDO_PASSWORD=$(grep '^SUDO_PASSWORD=' "${TCP_REPO}/.env" 2>/dev/null | cut -d= -f2- || true)
if [[ -z "${SUDO_PASSWORD}" ]]; then
  echo "setup-workspace: SUDO_PASSWORD not found in ${TCP_REPO}/.env" >&2
  exit 1
fi

mkdir -p "${SCRIPT_DIR}/runtime/conversations" "${SCRIPT_DIR}/runtime/bash_events"
echo "${SUDO_PASSWORD}" | sudo -S chmod -R 777 "${SCRIPT_DIR}/runtime" 2>/dev/null || true

if ! command -v setfacl >/dev/null 2>&1; then
  echo "setup-workspace: setfacl not found; install acl package" >&2
  exit 1
fi

echo "setup-workspace: granting uid ${OH_UID} read/write on ${TCP_REPO}"
echo "${SUDO_PASSWORD}" | sudo -S setfacl -R -m "u:${OH_UID}:rwX" "${TCP_REPO}"
echo "${SUDO_PASSWORD}" | sudo -S setfacl -R -d -m "u:${OH_UID}:rwX" "${TCP_REPO}"
echo "setup-workspace: done"
