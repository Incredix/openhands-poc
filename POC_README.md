# OpenHands POC

Proof-of-concept for [OpenHands](https://github.com/OpenHands/OpenHands) on the TradeChefPro repo.

Repo: https://github.com/Incredix/openhands-poc

## Prerequisites

- Docker running
- `uv` installed (`~/.local/bin/uv`)
- OpenHands CLI: `uv tool install openhands --python 3.12`

## Start (tcp repo mounted)

One-time / after Docker restarts:

```bash
cd /home/vib/code/pocs/openhands-poc
./setup-workspace.sh   # grants agent uid 10001 write access to tcp repo
./warmup.sh
./start-tcp.sh
```

`start-tcp.sh` runs `setup-workspace.sh` automatically.

Open http://localhost:3000 and configure an LLM provider + API key in Settings.

To mount a different repo:

```bash
TCP_REPO=/path/to/repo ./start-tcp.sh
```

## Background (SSH / no TTY)

`start-tcp.sh` auto-detects non-interactive shells and uses `docker compose up -d`:

```bash
./start-tcp.sh
docker compose -f docker-compose.yml logs -f
```

## Stop

```bash
./stop.sh
```

## Troubleshooting

**`UnixHTTPConnectionPool ... Read timed out (read timeout=60)`**

Fixed in this POC by patching the Docker client timeout to **300s** (`patch/` +
`DOCKER_CLIENT_TIMEOUT`). Also run `./warmup.sh` before first use.

**`Sandbox entered error state` / `Permission denied: /workspace/conversations`**

The agent-server runs as **uid 10001** inside the sandbox. Run
`./setup-workspace.sh` (uses `setfacl` via sudo) so it can write the tcp repo
and runtime dirs.

**UI stuck on Loading…**

Usually a failed start task. Go home → **new conversation** (don't reopen ERROR
tasks). Skip GitHub repo picker — tcp is already at `/workspace`.

**First conversation is slow**

Expect **60–120s** while `oh-agent-server-*` starts. Watch:
`docker ps --filter name=oh-agent-server`

## Notes

- Workspace mount: repo root appears as `/workspace` inside the agent sandbox.
- Settings and conversation history live in `~/.openhands`.
- Compare with overnight Aider automation in `tcp/aider/`.
