# Publishing this repo to GitHub

This repo is a **Compose wrapper** around the upstream [Crosstalk-Solutions/project-nomad](https://github.com/Crosstalk-Solutions/project-nomad) image (`ghcr.io/crosstalk-solutions/project-nomad:latest`). Upstream ships the Command Center container and install script; **this repo** adds:

- `compose.yml` for Docker Compose v2 (any Linux host, tested on NixOS)
- Custom **updater sidecar** (`sidecar-updater/`) — no pre-built image on Docker Hub
- `configure-app-urls.mjs` — re-applies public app URLs after NOMAD updates
- Docs for Kiwix symlinks, storage permissions, reverse proxy, Traefik

Upstream does **not** publish a separate “compose-only” repo; this one fills that gap.

## Never commit

| Path | Why |
|------|-----|
| `.env` | Secrets (`APP_KEY`, DB passwords) |
| `storage/` | ZIM files, maps, logs, runtime data |
| `mysql/`, `redis/` | Database volumes |
| `nomad-disk-info.json` | Machine-specific |
| `pmtiles-work/`, `*.pmtiles` | Large map assets |
| `docs/agent-prompt-traefik-45.md` | Personal deploy notes (gitignored) |
| `docs/issue-url.txt` | One-off GitHub issue draft URL |
| `docs/bug-report-*.md` | Filed upstream — local copies only (gitignored) |

Already in `.gitignore`: `.env`, `storage/`, `mysql/`, `redis/`, etc.

## Safe to commit (generic placeholders)

| Path | Notes |
|------|-------|
| `compose.yml`, `entrypoint.sh` | No secrets |
| `scripts/configure-app-urls.mjs` | Reads from `.env` at runtime |
| `.env.example`, `.env.lan.example`, `.env.traefik.example` | Placeholders only |
| `traefik-*.snippet.yaml` | Replace `NOMAD_BACKEND` and `*.example.com` before use |
| `docs/*.md` (except gitignored) | Use `YOUR_SERVER_IP`, `example.com` |
| `sidecar-updater/` | Public build context |

## Per-machine setup (each user)

1. `cp .env.example .env` and fill secrets + paths
2. Choose LAN (`.env.lan.example`) or Traefik (`.env.traefik.example`) URLs
3. `mkdir -p storage/logs && docker compose up -d`
4. Optional: Kiwix symlink per [kiwix-symlinks.md](kiwix-symlinks.md) if not using `/opt/project-nomad`

## Upstream image

No need to build NOMAD yourself — `compose.yml` pulls:

```yaml
image: ghcr.io/crosstalk-solutions/project-nomad:latest
```

Only `updater` is built locally: `docker compose build updater`.

## Related upstream issues (local notes only)

- [#931](https://github.com/Crosstalk-Solutions/project-nomad/issues/931) — Ollama update UX (double-click during long pull). Maintainer: lock exists; UI should disable Update + show progress.
- Comprehensive tier 404 downloads — see local `docs/stuck-downloads.md` for workarounds; bug reports stay out of this repo.
