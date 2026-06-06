# Reverse proxy (Traefik, Caddy, nginx)

NOMAD runs in Docker on your host. Two access modes are supported.

## LAN direct (default)

Open NOMAD and apps by **host IP** — no reverse proxy, no HSTS issues:

| Service | URL |
|---------|-----|
| NOMAD UI | `http://YOUR_SERVER_IP:8180` |
| Kiwix | `http://YOUR_SERVER_IP:8090` |
| CyberChef | `http://YOUR_SERVER_IP:8100` |
| FlatNotes | `http://YOUR_SERVER_IP:8200` |
| Kolibri | `http://YOUR_SERVER_IP:8300` |
| Dozzle | `http://YOUR_SERVER_IP:9999` |

Copy [`.env.lan.example`](../.env.lan.example) into `.env`. `entrypoint.sh` re-applies URLs on every admin start.

**Do not mix** `https://nomad.example.com` (HSTS) with port links — use IP URLs consistently.

## Traefik / HTTPS

Full guide: [traefik.md](traefik.md)

- App links use **HTTPS subdomains** on port 443 (`https://kiwix.example.com`), not `:8090` ports
- Dozzle Settings link uses `nomad.example.com:9999` (hardcoded in NOMAD UI) — Traefik needs TCP+TLS on `:9999`
- Copy [`.env.traefik.example`](../.env.traefik.example) into `.env` after Traefik routes exist

## Why `nomad.example.com:8090` fails in browsers

`https://nomad.example.com` sends HSTS. The browser upgrades `:8090` to HTTPS, but plain HTTP TCP proxy cannot answer TLS → `ERR_SSL_PROTOCOL_ERROR`. Use subdomains on 443 instead.

## What stays in this repo vs on the proxy host

| Config | Where |
|--------|-------|
| `NOMAD_URL`, `NOMAD_APP_*_URL` | `.env` here (gitignored) |
| Traefik routes | Your proxy host Git repo — commit or lose on restart |
| `configure-app-urls.mjs` | This repo — survives NOMAD image updates |
