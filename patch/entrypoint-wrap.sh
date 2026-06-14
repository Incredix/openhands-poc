#!/bin/bash
set -euo pipefail

python3 /patch/patch-docker-timeout.py
exec /app/entrypoint.sh "$@"
