#!/usr/bin/env python3
"""Patch OpenHands Docker client to use a longer socket timeout on slow hosts."""
from __future__ import annotations

import os
from pathlib import Path

TARGET = Path("/app/openhands/app_server/sandbox/docker_sandbox_spec_service.py")
TIMEOUT = os.environ.get("DOCKER_CLIENT_TIMEOUT", "300")
OLD = "_global_docker_client = docker.from_env()"
NEW = (
    '_global_docker_client = docker.from_env('
    f'timeout=int(os.environ.get("DOCKER_CLIENT_TIMEOUT", "{TIMEOUT}")))'
)


def main() -> None:
    text = TARGET.read_text()
    if NEW in text:
        print(f"docker timeout patch already applied ({TIMEOUT}s)")
        return
    if OLD not in text:
        print("WARN: docker.from_env() line not found; patch skipped")
        return
    if "\nimport os\n" not in text[:800]:
        text = text.replace("import asyncio", "import asyncio\nimport os", 1)
    text = text.replace(OLD, NEW)
    TARGET.write_text(text)
    print(f"patched docker client timeout -> {TIMEOUT}s")


if __name__ == "__main__":
    main()
